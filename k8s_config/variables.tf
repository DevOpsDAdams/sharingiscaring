variable "create" {
  description = "Controls if EKS resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment                                       = "NonProd"
    Product                                           = "Platform"
    Organization                                      = "My Awesome Organization"
    Vendor                                            = "None"
  }
}

variable "prefix_separator" {
  description = "The separator to use between the prefix and the generated timestamp for resource names"
  type        = string
  default     = "-"
}

variable "dev_role" {
  description = "The ARN of the Developer Role. "
  type        = string
  default     = "arn:aws:iam::111222333444:role/nonprod-developer"
}

variable "dev_username" {
  description = "The name of the Developer Role. "
  type        = string
  default     = "nonprod-developer"
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cluster-nonprod"
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.21`)"
  type        = string
  default     = 1.21
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster (ENIs) will be provisioned along with the nodes/node groups. Node groups can be deployed within a different set of subnet IDs from within the node group configuration"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

################################################################################
# Cluster Security Group
################################################################################

variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster or use the existing `cluster_security_group_id`"
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "Existing security group ID to be attached to the cluster. Required if `create_cluster_security_group` = `false`"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and its nodes will be provisioned"
  type        = string
  default     = "vpc-id123456"
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created"
  type        = string
  default     = "eks-nonprod-sg"
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "cluster_security_group_description" {
  description = "Description of the cluster security group created"
  type        = string
  default     = "EKS cluster security group"
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created"
  type        = any
  default     = {}
}

variable "cluster_security_group_tags" {
  description = "A map of additional tags to add to the cluster security group created"
  type        = map(string)
  default     = {}
}

################################################################################
# Node Security Group
################################################################################

variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups or use the existing `node_security_group_id`"
  type        = bool
  default     = true
}

variable "node_security_group_id" {
  description = "ID of an existing security group to attach to the node groups created"
  type        = string
  default     = ""
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = "eks-node-nonprod-sg"
}

variable "node_security_group_use_name_prefix" {
  description = "Determines whether node security group name (`node_security_group_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "node_security_group_description" {
  description = "Description of the node security group created"
  type        = string
  default     = "EKS node shared security group"
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created"
  type        = any
  default     = {}
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}

################################################################################
# IRSA
################################################################################

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
  type        = list(string)
  default     = []
}

################################################################################
# Cluster IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = "eks-role"
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# EKS Addons
################################################################################

variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

################################################################################
# EKS Identity Provider
################################################################################

variable "cluster_identity_providers" {
  description = "Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA"
  type        = any
  default     = {}
}

################################################################################
# Fargate
################################################################################

variable "fargate_profiles" {
  description = "Map of Fargate Profile definitions to create"
  type        = any
  default     = {}
}

variable "fargate_profile_defaults" {
  description = "Map of Fargate Profile default configurations"
  type        = any
  default     = {}
}

################################################################################
# Self Managed Node Group
################################################################################

variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions to create"
  type        = any
  default     = {}
}

variable "self_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}

################################################################################
# EKS Managed Node Group
################################################################################

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default     = {}
}


################################################################################
# RDS Variables
################################################################################

variable "RDScount" {
  description = "The Number of Instance Runs to Pass."
  type        = number
  default     = 1
}

variable "minStorage" {
  description = "The Minimum Storage Amount to Scale for RDS Instance."
  type        = number
  default     = 10
}

variable "maxStorage" {
  description = "The Maximum Storage Amount to Scale for RDS Instance."
  type        = number
  default     = 100
}

variable "engine" {
  description = "The Engine Type for RDS Instance."
  type        = string
  default     = "oracle-se2"
}

variable "engineVersion" {
  description = "The Preferred Engine Version for your RDS Instance"
  type        = string
  default     = "19"
}

variable "License_Model" {
  description = "The Required License Model for an Oracle RDS Instance"
  type        = string
  default     = "license-included"
}


variable "instanceClass" {
  description = "The Instance Class to use for RDS."
  type        = string
  default     = "db.t3.medium"
}

variable "allowUpgrade" {
  description = "True/False to allow major version upgrades for your RDS Instances"
  type        = bool
  default     = true
}

variable "applyImmediately" {
  description = "True/False to apply configuration changes immediately"
  type        = bool
  default     = true
}

variable "DBname" {
  description = "The name of your RDS Instance"
  type        = string
  default     = "dbname"
}

variable "DBuser" {
  description = "The username of the administrative user in RDS."
  type        = string
  default     = "aws_rds_admin"
}

variable "skipSnapshot" {
  description = "True/False to skip final snapshot when terminating an instance."
  type        = bool
  default     = true
}

variable "multiAZ" {
  description = "True/False to configure RDS Instance in a MultiAZ."
  type        = bool
  default     = true
}

variable "subnet_group_name" {
  type        = string
  default     = "db-nonprod"
}

################################################################################
# EC2 Variables
################################################################################

variable "EC2tags" {
  description = "A map of tags to apply to EC2 Instances."
  type        = map(string)
  default     = {
    Name                                              = "jumpbox-nonprod"
    Environment                                       = "NonProd"
    Product                                           = "Platform"
    Organization                                      = "My awesome organization"
    Vendor                                            = "None"
  }
}

variable "sg_name" {
  description = "EC2 Security Group to Use."
  type        = string
  default     = "portal-jumpbox"
}

variable "VPCId" {
  description = "VPC ID to Use."
  type        = string
  default     = "vpc-id123456"
}

variable "IPv4_CIDR" {
  description = "List of CIDR Blocks to Use in Security Group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "IPv6_CIDR" {
  description = "List of IPv6 CIDR Blocks to Use in Security Group."
  type        = list(string)
  default     = ["::/0"]
}


variable "iam_role" {
  description = "IAM Role/Profile to Attach to EC2 Instance"
  type        = string
  default     = "None"
}

variable "instance_type" {
  description = "Instance Type of the EC2 Instance"
  type        = string
  default     = "t3.small"
}

variable "monitoring" {
  description = "True/False for Cloudwatch Monitoring Enablement."
  type        = bool
  default     = true
}

variable "has_public_ip" {
  description = "True/False for Determining Public IP"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of the Key Pair to Use for Connecting to the EC2 Instance."
  type        = string
  default     = "ssh-key"
}

variable "IsProtected" {
  description = "True/False to enable Termination Protection for EC2 Instance."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "The Subnet ID to use with the EC2 Instance."
  type        = string
  default     = "subnet-id123456"
}

variable "EBSDelete" {
  description = "True/False for Delete EBS Volume on Termination"
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "The EBS Volume Type for EC2 Instance"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "The EBS Volume Size (in GiB) for the EC2 Instance"
  type        = number
  default     = 50
}

variable "iops" {
  description = "IOPS (if needed) for the io1 or io2 EBS Volume for EC2 Instance"
  type        = number
  default     = 1500
}

variable "encryption" {
  description = "True/False for Encrypting EBS Volume"
  type        = bool
  default     = true
}
