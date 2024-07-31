resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan
    content {
      id      = ddos_protection_plan.value.id
      enable = ddos_protection_plan.value.enable
    }
  }

dynamic "encryption" {
    for_each = var.encryption
    content {
      enforcement = encryption.value.enforcement
    }
  }


  tags = var.tags
}
