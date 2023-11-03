terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.41"
    }
  }
}

data "azurerm_client_config" "current" {
}
