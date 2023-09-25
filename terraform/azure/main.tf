variable "json" {
  type        = any
  description = "JSON containing all TF Vars"
}

locals {
  resource_tags = {
    "Application Name"  = var.json.tags.ApplicationName
    "Approver Name"     = var.json.tags.ApproverName
    "Budget Amount"     = var.json.tags.Budget
    "Business Unit"     = var.json.tags.BusinessUnit
    "Cost Center"       = var.json.tags.CostCenter
    "Disaster Recovery" = var.json.tags.DR
    "End Date"          = var.json.tags.EndDate
    "Environment"       = var.json.tags.Environment
    "Owner Name"        = var.json.tags.Owner
    "Requestor Name"    = var.json.tags.Requestor
    "Service Class"     = var.json.tags.ServiceClass
    "Start Date"        = var.json.tags.StartDate
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.json.shared_settings.tenant}-rg-${var.json.shared_settings.service-name}-${var.json.shared_settings.ApplicationName}-001"
  location = var.json.shared_settings.location
}

data "azurerm_virtual_network" "main" {
  name                = var.json.vnet_settings.name
  resource_group_name = var.json.vnet_settings.resource_group
}

data "azurerm_subnet" "main" {
  name                 = var.json.vnet_settings.subnet_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = var.json.vnet_settings.resource_group
}

resource "azurerm_network_interface" "main" {
  name                = "${var.json.vnet_settings.nic-prefix}-${var.json.vm_settings.name}-${var.json.shared_settings.environment}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipc-${var.json.vm_settings.name}-001"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm${lower(var.json.tags.ApplicationName)}001"
  resource_group_name = var.json.vnet_settings.resource_group
  location            = var.json.shared_settings.location
  size                = var.json.vm_settings.size
  admin_username      = var.json.vm_settings.adminuser
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = var.json.vm_settings.adminuser
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = var.json.vm_settings.disk_settings.caching
    storage_account_type = var.json.vm_settings.disk_settings.sa_type
    disk_size_gb         = var.json.vm_settings.disk_settings.disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}
