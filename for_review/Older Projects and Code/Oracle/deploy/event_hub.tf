data "azurerm_eventhub_authorization_rule" "lb" {
  provider            = azurerm.event_hub
  name                = var.json.event_hub_info.auth_rule
  namespace_name      = var.json.event_hub_info.name
  eventhub_name       = var.json.event_hub_info.name
  resource_group_name = var.json.event_hub_info.rg
}
