resource "azurerm_application_gateway" "app_gateway" {
  name                = var.agw_name # Example: "agw-application-dev-001"
  resource_group_name = var.resource_group_name
  location            = var.location

# Enforced per OneAMerica Policy. Do Not Disable.
  enable_http2        = true

   sku {
    name     = var.sku_name # "Standard_Medium"
    tier     = var.sku_tier # "Standard"
    capacity = var.sku_capacity # 2
  }

# Forced Set by OneAmerica Policy
  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.policy_name
    min_protocol_version = "TLSv1_2"
  }

  gateway_ip_configuration {
    name      = var.gateway_ipc_name
    subnet_id = var.subnet_id # subnet created with the RG used for LBs
  }

  frontend_port {
    name =  var.frontend_port_name # from vnet name
    port =  var.frontend_port # 80
  }

  frontend_ip_configuration {
    name                 =  var.fipc_name # from vnet name again
    subnet_id            = var.subnet_id # subnet created with the RG used for LBs
    private_ip_address   = var.fipc_ip_address # some private ip address
    private_ip_address_allocation = var.ip_allocation
  }

  backend_address_pool {
    name =  var.bep_name # from vnet name yet again
    ip_addresses = var.ip_address_list
  }

  backend_http_settings {
    name                  = var.bep_http_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.fipc_name
    frontend_port_name             = var.frontend_port_name
    protocol                       =  var.listener_protocol # Http
  }

  request_routing_rule {
    name                       = var.routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.bep_name
    backend_http_settings_name = var.bep_http_name
  }

  tags = var.resource_tags
  timeouts {
    create = "60m"
    delete = "2h"
  }
}
