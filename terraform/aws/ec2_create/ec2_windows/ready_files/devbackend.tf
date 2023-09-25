terraform {
  backend "s3" {
    bucket  			= "terraform-state-np"
    region      		= "us-east-1"
  }
}
