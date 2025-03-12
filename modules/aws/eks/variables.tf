variable "name" {
  description = "Name for EKS cluster and related resources"
  type        = string
  default     = "sadcloud-eks"
}

############## Cluster Configuration ##############

variable "out_of_date" {
  description = "Whether to use an outdated Kubernetes version"
  type        = bool
  default     = false
}

variable "no_logs" {
  description = "Whether to disable cluster logging"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether to make the EKS API endpoint publicly accessible"
  type        = bool
  default     = false
}

variable "globally_accessible" {
  description = "Whether to allow access to the EKS API endpoint from any IP"
  type        = bool
  default     = false
}

variable "disable_encryption" {
  description = "Whether to disable envelope encryption for secrets"
  type        = bool
  default     = false
}

variable "disable_security_groups" {
  description = "Whether to use overly permissive security groups"
  type        = bool
  default     = false
}

variable "disable_network_policy" {
  description = "Whether to disable Kubernetes network policies"
  type        = bool
  default     = false
}

variable "create_public_nodegroup" {
  description = "Whether to create node groups in public subnets"
  type        = bool
  default     = false
}

variable "disable_imds_v2" {
  description = "Whether to disable IMDSv2 requirement on nodes"
  type        = bool
  default     = false
}

variable "overly_permissive_role" {
  description = "Whether to create overly permissive IAM roles"
  type        = bool
  default     = false
}

variable "disable_control_plane_logging" {
  description = "Whether to disable control plane logging components"
  type        = bool
  default     = false
}

############## Network ##############

variable "vpc_id" {
  description = "VPC ID where EKS resources will be created"
  type        = string
}

variable "main_subnet_id" {
  description = "Primary subnet ID for EKS cluster"
  type        = string
}

variable "secondary_subnet_id" {
  description = "Secondary subnet ID for EKS cluster"
  type        = string
}

variable "allow_public_access" {
  description = "Whether to allow public access to the cluster endpoint"
  type        = bool
  default     = false
}

############## Node Configuration ##############

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "disable_node_updates" {
  description = "Whether to disable automatic node updates"
  type        = bool
  default     = false
}

variable "allow_root_access" {
  description = "Whether to allow root access on worker nodes"
  type        = bool
  default     = false
}

variable "disable_node_security" {
  description = "Whether to disable security features on worker nodes"
  type        = bool
  default     = false
}
