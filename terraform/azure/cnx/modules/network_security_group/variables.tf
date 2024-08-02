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

variable "subnet_ids" {
  description = "The subnet ids to associate with the network security group."
  type        = list(string)
}
