resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "azurerm_key_vault_key" "key_vault_key" {
  name         = var.name
  key_vault_id = var.key_vault_id
  key_type     = var.type
  key_size     = var.key_size
  key_opts     = var.key_options

  dynamic "rotation_policy" {
    for_each = var.rotation_policy == null ? [] : [var.rotation_policy]

    content {
      expire_after    = var.expire_after
      automatic {
        time_after_creation = var.time_after_creation
      }
      notify_before_expiry = var.notify_before_expiry
    }
  }

  lifecycle {
    ignore_changes = [
      rotation_policy,
      secret,
      x509_certificate,
    ]
  }

  tags         = var.tags
}
