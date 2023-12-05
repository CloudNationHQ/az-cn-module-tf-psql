module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["prod", "demo"]
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

  for_each = {
    for key, kv in local.key_vaults : key => kv
  }

  naming = local.naming

  vault = each.value

}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 0.1"

  naming = local.naming

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
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

  naming = local.naming

  for_each = {
    for key, psql in local.postgresql_servers : key => psql
  }
  postgresql = each.value
}

module "private_dns" {
  source  = "cloudnationhq/sa/azure//modules/private-dns"
  version = "~> 0.1"

  providers = {
    azurerm = azurerm.connectivity
  }

  zone = {
    name          = "privatelink.postgres.database.azure.com"
    resourcegroup = "rg-dns-shared-001"
    vnet          = module.network.vnet.id
  }
}

resource "azurerm_user_assigned_identity" "backup_user" {

  name                = local.naming.user_assigned_identity.name
  resource_group_name = module.rg.groups.demo.name
  location            = module.rg.groups.demo.location
}
