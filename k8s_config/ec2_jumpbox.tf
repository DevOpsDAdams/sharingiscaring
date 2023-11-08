data "aws_ami" "ami" {
  most_recent           = true
  owners           	  	= ["amazon"]

  filter {
    name                = "description"
    values              = ["Amazon Linux * AMI * x86_64 HVM*"]
  }

}

resource "aws_security_group" "portal" {
  name        = var.sg_name
  description = "Allow Public and Private SSH into Bastion Host"
  vpc_id      = var.VPCId

  ingress {
    description      = "SSH from Public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.IPv4_CIDR
    ipv6_cidr_blocks = var.IPv6_CIDR
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "RDS Traffic"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    self             = true
  }

  tags = var.tags
}

module "ec2" {
  source              = "./modules/ec2"
  ami_id        	  	= data.aws_ami.ami.id
  instance_type 	  	= var.instance_type
  IsMonitored  		  	= var.monitoring
  HasPublicIP     	  = var.has_public_ip
  KeyName             = var.key_name
  security_group_ids  = [aws_security_group.portal.id]
  instance_profile 	 	= var.iam_role
  term_protection 	  = var.IsProtected
  subnetID 		  	    = var.subnet_id
  resource_tags	      = var.EC2tags
  ebs_delete          = var.EBSDelete
  volumeType          = var.volume_type
  volumeSize          = var.volume_size
  IOPS                = var.iops
  IsEncrypted         = var.encryption
}
