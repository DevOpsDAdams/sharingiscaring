variable "name" {
  description = "The name of the key vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the key vault."
  type        = string
}
variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}

variable "tenant_id" {
  description = "The tenant ID that should be used for the key vault."
  type        = string
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft deleted."
  type        = number
}

variable "purge_protect" {
  description = "Should the key vault be protected from purging."
  type        = bool
}

variable "sku_name" {
  description = "The SKU name of the Key Vault to create."
  type        = string
}

variable "object_id" {
  description = "The object ID of the principal to grant access to the key vault."
  type        = string
}

variable "key_permissions" {
  description = "The key permissions to grant to the principal."
  type        = list(string)
}

variable "secret_permissions" {
  description = "The secret permissions to grant to the principal."
  type        = list(string)
}

variable "storage_permissions" {
  description = "The storage permissions to grant to the principal."
  type        = list(string)
}

variable "default_action" {
  description = "The default action to apply when no rules match."
  type        = string
}

variable "ip_rules" {
  description = "The list of IP rules to apply."
  type        = list(string)
}

variable "virtual_network_subnet_ids" {
  description = "The list of virtual network subnet IDs to apply."
  type        = list(string)
}

variable "bypass" {
  description = "The bypass rules to apply."
  type        = string
}

variable "enabled_for_deployment" {
  description = "Should the key vault be enabled for deployment."
  type        = bool
}

variable "enabled_for_disk_encryption" {
  description = "Should the key vault be enabled for disk encryption."
  type        = bool
}

variable "enabled_for_template_deployment" {
  description = "Should the key vault be enabled for template deployment."
  type        = bool
}

variable "enable_rbac_authorization" {
  description = "Should the key vault be enabled for RBAC authorization."
  type        = bool
}

variable "public_network_access_enabled" {
  description = "Should the key vault be enabled for public network access."
  type        = bool
}
