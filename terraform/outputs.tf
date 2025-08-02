# Export outputs
output "aks_kube_config" {
  description = "The KubeConfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "postgres_server_name" {
  description = "The name of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.db_server.name
}

output "postgres_admin_username" {
  description = "The administrator username for the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.db_server.administrator_login
}

output "postgres_admin_password" {
  description = "The administrator password for the PostgreSQL server"
  value       = random_password.db_password.result
  sensitive   = true
}
