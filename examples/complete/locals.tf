locals {
  naming = {
    key_vault_key          = module.naming.key_vault_key.name
    key_vault_secret       = module.naming.key_vault_secret.name
    subnet                 = module.naming.subnet.name
    network_security_group = module.naming.network_security_group.name
    route_table            = module.naming.route_table.name
    user_assigned_identity = module.naming.user_assigned_identity.name
    postgresql_database    = module.naming.postgresql_database.name
  }
}
