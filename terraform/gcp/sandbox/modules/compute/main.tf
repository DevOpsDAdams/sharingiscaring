data "google_compute_zones" "available" {
}

resource "google_compute_disk" "disk" {
  name  = "${var.name}-disk"
  zone  = data.google_compute_zones.available.names[0]
  image = var.image
}

resource "google_compute_address" "ip" {
  name         = "${var.name}-internal"
  address_type = "INTERNAL"
  subnetwork   = var.subnetwork
}

// TODO(NK): Add google_compute_health_check

resource "google_compute_instance" "instance" {
  name                      = var.name
  machine_type              = var.machine_type
  allow_stopping_for_update = "true"
  zone                      = data.google_compute_zones.available.names[0]
  boot_disk {
    source      = google_compute_disk.disk.self_link
    auto_delete = false
  }

  can_ip_forward = var.can_ip_forward
  tags           = var.network_tags
  network_interface {
    subnetwork = var.subnetwork
    network_ip = google_compute_address.ip.address
    access_config {}
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }
}
