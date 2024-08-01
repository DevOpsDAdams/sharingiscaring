module "service_principal" {
  source   = "../modules/service_principal/"
  for_each = var.json.service_principal_info

  display_name                 = each.value.display_name
  alternative_names            = each.value.alternative_names
  account_enabled              = each.value.account_enabled
  app_role_assignment_required = each.value.app_role_assignment_required
  owners                       = data.current_user.current_user.client_id
  description                  = each.value.description
  tags                         = var.json.tags

  depends_on = [module.resource_group]
}
