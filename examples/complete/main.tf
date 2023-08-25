module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["${var.environment}", "${var.workload}"]
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

module "kv" {
  source = "github.com/cloudnationhq/az-cn-module-tf-kv"

  for_each = {
    for kv in local.key_vaults : kv.name => kv
  }

  naming = local.naming
  
  vault = each.value
 
}

module "network" {
  source = "github.com/cloudnationhq/az-cn-module-tf-vnet"

  naming = {
    subnet                 = module.naming.subnet.name
    network_security_group = module.naming.network_security_group.name
    route_table            = module.naming.route_table.name
  }

  vnet = local.vnet
}

module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"
  
  for_each = {
    for pg in local.postgresql_servers : pg.name => pg
  }
  postgresql = each.value
}

data "azurerm_user_assigned_identity" "backup_user" {
  name                = "name-uai"
  resource_group_name = "rg-test"
}

data "azurerm_private_dns_zone" "postgresql" {
  name     = "privatelink.postgres.database.azure.com"
  provider = azurerm.connectivity  ## Private link as used in CAF module
}