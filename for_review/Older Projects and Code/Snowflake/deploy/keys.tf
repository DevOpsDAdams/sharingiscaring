resource "azurerm_key_vault" "cmk" {
  name                        = "${var.json.key_vault_info.cmk.prefix}-${lower(var.json.common_info.app_name_short)}${var.json.common_info.env_short}-${random_string.suffix.result}-001"
  location                    = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.json.key_vault_info.cmk.purge_protect

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = var.json.key_vault_info.cmk.key_permissions

    secret_permissions = var.json.key_vault_info.cmk.secret_permissions

    storage_permissions = var.json.key_vault_info.cmk.storage_permissions
  }
  tags = local.resource_tags

  network_acls {
    default_action = "Deny"
    ip_rules = concat(var.json.allowed_ip_cidrs, local.azure_cidrs)
    virtual_network_subnet_ids = [data.azurerm_subnet.subnet.id]
    bypass = "AzureServices"
  }
  lifecycle {
    ignore_changes = [access_policy
    ]
  }
  depends_on = [
    azurerm_resource_group.resource_group
  ]

}

resource "azurerm_key_vault_key" "cmk" {
  name         = "${var.json.key_vault_info.cmk_key.prefix}-${var.json.common_info.env_short}-${random_string.suffix.result}"
  key_vault_id = azurerm_key_vault.cmk.id
  key_type     = var.json.key_vault_info.cmk_key.type
  key_size     = var.json.key_vault_info.cmk_key.size

  key_opts = var.json.key_vault_info.cmk_key.key_options
  depends_on = [
    azurerm_key_vault.cmk
  ]
}
