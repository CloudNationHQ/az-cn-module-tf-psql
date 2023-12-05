module "naming" {
  source  = "cloudnationhq/rg/azure"
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

    secrets = {
      random_string = {
        psql-admin-password = {
          length      = 16
          special     = false
          min_special = 0
        }
      }
    }
  }
}

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

  postgresql = {
    name           = module.naming.postgresql.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    create_mode    = "Default"
    sku_name       = "GP_Standard_D2s_v3"
    server_version = 15

    admin_password = module.kv.kv_secrets.psql-admin-password.value
    key_vault_id   = module.kv.vault.id

    enabled = {
      ad_auth = true
      pw_auth = true
    }

    ad_admin = { ## This is the service principal that will be set as AD admin on the PostgreSQL server, if not defined the Service Principal of the Terraform run will be used
      object_id      = "XXXXXXXX-YYYY-ZZZZ-AAAA-1234567890"
      principal_name = "service-principal"
    }
  }
}
