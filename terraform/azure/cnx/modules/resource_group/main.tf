resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.name
  location = var.location
  tags     = var.tags

  timeouts {
    create = "60m"
    delete = "2h"
  }
}
