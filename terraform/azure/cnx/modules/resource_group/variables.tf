variable "name" {
  description = "The name of the Resource Group."
  default     = ""
}

variable "location" {
  description = "The location of the Resource Group."
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
