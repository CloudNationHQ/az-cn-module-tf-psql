locals {
  naming = {
    key_vault_secret       = module.naming.key_vault_secret.name
    key_vault_key          = module.naming.key_vault_key.name
    user_assigned_identity = module.naming.user_assigned_identity.name
  }
}
