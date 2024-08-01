output "id" {
  description = "The ID of the Key Vault Key."
  value       = azurerm_key_vault_key.key_vault_key.id
}

output "vault_uri" {
  description = "The URI of the Key Vault Key."
  value       = azurerm_key_vault_key.key_vault_key.vault_uri
}
