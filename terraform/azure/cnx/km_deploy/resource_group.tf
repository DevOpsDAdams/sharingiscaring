module "resource_group" {
  source = "../modules/resource_group/"
  for_each = var.json.resource_groups
  name     = "${each.value.name}-${upper(var.json.common_info.location)}-rg"
  location = var.json.common_info.location
  tags     = var.json.tags
}
