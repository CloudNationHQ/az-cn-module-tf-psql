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

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_secrets_on_destroy = false
    }
  }
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}
