data "azurerm_network_interface" "this" {
  count = var.enabled && var.network_interface_exists ? var.vm_count : 0

  name                = var.network_interface_external_names[count.index]
  resource_group_name = var.resource_group_name
}

data "azurerm_managed_disk" "this" {
  count = var.disk_recovered_from_backup ? 1 : 0

  name                = var.existing_disk_name
  resource_group_name = var.resource_group_name
}
