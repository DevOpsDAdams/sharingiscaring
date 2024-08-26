output "subnet_ids" {
  description = "List of Created Subnet IDs"
  value       = azurerm_subnet.subnet.id
}

output "subnet_names" {
  description = "List of Created Subnet Names"
  value       = azurerm_subnet.subnet.name
}

output "virtual_network_name" {
  description = "Virtual Network Name"
  value       = azurerm_subnet.subnet.virtual_network_name
}

output "address_prefixes" {
  description = "Address Prefixes"
  value       = azurerm_subnet.subnet.address_prefixes
}
