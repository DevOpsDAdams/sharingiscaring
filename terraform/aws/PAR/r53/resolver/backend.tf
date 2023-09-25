terraform {
  backend "s3" {
    bucket  			= "some-bucket"
    region      		= "us-east-1"
  }
}
