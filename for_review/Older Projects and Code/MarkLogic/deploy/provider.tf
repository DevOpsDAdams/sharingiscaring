provider "azurerm" {
  subscription_id = var.json.common_info.active_subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy  = false
      purge_soft_deleted_secrets_on_destroy = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

provider "azurerm" {
  alias = "event_hub"
  subscription_id = var.json.event_hub_info.subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy  = false
    }
  }
}


provider "azurerm" {
  alias = "image_gallery"
  subscription_id = var.json.image_gallery_info.subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy  = false
    }
  }
}

provider "azurerm" {
  alias = "recovery_vault"
  subscription_id = var.json.recovery_vault.subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy  = false
    }
  }
}

provider "azurerm" {
  alias = "networking"
  subscription_id = var.json.common_network_info.vnet_subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy  = false
    }
  }
}

provider "azurerm" {
  alias = "deployment"
  subscription_id = var.json.common_info.deployment_subscription
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy  = false
    }
  }
}

terraform {
  required_providers {
    azurerm = {
      version = "=3.3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "<<resource_group_name>>"
    storage_account_name = "<<storage_account_name>>"
    subscription_id      = "<<subscription_id>>"
    container_name       = "tfstates"
  }
}
