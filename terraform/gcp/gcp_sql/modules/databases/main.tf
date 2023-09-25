locals {
  qlik = var.qlik_ip
}

data "google_compute_network" "private_network" {
  name = var.network_name
}


resource "google_sql_source_representation_instance" "master" {
  name             = var.masterinstance
  region           = var.source_region
  database_version = var.dbver
  host             = var.sourceip
  port             = 3306
}


resource "google_sql_database_instance" "replica" {
  name                 = var.repdbname
  master_instance_name = google_sql_source_representation_instance.master.name
  database_version     = var.dbver
  deletion_protection  = var.dbprotect
  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"
    disk_size         = var.db_disk_size
    disk_type         = var.db_disk_type
    ip_configuration {
      private_network = data.google_compute_network.private_network.id
      require_ssl     = var.sslrequire
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
  replica_configuration {
    username       = "repl"
    password       = var.rootpw
    dump_file_path = var.gspath
  }
  depends_on = [
    google_sql_source_representation_instance.master
  ]
  timeouts {
    create = "90m"
    delete = "2h"
  }
}

resource "google_sql_user" "users" {
  name     = "repl"
  instance = google_sql_database_instance.replica.name
  password = var.rootpw
}
