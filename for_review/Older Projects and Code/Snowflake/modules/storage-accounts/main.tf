resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric  = true
}


resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.storage_account_name}${random_string.sa_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = var.sa_kind
  account_tier             = var.sa_tier
  account_replication_type = var.replication_type

  # Below Enforced as static value per OA Policy
  min_tls_version          = "TLS1_2"
  enable_https_traffic_only = true

  blob_properties {
    delete_retention_policy {
      days = 14
    }
    container_delete_retention_policy {
      days = 14
    }
  }
  # Enforced as static value per OA Policy
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags

  lifecycle {
    ignore_changes = [customer_managed_key
    ]
  }
  timeouts {
    create = "30m"
    delete = "30m"
  }
}


resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id       = azurerm_storage_account.storage_account.id
  default_action             = "Deny"
  virtual_network_subnet_ids = var.subnet_ids
  ip_rules                   = concat(var.ip_rules, var.ip_rules2)
  bypass                     = ["Logging", "Metrics", "AzureServices"]
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
