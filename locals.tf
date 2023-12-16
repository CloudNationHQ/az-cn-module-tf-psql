locals {
  databases = flatten([
    for db_key, db in try(var.postgresql.databases, {}) : {

      db_key    = db_key
      name      = "${var.naming.postgresql_database}-${db_key}"
      charset   = try(db.charset, null)
      collation = try(db.collation, null)
    }
  ])
}
