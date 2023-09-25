provider "aws" {
  region = "us-east-1"
}

variable "json" {
  type = any
  description = "Allows the use of the Terraform TFVars JSON document."
}

locals {
  resource_tags = {
    "AppName"		  	= var.json.tags.AppName
    "Description"		= var.json.tags.Description
    "Environment"	  	= var.json.tags.Environment
  }
}

data "aws_acm_certificate" "userdomain" {
  domain      = "*.userdomain.com"
  types       = ["AMAZON_ISSUED"]
}
resource "aws_lb" "alb" {
  name               = lower("${var.json.alb_settings.name}-${var.json.deployenv}-alb")
  internal           = true
  load_balancer_type = "application"
  subnets            = var.json.shared_settings.subnet_ids
  idle_timeout       = "300"

  access_logs {
    bucket  = "domain-logs"
    prefix  = "${var.json.alb_settings.name}-${var.json.deployenv}-alb"
    enabled = true
  }

  tags = local.resource_tags
}

resource "aws_lb_listener" "listener-443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-2018-06"
  certificate_arn   = data.aws_acm_certificate.userdomain.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}
resource "aws_lb_listener" "listener-80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}


resource "aws_lb_target_group" "aix-targets" {
  name     = "${var.json.alb_settings.name}-aix-${var.path-list[count.index]}"
  port     = 9091
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  tags = local.common_tags
  deregistration_delay = 180
  count = length(var.path-list)
}

resource "aws_lb_listener_rule" "rules-443" {
  listener_arn = aws_lb_listener.listener-443.arn
  condition {
    path_pattern {
      values = ["/${var.path-list[count.index]}/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aix-targets[count.index].arn
  }
  count = length(var.path-list)
}
resource "aws_lb_listener_rule" "rules-80" {
  listener_arn = aws_lb_listener.listener-80.arn
  condition {
    path_pattern {
      values = ["/${var.path-list[count.index]}/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aix-targets[count.index].arn
  }
  count = length(var.path-list)
}
resource "aws_lb_target_group_attachment" "aix-soap" {
  target_group_arn = aws_lb_target_group.aix-targets[0].arn
  target_id        = var.target_ip
  port             = var.port-list-soap[count.index]
  availability_zone = "all"
  count = length(var.port-list-soap)
}
resource "aws_lb_target_group_attachment" "aix-soapout" {
  target_group_arn = aws_lb_target_group.aix-targets[1].arn
  target_id        = var.target_ip
  port             = var.port-list-soapout[count.index]
  availability_zone = "all"
  count = length(var.port-list-soapout)
}
resource "aws_lb_target_group_attachment" "aix-soapedm" {
  target_group_arn = aws_lb_target_group.aix-targets[2].arn
  target_id        = var.target_ip
  port             = var.port-list-soapedm[count.index]
  availability_zone = "all"
  count = length(var.port-list-soapedm)
}
resource "aws_lb_target_group_attachment" "aix-soapedmout" {
  target_group_arn = aws_lb_target_group.aix-targets[3].arn
  target_id        = var.target_ip
  port             = var.port-list-soapedmout[count.index]
  availability_zone = "all"
  count = length(var.port-list-soapedmout)
}
