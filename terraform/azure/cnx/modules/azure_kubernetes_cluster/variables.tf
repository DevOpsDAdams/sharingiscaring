variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "location" {
  description = "The location of the resource group in which to create the AKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix specified when creating the AKS cluster."
  type        = string
}

variable "default_node_pool_name" {
  description = "The name of the default node pool."
  type        = string
}

variable "default_node_pool_count" {
  description = "The number of nodes in the default node pool."
  type        = number
}

variable "default_node_pool_vm_size" {
  description = "The VM size of the default node pool."
  type        = string
}

variable "identity_type" {
  description = "The type of identity to use for the AKS cluster."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}
