variable "sg_name" {
    type = string
    default = "resource-group-name"
}

variable "vpc_name" {
    type = string
    default = "vpc-name"
}

variable "out_res_name" {
    type = string
    default = "outbound_resolver_name"
}

variable "subnet_ids" {
    type = list
    default = ["subnet-1", "subnet-2"]
}

variable "endpoint_ip_list" {
    type = list
    default = ["192.168.0.1", "192.168.0.12"]
}


variable "tags" {
    type = map
    default = {
        DNSTarget = "OnPrem"
    }
}

variable "rule_map" {
    default = [
        {
          "name": "mydomain",
          "domain_name": "mydomain.net",
          "rule_type": "FORWARD",
          "ip_list": ["192.168.0.11", "192.168.0.12"]
        },
        {
          "name": "myotherdomain",
          "domain_name": "mydomain.com",
          "rule_type": "FORWARD",
          "ip_list": ["192.168.0.1", "192.168.0.2"]
        }
    ]
}
