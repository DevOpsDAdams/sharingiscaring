variable "pager_duty_integration_url" {
    type  = string
    description  = "URL of the PagerDuty AWS CloudWatch integration endpoint."
}

variable "slack_chatbot_support_info_url" {
    type  = string
    description  = "URL of the AWS CloudWatch integration endpoint."
}

variable "sg_name" {
    type  = string
    description  = "The name of the Security Group being Used for Route53 Resolver."
}

variable "vpc_name" {
    type  = string
    description  = "The name of the VPC to be used with the Security Group"
}
variable "vpc_ids" {
    type  = any
    description  = "The VPC IDs to be Associated with Route53 Resolver."
}
variable "out_res_name" {
    type  = string
    description  = "The name of the Outbound Endpoint Used for Route53 Resolver."
}
variable "subnet_ids" {
    type  = any
    description  = "The IDs of the Subnets being Used for Route53 Resolver."
}

variable "rule_map" {
    type  = any
    description  = "The Rules Mapped To the Route53 Resolver Endpoint."
}

variable "tags" {
    type  = any
    description  = "Tags to be applied to resources."
}
