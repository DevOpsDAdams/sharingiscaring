output "nic_ip_list" {
  description = "The list of IPs from the Data Sourced NICs."
  value =  flatten(data.azurerm_network_interface.nic.*.private_ip_address)
}
