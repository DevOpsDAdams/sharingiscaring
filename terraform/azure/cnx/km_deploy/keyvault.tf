module "keyvault" {
  source = "../modules/keyvault/"
  for_each = var.json.keyvaults
  name     = each.value.name
  location = var.json.common_info.location
  tags     = var.json.tags
  resource_group_name = module.resource_group[each.value.resource_group].name
}
