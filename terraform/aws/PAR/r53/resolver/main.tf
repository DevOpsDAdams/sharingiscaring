provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "<<path/to/credentials/file" # There are better ways of achieving this result.
  profile = "nonprod" # Again, there are better ways of achieving this result
}

locals {
  resource_tags = {
    "DNSTarget"		    	= var.tags["DNSTarget"]
  }
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
    subnet_id = var.subnet_ids[0]
    #ip        = var.endpoint_ip_list[0]
  }

  ip_address {
    subnet_id = var.subnet_ids[1]
    #ip        = var.endpoint_ip_list[1]
  }

  tags = local.resource_tags
}

resource "aws_route53_resolver_rule" "rule" {
  count = length(var.rule_map)
  domain_name          = var.rule_map[count.index].domain_name
  name                 = var.rule_map[count.index].name
  rule_type            = var.rule_map[count.index].rule_type
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id
  target_ip {
    ip = var.rule_map[count.index].ip_list[0]
  }
  target_ip {
    ip = var.rule_map[count.index].ip_list[1]
  }
}
