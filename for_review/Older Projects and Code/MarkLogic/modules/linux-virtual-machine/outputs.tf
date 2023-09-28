###
# Network Interface
###

output "network_interface_ids" {
  value = azurerm_network_interface.this.*.id
}

output "network_interface_private_ip_addresses" {
  value = azurerm_network_interface.this.*.private_ip_address
}

###
# Virtual Machines
###

output "ids" {
  value = azurerm_linux_virtual_machine.this.*.id
}

output "identities" {
  value = azurerm_linux_virtual_machine.this.*.identity
}
