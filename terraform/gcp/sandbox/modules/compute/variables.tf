variable "name" {
  type = string
}

variable "can_ip_forward" {
  type    = bool
  default = false
}

variable "subnetwork" {
  type = string
}

variable "image" {
  type = string
}

variable "network_tags" {
  type    = list(string)
  default = []
}

variable "machine_type" {
  type    = string
  default = "e2-small"
}

variable "service_account" {
  type    = string
  default = ""
}
