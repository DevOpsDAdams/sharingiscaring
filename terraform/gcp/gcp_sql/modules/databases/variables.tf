variable "repdbname" {
  type = string
}

variable "dbver" {
  type = string
}

variable "db_tier" {
  type = string
}

variable "availability" {
  type = string
}

variable "dbprotect" {
  type = bool
}

variable "db_disk_size" {
  type = number
}

variable "db_disk_type" {
  type = string
}

variable "backup_enabled" {
  type = bool
}

variable "bin_log_enabled" {
  type = bool
}

variable "retention" {
  type = number
}

variable "backup_retention" {
  type = number
}

variable "maint_day" {
  type = number
}

variable "maint_hour" {
  type = number
}

variable "maint_update" {
  type = string
}

variable "qlik_ip" {
  type = list(any)
}
variable "rootpw" {
  type = string
}

variable "network_name" {
  type = string
}

variable "sslrequire" {
  type = string
}

variable "gspath" {
  type = string
}

variable "masterinstance" {
  type = string
}

variable "sourceip" {
  type = string
}

variable "source_region" {
  type = string
}
