locals {
  postgresql_servers = {
    main = {
      name           = "${module.naming.postgresql_server.name}-main"
      location       = module.rg.groups.demo.location
      resource_group = module.rg.groups.demo.name

      server_version               = 15
      sku                          = "B_Standard_B2s"
      storage_mb                   = 65536
      backup_retention_days        = 35
      geo_redundant_backup_enabled = true
      zone                         = 1

      create_mode = "Default"

      admin_password = module.kv["main"].kv_secrets.psql-admin-password.value
      key_vault_id   = module.kv["main"].vault.id

      identity = {
        user_assigned_identity = true
        other_identity_ids     = [data.azurerm_user_assigned_identity.backup_user.id]
      }

      cmk = {
        key_vault_key_id                     = module.kv["main"].kv_keys.psql.id
        geo_backup_key_vault_key_id          = module.kv["backup"].kv_keys.psql.id
        geo_backup_user_assigned_identity_id = data.azurerm_user_assigned_identity.backup_user.id
      }

      databases = [
        {
          name    = "postgres"
          charset = "UTF8"
        },
        {
          name = "main_${var.environment}"
        }
      ]

      firewall_rules = [
        {
          name             = "rule1"
          start_ip_address = "111.222.333.444"
          end_ip_address   = "111.222.333.444"
        },
        {
          name             = "AllowAzureServices"
          start_ip_address = "0.0.0.0"
          end_ip_address   = "0.0.0.0"
        }
      ]

      enabled = {
        ad_auth = true
        pw_auth = true
      }

      network = {
        delegated_subnet_id = module.network.subnets.postgresql.id
        private_dns_zone_id = module.private_dns.zone.id
      }

      maintenance_window = {
        day_of_week  = "0" #sunday
        start_hour   = "20"
        start_minute = "30"
      }

      high_availability = {
        mode                      = ZoneRedundant
        standby_availability_zone = 2
      }
    }
    replica = {
      name           = "${module.naming.postgresql_server.name}-replica"
      location       = module.rg.groups.demo.location
      resource_group = module.rg.groups.demo.name

      server_version               = 15
      sku                          = "B_Standard_B2s"
      storage_mb                   = 65536
      backup_retention_days        = 35
      geo_redundant_backup_enabled = false
      zone                         = 1

      create_mode      = "Replica"
      replication_role = "None"
      source_server_id = module.postgresql["main"].postgresql_server.id
    }
    restore = {
      name           = "${module.naming.postgresql_server.name}-restore"
      location       = module.rg.groups.demo.location
      resource_group = module.rg.groups.demo.name

      server_version               = 15
      sku                          = "B_Standard_B2s"
      storage_mb                   = 65536
      backup_retention_days        = 35
      geo_redundant_backup_enabled = false
      zone                         = 1

      create_mode                       = "PointInTimeRestore"
      source_server_id                  = module.postgresql["main"].postgresql_server.id
      point_in_time_restore_time_in_utc = "2023-25-08 12:40:41"
    }
  }
}
