# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terrastate3tierproj"
    container_name       = "tfstate"
    key                  = "aks.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# AKS Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.resource_group_name}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Database Subnet (Delegated)
resource "azurerm_subnet" "db_subnet" {
  name                 = "${var.resource_group_name}-db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "Microsoft.DBforPostgreSQL/flexibleServers"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Create Private DNS Zone for PostgreSQL flexible server
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link the private DNS zone to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "${var.resource_group_name}-dnslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_postgresql_flexible_server" "db_server" {
  name                   = var.postgres_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.postgres_admin_username
  administrator_password = random_password.db_password.result
  sku_name               = "B_Standard_B1ms" # or GP_Standard_D2s_v3 if you prefer
  storage_mb             = 32768
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false
  delegated_subnet_id    = azurerm_subnet.db_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgresql.id

  public_network_access_enabled = false
}


# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    vm_size    = var.vm_size
    node_count = 2
  }

  network_profile {
    network_plugin    = "azure"
    dns_service_ip    = "10.0.3.10"
    service_cidr      = "10.0.3.0/24"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}

# Generate a random password for PostgreSQL admin
resource "random_password" "db_password" {
  length  = 16
  special = true
}
