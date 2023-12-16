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


module "postgresql_replica" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

  postgresql = {
    name           = "${module.naming.postgresql_server.name}-replica"
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku_name       = "GP_Standard_D2s_v3"

    create_mode      = "Replica"
    source_server_id = module.postgresql.postgresql_server.id
  }

  depends_on = [module.postgresql]
}

