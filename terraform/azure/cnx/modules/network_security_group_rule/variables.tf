variable "name" {
  description = "The name of the key vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the key vault."
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group."
  type        = string
}

variable "priority" {
  description = "The priority of the rule."
  type        = number
}

variable "direction" {
  description = "The direction of the rule."
  type        = string
}

variable "rule_access" {
  description = "The access of the rule."
  type        = string
}

variable "rule_protocol" {
  description = "The protocol of the rule."
  type        = string
}

variable "source_port" {
  description = "The source port of the rule."
  type        = string
}

variable "destination_port" {
  description = "The destination port of the rule."
  type        = string
}

variable "source_prefix" {
  description = "The source prefix of the rule."
  type        = list(string)
}

variable "destination_prefix" {
  description = "The destination prefix of the rule."
  type        = string
}
