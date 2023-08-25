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

      location        = module.rg.groups.demo.location
      resource_group  = module.rg.groups.demo.name
      sku_name        = "B_Standard_B2s"
      server_version  = 15
  
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