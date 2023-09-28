locals {
  current_time = timestamp()
  next_year = timeadd(local.current_time, "8784h")
  nic_prefix = "${var.json.common_info.placement_code}${var.json.common_info.location_code}${var.json.common_info.env_code}${var.json.common_info.os_code}"
  azure_cidrs = flatten(regexall("\"(.*)\"", file("./microsoft_cidrs.json")))
  blob_containers = flatten(regexall("\"(.*)\"", file("./blob_containers.txt")))
  resource_tags = {
    "ApplicationName"    = var.json.tags.ApplicationName
    "Automation"         = var.json.tags.Automation
    "LineofBusiness"     = var.json.tags.LineofBusiness
    "CostCenter"         = var.json.tags.CostCenter
    "DataType"           = var.json.tags.DataType
    "DisasterRecovery"   = var.json.tags.DisasterRecovery
    "dxcManaged"         = var.json.tags.dxcManaged
    "dxcMonitored"       = var.json.tags.dxcMonitored
    "dxcPrimarySupport"  = var.json.tags.dxcPrimarySupport
    "Environment"        = var.json.tags.Environment
    "Owner"              = var.json.tags.Owner
  }

  vm_tags = {
    "dxcEPAgent"                = var.json.tags.dxcEPAgent
    "dxcAutoShutdownSchedule"   = var.json.tags.dxcAutoShutdownSchedule
  }
}
