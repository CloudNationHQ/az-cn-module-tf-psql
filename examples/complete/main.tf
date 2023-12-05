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

  naming = {
    subnet                 = module.naming.subnet.name
    network_security_group = module.naming.network_security_group.name
    route_table            = module.naming.route_table.name
  }

  vnet = local.vnet
}

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 0.1"

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

data "azurerm_user_assigned_identity" "backup_user" {
  name                = "name-uai"
  resource_group_name = "rg-test"
}
