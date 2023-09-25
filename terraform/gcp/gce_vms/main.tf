terraform {
  backend "gcs" {
    bucket = "my-terraform"
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_image" "image" {
  name    = "image-name"
  project = "image-cloud"
}

data "google_compute_image" "ubuntu" {
  name    = "ubuntu-2004-focal-v20210119a"
  project = "ubuntu-os-cloud"
}


module "image_deploy" {
  source     = "./modules/compute"
  name       = "image_deploy"
  subnetwork = var.subnet
  image      = data.google_compute_image.ubuntu.self_link

  can_ip_forward = true
  network_tags   = google_compute_firewall.local_all.target_tags
}
