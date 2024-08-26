resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

#Create User Idenity
resource "azurerm_user_assigned_identity" "user_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.user_identity_name
}

#Create CosmosDB Account
resource "azurerm_cosmosdb_account" "db_account" {
  name                = "${var.account_name}-${random_integer.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  default_identity_type = join("=", ["UserAssignedIdentity", azurerm_user_assigned_identity.user_identity.id])
  offer_type          = var.offer_type
  kind                = var.account_kind

  automatic_failover_enabled = var.automatic_failover_enabled

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "EnableServerless"
  }

  capabilities {
    name = "EnableTable"
  }

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  geo_location {
    location          = var.failover_priority_location_2
    failover_priority = 1
  }

  geo_location {
    location          = var.failover_priority_location
    failover_priority = 0
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }

  virtual_network_rule {
    id                = var.vnet_id
    ignore_missing_vnet_service_endpoint = var.ignore_missing_vnet_service_endpoint
  }

  tags = var.tags
}
