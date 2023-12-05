output "postgresql_server" {
  description = "contains the postgresql server config"
  value       = azurerm_postgresql_flexible_server.postgresql
}

output "admin_password" {
  description = "contains the admin password generated for the postgresql server if not provided"
  value       = random_password.psql_admin_password.result
}

output "databases" {
  description = "contains the databases created on the postgresql server"
  value       = azurerm_postgresql_flexible_server_database.database
}
