resource "random_string" "sa_suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "azuread_application" "azure_app" {
  display_name = var.display_name
  owners       = var.owners
}

resource "azuread_service_principal" "service_principal" {
  alternative_names            = var.alternative_names
  client_id                    = azuread_application.azure_app.client_id
  account_enabled              = var.account_enabled
  app_role_assignment_required = var.app_role_assignment_required
  owners                       = var.owners
  description                  = var.description
  tags                         = var.tags
}
