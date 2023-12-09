locals {
  postgresql_servers = {
    main = {
      name           = "${module.naming.postgresql_server.name}-main"
      location       = module.rg.groups.demo.location
      resource_group = module.rg.groups.demo.name

      server_version               = 15
      sku_name                     = "GP_Standard_D2s_v3"
      storage_mb                   = 65536
      backup_retention_days        = 35
      geo_redundant_backup_enabled = true
      zone                         = 3
      create_mode                  = "Default"

      admin_password      = module.kv["main"].secrets.psql-admin-password.value
      key_vault_id        = module.kv["main"].vault.id
      key_vault_backup_id = module.kv["backup"].vault.id

      identity = {
        user_assigned_identity        = true
        user_assigned_backup_identity = true
      }

      cmk = {
        key_vault_key_id        = module.kv["main"].keys.psql.id
        key_vault_backup_key_id = module.kv["backup"].keys.psql.id
      }

      databases = {
        postgresdb1 = {
          charset = "UTF8"
        }
        postgresdb2 = {
        }
      }

      firewall_rules = {
        rule1 = {
          start_ip_address = "255.255.255.255"
          end_ip_address   = "255.255.255.255"
        }
        AllowAzureServices = {
          start_ip_address = "0.0.0.0"
          end_ip_address   = "0.0.0.0"
        }
      }

      enabled = {
        ad_auth = true
        pw_auth = true
      }

      ad_admin = { ## This is the service principal that will be set as AD admin on the PostgreSQL server, if not defined the Service Principal of the Terraform run will be used
        object_id      = "XXXXXXXX-YYYY-ZZZZ-AAAA-1234567890"
        principal_name = "service-principal"
        principal_type = "User"
      }

      network = {
        delegated_subnet_id = module.network.subnets.psql.id
        private_dns_zone_id = module.private_dns.zone.id
      }

      maintenance_window = {
        day_of_week  = "0" #sunday
        start_hour   = "20"
        start_minute = "30"
      }

      high_availability = {
        mode                      = "ZoneRedundant"
        standby_availability_zone = 1
      }
    }
  }
  postgresql_replicas = {
    replica = {
      name                  = "${module.naming.postgresql_server.name}-replica"
      location              = module.rg.groups.demo.location
      resource_group        = module.rg.groups.demo.name
      server_version        = 15
      sku_name              = "GP_Standard_D2s_v3"
      storage_mb            = 65536
      backup_retention_days = 35
      zone                  = 3

      create_mode      = "Replica"
      source_server_id = module.postgresql["main"].postgresql_server.id

      admin_password      = module.kv["main"].secrets.psql-admin-password.value
      key_vault_id        = module.kv["main"].vault.id
      key_vault_backup_id = module.kv["backup"].vault.id

      identity = {
        user_assigned_identity        = true
        user_assigned_backup_identity = true
      }

      cmk = {
        key_vault_key_id        = module.kv["main"].keys.psql.id
        key_vault_backup_key_id = module.kv["backup"].keys.psql.id
      }


      firewall_rules = {
        rule1 = {
          start_ip_address = "255.255.255.255"
          end_ip_address   = "255.255.255.255"
        }
        AllowAzureServices = {
          start_ip_address = "0.0.0.0"
          end_ip_address   = "0.0.0.0"
        }
      }

      network = {
        delegated_subnet_id = module.network.subnets.psql.id
        private_dns_zone_id = module.private_dns.zone.id
      }
    }
    restore = {
      name           = "${module.naming.postgresql_server.name}-restore"
      location       = module.rg.groups.demo.location
      resource_group = module.rg.groups.demo.name

      server_version        = 15
      sku_name              = "GP_Standard_D2s_v3"
      storage_mb            = 65536
      backup_retention_days = 35

      create_mode      = "PointInTimeRestore"
      source_server_id = module.postgresql["main"].postgresql_server.id
      restore_time_utc = timeadd(timestamp(), "30m")
    }
  }
}
