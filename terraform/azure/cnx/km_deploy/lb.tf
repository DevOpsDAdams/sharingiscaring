module "load_balancers" {
  source              = "../modules/load_balancer"
  for_each            = var.json.networking_info.load_balancer
  location            = var.json.common_info.location
  resource_group_name = module.resource_group.networking.name

  type    = each.value.type
  lb_sku  = each.value.sku
  lb_name = "${each.value.name}-${var.json.common_info.env_short}-001"

  lb_port  = { frontend_1 = each.value.lb_port_frontend }
  lb_probe = { Tcp = each.value.lb_probe_tcp }

  lb_probe_interval            = var.json.load_balancer.probe_interval
  lb_probe_unhealthy_threshold = var.json.load_balancer.probe_unhealthy_threshold

  frontend_ip                            = each.value.frontend_ip
  frontend_names                         = ["${each.value.frontend_prefix}-${upper(var.json.common_info.env_short)}"]
  frontend_subnet_id                     = module.subnets.lb.id
  frontend_private_ip_address_allocation = each.value.ip_allocation

  network_interface_ids                    = module.network_interface.nic.*.id
  network_interface_ids_count              = length(module.network_interface.nic.*.id)
  network_interface_ip_configuration_names = flatten(module.network_interface.nic[*].ip_configuration[*].name)
  lb_availability_zone                     = each.value.zone

  tags = local.resource_tags
  depends_on = [
    module.subnets, module.network_interface
  ]
}
