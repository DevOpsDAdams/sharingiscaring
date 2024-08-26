module "databricks" {
  source = "../../modules/databricks_workspace"

  for_each = each.value
  resource_group_name          = module.resource_group.main.name
  location                     = module.resource_group.main.location
  workspace_name               = each.value.workspace_name
  workspace_sku                = each.value.workspace_sku
  tags                         = var.json.tags
  db_kv_name                   = each.value.db_kv_name
  kv_sku_name                  = each.value.kv_sku_name
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  object_id                    = data.azurerm_client_config.current.object_id
  purge_protection_enabled     = each.value.purge_protection_enabled
  soft_delete_retention_days   = each.value.soft_delete_retention_days
  customer_managed_key_enabled = each.value.customer_managed_key_enabled
  cmk_key_name                 = each.value.cmk_key_name
  key_type                     = each.value.key_type
  key_size                     = each.value.key_size
  key_opts                     = each.value.key_opts
  terraform_key_permissions    = each.value.terraform_key_permissions
  databricks_key_permissions   = each.value.databricks_key_permissions

  depends_on = [module.resource_group]
}
