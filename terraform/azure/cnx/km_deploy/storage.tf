module "storage" {
  source                                                            = "../modules/storage-accounts/"
  count                                                             = length(var.json.storage_account_info)
  # Storage Account(s)
  storage_account_name                                              = "st${var.json.storage_account_info[count.index].purpose}${lower(var.json.common_info.app_name_short)}${var.json.common_info.env_short}"
  resource_group_name                                               = azurerm_resource_group.resource_group.name
  location                                                          = azurerm_resource_group.resource_group.location
  sa_kind                                                           = var.json.storage_account_info[count.index].kind
  sa_tier                                                           = var.json.storage_account_info[count.index].tier
  replication_type                                                  = var.json.storage_account_info[count.index].replication
  tags                                                              = local.resource_tags
  ip_rules                                                          = var.json.common_network_info.allowed_ips
  subnet_ids                                                        = [data.azurerm_subnet.vm.id, data.azurerm_subnet.lb.id, data.azurerm_subnet.agw.id]
  diag_name                                                         = "st-${var.json.monitoring_info.prefix}-${var.json.common_info.application_name}-${var.json.common_info.env_short}-001"
  diag_sa                                                           = "st${var.json.storage_account_info[0].purpose}001"
  subscription_id                                                   = data.azurerm_client_config.current.subscription_id

  # CMK Information
  key_vault_id                                                     = azurerm_key_vault.cmk.id
  key_name                                                         = azurerm_key_vault_key.cmk.name
  key_permissions                                                  = var.json.key_vault_info.cmk.key_permissions
  secret_permissions                                               = var.json.key_vault_info.cmk.secret_permissions
  storage_permissions                                              = var.json.key_vault_info.cmk.storage_permissions
  tenant_id                                                        = data.azurerm_client_config.current.tenant_id
  depends_on = [
    azurerm_key_vault_key.cmk
  ]
}

data "external" "storage_account" {
  program = ["python3", "${path.root}/../scripts/get_storage_info.py", "./${var.json.common_info.env_short}/terraform.tfvars.json"]
  depends_on = [
    module.storage
  ]
}
