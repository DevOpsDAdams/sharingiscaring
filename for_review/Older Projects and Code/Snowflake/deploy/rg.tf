resource "azurerm_resource_group" "resource_group" {
  name                 = "${var.json.common_info.tenant}-${var.json.common_info.rg_prefix}-${var.json.common_info.application_name}-${var.json.common_info.environment}-001"
  location             = var.json.common_info.location
  tags                 = local.resource_tags
  timeouts {
    create = "60m"
    delete = "2h"
  }
}
