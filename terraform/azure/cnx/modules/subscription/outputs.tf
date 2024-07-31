output "subscription_id" {
  description = "The ID of the Subscription."
  value = azurerm_subscription.subscription.id
}

output "tenant_id" {
  description = "The ID of the Tenant."
  value = azurerm_subscription.subscription.tenant_id
}
