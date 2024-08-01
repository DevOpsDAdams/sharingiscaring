output "id" {
  value = azurerm_key_vault_key.key_vault_key.id
}

output "resource_id" {
  value = azurerm_key_vault_key.key_vault_key.resource_id
}

output "public_key_pem" {
  value = azurerm_key_vault_key.key_vault_key.public_key_pem
}

output "public_key_openssh" {
  value = azurerm_key_vault_key.key_vault_key.public_key_openssh
}
