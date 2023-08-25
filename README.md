# Postgresql Flexible Server

This terraform module simplifies the process of creating and managing postgresql flexible server and database resources on azure with configurable options for a integrated virtual network, 
customer managed keys, user assigned identity, subnets, private dns zone and more to ensure a secure and efficient environment for resource communication in the cloud.

**Note**: This module will deploy the flexible server and not the single server which is on a deprecation [path](https://azure.microsoft.com/en-us/updates/azure-database-for-postgresql-single-server-will-be-retired-migrate-to-flexible-server-by-28-march-2025/). 

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

## Features

- Options for Azure AD administrator authentication, local administrator authentication or both.
- Support for customer managed keys with an user assigned identity. 
- Enable VNET integration by setting a delegation for a subnet and private dns link.
- Create your own subnet and private dns zone or provide existing as input. 
- Support for maintenance window, high availability and restore options. 
- Option for creating (empty) postgresql databases. 

The below examples shows the usage when consuming the module:

## Usage: Simple

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"
  
  postgresql  = {
    name            = module.naming.postgresql.name_unique
    location        = "westeurope"
    resource_group  = "rg-test"
    create_mode     = "Default"
    sku_name        = "GP_Standard_D2s_v3"
    server_version  = 15
  }

}
```

## Usage: Simple - for each

**Calling module with a for_each loop**
```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"
  
  for_each = {
     for pg in local.postgresql_servers : pg.name => pg
  }

  postgresql        = each.value

}
```
**Local variable with multiple objects to iterate over**
```hcl
locals {
  postgresql_servers = [
    {
    name            = module.naming.postgresql_server.name_unique
    location        = "westeurope"
    resource_group  = "rg-test"
    create_mode     = "Default"
    sku_name        = "GP_Standard_D2s_v3"
    server_version  = 15
   },
   {
    name            = "${module.naming.postgresql_server.name}-postfix"
    location        = "westeurope"
    resource_group  = "rg-demo"
    create_mode     = "Default"
    sku_name        = "B_Standard_B2s"
    server_version  = 14
   }
  ]
}
```

## Usage: Customer Managed Key with UAI

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  postgresql  = {

    location        = module.rg.groups.test.name
    resource_group  = module.rg.groups.test.name
    sku_name        = "GP_Standard_D2s_v3"
    server_version  = 15

    cmk = {
      key_vault_key_id                     = module.kv.kv_keys["pgsql"].id
      geo_backup_key_vault_key_id          = module.kv_backup.kv_keys["pgsql"].id 
      geo_backup_user_assigned_identity_id = data.azurerm_user_assigned_identity.backup_user.id
    }

    identity = {
      user_assigned_identity = true
    }
  }
}

data "azurerm_user_assigned_identity" "backup_user" {
  name                = "name-uai"
  resource_group_name = "rg-test"
}
```

## Usage: AD and/or local Authentication

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

    postgresql  = {

      location        = module.rg.groups.test.name
      resource_group  = module.rg.groups.test.name
      sku_name        = "B_Standard_B2s"
      server_version  = 15
  
      auth = {
        ad_auth_enabled = true
        pw_auth_enabled = true
      }
  }
}
```

## Usage: Subnet delegation with private DNS

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  postgresql  = {

      location        = module.rg.groups.test.name
      resource_group  = module.rg.groups.test.name
      sku_name        = "B_Standard_B2s"
      server_version  = 15
  
      network = {
        delegated_subnet_id   = module.network["module.naming.virtual_network.name"].subnets["postgresql"].id
        private_dns_zone_name = data.azurerm_private_dns_zone.postgresql.name
        private_dns_zone_id   = data.azurerm_private_dns_zone.postgresql.id
    }
  }
}

data "azurerm_private_dns_zone" "postgresql" {
  name     = "privatelink.postgres.database.azure.com"
  provider = azurerm.connectivity  ## Private link used in CAF module
}

```

## Usage: Subnet delegation creating your own DNS zone and subnet

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  postgresql  = {

      location        = module.rg.groups.test.name
      resource_group  = module.rg.groups.test.name
      sku_name        = "B_Standard_B2s"
      server_version  = 15
  
      network = {
        subnet_name               = "snet-psql"
        subnet_address            = "10.0.0.0/23"
        vnet_name                 = "vnet-spoke-main"  #existing vnet
        vnet_resource_group       = "rg-network"
        dns_zone_subdomain_prefix = "privatelink"
    }
  }
}
```

## Usage: High availability

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  postgresql  = {

      location        = module.rg.groups.test.name
      resource_group  = module.rg.groups.test.name
      sku_name        = "B_Standard_B2s"
      server_version  = 15
      zone            = 1
  
      high_availability = {
        mode                       = ZoneRedundant
        standby_availability_zone  = 2
    }
  }
}
```

## Usage: Maintenance window

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  postgresql  = {

      location        = module.rg.groups.test.name
      resource_group  = module.rg.groups.test.name
      sku_name        = "B_Standard_B2s"
      server_version  = 15
  
      maintenance_window = {
        day_of_week             = "1" #monday
        start_hour              = "20"
        start_minute            = "30"
    }
  }
}
```

## Usage: Databases
```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  postgresql  = {

      location        = module.rg.groups.test.name
      resource_group  = module.rg.groups.test.name
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
```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_active_directory_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator) | resource |
| [azurerm_postgresql_flexible_server_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `postgresql` | describes postgresql server related configuration | object | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `postgresql_server` | contains all postgresql flexible server config |
| `databases` | contains all postgresql databases |

## Testing


The github repository utilizes a Makefile to conduct tests to evaluate and validate different configurations of the module. These tests are designed to enhance its stability and reliability.

Before initiating the tests, please ensure that both go and terraform are properly installed on your system.

The [Makefile](Makefile) incorporates three distinct test variations. The first one, a local deployment test, is designed for local deployments and allows the overriding of workload and environment values. It includes additional checks and can be initiated using the command ```make test_local```.

The second variation is an extended test. This test performs additional validations and serves as the default test for the module within the github workflow.

The third variation allows for specific deployment tests. By providing a unique test name in the github workflow, it overrides the default extended test, executing the specific deployment test instead.

Each of these tests contributes to the robustness and resilience of the module. They ensure the module performs consistently and accurately under different scenarios and configurations.

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/az-cn-module-tf-pgsql/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/az-cn-module-tf-pgsql/blob/main/LICENSE) for full details.

## Reference

- [Documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/postgresql/)
