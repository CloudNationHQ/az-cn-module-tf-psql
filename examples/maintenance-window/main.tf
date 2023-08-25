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

module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"
  
  postgresql  = {
    name            = module.naming.postgresql.name_unique
    location        = module.rg.groups.demo.location
    resource_group  = module.rg.groups.demo.name

    create_mode     = "Default"
    sku_name        = "GP_Standard_D2s_v3"
    server_version  = 15

    maintenance_window = {
        day_of_week             = "0" #sunday
        start_hour              = "20"
        start_minute            = "30"
    }
  }
}