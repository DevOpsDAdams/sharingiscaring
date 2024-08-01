variable "display_name" {
  description = "The display name of the service principal"
  type        = string
}

variable "owners" {
  description = "The owners of the service principal"
  type        = list(string)
}

variable "account_enabled" {
  description = "Is the service principal account enabled"
  type        = bool
}

variable "app_role_assignment_required" {
  description = "Is the app role assignment required"
  type        = bool
}

variable "description" {
  description = "The description of the service principal"
  type        = string
}

variable "alternative_names" {
  description = "The alternative names of the service principal"
  type        = list(string)
}

variable "tags" {
  description = "The tags of the service principal"
  type        = map(string)
}
