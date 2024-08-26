module "network_security_group" {
  source   = "../modules/network_security_group/"
  for_each = var.json.networking_info.security_groups

  name                = each.value.name
  location            = var.json.common_info.location
  resource_group_name = module.resource_group.networking.resource_group_name
  tags                = var.json.tags
  subnet_ids          = [module.subnets.subnet_ids]
  depends_on          = [module.resource_group.networking, module.vnet, module.subnets]
}

module "network_security_group_rule" {
  source   = "../modules/network_security_group_rule/"
  for_each = var.json.networking_info.security_groups.security_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  rule_access                 = each.value.access
  rule_protocol               = each.value.protocol
  source_port                 = each.value.source_port_range
  destination_port            = each.value.destination_port_range
  source_prefix               = each.value.source_address_prefix
  destination_prefix          = each.value.destination_address_prefix
  resource_group_name         = module.resource_group.networking.resource_group_name
  network_security_group_name = module.network_security_group[each.value.network_security_group_name].network_security_group_name

  depends_on = [module.network_security_group]
}
