# Postgresql Flexible Server

This terraform module simplifies the process of creating and managing postgresql flexible server and databasek resources on azure with configurable options for a integrated virtual network, 
customer managed keys, user assigned identity, subnets, private dns zone and more to ensure a secure and efficient environment for resource communication in the cloud.

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

## Features


The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
module "postgresql" {
  source = "github.com/cloudnationhq/az-cn-module-tf-psql"

  environment       = var.environment
  workload          = var.workload
  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id

  postgresql        = var.postgresql
}
```
**example - variables.tfvars**
```hcl
postgresql = {
  location        = "westeurope"
  resource_group  = "rg-test"
  create_mode     = "Default"
  sku_name        = "GP_Standard_D2s_v3"
  server_version  = 15
}
```

## Resources

| Name | Type |
| :-- | :-- |


## Inputs



## Outputs



## Testing


## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/az-cn-module-tf-pgsql/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/az-cn-module-tf-pgsql/blob/main/LICENSE) for full details.

## Reference

- [Documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/postgresql/)
