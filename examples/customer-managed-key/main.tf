provider "azurerm" {
  features {}
}

module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["demo", "dev"]
}

module "rg" {
  source = "github.com/cloudnationhq/az-cn-module-tf-rg"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "kv" {
  source = "github.com/cloudnationhq/az-cn-module-tf-kv"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    keys = {
      pgsql = {
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
  source = "github.com/cloudnationhq/az-cn-module-tf-kv"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    keys = {
      pgsql = {
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
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"
  
  postgresql  = {
    name            = module.naming.postgresql.name_unique
    location        = module.rg.groups.demo.location
    resource_group  = module.rg.groups.demo.name

    create_mode     = "Default"
    sku_name        = "GP_Standard_D2s_v3"
    server_version  = 14
    

    cmk = {
      key_vault_key_id                     = module.kv.kv_keys["pgsql"].id
      geo_backup_key_vault_key_id          = module.kv_backup.kv_keys["pgsql"].id 
      geo_backup_user_assigned_identity_id = data.azurerm_user_assigned_identity.backup_user.id
    }

    identity = {
      user_assigned_identity = true
    }
  }
}

data "azurerm_user_assigned_identity" "backup_user" {
  name                = "name-uai"
  resource_group_name = "rg-test"
}