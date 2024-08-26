variable "user_identity_name" {
  description = "The name of the user-assigned identity"
  type        = string
}
variable "account_name" {
  description = "The name of the CosmosDB account"
  type        = string
}

variable "location" {
  description = "The location of the CosmosDB account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the CosmosDB account"
  type        = string
}

variable "offer_type" {
  description = "The offer type for the CosmosDB account"
  type        = string
}

variable "account_kind" {
  description = "The kind of CosmosDB account to create"
  type        = string
}

variable "automatic_failover_enabled" {
  description = "Whether or not automatic failover is enabled for the CosmosDB account"
  type        = bool
}

variable "failover_priority_location" {
  description = "The location of the primary failover region"
  type        = string
}

variable "failover_priority_location_2" {
  description = "The location of the secondary failover region"
  type        = string
}

variable "consistency_level" {
  description = "The consistency level for the CosmosDB account"
  type        = string
}

variable "max_interval_in_seconds" {
  description = "The maximum interval in seconds for the CosmosDB account"
  type        = number
}

variable "max_staleness_prefix" {
  description = "The maximum staleness prefix for the CosmosDB account"
  type        = number
}

variable "vnet_id" {
  description = "The ID of the virtual network to associate with the CosmosDB account"
  type        = string
}

variable "ignore_missing_vnet_service_endpoint" {
  description = "Whether or not to ignore missing VNet service endpoints"
  type        = bool
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}
