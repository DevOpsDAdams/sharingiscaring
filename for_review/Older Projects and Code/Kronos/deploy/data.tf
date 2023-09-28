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

data "azurerm_subnet" "vm" {
  provider            = azurerm.networking
  name                 = var.json.common_network_info.vm_subnet
  virtual_network_name = var.json.common_network_info.vnet
  resource_group_name  = var.json.common_network_info.vnet_rg
}

data "azurerm_client_config" "current" {
}
