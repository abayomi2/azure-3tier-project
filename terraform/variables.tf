# Define variables
variable "resource_group_name" {
  description = "The name of the resource group to create all resources in"
  type        = string
  default     = "3-tier-project-rg"
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "3-tier-aks-cluster"
}

variable "vm_size" {
  description = "The size of the virtual machines in the AKS node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

# Add database variables
variable "postgres_server_name" {
  description = "The name of the Azure PostgreSQL server"
  type        = string
  default     = "3tier-db-server"
}

variable "postgres_admin_username" {
  description = "The administrator username for the PostgreSQL server"
  type        = string
  default     = "dbadmin"
}





# # Define variables
# variable "resource_group_name" {
#   description = "The name of the resource group to create all resources in"
#   type        = string
#   default     = "3-tier-project-rg"
# }

# variable "location" {
#   description = "The Azure region to deploy resources"
#   type        = string
#   default     = "East US"
# }

# variable "cluster_name" {
#   description = "The name of the AKS cluster"
#   type        = string
#   default     = "3-tier-aks-cluster"
# }

# variable "vm_size" {
#   description = "The size of the virtual machines in the AKS node pool"
#   type        = string
#   default     = "Standard_DS2_v2"
# }

# # Add database variables
# variable "postgres_server_name" {
#   description = "The name of the Azure PostgreSQL server"
#   type        = string
#   default     = "3tier-db-server"
# }

# variable "postgres_admin_username" {
#   description = "The administrator username for the PostgreSQL server"
#   type        = string
#   default     = "dbadmin"
# }
