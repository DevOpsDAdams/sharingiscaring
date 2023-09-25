locals {
  qlik = ["192.168.0.119", "192.168.0.120", "192.168.0.121"]
}

resource "google_sql_database_instance" "sql" {
  name                = var.dbname
  database_version    = var.dbver
  deletion_protection = var.dbprotect
  settings {
    tier              = var.db_tier
    availability_type = var.availability
    disk_size         = var.db_disk_size
    disk_type         = var.db_disk_type
    backup_configuration {
      enabled            = var.backup_enabled
      binary_log_enabled = var.bin_log_enabled
    }
    maintenance_window {
      day          = var.maint_day
      hour         = var.maint_hour
      update_track = var.maint_update
    }
    ip_configuration {
      dynamic "authorized_networks" {
        for_each = local.qlik
        iterator = qlik
        content {
          name  = "qlik-${qlik.key + 1}"
          value = qlik.value
        }
      }
    }
  }
}

resource "google_sql_user" "users" {
  name     = "visualizer"
  instance = google_sql_database_instance.sql.name
  password = var.rootpw
}
