resource "azurerm_network_security_rule" "additional_rules" {
  resource_group_name           = var.resource_group_name
  network_security_group_name   = var.network_security_group_name
  name                          = var.name
  priority                      = var.priority
  direction                     = var.direction
  access                        = var.rule_access
  protocol                      = var.rule_protocol
  source_port_range             = var.source_port
  destination_port_range        = var.destination_port
  source_address_prefixes       = var.source_prefix
  destination_address_prefix    = var.destination_prefix
}
