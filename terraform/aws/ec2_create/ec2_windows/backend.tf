terraform {
  backend "s3" {
    bucket  			= "terraform-np"
    region      		= "us-east-1"
  }
}
