terraform {
  backend "gcs" {
    bucket = "gcp-bucket"
    prefix = "testing.tfstate"
  }
}
