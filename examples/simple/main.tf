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
  source = "github.com/CloudNationHQ/az-cn-module-tf-psql"
  # version = "~> 0.1"

  postgresql = {
    name           = module.naming.postgresql_server.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    create_mode    = "Default"
    sku_name       = "GP_Standard_D2s_v3"
    server_version = 15
  }
}
