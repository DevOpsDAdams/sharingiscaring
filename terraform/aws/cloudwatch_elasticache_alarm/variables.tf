variable "redis_cluster_ids" {
    type                                = list(string)
    description                         = "List of Redis Elasticache Cluster IDs to monitor."
    default = [ "value" ]
}

variable "sns_topic" {
    type                                = string
    description                         = "The SNS Topic Name to use for data sources."
    default = "Some SNS Topic Name"
}

variable "tags" {
  type = map(string)
  default = {
    AppName		   	  = "SomeAppName"
    AppOwner		  = "Some Owner"
    Backup			  = "Backup Required"
    BusinessUnit	  = "Information Technology"
    CostCenter   	  = "NoneAssigned"
    CostCenter	      = "Some CostCenter"
    Description		  = "Metrics Alarm for Redis Elasticache Cluster"
    Environment	  	  = "NPE"
  }
}
