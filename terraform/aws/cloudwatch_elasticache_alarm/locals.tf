locals {
  resource_tags = {
    "AppName"		    	= var.tags["AppName"]
    "AppOwner"			  = var.tags["AppOwner"]
    "Backup"			    = var.tags["Backup"]
    "BusinessUnit"		= var.tags["BusinessUnit"]
    "CostCenter"   		= var.tags["CostCenter"]
    "CostAllocation"	= var.tags["CostAllocation"]
    "Description"		  = var.tags["Description"]
    "Environment"	  	= var.tags["Environment"]
  }
}
