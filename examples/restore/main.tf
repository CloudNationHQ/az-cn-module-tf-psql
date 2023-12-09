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

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

  postgresql = {
    name           = "${module.naming.postgresql_server.name}-main"
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku_name       = "GP_Standard_D2s_v3"

    create_mode = "Default"

  }
}

## Needed to wait for the server to be created before we can restore to it
resource "time_sleep" "wait" {
  depends_on = [module.postgresql]

  create_duration = "60s"
}


module "postgresql_restore" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

  postgresql = {
    name           = "${module.naming.postgresql_server.name}-restore"
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku_name       = "GP_Standard_D2s_v3"

    create_mode      = "PointInTimeRestore"
    source_server_id = module.postgresql.postgresql_server.id
    restore_time_utc = timeadd(timestamp(), "5m")
  }

  depends_on = [time_sleep.wait]
}

