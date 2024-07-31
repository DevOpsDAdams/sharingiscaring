# Azure load balancer module
data "azurerm_resource_group" "azlb" {
  name = var.resource_group_name
}

resource "azurerm_lb" "azlb" {
  name                = "${var.lb_name}"
  resource_group_name = data.azurerm_resource_group.azlb.name
  location            = coalesce(var.location, data.azurerm_resource_group.azlb.location)
  sku                 = var.lb_sku
  tags                = var.tags

 dynamic frontend_ip_configuration {
    for_each = zipmap(var.frontend_names, var.frontend_ip)
    content {
      name = frontend_ip_configuration.key
      subnet_id                     = var.frontend_subnet_id
      private_ip_address = frontend_ip_configuration.value
      private_ip_address_allocation = var.frontend_private_ip_address_allocation
      zones               = [var.lb_availability_zone]  # Enforced per OneAmerica policy

    }
  }
}

resource "azurerm_lb_probe" "azlb" {
  count               = length(var.lb_probe)
  name                = element(keys(var.lb_probe), count.index)
  loadbalancer_id     = azurerm_lb.azlb.id
  protocol            = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 0)
  port                = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 1)
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 2)
}

resource "azurerm_lb_backend_address_pool" "azlb" {
  name                = "BackEndAddressPool"
  loadbalancer_id     = azurerm_lb.azlb.id
}

resource "azurerm_lb_rule" "azlb" {
  count                          = length(var.lb_port)
  name                           = element(keys(var.lb_port), count.index)
  loadbalancer_id                = azurerm_lb.azlb.id
  protocol                       = element(var.lb_port[element(keys(var.lb_port), count.index)], 1)
  frontend_port                  = element(var.lb_port[element(keys(var.lb_port), count.index)], 0)
  backend_port                   = element(var.lb_port[element(keys(var.lb_port), count.index)], 2)
  frontend_ip_configuration_name = element(var.frontend_names, count.index)
  enable_floating_ip             = var.floating_ip
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.azlb.id]
  idle_timeout_in_minutes        = 5
  probe_id                       = element(azurerm_lb_probe.azlb.*.id, count.index)
}


resource "azurerm_network_interface_backend_address_pool_association" "azlb" {
  count =           length(var.network_interface_ids)
  network_interface_id    =  element(var.network_interface_ids,count.index)
  ip_configuration_name   =  element(var.network_interface_ip_configuration_names,count.index)
  backend_address_pool_id = azurerm_lb_backend_address_pool.azlb.id

  lifecycle {
    ignore_changes = [
      ip_configuration_name,
      network_interface_id
    ]
  }
}
