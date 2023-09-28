resource "azurerm_monitor_action_group" "alert" {
  name                = var.alert_name
  resource_group_name = var.resource_group_name
  short_name          = var.alert_short_name

  email_receiver {
    name          = var.email_name
    email_address = var.email_address
  }

}
