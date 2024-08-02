module "subnets" {
  source                                                            = "../modules/subnet/"
  for_each                                                          = var.json.networking_info.subnet

  subnet_name                                                       = "${each.value.name}-${var.json.common_info.env_short}-${var.json.common_info.location}-subnet"
  resource_group_name                                               = module.resource_group.networking.resource_group_name
  vnet_name                                                         = module.vnet.name
  address_prefixes                                                  = each.value.address_prefixes
  service_endpoints                                                 = each.value.service_endpoints

  # Delegation Service Information
  delegation_name                                                   = each.value.delegation_name
  delegation_service_name                                           = each.value.delegation_service_name
  delegation_service_actions                                        = each.value.delegation_service_actions

  depends_on                                                        = [module.resource_group.networking, module.vnet]
}
