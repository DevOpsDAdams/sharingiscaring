resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}


resource "azurerm_storage_account" "storage_account" {
  name                                 = "${var.storage_account_name}${random_string.sa_suffix.result}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  account_kind                         = var.account_kind
  account_tier                         = var.account_tier
  account_replication_type             = var.replication_type
  min_tls_version                      = var.min_tls_version
  enable_https_traffic_only            = var.enable_https_traffic_only
  access_tier                          = var.access_tier
  cross_tenant_replication_enabled     = var.cross_tenant_replication_enabled
  allow_nested_items_to_be_public      = var.allow_nested_items_to_be_public
  shared_access_key_enabled            = var.shared_access_key_enabled
  is_hns_enabled                       = var.is_hns_enabled
  default_to_oauth_authentication      = var.default_to_oauth_authentication
  public_network_access_enabled        = var.public_network_access_enabled
  nfsv3_enabled                        = var.nfsv3_enabled
  large_file_share_enabled             = var.large_file_share_enabled

  blob_properties {
    delete_retention_policy {
      days = 14
    }
    container_delete_retention_policy {
      days = 14
    }
  }
  identity {
    type = var.identity_type
  }
  tags = var.tags

  lifecycle {
    ignore_changes = [customer_managed_key
    ]
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
}


resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id       = azurerm_storage_account.storage_account.id
  default_action             = var.default_action
  virtual_network_subnet_ids = var.subnet_ids
  ip_rules                   = concat(var.ip_rules, var.allowed_ips)
  bypass                     = var.bypass
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_storage_account.storage_account.identity.0.principal_id

  key_permissions    = var.key_permissions
  secret_permissions = var.secret_permissions
  storage_permissions = var.storage_permissions
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = var.key_vault_id
  key_name           = var.key_name
  depends_on = [
    azurerm_key_vault_access_policy.storage
  ]
}
