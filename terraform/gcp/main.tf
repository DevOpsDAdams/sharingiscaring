provider "google" {
  project     = "gcp-project"
  region      = "us-west1"
}

locals {
  qlik = ["192.168.0.121", "192.168.0.122", "192.168.0.123"]
}

resource "null_resource" "rootpw" {
  provisioner "local-exec" {
    command = "gcloud secrets versions access latest --secret=prod_sql_root_pw --project my-project > ./rootpw"
  }
}

data "local_file" "sqlpw" {
  filename = "./rootpw"
  depends_on = [
    null_resource.rootpw
  ]
}
resource "google_compute_network" "network" {
  name                    = "test-dadams-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "dadams-subnet-01"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.network.self_link
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "dadams-priv-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.id
}

resource "google_service_networking_connection" "servicing_connection" {
  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

/*
Reserved for future iteration. Returning permissions errors at this time.
Please do not delete.
data "google_secret_manager_secret_version" "sqlpw" {
  project = "my-project"
  secret = var.google_secret
}
rootpw           = data.google_secret_manager_secret_version.sqlpw.secret_data

*/

module "cloudsql" {
  count            = 1
  source           = "./modules/databases/"
  dbname           = "${var.database_name}${count.index + 1}"
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
  rootpw           = data.local_file.sqlpw.content
  network_name     = var.network
  sslrequire       = var.ssl_require
  gspath           = var.gs_path
  masterinstance   = var.master_instance
  depends_on = [
    google_service_networking_connection.servicing_connection
  ]
}
