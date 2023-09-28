output "alert_ids" {
    description = "The output of the Alert IDs Created."
    value = azurerm_monitor_action_group.alert.id
}
