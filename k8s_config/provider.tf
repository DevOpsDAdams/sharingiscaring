provider                "aws" {
    region                  = "us-east-1"
}

terraform {
    backend             "s3" {
    bucket  			= "terraform-state-nonprod"
    region      		= "us-east-1"
    key                 = "prep.tfstate"
    }
}
