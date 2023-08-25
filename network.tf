resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql" {
  for_each = try({for rule in var.postgresql.firewall_rules: rule.name => rule}, {})

  name                = each.key
  server_id           = azurerm_postgresql_flexible_server.postgresql.id
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}
