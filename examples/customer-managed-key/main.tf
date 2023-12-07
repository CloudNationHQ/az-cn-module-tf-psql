module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.2"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    keys = {
      psql = {
        key_type = "RSA"
        key_size = 2048

        key_opts = [
          "decrypt", "encrypt",
          "sign", "unwrapKey",
          "verify", "wrapKey"
        ]

        policy = {
          rotation = {
            expire_after         = "P90D"
            notify_before_expiry = "P30D"
            automatic = {
              time_after_creation = "P83D"
              time_before_expiry  = "P30D"
            }
          }
        }
      }
    }
  }
}

module "kv_backup" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.2"

  naming = local.naming

  vault = {
    name          = "${module.naming.key_vault.name_unique}-backup"
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    keys = {
      psql = {
        key_type = "RSA"
        key_size = 2048

        key_opts = [
          "decrypt", "encrypt",
          "sign", "unwrapKey",
          "verify", "wrapKey"
        ]

        policy = {
          rotation = {
            expire_after         = "P90D"
            notify_before_expiry = "P30D"
            automatic = {
              time_after_creation = "P83D"
              time_before_expiry  = "P30D"
            }
          }
        }
      }
    }
  }
}

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

  naming = local.naming

  postgresql = {
    name           = module.naming.postgresql_server.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    create_mode    = "Default"
    sku_name       = "GP_Standard_D2s_v3"
    server_version = 14


    cmk = {
      key_vault_key_id                     = module.kv.keys.psql.id
      geo_backup_key_vault_key_id          = module.kv_backup.keys.psql.id
      geo_backup_user_assigned_identity_id = azurerm_user_assigned_identity.backup_user.id
    }

    identity = {
      user_assigned_identity = true
      other_identity_ids     = [azurerm_user_assigned_identity.backup_user.id]
    }
  }
}


resource "azurerm_user_assigned_identity" "backup_user" {

  name                = module.naming.user_assigned_identity.name
  resource_group_name = module.rg.groups.demo.name
  location            = module.rg.groups.demo.location
}
