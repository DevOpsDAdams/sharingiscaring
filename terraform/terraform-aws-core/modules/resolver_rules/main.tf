resource "aws_route53_resolver_rule" "rule" {
  domain_name          = var.dname
  name                 = var.name
  rule_type            = var.ruletype
  resolver_endpoint_id = var.endpoint_id
  target_ip {
    ip = var.target_ip_list_0
  }
  target_ip {
    ip = var.target_ip_list_1
  }
}

resource "aws_route53_resolver_rule_association" "association" {
  count            = length(var.vpc_ids)
  resolver_rule_id = aws_route53_resolver_rule.rule.id
  vpc_id           = var.vpc_ids[count.index]
}
