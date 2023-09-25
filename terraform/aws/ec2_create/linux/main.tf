provider "aws" {
  region			= "us-east-1"
}

variable "json" {
  type = any
  description = "Allows the use of the Terraform TFVars JSON document."
}

locals {
  resource_tags = {
    "AppName"		  	= var.json.tags.AppName
    "AppOwner"			= var.json.tags.AppOwner
    "Backup"			= var.json.tags.Backup
    "BusinessUnit"		= var.json.tags.BU
    "CostCenter"    		= var.json.tags.CostCenterCode
    "CostAllocation"		= var.json.tags.CostAllocation
    "Description"		= var.json.tags.Description
    "Environment"	  	= var.json.tags.Environment
    "InstanceManager"		= var.json.tags.InstanceManager
    "Name"			= var.json.tags.Name
    "Product"		  	= var.json.tags.Product
  }
}

data "aws_ami" "ami" {
  most_recent                   = true
  #name_regex       	  	= "*amzn*"
  owners           	  	= ["amazon"]

  filter {
    name                        = "description"
    values                      = ["Amazon Linux * AMI * x86_64 HVM*"]
  }

}
data "aws_security_group" "security_group" {
  name = var.json.shared_settings.sg_name
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [var.json.shared_settings.vpc_name]
  }
}


resource "aws_instance" "ec2_instance" {
  ami           	  	= data.aws_ami.ami.id
  instance_type 	  	= var.json.instance_settings.instance_type
  monitoring 		  	= true
  associate_public_ip_address	= true
  key_name			= "win_test"
  vpc_security_group_ids  	= [data.aws_security_group.security_group.id]
  #iam_instance_profile 	  	= var.json.shared_settings.iam_role
  disable_api_termination 	= false
  subnet_id 		  	= var.json.shared_settings.subnet_id
  tags 			  	= local.resource_tags
  root_block_device  {
    delete_on_termination = false
    volume_type = var.json.instance_settings.volume_type
    volume_size = var.json.instance_settings.volume_size
    #iops = var.json.instance_settings.iops
    encrypted = var.json.instance_settings.encryption

  }

}
