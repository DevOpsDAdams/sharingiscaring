locals {
  vm_name = "${var.json.common_info.placement_code}${var.json.common_info.location_code}${var.json.common_info.env_code}${var.json.common_info.os_code}${var.json.common_info.app_name_short}"
}


module "hyb_servers" {
  source  = "../modules/linux-virtual-machine"
  count   = length(var.json.hyb_info)

  keyvault_name                                                     = azurerm_key_vault.cmk.name
  keyvault_rg                                                       = azurerm_resource_group.resource_group.name

  resource_group_name                                               = azurerm_resource_group.resource_group.name
  resource_group_location                                           = azurerm_resource_group.resource_group.location
  network_interface_enabled                                         = var.json.hyb_info[count.index].nic_enabled
  network_interface_names                                           = "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}-nic01"
  network_interface_ip_configuration_names                          = "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}-private-ip"
  network_interface_ip_configuration_subnet_ids                     = data.azurerm_subnet.vm.id
  network_interface_ip_configuration_private_ip_address_allocations = var.json.hyb_info[count.index].ip_allocations
  network_interface_ip_configuration_private_ip_addresses           = var.json.hyb_info[count.index].pip
  network_interface_ip_configuration_private_ip_address_versions    = var.json.hyb_info[count.index].ip_versions
  network_acceleration_enabled                                      = var.json.common_network_info.network_acceleration_enabled

  managed_disk_count                                                = length(var.json.hyb_info[count.index].disk_size)
  managed_disk_names                                                = ["${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}-data-01", "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}-data-02", "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}-swap-01"]
  managed_disk_storage_account_types                                = [var.json.hyb_info[count.index].sa_types]
  managed_disk_size_gbs                                             = var.json.hyb_info[count.index].disk_size
  managed_data_disk_cachings                                        = [var.json.hyb_info[count.index].disk_cache]
  managed_disk_os_types                                             = [var.json.hyb_info[count.index].type]
  managed_disk_zones                                                = var.json.hyb_info[count.index].zones
  managed_disk_lun                                                  = var.json.hyb_info[count.index].disk_luns

  vm_count                                                          = var.json.hyb_info[count.index].vm_count
  linux_vm_enabled                                                  = var.json.hyb_info[count.index].linux_vm
  vm_type                                                           = var.json.hyb_info[count.index].type
  vm_names                                                          = "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}"
  vm_size                                                           = var.json.hyb_info[count.index].size
  admin_username                                                    = var.json.hyb_info[count.index].username
  admin_secret                                                      = "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}-${var.json.hyb_info[count.index].username}"
  computer_name                                                     = "${local.vm_name}${var.json.hyb_info[count.index].unique_name}0${count.index+1}"
  source_image_id                                                   = data.azurerm_shared_image_version.image_version.id
  provision_vm_agent                                                = var.json.hyb_info[count.index].vm_agent
  dedicated_host_enabled                                            = var.json.hyb_info[count.index].dedicated_host
  additional_capabilities_ultra_ssd_enabled                         = var.json.hyb_info[count.index].ssd_enabled
  zone_enabled                                                      = var.json.hyb_info[count.index].zone_enabled
  zone                                                              = var.json.hyb_info[count.index].zones

  vm_extension_settings                                             = var.json.vm_extension_settings
  boot_diagnostics_enabled                                          = var.json.hyb_info[count.index].boot_diag
  boot_diagnostics_storage_account_uri                              = module.storage.0.primary_file_endpoint
  os_disk_caching                                                   = var.json.hyb_info[count.index].disk_cache
  os_disk_size_gb                                                   = var.json.hyb_info[count.index].os_disk_size
  os_disk_storage_account_type                                      = var.json.hyb_info[count.index].sa_types
  allow_extension_operations                                        = var.json.hyb_info[count.index].allow_extensions
  priority                                                          = var.json.hyb_info[count.index].priority
  identity_types                                                    = var.json.hyb_info[count.index].identity_types
  tags                                                              = local.resource_tags
  vm_tags                                                           = local.vm_tags
  disk_encryption_enabled                                           = var.json.hyb_info[count.index].disk_encrypt
  key_vault_id                                                      = azurerm_key_vault.cmk.id
  keyvault_encryption_key_id                                        = azurerm_key_vault_key.cmk.id
  key_permissions                                                   = var.json.common_info.key_permissions
  action_group_id                                                   = module.alerting.alert_ids
  health_check_alert                                                = var.json.hyb_info[count.index].health_check
  backup_policy_id                                                  = data.azurerm_backup_policy_vm.backup-policy.id
  recovery_vault_name                                               = var.json.recovery_vault.name
  recovery_vault_rg                                                 = var.json.recovery_vault.rg
  next_year                                                         = local.next_year
  depends_on = [
    data.azurerm_subnet.vm,
    module.storage,
    azurerm_key_vault.cmk
  ]
}

module "utl_servers" {
  source  = "../modules/linux-virtual-machine"
  count   = length(var.json.utl_info)

  keyvault_name                                                     = azurerm_key_vault.cmk.name
  keyvault_rg                                                       = azurerm_resource_group.resource_group.name

  resource_group_name                                               = azurerm_resource_group.resource_group.name
  resource_group_location                                           = azurerm_resource_group.resource_group.location
  network_interface_enabled                                         = var.json.utl_info[count.index].nic_enabled
  network_interface_names                                           = "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}-nic01"
  network_interface_ip_configuration_names                          = "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}-private-ip"
  network_interface_ip_configuration_subnet_ids                     = data.azurerm_subnet.vm.id
  network_interface_ip_configuration_private_ip_address_allocations = var.json.utl_info[count.index].ip_allocations
  network_interface_ip_configuration_private_ip_addresses           = var.json.utl_info[count.index].pip
  network_interface_ip_configuration_private_ip_address_versions    = var.json.utl_info[count.index].ip_versions
  network_acceleration_enabled                                      = var.json.common_network_info.network_acceleration_enabled

  managed_disk_count                                                = length(var.json.utl_info[count.index].disk_size)
  managed_disk_names                                                = ["${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}-data-01", "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}-data-02", "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}-swap-01"]
  managed_disk_storage_account_types                                = [var.json.utl_info[count.index].sa_types]
  managed_disk_size_gbs                                             = var.json.utl_info[count.index].disk_size
  managed_data_disk_cachings                                        = [var.json.utl_info[count.index].disk_cache]
  managed_disk_os_types                                             = [var.json.utl_info[count.index].type]
  managed_disk_zones                                                = var.json.utl_info[count.index].zones
  managed_disk_lun                                                  = var.json.utl_info[count.index].disk_luns

  vm_count                                                          = var.json.utl_info[count.index].vm_count
  linux_vm_enabled                                                  = var.json.utl_info[count.index].linux_vm
  vm_type                                                           = var.json.utl_info[count.index].type
  vm_names                                                          = "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}"
  vm_size                                                           = var.json.utl_info[count.index].size
  admin_username                                                    = var.json.utl_info[count.index].username
  admin_secret                                                      = "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}-${var.json.utl_info[count.index].username}"
  computer_name                                                     = "${local.vm_name}${var.json.utl_info[count.index].unique_name}0${count.index+1}"
  source_image_id                                                   = data.azurerm_shared_image_version.image_version.id
  provision_vm_agent                                                = var.json.utl_info[count.index].vm_agent
  dedicated_host_enabled                                            = var.json.utl_info[count.index].dedicated_host
  additional_capabilities_ultra_ssd_enabled                         = var.json.utl_info[count.index].ssd_enabled
  zone_enabled                                                      = var.json.utl_info[count.index].zone_enabled
  zone                                                              = var.json.utl_info[count.index].zones

  vm_extension_settings                                             = var.json.vm_extension_settings
  boot_diagnostics_enabled                                          = var.json.utl_info[count.index].boot_diag
  boot_diagnostics_storage_account_uri                              = module.storage.0.primary_file_endpoint
  os_disk_caching                                                   = var.json.utl_info[count.index].disk_cache
  os_disk_size_gb                                                   = var.json.utl_info[count.index].os_disk_size
  os_disk_storage_account_type                                      = var.json.utl_info[count.index].sa_types
  allow_extension_operations                                        = var.json.utl_info[count.index].allow_extensions
  priority                                                          = var.json.utl_info[count.index].priority
  identity_types                                                    = var.json.utl_info[count.index].identity_types
  tags                                                              = local.resource_tags
  vm_tags                                                           = local.vm_tags
  disk_encryption_enabled                                           = var.json.utl_info[count.index].disk_encrypt
  key_vault_id                                                      = azurerm_key_vault.cmk.id
  keyvault_encryption_key_id                                        = azurerm_key_vault_key.cmk.id
  key_permissions                                                   = var.json.common_info.key_permissions
  action_group_id                                                   = module.alerting.alert_ids
  health_check_alert                                                = var.json.utl_info[count.index].health_check
  backup_policy_id                                                  = data.azurerm_backup_policy_vm.backup-policy.id
  recovery_vault_name                                               = var.json.recovery_vault.name
  recovery_vault_rg                                                 = var.json.recovery_vault.rg
  next_year                                                         = local.next_year
  depends_on = [
    data.azurerm_subnet.vm,
    module.storage,
    azurerm_key_vault.cmk
  ]
}
