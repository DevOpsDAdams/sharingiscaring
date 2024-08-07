output "azurerm_resource_group_tags" {
  description = "the tags provided for the resource group"
  value       = data.azurerm_resource_group.azlb.tags
}

output "azurerm_resource_group_name" {
  description = "name of the resource group provisioned"
  value       = data.azurerm_resource_group.azlb.name
}

output "azurerm_lb_id" {
  description = "the id for the azurerm_lb resource"
  value       = azurerm_lb.azlb.id
}

output "azurerm_lb_frontend_ip_configuration" {
  description = "the frontend_ip_configuration for the azurerm_lb resource"
  value       = azurerm_lb.azlb.frontend_ip_configuration
}

output "azurerm_lb_probe_ids" {
  description = "the ids for the azurerm_lb_probe resources"
  value       = azurerm_lb_probe.azlb.*.id
}

output "azurerm_lb_backend_address_pool_id" {
  description = "the id for the azurerm_lb_backend_address_pool resource"
  value       = azurerm_lb_backend_address_pool.azlb.id
}
