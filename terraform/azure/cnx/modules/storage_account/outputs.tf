output "storage_account_ids" {
  description = "List of Created Storage Account IDs"
  value       = azurerm_storage_account.storage_account.*.id
}

output "primary_file_endpoint" {
  value = azurerm_storage_account.storage_account.*.primary_file_endpoint[0]
}
