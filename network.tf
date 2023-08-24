

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql" {
  for_each = try({for rule in var.postgresql.firewall_rules: rule.name => rule}, {})

  name                = each.key
  server_id           = azurerm_postgresql_flexible_server.postgresql.id
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

resource "azurerm_private_dns_zone" "postgresql" {
  for_each = try(var.postgresql.dns_zone_name, null) !=  null ? {"dns" = {}} : {}
  name                = "${var.postgresql.dns_zone_subdomain_prefix}.postgres.database.azure.com"
  resource_group_name = var.postgresql.resource_group
}

resource "azurerm_subnet" "postgresql" {
  for_each = try(var.postgresql.network.subnet_name, null) != null  ? {"subnet" = {}} : {}

  name                 = var.postgresql.network.subnet_name
  resource_group_name  = var.postgresql.network.subnet_resource_group
  virtual_network_name = var.postgresql.network.vnet_name
  address_prefixes     = [var.postgresql.network.subnet_address]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

data "azurerm_virtual_network" "vnet" {
  for_each = try(var.postgresql.network.vnet_name, null) != null  ? {"vnet" = {}} : {}

  name                = var.postgresql.network.vnet_name
  resource_group_name = var.postgresql.network.subnet_resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  for_each = try(var.postgresql.network.vnet_name, null) != null  ? {"dns_link" = {}} : {}

  name                  = "postgresql-link"
  resource_group_name   = var.postgresql.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.postgresql["dns"].name
  virtual_network_id    = data.azurerm_virtual_network.vnet["vnet"].id
}
