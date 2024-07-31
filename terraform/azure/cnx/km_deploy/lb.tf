module "lb-l4" {
  source              = "../modules/load-balancer"
  location            = var.json.common_info.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type    = var.json.load_balancer.type
  lb_sku  = var.json.load_balancer.sku
  lb_name = "${var.json.load_balancer.prefix}-${lower(var.json.common_info.app_name_short)}-${var.json.common_info.env_short}-001"

  lb_port = {frontend_1 = var.json.load_balancer.lb_port_frontend}
  lb_probe = {Tcp = var.json.load_balancer.lb_probe_tcp}

  lb_probe_interval            = var.json.load_balancer.probe_interval
  lb_probe_unhealthy_threshold = var.json.load_balancer.probe_unhealthy_threshold

  frontend_ip                            = var.json.load_balancer.frontend_ip
  frontend_names                         = ["${var.json.load_balancer.frontend_prefix}-${var.json.common_info.app_name_short}-${upper(var.json.common_info.env_short)}-001"]
  frontend_subnet_id                     = data.azurerm_subnet.lb.id
  frontend_private_ip_address_allocation = var.json.load_balancer.ip_allocation

  network_interface_ids                    = data.azurerm_network_interface.nic.*.id
  network_interface_ids_count              = length(data.azurerm_network_interface.nic.*.id)
  network_interface_ip_configuration_names = flatten(data.azurerm_network_interface.nic[*].ip_configuration[*].name)
  lb_availability_zone = var.json.load_balancer.zone

  tags = local.resource_tags
  depends_on = [
    module.hyb_servers
  ]
}
