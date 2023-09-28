variable "nic" {
  description = "The NIC Name Prefix used for allocating targets for the App Gateway."
  default     = "nic"
}

variable "agw_name" {
  description = "Name of the Application Gateway."
  default     = "agw_default"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources in this module. Changing this forces a new resource to be created."
  default     = ""
}

variable "location" {
  description = "Location of the Resources Being Deployed."
  default     = {}
}

variable "ascale_min" {
  description = "The minimum number of virtual machines in the scaler."
  default     = 1
}

variable "ascale_max"{
  description = "The maximum number of virtual machines in the scaler."
  default = 2
}

variable "sku_name"{
  description = "The Name of the SKU Class used with the App Gateway"
  default = "Standard_Small"
}

variable "sku_tier"{
  description = "The Name of the SKU Tier used with the App Gateway."
  default = "Standard"
}

variable "sku_capacity"{
  description = "The Capacity of your SKU. 1-32 for Standard and 1-125 for a V2 SKU."
  default = "Standard"
}

variable "subnet_id" {
  description = "The Subnet ID to use with the App Gateway"
  default     = ""
}

variable "frontend_port" {
  description = "The port number to be used on the frontend of the App Gateway"
  default     = 80
}

variable "fipc_ip_address" {
  description = "The IP Address to Assign to the App Gateway Frontend."
  default     = null
}

variable "ip_allocation" {
  description = "The Allocation Type for the App Gateway"
  default     = "Dynamic"
}

variable "ip_address_list" {
  description = "A List of IP Addresses to use for the App Gateway targets."
  default     = [""]
}

variable "backend_port"{
  description = "The Port to use for the Backend of the App Gateway"
  default = 8000
}

variable "listener_protocol"{
  description = "Which Protocol to use for the App Gateway"
  default = "Http"
}

variable "frontend_port_name"{
  description = "The name of the Frontend Port."
  default = ""
}

variable "fipc_name" {
  description = "The name of the Frontend IP Configuration."
  default     = ""
}

variable "bep_name" {
  description = "The name of the Backend Address Pool."
  default     = ""
}

variable "bep_http_name" {
  description = "The Backend Address Pool HTTP Settings Name."
  default     = ""
}

variable "listener_name"{
  description = "The name of the HTTP Listener"
  default = ""
}

variable "routing_rule_name"{
  description = "The name of the routing rule to be used with the App Gateway."
  default = ""
}

variable "gateway_ipc_name"{
  description = "The name of the Gateway IP Configuration to be used with the App Gateway."
  default = ""
}

variable "resource_tags"{
  description = "The tags to be used with."
  default = ""
}

variable "policy_name" {
  default = "AppGwSslPolicy20170401S"
}
