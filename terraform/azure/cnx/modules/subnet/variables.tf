variable "subnet_name" {
  description = "The long name of the Alert."
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the Resource Group for the Subnet."
  default     = ""
}

variable "vnet_name" {
  description = "The name of the VNET To be Used"
  default     = ""
}

variable "address_prefixes" {
  description = "The address CIDRs to be used in the subnet"
  default     = [""]
}

variable "service_endpoints" {
  description = "Service Endpoint Assignments for the Subnet"
  default     = [""]
}

variable "delegation_name" {
  description = "The name of the Azure Service Delegation"
  default     = ""
}

variable "delegation_service_name" {
  description = "The name of the Azure Service Delegation"
  default     = ""
}

variable "delegation_service_actions" {
  description = "The actions to be delegated to the service"
  default     = [""]
}
