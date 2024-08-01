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

variable "account_kind" {
  description = "The kind for the Storage Account."
  default     = ""
}

variable "account_tier" {
  description = "The tier for the Storage Account."
  default     = ""
}

variable "access_tier" {
  description = "The access tier for the Storage Account."
  default     = ""
}

variable "cross_tenant_replication_enabled" {
  description = "Enable Cross Tenant Replication for the Storage Account."
  type        = bool
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

variable "public_network_access_enabled" {
  description = "Enable Public Network Access for the Storage Account."
  type        = bool
}

variable "large_file_share_enabled" {
  description = "Enable Large File Share for the Storage Account."
  type        = bool
}

variable "nfsv3_enabled" {
  description = "Enable NFSv3 for the Storage Account."
  type        = bool
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

variable "allowed_ips" {
  description = "List of IP Addresses to allow access to the Storage Account."
}

variable "min_tls_version" {
  description = "The minimum TLS version for the Storage Account."
  default     = ""
}

variable "enable_https_traffic_only" {
  description = "Enable HTTPS Traffic Only for the Storage Account."
  type        = bool
}

variable "identity_type" {
  description = "The Identity Type for the Storage Account."
  default     = ""
}

variable "allow_nested_items_to_be_public" {
  description = "Allow Nested Items to be Public for the Storage Account."
  type        = bool
}

variable "shared_access_key_enabled" {
  description = "Enable Shared Access Key for the Storage Account."
  type        = bool
}

variable "is_hns_enabled" {
  description = "Enable Hierarchical Namespace for the Storage Account."
  type        = bool
}

variable "default_to_oauth_authentication" {
  description = "Enable OAuth Authentication for the Storage Account."
  type        = bool
}

variable "bypass" {
  description = "Bypass the Network Restrictions for the Storage Account."
  type        = list(string)
}

variable "default_action" {
  description = "Default Action for the Storage Account Network Rules."
  default     = ""
}
