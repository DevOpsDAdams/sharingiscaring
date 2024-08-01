module "key_vault_key" {
  source = "../modules/key_vault_key/"
  for_each = var.json.key_vault_key_info
  name     = "${each.value.name}-${upper(var.json.common_info.location)}-key"
  key_vault_id = module.key_vault[each.value.key_vault].id
  type = each.value.key_type
  key_size = each.value.size
  key_options = each.value.key_options
  tags = var.json.tags
  rotation_policy = each.value.rotation_policy
  expire_after = each.value.rotation_policy.expire_after
  automatic = each.value.rotation_policy.automatic
  time_after_creation = each.value.rotation_policy.automatic.time_after_creation
  notify_before_expiry = each.value.rotation_policy.notify_before_expiry

  depends_on = [ module.key_vault ]

}
