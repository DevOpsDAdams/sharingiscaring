variable "name" {
  description = "The name of the key vault."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault."
  type        = string
}

variable "type" {
  description = "The type of the key."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}

variable "key_size" {
  description = "The size of the key."
  type        = number
}

variable "key_options" {
  description = "The options of the key."
  type        = list(string)
}

variable "rotation_policy" {
  description = "The rotation policy of the key."
  type        = map(string)
  }

variable "expire_after" {
  description = "The expiration date of the key."
  type        = string
}

variable "automatic" {
  description = "The automatic rotation of the key."
  type        = map(string)
}

variable "time_after_creation" {
  description = "The time after creation of the key."
  type        = string
}

variable "notify_before_expiry" {
  description = "The notification before expiry of the key."
  type        = string
}
