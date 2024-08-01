provider "azurerm" {
  subscription_id = module.subscription.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_secrets_on_destroy = false
      purge_soft_deleted_keys_on_destroy    = false
    }
  }
}

terraform {
  required_providers {
    azurerm = {
      version = "latest"
    }
  }
  backend "azurerm" {
    resource_group_name  = "<<subscription_name>>"
    storage_account_name = "<<storage_account_name>>"
    subscription_id      = "<<subscription_id>>"
    container_name       = "<<container_name>>"
  }
}
