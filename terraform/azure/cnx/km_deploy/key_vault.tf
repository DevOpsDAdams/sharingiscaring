module "key_vault" {
  source                          = "../modules/key_vault/"
  for_each                        = var.json.key_vault_info
  name                            = "${each.value.name}-${upper(var.json.common_info.location)}-kv"
  location                        = var.json.common_info.location
  tags                            = var.json.tags
  resource_group_name             = module.resource_group[each.value.resource_group.security].name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  purge_protect                   = each.value.purge_protect
  sku_name                        = each.value.sku_name
  object_id                       = each.value.object_id
  key_permissions                 = each.value.key_permissions
  secret_permissions              = each.value.secret_permissions
  storage_permissions             = each.value.storage_permissions
  default_action                  = each.value.network_acls.default_action
  ip_rules                        = concat(each.value.network_acls.ip_rules)
  virtual_network_subnet_ids      = each.value.network_acls.virtual_network_subnet_ids
  bypass                          = each.value.network_acls.bypass
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  enable_rbac_authorization       = each.value.enable_rbac_authorization
  public_network_access_enabled   = each.value.public_network_access_enabled
  depends_on = [
    module.resource_group
  ]

}
