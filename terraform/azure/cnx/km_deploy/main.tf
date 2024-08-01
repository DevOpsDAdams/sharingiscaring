variable "json" {
  type        = any
  description = "Allows the use of the Terraform TFVars JSON document."
}
resource "random_string" "suffix" {
  length  = 2
  special = false
  upper   = false
  numeric = true
}
