locals {
  resource_tags = {
    "DNSTarget"		    	= var.tags.DNSTarget
  }
  subnetID = split(",", var.subnet_ids)
  vpcIDs = split(",", var.vpc_ids)
}

data "aws_security_group" "security_group" {
  name = var.sg_name
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name      = var.out_res_name
  direction = "OUTBOUND"
  security_group_ids = [
    data.aws_security_group.security_group.id
  ]
  ip_address {
    subnet_id = local.subnetID[0]
    #ip        = var.endpoint_ip_list[0]
  }
  ip_address {
    subnet_id = local.subnetID[1]
    #ip        = var.endpoint_ip_list[1]
  }
  tags = local.resource_tags
}

module "r53_resolver_rules" {
  count            = length(var.rule_map)
  source           = "./modules/resolver_rules"
  dname            = var.rule_map[count.index].domain_name
  name             = var.rule_map[count.index].name
  ruletype         = var.rule_map[count.index].rule_type
  endpoint_id      = aws_route53_resolver_endpoint.outbound.id
  target_ip_list_0 = var.rule_map[count.index].ip_list[0]
  target_ip_list_1 = var.rule_map[count.index].ip_list[1]
  vpc_ids          = local.vpcIDs
}
