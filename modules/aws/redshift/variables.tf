variable "name" {
  description = "Name for Redshift cluster resources"
  type        = string
  default     = "sadcloud-redshift"
}

############## Security Misconfigurations ##############

variable "disable_encryption" {
  description = "Whether to disable encryption at rest"
  type        = bool
  default     = false
}

variable "use_weak_password" {
  description = "Whether to use a weak master password"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Whether to make the cluster publicly accessible"
  type        = bool
  default     = false
}

variable "disable_ssl" {
  description = "Whether to disable SSL connections"
  type        = bool
  default     = false
}

variable "disable_audit_logging" {
  description = "Whether to disable audit logging"
  type        = bool
  default     = false
}

variable "disable_automated_snapshots" {
  description = "Whether to disable automated snapshots"
  type        = bool
  default     = false
}

variable "allow_version_upgrade" {
  description = "Whether to allow version upgrade (potential security risk)"
  type        = bool
  default     = false
}

variable "disable_vpc" {
  description = "Whether to launch the cluster outside a VPC (EC2-Classic)"
  type        = bool
  default     = false
}

############## Cluster Configuration ##############

variable "node_type" {
  description = "Node type for the cluster"
  type        = string
  default     = "dc2.large"
}

variable "number_of_nodes" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "sadcloud"
}

variable "master_username" {
  description = "Master username for the cluster"
  type        = string
  default     = "sadcloud"
}

variable "port" {
  description = "Port for the cluster"
  type        = number
  default     = 5439
}

############## Network Configuration ##############

variable "vpc_id" {
  description = "VPC ID where Redshift cluster will be created"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redshift cluster"
  type        = list(string)
  default     = []
}

variable "allow_all_incoming" {
  description = "Whether to allow incoming traffic from all sources"
  type        = bool
  default     = false
}

############## Backup Configuration ##############

variable "automated_snapshot_retention_period" {
  description = "Retention period for automated snapshots in days"
  type        = number
  default     = 1
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sat:04:00-sat:04:30"
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to Redshift resources"
  type        = map(string)
  default     = {}
}

############## Network ##############

variable "main_subnet_id" {
  description = "ID of main subnet"
  default = "default_main_subnet_id"
}

############## Findings ##############

variable "parameter_group_ssl_not_required" {
  description = "allow cleartext connections"
  type        = bool
  default     = false
}

variable "parameter_group_logging_disabled" {
  description = "disable logging"
  type        = bool
  default     = false
}

variable "cluster_publicly_accessible" {
  description = "enable public access to cluster"
  type        = bool
  default     = false
}

variable "cluster_no_version_upgrade" {
  description = "disable automatic version upgrades"
  type        = bool
  default     = false
}

variable "cluster_database_not_encrypted" {
  description = "disable database encryption"
  type        = bool
  default     = false
}
