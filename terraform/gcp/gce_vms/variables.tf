variable "project_id" {
  type        = string
  default     = "my-cloud"
  description = "The Project ID to use for deployments"
}

variable "region" {
  type        = string
  default     = "us-west1"
  description = "The region being deployed to."
}

variable "subnet" {
  type        = string
  default     = "subnet-01"
  description = "Desired Subnet"
}

variable "delete_protection" {
  type        = bool
  default     = false
  description = "Determine deletion protection for the database. True is required for production environments."
}

variable "avail_type" {
  type        = string
  default     = "REGIONAL"
  description = "Availability type. Choices are Regional or Zone."
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "Number. Size of the disk for the database instance."
}

variable "disk_type" {
  type        = string
  default     = "PD_SSD"
  description = "Type of disk used for the database instance. Choices are PD_SSD or PD_HDD."
}

variable "backup_config_bool" {
  type = map(any)
  default = {
    "enabled" = true
    "bin_log" = true
  }
}

variable "backup_config_int" {
  type = map(any)
  default = {
    "transaction_retention_days" = 3
    "backup_retention"           = 3
  }
}

variable "maintenance_int" {
  type = map(any)
  default = {
    "day"              = 6
    "hour"             = 0
    "backup_retention" = 3
  }
}

variable "maintenance_update" {
  type        = string
  default     = "stable"
  description = "Provides the update type for the maintenance window."
}

variable "network" {
  type = string
  default = "vpc"
}

variable "ssl_require" {
  type = string
  default = "true"
}

variable "gs_path" {
  type = string
  default = "gs://google-cloud-bucket/source-database.sql.gz"
}

variable "google_secret" {
  type = string
  default = "prod_sql_root_pw"
}

variable "master_instance" {
  type = string
  default = "rep-test"
}
