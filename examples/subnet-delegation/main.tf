provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias  = "connectivity"
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

module "network" {
  source = "github.com/cloudnationhq/az-cn-module-tf-vnet"

  naming = {
    subnet                 = module.naming.subnet.name
    network_security_group = module.naming.network_security_group.name
    route_table            = module.naming.route_table.name
  }

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      postgresql = { 
        cidr = ["10.18.1.0/27"] 
        delegations = {
          psql-delegation = {
            name    = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
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
    server_version  = 15

    network = {
    delegated_subnet_id   = module.network.subnets["postgresql"].id
    private_dns_zone_id   = data.azurerm_private_dns_zone.postgresql.id
    }
  }
}

data "azurerm_private_dns_zone" "postgresql" {
  name     = "privatelink.postgres.database.azure.com"
  provider = azurerm.connectivity  ## Private link as used in CAF module
}
