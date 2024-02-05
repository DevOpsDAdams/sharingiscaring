provider "aws" {
    region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket                      = "par-terraform-state-nonprod"
    region                      = "us-east-1"
    shared_credentials_file     = "$HOME/.aws/credentials"
    profile = "nonprod"
  }
}
