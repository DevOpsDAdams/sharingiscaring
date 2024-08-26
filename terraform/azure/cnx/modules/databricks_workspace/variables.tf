variable "workspace_name" {
  type        = string
  description = "The name of the Databricks workspace"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Databricks workspace"
}

variable "location" {
  type        = string
  description = "The location of the Databricks workspace"
}

variable "workspace_sku" {
  type        = string
  description = "The SKU of the Databricks workspace"
}

variable "customer_managed_key_enabled" {
  type        = bool
  description = "Whether or not to enable customer managed key for the Databricks workspace"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
}

variable "db_kv_name" {
  type        = string
  description = "The name of the Key Vault to create for the Databricks workspace"
}

variable "kv_sku_name" {
  type        = string
  description = "The SKU of the Key Vault to create for the Databricks workspace"
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID of the Azure Active Directory"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Whether or not to enable purge protection for the Key Vault"
}

variable "soft_delete_retention_days" {
  type        = number
  description = "The number of days to retain soft deleted keys for the Key Vault"
}

variable "cmk_key_name" {
  type        = string
  description = "The name of the key to create in the Key Vault for the Databricks workspace"
}

variable "key_type" {
  type        = string
  description = "The type of key to create in the Key Vault for the Databricks workspace"
}

variable "key_size" {
  type        = number
  description = "The size of the key to create in the Key Vault for the Databricks workspace"
}

variable "key_opts" {
  type        = list(string)
  description = "A list of options to assign to the key"
}

variable "object_id" {
  type        = string
  description = "The object ID of the Azure Active Directory"
}

variable "terraform_key_permissions" {
  type        = list(string)
  description = "A list of key permissions to assign to the Terraform service principal"
}

variable "databricks_key_permissions" {
  type        = list(string)
  description = "A list of key permissions to assign to the Databricks service principal"
}
