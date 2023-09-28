data "external" "admin_pass" {
  program = ["python3", "${path.module}/pass_gen.py", "${var.keyvault_name}", "${var.admin_secret}"]
}

locals {
  should_create_availability_set  = var.enabled && var.availability_set_enabled && !var.availability_set_exists
  should_create_network_interface = var.enabled && var.network_interface_enabled && !var.network_interface_exists && var.vm_count > 0
}

# Discover Password from Keyvault if it exists.
# If it doesn't, create a password.

# Network Interface


resource "azurerm_network_interface" "this" {
  name                = var.network_interface_names
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  enable_accelerated_networking = var.network_acceleration_enabled



  ip_configuration {
    name                          = var.network_interface_ip_configuration_names
    primary                       = var.network_interface_ip_configuration_primary
    public_ip_address_id          = var.network_interface_ip_configuration_public_ip_address_ids
    subnet_id                     = var.network_interface_ip_configuration_subnet_ids
    private_ip_address            = var.network_interface_ip_configuration_private_ip_addresses
    private_ip_address_allocation = var.network_interface_ip_configuration_private_ip_address_allocations
    private_ip_address_version    = var.network_interface_ip_configuration_private_ip_address_versions
  }

  tags = merge(
    var.tags,
    var.network_interface_tags,
  )
  timeouts {
    create = "2h"
    delete = "2h"
  }
}

resource "azurerm_disk_encryption_set" "diskencryptionkey" {
  name                      = "${var.vm_names}-DiskEncryptionKey"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  key_vault_key_id          = var.keyvault_encryption_key_id
  auto_key_rotation_enabled = false
  encryption_type           = "EncryptionAtRestWithCustomerKey"
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "diskencryptionkey_permissions" {
  key_vault_id = var.key_vault_id
  tenant_id = azurerm_disk_encryption_set.diskencryptionkey.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.diskencryptionkey.identity.0.principal_id
  key_permissions = var.key_permissions
  depends_on = [
    azurerm_disk_encryption_set.diskencryptionkey
  ]
}


# Windows virtual machine


resource "azurerm_windows_virtual_machine" "this" {
  name                = var.vm_names
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = data.external.admin_pass.result["Password"]
  enable_automatic_updates = var.automatic_updates
  source_image_id    = var.source_image_id
  provision_vm_agent = var.provision_vm_agent
  allow_extension_operations = var.allow_extension_operations
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]
  additional_capabilities {
    ultra_ssd_enabled = var.additional_capabilities_ultra_ssd_enabled
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  plan {
    name = var.plan_name
    publisher = var.plan_publisher
    product = var.plan_product
  }
  dynamic "os_disk" {
    for_each = var.os_disk_caching != "" ? [1] : []

    content {
      name                      = "${var.vm_names}-OSDisk"
      caching                   = var.os_disk_caching
      storage_account_type      = var.os_disk_storage_account_type
      disk_encryption_set_id    = azurerm_disk_encryption_set.diskencryptionkey.id
      disk_size_gb              = var.os_disk_size_gb
      write_accelerator_enabled = var.os_disk_storage_account_type == "Premium_LRS" && var.os_disk_caching == "None" ? true : false

      dynamic "diff_disk_settings" {
        for_each = var.diff_disk_settings_option != "" ? [1] : []

        content {
          option = var.diff_disk_settings_option
        }
      }
    }

  }

  custom_data = filebase64("${path.module}/disableoldtlsandciphers.ps1")

  tags = merge(
    var.tags,
    var.vm_tags
  )

  depends_on = [
    azurerm_key_vault_access_policy.diskencryptionkey_permissions
  ]

  lifecycle {
    ignore_changes = [admin_password,
    source_image_id
    ]
  }

  timeouts {
    create = "2h"
    delete = "2h"
  }
}

# Store Admin Password in Key Vault

data "azurerm_key_vault" "store_pass" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}

resource "azurerm_key_vault_secret" "store_pass" {
  name         = var.admin_secret
  value        = data.external.admin_pass.result["Password"]
  key_vault_id = data.azurerm_key_vault.store_pass.id
  content_type = var.network_interface_ip_configuration_private_ip_addresses
  expiration_date = var.next_year
  tags         = var.tags

  lifecycle {
    ignore_changes = [
      value,
      expiration_date,
      id,
      key_vault_id
    ]
  }
}

# Managed Disks


resource "azurerm_managed_disk" "this" {
  count = var.managed_disk_count

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name                 = var.num_suffix_digits > 0 ? format("%s%0${var.num_suffix_digits}d", element(var.managed_disk_names, floor(count.index / var.vm_count) % var.managed_disk_count), count.index) : element(var.managed_disk_names, count.index)
  storage_account_type = element(var.managed_disk_storage_account_types, floor(count.index / var.vm_count) % var.managed_disk_count)
  disk_size_gb         = element(var.managed_disk_size_gbs, floor(count.index / var.vm_count) % var.managed_disk_count)
  disk_encryption_set_id = azurerm_disk_encryption_set.diskencryptionkey.id
  zone                = var.managed_disk_zones

  create_option = element(var.managed_disk_create_options, floor(count.index / var.vm_count) % var.managed_disk_count)

  image_reference_id = element(var.managed_disk_create_options, floor(count.index / var.vm_count) % var.managed_disk_count) == "FromImage" ? element(var.managed_disk_image_reference_ids, floor(count.index / var.vm_count) % var.managed_disk_count) : null
  source_resource_id = element(var.managed_disk_create_options, floor(count.index / var.vm_count) % var.managed_disk_count) == "Copy" ? element(var.managed_disk_source_resource_ids, floor(count.index / var.vm_count) % var.managed_disk_count) : null
  source_uri         = element(var.managed_disk_create_options, floor(count.index / var.vm_count) % var.managed_disk_count) == "Import" ? element(var.managed_disk_source_uris, floor(count.index / var.vm_count) % var.managed_disk_count) : null

  os_type = element(var.managed_disk_os_types, floor(count.index / var.vm_count) % var.managed_disk_count)

  dynamic "encryption_settings" {
    for_each = var.disk_encryption_enabled == false && var.managed_disk_encryption_settings_enabled != "" ? [1] : []

    content {
      enabled = var.managed_disk_encryption_settings_enabled

      dynamic "disk_encryption_key" {
        for_each = var.managed_disk_encryption_key_secret_url != "" ? [1] : []

        content {
          secret_url      = element(var.managed_disk_encryption_key_secret_url, count.index)
          source_vault_id = var.managed_disk_encryption_key_source_vault_id
        }
      }

      dynamic "key_encryption_key" {
        for_each = var.managed_disk_key_encryption_key_source_valut_id != "" ? [1] : []

        content {
          key_url         = var.managed_disk_key_encryption_key_key_url
          source_vault_id = var.managed_disk_key_encryption_key_source_valut_id
        }
      }
    }
  }

  tags = merge(
    var.tags,
    var.managed_disk_tags
  )
  depends_on = [
    azurerm_windows_virtual_machine.this
  ]
  timeouts {
    create = "2h"
    delete = "2h"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count = var.enabled && var.disk_attach_enabled && var.vm_count  > 0 ? var.managed_disk_count * var.vm_count : 0

  managed_disk_id    = var.disk_recovered_from_backup ? data.azurerm_managed_disk.this.*.id[count.index] : azurerm_managed_disk.this.*.id[count.index]
  virtual_machine_id = azurerm_windows_virtual_machine.this.id

  lun                       = element(var.managed_disk_lun, count.index) == null ? count.index : element(var.managed_disk_lun, count.index)
  caching                   = element(var.managed_data_disk_cachings, floor(count.index / var.vm_count) % var.managed_disk_count)
  create_option             = element(var.managed_data_disk_create_options, floor(count.index / var.vm_count) % var.managed_disk_count)
  write_accelerator_enabled = element(var.managed_data_disk_write_accelerator_enableds, floor(count.index / var.vm_count) % var.managed_disk_count)
  timeouts {
    create = "2h"
    delete = "2h"
  }
  depends_on = [
  azurerm_managed_disk.this
  ]
}



# Monitoring


resource "azurerm_backup_protected_vm" "this" {
  resource_group_name = var.recovery_vault_rg
  recovery_vault_name = var.recovery_vault_name
  source_vm_id        = azurerm_windows_virtual_machine.this.id
  backup_policy_id    = var.backup_policy_id
  timeouts {
    create = "30m"
    delete = "30m"
  }
}


resource "azurerm_monitor_activity_log_alert" "resourcehealth" {
  name                =  "${var.vm_names}-ResourceHealth"
  description         =  "${var.vm_names}-ResourceHealthAlert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_windows_virtual_machine.this.id]
  criteria {
    resource_id    = azurerm_windows_virtual_machine.this.id
    operation_name = "Microsoft.Resourcehealth/healthevent/Activated/action"
    category       = "ResourceHealth"
  }

  action {
    action_group_id = var.action_group_id
  }
  tags = var.tags

  lifecycle {
    ignore_changes = [action
    ]
  }
}
