data "azurerm_shared_image_gallery" "gallery" {
  provider            = azurerm.image_gallery
  name                = var.json.image_gallery_info.gallery_name
  resource_group_name = var.json.image_gallery_info.rg
}

data "azurerm_shared_image" "image" {
  provider            = azurerm.image_gallery
  name                = var.json.image_gallery_info.image_name
  gallery_name        = var.json.image_gallery_info.gallery_name
  resource_group_name = var.json.image_gallery_info.rg
}

data "azurerm_shared_image_version" "image_version" {
  provider            = azurerm.image_gallery
  name                = "latest"
  image_name          = var.json.image_gallery_info.image_name
  gallery_name        = var.json.image_gallery_info.gallery_name
  resource_group_name = var.json.image_gallery_info.rg
}

data "azurerm_recovery_services_vault" "recovery-vault" {
  provider            = azurerm.recovery_vault
  name                = var.json.recovery_vault.name
  resource_group_name = var.json.recovery_vault.rg
}

data "azurerm_backup_policy_vm" "backup-policy" {
  provider            = azurerm.recovery_vault
  name                = var.json.backup_policy.name
  recovery_vault_name = var.json.recovery_vault.name
  resource_group_name = var.json.recovery_vault.rg
}

data "azurerm_virtual_network" "vnet" {
  provider            = azurerm.networking
  name                = var.json.common_network_info.vnet
  resource_group_name = var.json.common_network_info.vnet_rg
}

data "azurerm_subnet" "subnet" {
  provider            = azurerm.networking
  name                 = var.json.common_network_info.subnet
  virtual_network_name = var.json.common_network_info.vnet
  resource_group_name  = var.json.common_network_info.vnet_rg
}

data "azurerm_network_interface" "nic" {
  count               = length(var.json.vm_info)
  name                = "${local.nic_prefix}${var.json.vm_info[count.index].unique_name}0${count.index+1}-nic01"
  resource_group_name =  azurerm_resource_group.resource_group.name
  depends_on = [
    module.servers
  ]
}


data "azurerm_client_config" "current" {
}
