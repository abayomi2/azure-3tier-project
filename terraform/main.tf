# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "azurerm" {
    # Replace these values with your Azure Storage Account details for remote state
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terrastate3tierproj"
    container_name       = "tfstate"
    key                  = "aks.terraform.tfstate"
  }
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet for the AKS cluster
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.resource_group_name}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a subnet for the database, this is required for VNet rules
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

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    vm_size    = var.vm_size
    node_count = 2 # Set a reasonable default for a project
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.0.10"
    service_cidr = "10.0.2.0/24"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}

# Create a PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "db_server" {
  name                   = var.postgres_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.postgres_admin_username
  administrator_password = random_password.db_password.result
  sku_name               = "Standard_B1ms" # Smallest size for testing
  storage_mb             = 32768
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false
}

# Generate a random password for the database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Allow the AKS subnet to connect to the database server
resource "azurerm_postgresql_flexible_server_virtual_network_rule" "aks_vnet_rule" {
  name                = "aks-vnet-rule"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_flexible_server.db_server.name
  subnet_id           = azurerm_subnet.aks_subnet.id
}
