terraform {
  backend "s3" {
    bucket  			= "terraform-state-prod"
    region      		= "us-east-1"
  }
}
