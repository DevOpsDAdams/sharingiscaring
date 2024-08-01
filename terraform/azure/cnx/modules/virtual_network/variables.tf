variable "name" {
  description = "The name of the virtual network."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
  type        = string
}

variable "location" {
  description = "The location/region where the virtual network is created."
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
}

variable "ddos_protection_plan" {
  description = "A list of DDoS protection plan IDs to associate with the virtual network."
  type        = map(object)
  default = {
    "id"     = "<<ID>>"
    "enable" = true
  }
}
variable "encryption" {
  description = "A list of encryption service names to enable for the virtual network."
  type        = map(object)
  default = {
    "enforcement" = "DropUnencrypted"
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}
