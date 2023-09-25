resource "aws_security_group" "security_group" {
  name        = "EC2_Windows_${var.json.environment_name}_SG"
  description = "Security Group for Dev Windows Instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "sgrules" {
  count             = length(var.json.sgrule_settings)
  type              = var.json.sgrule_settings[count.index].type
  from_port         = var.json.sgrule_settings[count.index].from
  to_port           = var.json.sgrule_settings[count.index].to
  protocol          = var.json.sgrule_settings[count.index].protocol
  cidr_blocks       = var.json.sgrule_settings[count.index].cidr_blocks
  desription        = var.json.sgrule_settings[count.index].description
  security_group_id = aws.aws_security_group.security_group.id
}
