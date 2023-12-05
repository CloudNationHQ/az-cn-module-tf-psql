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

    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku_name       = "B_Standard_B2s"
    server_version = 15

    databases = [
      {
        name    = "database1"
        charset = "UTF8"
      },
      {
        name = "database2"
      }
    ]
  }
}
