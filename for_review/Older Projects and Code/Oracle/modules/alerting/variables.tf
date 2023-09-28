variable "alert_name" {
  description = "The long name of the Alert."
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the Resource Group for the Alert Setup."
  default     = ""
}

variable "alert_short_name" {
  description = "The Short Name of the Alert"
  default     = ""
}

variable "email_name" {
  description = "The name of the Email Alert Congifguration"
  default     = ""
}

variable "email_address" {
  description = "The email address to be used for alerting"
  default     = ""
}
