output "vnet_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_guid" {
  description = "The GUID of the virtual network."
  value       = azurerm_virtual_network.vnet.guid
}

output "name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}
