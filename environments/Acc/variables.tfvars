environment     = "acc"
workload        = "test"
subscription_id = "XXX"
tenant_id       = "XXX"

# server config
postgresql = {
  location        = "westeurope"
  resource_group  = "test-deployment"
  create_mode     = "Default"
  sku_name        = "GP_Standard_D2s_v3"
  server_version  = 14
  storage_mb      = 131072
  
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  
  identity = {
      user_assigned_identity = true 
      other_identity_ids          = ["/subscriptions/XXX/resourceGroups/test-deployment/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pgsql-test-acc-second-uai"]
  }

  auth = {
    ad_auth_enabled               = true
    pw_auth_enabled               = true
  }

  cmk = {
    # geo_backup_key_vault_key_id             = 
    geo_backup_user_assigned_identity_id    = "/subscriptions/XXX/resourceGroups/test-deployment/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pgsql-test-acc-second-uai"
  }

  databases =[
    {
        name = "database1"
        collation = "en_GB.UTF8"
        charset = "SQL_ASCII"
    },
    {
        name = "database2"
        collation = "fi_FI.UTF8"
    },
    {
        name = "database3"
        charset = "UTF8"
    },
    {
        name = "database4"
    }
  ]
   dns_zone_name = "test.com"

   firewall_rules =[
    {
        name = "rule1"
        start_ip_address = "149.177.166.251"
        end_ip_address  = "149.177.166.251"
    },
    {
        name = "rule2"
        start_ip_address = "144.177.166.251"
        end_ip_address  = "144.177.166.251"
    },
    {
        name = "AllowAzureServices"
        start_ip_address = "0.0.0.0"
        end_ip_address  = "0.0.0.0"
    },
  ]
}