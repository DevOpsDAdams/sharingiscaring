variable "storage_account_name" {
  description = "The name of the Storage Account"
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the Resource Group for the Subnet."
  default     = ""
}

variable "location" {
  description = "The location of the Storage Account in Azure."
  default     = ""
}

variable "sa_kind" {
  description = "The kind for the Storage Account."
  default     = ""
}

variable "sa_tier" {
  description = "The tier for the Storage Account."
  default     = ""
}

variable "replication_type" {
  description = "The replication type for the Storage Account."
  default     = ""
}

variable "tags" {
}

variable "subnet_ids" {
  description = "A List of Subnet IDs to use with the Storage Account Network Rules"
  default     = [""]
}

variable "diag_name" {
  description = "The name of the Diagnostic Setting."
  default     = ""
}

variable "diag_sa" {
  description = "The name of the Diagnostic Setting Storage Account."
  default     = ""
}

variable "subscription_id" {
  description = "The subscription id for the null resource script"
}

variable "key_vault_id" {
  description = "The ID of the KeyVault to use for CMK Keys"
}

variable "key_name" {
  description = "The name of the KeyVault Key to use for CMK Keys"
}

variable "tenant_id" {
  description = "The current config Tenant ID"
}

variable "key_permissions" {
  description = "Key Permissions for the Keyvault"
}

variable "secret_permissions" {
  description = "Secret Permissions for the Keyvault"
}

variable "storage_permissions" {
  description = "Storage Permissions for the Keyvault"
}

variable "ip_rules" {
  description = "Initial IP Addresse to Bypass the Network Restrictions."
}

variable "ip_rules2" {
  description = "Additional IP Addresse(s) to Bypass the Network Restrictions."
}
