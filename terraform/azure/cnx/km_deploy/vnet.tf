 module "vnet" {
   source = "../../modules/virtual_network"
   for_each = var.json.networking_info.vnet
   name = each.value.name
   location = var.json.common_info.location
   resource_group_name = module.resource_group.networking.name
   address_space = each.value.address_space
   tags = var.json.tags

   depends_on = [
     module.resource_group
   ]
 }
