locals {
  key_vaults = {
    main = {
      name          = "${module.naming.key_vault.name_unique}-main"
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name

      keys = {
        psql = {
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
          psql-admin-password = {
            length      = 16
            special     = false
            min_special = 0
            min_upper   = 2
          }
        }
      }
    }
    backup = {
      name          = "${module.naming.key_vault.name_unique}-backup"
      location      = "westus"
      resourcegroup = module.rg.groups.demo.name

      keys = {
        psql = {
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
  }
}
