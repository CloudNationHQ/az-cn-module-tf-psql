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

    secrets = {
      random_string = {
        "${module.naming.key_vault_secret.name}-admin-password" = {
          length      = 16
          special     = false
          min_special = 0
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
    server_version  = 15

    admin_password = module.kv.kv_secrets["${module.naming.key_vault_secret.name}-admin-password"].value
    key_vault_id   = module.kv.vault.id

    auth = {
        ad_auth_enabled = true
        pw_auth_enabled = true

        object_id       = "XXXXXXXX-YYYY-ZZZZ-AAAA-1234567890"
        principal_name  = 'service-principal'
      }
  }
}
