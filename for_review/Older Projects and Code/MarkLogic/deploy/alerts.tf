module "alerting" {
  source  = "../modules/alerting"
  alert_name                = var.json.alert_info.name
  resource_group_name       = azurerm_resource_group.resource_group.name
  alert_short_name          = var.json.alert_info.short_name
  email_name                = var.json.alert_info.email_name
  email_address             = var.json.alert_info.email

}
