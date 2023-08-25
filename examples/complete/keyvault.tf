locals = {
  key_vaults = [
    {
      name          = "${module.naming.key_vault.name}-main"
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name

      keys = {
        pgsql = {
          key_type = "RSA"
          key_size = 2048

          key_opts = [
            "decrypt", "encrypt",
            "sign", "unwrapKey",
            "verify", "wrapKey"
          ]

          policy = {
            rotation = {
              expire_after         = "P90D"
              notify_before_expiry = "P30D"
              automatic = {
                time_after_creation = "P83D"
                time_before_expiry  = "P30D"
              }
            }
          }
        }
      }

      secrets = {
        random_string = {
          "${module.naming.key_vault_secret.name}-admin-password" = {
            length      = 16
            special     = false
            min_special = 0
          }
        }
      }
    },
    {
      name          = "${module.naming.key_vault.name}-backup"
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name

      keys = {
        pgsql = {
          key_type = "RSA"
          key_size = 2048

          key_opts = [
            "decrypt", "encrypt",
            "sign", "unwrapKey",
            "verify", "wrapKey"
          ]

          policy = {
            rotation = {
              expire_after         = "P90D"
              notify_before_expiry = "P30D"
              automatic = {
                time_after_creation = "P83D"
                time_before_expiry  = "P30D"
              }
            }
          }
        }
      }
    }
  ]
}