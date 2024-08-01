resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "azurerm_key_vault" "key_vault" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protect
  sku_name                        = var.sku_name
  enable_rbac_authorization       = var.enable_rbac_authorization
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  public_network_access_enabled   = var.public_network_access_enabled

  access_policy {
    tenant_id           = var.tenant_id
    object_id           = var.object_id
    key_permissions     = var.key_permissions
    secret_permissions  = var.secret_permissions
    storage_permissions = var.storage_permissions
  }
  tags = var.tags

  network_acls {
    default_action             = var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
    bypass                     = var.bypass
  }
  lifecycle {
    ignore_changes = [access_policy]
  }
}
