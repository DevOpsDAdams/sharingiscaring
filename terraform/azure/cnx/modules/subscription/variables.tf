variable "alias" {
  description = "The alias of the Subscription."
  default     = ""
}

variable "subscription_name" {
  description = "The name of the Subscription."
  default     = ""
}

variable "billing_account_name" {
  description = "The name of the Billing Account."
  default     = ""
}

variable "enrollment_account_name" {
  description = "The name of the Enrollment Account."
  default     = ""
}

variable "tags" {
  description = "The tags for the Subscription."
  type        = map(string)
  default     = {}
}
