resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

data "azurerm_billing_enrollment_account_scope" "billing" {
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

resource "azurerm_subscription" "subscription" {
  alias             = var.alias
  subscription_name = var.subscription_name
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.billing.id
  tags              = var.tags

  timeouts {
    create = "60m"
    delete = "2h"
  }
}
