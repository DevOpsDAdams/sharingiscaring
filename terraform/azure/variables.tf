variable "sg_name" {
  default = "my-security-group"
}

variable "vpc_name" {
  default = "my-vpc"
}

variable "subnet_id" {
  default = "subnet-1"
}

variable "instance_type" {
  default = "c5.xlarge"
}

variable "secret_name"{
  default = "my-secret"
}

variable "instance_name" {
  default = "some_name"
}

variable "number_of_instances" {
  default = "2"
}

variable "volume_type" {
  default = "gp2"
}

variable "iops" {
  default = "1500"
}

variable "volume_size" {
  default = "150"
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

variable "tags" {
  type = map(string)
  default = {
    AppName		   	  = "Linux-EC2"
    AppOwner			  = "You" #Probably
    Backup			    = "Not Yet Assigned"
    BusinessUnit		= "Information Technology"
    CostCenter   		= "NoneAssigned"
    CostAllocation	= "Technology and Infrastructure"
    Description		  = "Automate Linux EC2 Instances Testing"
    Environment	  	= "dev"
    InstanceManager	= "Linux"
    Name			      = "some_name"
    Product		  	  = "Linux EC2 Instance"
  }
}
