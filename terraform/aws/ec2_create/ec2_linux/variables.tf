##### Adjust These Variables #####

variable "sg_name" {
  default = "my-security-group"
}

variable "vpc_name" {
  default = "vpc"
}

variable "subnet_id" {
  default = "subnet-1"
}

variable "instance_type" {
  default = "c5.xlarge"
}

variable "instance_name" {
  default = "some-name"
}

variable "number_of_instances" {
  default = "1"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "100"
}

variable "iops" {
  default = "1500"
}

variable "tags" {
  type = map(string)
  default = {
    AppName		   	= "The News"
    AppOwner			= "Huey Lewis"
    Automation  = "Terraform"
    Backup			= "{\"Snapshot\":{\"time\":{\"interval\":24},\"retention\":10,\"volumes\":[\"all\"]}}"
    BusinessUnit		= "Information Technology"
    CostCenter   		= "IT Information Technology"
    Description		= "Some long winded description of a server that probably doesn't need to be there but people with ZERO tech experience love seeing these things."
    Environment	  	= "Dev"
    Name			= "some-name"
    Product		  	= "Automation"
  }
}

##### Do Not Modify These Variables #####

variable "secret_name_1"{
  default = "my_secret"
}
variable "secret_name" {
  default = "my_super_secret"
}
variable "volume_encryption" {
  default = "true"
}
variable "domain_join" {
  type = bool
  default = false
}
variable "instance_profile" {
  type = string
  default = "windows-standard-role"
}
