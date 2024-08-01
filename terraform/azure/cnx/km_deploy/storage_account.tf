module "storage" {
  source                                                            = "../modules/storage_accounts/"
  for_each                                                          = var.json.storage_account_info
  # Storage Account(s)
  storage_account_name                                              = "km-${each.value.name}-${var.json.common_info.env_short}"
  resource_group_name                                               = module.resource_group[each.value.resource_group.storage].name
  location                                                          = var.json.common_info.location
  account_tier                                                      = each.value.account_tier
  account_kind                                                      = each.value.account_kind
  replication_type                                                  = each.value.replication_type
  access_tier                                                       = each.value.access_tier
  cross_tenant_replication_enabled                                  = each.value.cross_tenant_replication_enabled
  min_tls_version                                                   = each.value.min_tls_version
  allow_nested_items_to_be_public                                   = each.value.allow_nested_items_to_be_public
  shared_access_key_enabled                                         = each.value.shared_access_key_enabled
  is_hns_enabled                                                    = each.value.is_hns_enabled
  default_to_oauth_authentication                                   = each.value.default_to_oauth_authentication
  public_network_access_enabled                                     = each.value.public_network_access_enabled
  nfsv3_enabled                                                     = each.value.nfsv3_enabled
  large_file_share_enabled                                          = each.value.large_file_share_enabled
  identity_type                                                     = each.value.identity.type
  subscription_id                                                   = data.azurerm_client_config.current.subscription_id

  # Storage Account Network Rules
  bypass                                                            = each.value.bypass
  default_action                                                    = each.value.default_action
  tags                                                              = var.json.tags
  ip_rules                                                          = var.json.common_network_info.allowed_ips
  subnet_ids                                                        = [data.azurerm_subnet.vm.id, data.azurerm_subnet.lb.id, data.azurerm_subnet.agw.id]

  # Customer Managed Key Information
  key_vault_id                                                     = module.key_vault.km.id
  key_name                                                         = module.key_vault_key.km_key.name
  key_permissions                                                  = var.json.key_vault_info.km.key_permissions
  secret_permissions                                               = var.json.key_vault_info.km.secret_permissions
  storage_permissions                                              = var.json.key_vault_info.km.storage_permissions
  tenant_id                                                        = data.azurerm_client_config.current.tenant_id



  depends_on = [
    module.key_vault_key,
    module.service_principal
  ]
}

data "external" "storage_account" {
  program = ["python3", "${path.root}/../scripts/get_storage_info.py", "./${var.json.common_info.env_short}/terraform.tfvars.json"]
  depends_on = [
    module.storage
  ]
}
