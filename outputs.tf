output "postgresql_server" {
  value = azurerm_postgresql_flexible_server.postgresql
}

output "admin_password" {
  value = random_password.psql_admin_password.result
}

output "databases" {
  value = azurerm_postgresql_flexible_server_database.database
}
