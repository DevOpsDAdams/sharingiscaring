module "subscription" {
  source = "../modules/subscription/"
  for_each = var.json.subscription_info
  alias = each.value.alias
  subscription_name = each.value.name
  billing_account_name = var.json.billing_info.billing_account_name
  enrollment_account_name = var.json.billing_info.enrollment_account_name
}
