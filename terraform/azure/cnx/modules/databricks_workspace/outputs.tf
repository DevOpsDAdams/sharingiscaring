output "id" {
  value = azurerm_databricks_workspace.databricks.id
}

output "disk_encryption_set_id" {
  value = azurerm_databricks_workspace.databricks.disk_encryption_set_id
}

output "managed_disk_identity" {
  value = azurerm_databricks_workspace.databricks.managed_disk_identity
}

output "managed_resource_group_id" {
  value = azurerm_databricks_workspace.databricks.managed_resource_group_id
}

output "workspace_url" {
  value = azurerm_databricks_workspace.databricks.workspace_url
}

output "workspace_id" {
  value = azurerm_databricks_workspace.databricks.workspace_id
}

output "storage_account_identity" {
  value = azurerm_databricks_workspace.databricks.storage_account_identity
}
