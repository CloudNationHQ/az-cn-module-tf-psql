terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.16"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

data "azurerm_client_config" "current" {
}

# provider "postgresql" {
#   host             = azurerm_postgresql_server.main.fqdn
#   port             = 5432
#   username         = "${azurerm_postgresql_server.main.administrator_login}@${azurerm_postgresql_server.main.name}"
#   password         = data.azurerm_key_vault_secret.pg_admin.value
#   sslmode          = "require"
#   superuser        = false
#   connect_timeout  = 15
#   expected_version = var.server_version
#   max_connections  = 1
# }
