terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.41.0"
    }
  }
}

data "azurerm_client_config" "current" {
}
