variable "rep_db_name" {
  type        = string
  default     = "devqa-sqlrep-"
  description = "Name of the Replication Database. Can be made iterable."
}

variable "dbtier" {
  type        = string
  default     = "db-f1-micro"
  description = "SQL DB Tier"
}

variable "database_version" {
  type        = string
  default     = "MYSQL_8_0"
  description = "Desired database version."
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
  type    = string
  default = "sql-vpc"
}

variable "ssl_require" {
  type    = string
  default = "true"
}

variable "gs_path" {
  type    = string
  default = "gs://google-cloud-bucket/source-database.sql.gz"
}

variable "google_secret" {
  type    = string
  default = "prod_sql_root_pw"
}

variable "master_instance" {
  type    = string
  default = "master"
}

variable "source_ip" {
  type = string
  default = "192.168.1.121"
}

variable "sourceregion" {
  type    = string
  default = "us-west1"
}

variable "sql_cidr" {
  type = string
  default = "192.168.1.120/20"
}
