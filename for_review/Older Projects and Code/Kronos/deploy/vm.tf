locals {
  vm_name = "${var.json.common_info.placement_code}${var.json.common_info.location_code}${var.json.common_info.env_code}${var.json.common_info.os_code}"
}


module "servers" {
  source  = "../modules/windows-virtual-machine"
  count   = length(var.json.vm_info)

  keyvault_name                                                     = azurerm_key_vault.cmk.name
  keyvault_rg                                                       = azurerm_resource_group.resource_group.name

  resource_group_name                                               = azurerm_resource_group.resource_group.name
  resource_group_location                                           = azurerm_resource_group.resource_group.location
  network_interface_enabled                                         = var.json.vm_info[count.index].nic_enabled
  network_interface_names                                           = "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}-nic01"
  network_interface_ip_configuration_names                          = "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}-private-ip"
  network_interface_ip_configuration_subnet_ids                     = data.azurerm_subnet.vm.id
  network_interface_ip_configuration_private_ip_address_allocations = var.json.vm_info[count.index].ip_allocations
  network_interface_ip_configuration_private_ip_addresses           = var.json.vm_info[count.index].pip
  network_interface_ip_configuration_private_ip_address_versions    = var.json.vm_info[count.index].ip_versions
  network_acceleration_enabled                                      = var.json.common_network_info.network_acceleration_enabled

  managed_disk_count                                                = length(var.json.vm_info[count.index].disk_size)
  managed_disk_names                                                = ["${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}-data-01", "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}-data-02", "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}-swap-01"]
  managed_disk_storage_account_types                                = [var.json.vm_info[count.index].sa_types]
  managed_disk_size_gbs                                             = var.json.vm_info[count.index].disk_size
  managed_data_disk_cachings                                        = [var.json.vm_info[count.index].disk_cache]
  managed_disk_os_types                                             = [var.json.vm_info[count.index].type]
  managed_disk_zones                                                = var.json.vm_info[count.index].zones
  managed_disk_lun                                                  = var.json.vm_info[count.index].disk_luns

  vm_count                                                          = var.json.vm_info[count.index].vm_count
  automatic_updates                                                 = var.json.vm_info[count.index].automatic_updates
  vm_type                                                           = var.json.vm_info[count.index].type
  vm_names                                                          = "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}"
  vm_size                                                           = var.json.vm_info[count.index].size
  admin_username                                                    = var.json.vm_info[count.index].username
  admin_secret                                                      = "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}-${var.json.vm_info[count.index].username}"
  computer_name                                                     = "${local.vm_name}${var.json.vm_info[count.index].unique_name}0${count.index+1}"
  provision_vm_agent                                                = var.json.vm_info[count.index].vm_agent
  dedicated_host_enabled                                            = var.json.vm_info[count.index].dedicated_host
  additional_capabilities_ultra_ssd_enabled                         = var.json.vm_info[count.index].ssd_enabled
  zone_enabled                                                      = var.json.vm_info[count.index].zone_enabled
  zone                                                              = var.json.vm_info[count.index].zones

  source_image_id                                                   = data.azurerm_shared_image_version.image_version.id
  plan_publisher                                                    = var.json.image_plan_info.publisher
  plan_product                                                      = var.json.image_plan_info.product
  plan_name                                                         = var.json.image_plan_info.name


  boot_diagnostics_enabled                                          = var.json.vm_info[count.index].boot_diag
  boot_diagnostics_storage_account_uri                              = module.storage.0.primary_file_endpoint
  os_disk_caching                                                   = var.json.vm_info[count.index].disk_cache
  os_disk_size_gb                                                   = var.json.vm_info[count.index].os_disk_size
  os_disk_storage_account_type                                      = var.json.vm_info[count.index].sa_types
  allow_extension_operations                                        = var.json.vm_info[count.index].allow_extensions
  priority                                                          = var.json.vm_info[count.index].priority
  identity_types                                                    = var.json.vm_info[count.index].identity_types
  tags                                                              = local.resource_tags
  vm_tags                                                           = local.vm_tags
  disk_encryption_enabled                                           = var.json.vm_info[count.index].disk_encrypt
  key_vault_id                                                      = azurerm_key_vault.cmk.id
  keyvault_encryption_key_id                                        = azurerm_key_vault_key.cmk.id
  key_permissions                                                   = var.json.common_info.key_permissions
  action_group_id                                                   = module.alerting.alert_ids
  health_check_alert                                                = var.json.vm_info[count.index].health_check
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
