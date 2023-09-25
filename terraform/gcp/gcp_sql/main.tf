provider "google" {
  project     = "my-project"
  region      = "us-west1"
}

locals {
  qlik = ["192.168.0.121", "192.168.0.122", "192.168.0.123"]
}

resource "random_string" "random" {
  length  = 2
  special = false
  lower   = true
  upper   = false
}

data "google_secret_manager_secret_version" "sqlpw" {
  secret = var.google_secret
}

data "google_compute_network" "network" {
  name                    = "my-vpc"
}

data "google_compute_subnetwork" "subnetwork" {
  name          = "subnet-01"
}

resource "google_compute_network" "sqlnetwork" {
  name                    = "sql-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "sqlsubnet" {
  name          = "sql-subnet-01"
  ip_cidr_range = var.sql_cidr
  network       = google_compute_network.sqlnetwork.self_link
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "sql-peering"
  address_type  = "INTERNAL"
  prefix_length = 20
  purpose       = "VPC_PEERING"
  network       = google_compute_network.sqlnetwork.id
}

resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.sqlnetwork.id
  peer_network = data.google_compute_network.network.id
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = data.google_compute_network.network.id
  peer_network = google_compute_network.sqlnetwork.id
}

resource "google_service_networking_connection" "servicing_connection" {
  network                 = google_compute_network.sqlnetwork.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}



module "cloudsql" {
  count            = 1
  source           = "./modules/databases/"
  repdbname        = "${var.rep_db_name}${random_string.random.result}${count.index + 1}"
  dbver            = var.database_version
  dbprotect        = var.delete_protection
  db_tier          = var.dbtier
  availability     = var.avail_type
  db_disk_size     = var.disk_size
  db_disk_type     = var.disk_type
  backup_enabled   = var.backup_config_bool.enabled
  bin_log_enabled  = var.backup_config_bool.bin_log
  retention        = var.backup_config_int.transaction_retention_days
  backup_retention = var.backup_config_int.backup_retention
  maint_day        = var.maintenance_int.day
  maint_hour       = var.maintenance_int.hour
  maint_update     = var.maintenance_update
  qlik_ip          = local.qlik
  rootpw           = data.google_secret_manager_secret_version.sqlpw.secret_data
  network_name     = var.network
  sslrequire       = var.ssl_require
  gspath           = var.gs_path
  masterinstance   = "${var.master_instance}${random_string.random.result}${count.index + 1}"
  sourceip         = var.source_ip
  source_region    = var.sourceregion
  depends_on = [
    google_service_networking_connection.servicing_connection
  ]
}
