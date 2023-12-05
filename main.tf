resource "random_password" "psql_admin_password" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  override_special = "!#$%&-_?"
}

resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                = var.postgresql.name
  location            = var.postgresql.location
  resource_group_name = var.postgresql.resource_group

  version                      = try(var.postgresql.server_version, 15)
  sku_name                     = try(var.postgresql.sku_name, "B_Standard_B1ms")
  storage_mb                   = try(var.postgresql.storage_mb, 32768)
  backup_retention_days        = try(var.postgresql.backup_retention_days, null)
  geo_redundant_backup_enabled = try(var.postgresql.geo_redundant_backup_enabled, false)
  zone                         = try(var.postgresql.zone, null)

  create_mode            = try(var.postgresql.create_mode, "Default")
  administrator_login    = try(var.postgresql.create_mode, "Default") == "Default" || try(var.postgresql.enabled.pw_auth, null) == true ? "${replace(var.postgresql.name, "-", "_")}_admin" : null
  administrator_password = try(var.postgresql.create_mode, "Default") == "Default" || try(var.postgresql.enabled.pw_auth, null) == true ? try(var.postgresql.admin_password, random_password.psql_admin_password.result) : null

  delegated_subnet_id = try(var.postgresql.network.subnet_id, null)
  private_dns_zone_id = try(var.postgresql.network.private_dns_zone_id, null)

  source_server_id                  = try(var.postgresql.create_mode, null) == "PointInTimeRestore" || try(var.postgresql.create_mode, null) == "Replica" ? var.postgresql.source_server_id : null
  point_in_time_restore_time_in_utc = try(var.postgresql.create_mode, null) == "PointInTimeRestore" ? var.postgresql.restore_time_utc : null
  replication_role                  = try(var.postgresql.create_mode, null) == "Replica" ? "None" : null

  dynamic "identity" {
    for_each = try(var.postgresql.identity.user_assigned_identity, null) == true ? [1] : []

    content {
      type         = try(var.postgresql.identity.user_assigned_identity, null) == true ? "UserAssigned" : null
      identity_ids = concat([azurerm_user_assigned_identity.primary_identity["identity"].id], try(var.postgresql.identity.other_identity_ids, []))
    }
  }

  dynamic "customer_managed_key" {
    for_each = try(var.postgresql.cmk, null) != null ? var.postgresql.cmk : {}

    content {
      key_vault_key_id                     = try(var.postgresql.cmk.key_vault_key_id, null)
      primary_user_assigned_identity_id    = azurerm_user_assigned_identity.primary_identity["identity"].id
      geo_backup_key_vault_key_id          = try(var.postgresql.cmk.geo_backup_key_vault_key_id, null)
      geo_backup_user_assigned_identity_id = try(var.postgresql.cmk.geo_backup_user_assigned_identity_id, null)
    }
  }

  dynamic "authentication" {
    for_each = try(var.postgresql.enabled, null) != null ? [1] : []

    content {
      active_directory_auth_enabled = try(var.postgresql.enabled.ad_auth, true)
      password_auth_enabled         = try(var.postgresql.enabled.pw_auth, true)
      tenant_id                     = try(var.postgresql.enabled.ad_auth == true ? data.azurerm_client_config.current.tenant_id : null, null)
    }
  }

  dynamic "high_availability" {
    for_each = try(var.postgresql.high_availability, null) != null ? [1] : []

    content {
      mode                      = try(var.postgresql.high_availability.mode, "SameZone")
      standby_availability_zone = try(var.postgresql.high_availability.standby_availability_zone, null)
    }
  }

  dynamic "maintenance_window" {
    for_each = try(var.postgresql.maintenance_window, null) != null ? var.postgresql.maintenance_window : []

    content {
      day_of_week  = try(var.postgresql.maintenance_window.day_of_week, null)
      start_hour   = try(var.postgresql.maintenance_window.start_hour, null)
      start_minute = try(var.postgresql.maintenance_window.start_minute, null)
    }
  }

  tags = try(var.tags, null)

  lifecycle {
    ignore_changes = [zone, high_availability.0.standby_availability_zone]
  }

}

resource "azurerm_user_assigned_identity" "primary_identity" {
  for_each = try(var.postgresql.identity.user_assigned_identity, null) == true ? { "identity" = {} } : {}

  location            = var.postgresql.location
  name                = "uai-${var.postgresql.name}"
  resource_group_name = var.postgresql.resource_group
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "postgresql" {
  for_each = try(var.postgresql.enabled.ad_auth, null) == true ? { "ad_auth" = {} } : {}

  server_name         = azurerm_postgresql_flexible_server.postgresql.name
  resource_group_name = var.postgresql.resource_group
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = try(var.postgresql.ad_admin.object_id, data.azurerm_client_config.current.object_id)
  principal_type      = "ServicePrincipal"
  principal_name      = try(var.postgresql.ad_admin.principal_name, data.azuread_service_principal.current.display_name)
}

data "azuread_service_principal" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  for_each = try({ for database in var.postgresql.databases : database.name => database }, {})

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.postgresql.id
  charset   = try(each.value.charset, null)
  collation = try(each.value.collation, null)
}
