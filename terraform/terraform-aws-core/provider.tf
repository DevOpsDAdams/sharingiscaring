provider                "aws" {
    region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "<<your_bucket_name>>"
    region = "us-east-1"
    shared_credentials_file = "path/to/credentials" #this may not be necessary. There are better ways of doing this.
    profile = "Production" #this is the designation of the profile in your Credentials and Config file. There are better ways of doing this.
  }
}
