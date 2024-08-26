resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "azurerm_databricks_workspace" "databricks" {
  name                         = var.workspace_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku                          = var.workspace_sku
  customer_managed_key_enabled = var.customer_managed_key_enabled


  tags = var.tags
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "cmk" {
  depends_on = [azurerm_key_vault_access_policy.databricks]

  workspace_id     = azurerm_databricks_workspace.databricks.id
  key_vault_key_id = azurerm_key_vault_key.db_cmk_key.id
}

resource "azurerm_key_vault" "databricks_kv" {
  name                = var.db_kv_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.kv_sku_name
  tags                = var.tags

  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
}

resource "azurerm_key_vault_key" "db_cmk_key" {
  depends_on = [azurerm_key_vault_access_policy.db_cmk_terraform]

  name         = var.cmk_key_name
  key_vault_id = azurerm_key_vault.databricks_kv.id
  key_type     = var.key_type
  key_size     = var.key_size

  key_opts = var.key_opts
}

resource "azurerm_key_vault_access_policy" "db_cmk_terraform" {
  key_vault_id = azurerm_key_vault.databricks_kv.id
  tenant_id    = azurerm_key_vault.databricks_kv.tenant_id
  object_id    = var.object_id

  key_permissions = var.terraform_key_permissions
}

resource "azurerm_key_vault_access_policy" "databricks" {
  depends_on = [azurerm_databricks_workspace.databricks]

  key_vault_id = azurerm_key_vault.databricks_kv.id
  tenant_id    = azurerm_databricks_workspace.databricks.storage_account_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.databricks.storage_account_identity[0].principal_id

  key_permissions = var.databricks_key_permissions
}
