module "cosmos_db_sql" {
    source = "../../modules/cosmos_database_sql"
    for_each = var.json.database_info.cosmos_db_sql

# Azure CosmosDB Account Information
    user_identity_name = each.user_identity_name
    location = var.json.common_info.location
    resource_group_name = module.resource_group.main.resource_group_name
    offer_type = each.offer_type
    account_kind = each.account_kind
    automatic_failover_enabled = each.automatic_failover_enabled
    failover_priority_location = each.failover_priority_location
    failover_priority_location_2 = each.failover_priority_location_2
    consistency_level = each.consistency_level
    max_interval_in_seconds = each.max_interval_in_seconds # set to Null if consistency_level is not BoundedStaleness
    max_staleness_prefix = each.max_staleness_prefix # set to Null if consistency_level is not BoundedStaleness
    vnet_id = module.vnet.main.vnet_id
    ignore_missing_vnet_service_endpoint = each.ignore_missing_vnet_service_endpoint
    tags = var.tags

# Azure CosmosDB SQL Database Information
}
