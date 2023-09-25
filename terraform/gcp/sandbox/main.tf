provider "google" {
  project     = ""
  region      = "us-west1"
}


locals {
  qlik = ["18.205.71.36", "18.232.32.199", "34.237.68.254"]
}

resource "null_resource" "rootpw" {
  provisioner "local-exec" {
    command = "gcloud secrets versions access latest --secret= --project <<project>>-cloud> ./rootpw"
  }
}

data "local_file" "sqlpw" {
  filename = "./rootpw"
  depends_on = [
    null_resource.rootpw
  ]
}

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
}
