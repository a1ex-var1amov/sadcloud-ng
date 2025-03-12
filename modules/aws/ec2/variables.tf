variable "name" {
  description = "Name for EC2 instance and related resources"
  type        = string
  default     = "sadcloud"
}

############## Network ##############

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "main_subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

############## Findings ##############

variable "create_insecure_instance" {
  description = "Whether to create an EC2 instance with security misconfigurations"
  type        = bool
  default     = false
}

variable "use_old_ami" {
  description = "Whether to use an old, potentially vulnerable Ubuntu AMI"
  type        = bool
  default     = false
}

variable "disallowed_instance_type" {
  description = "Whether to use a disallowed instance type"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "Name of SSH key pair to use for the instance"
  type        = string
  default     = null
}

variable "instance_with_user_data_secrets" {
  description = "Whether to include sensitive information in user data"
  type        = bool
  default     = false
}

variable "create_overly_permissive_role" {
  description = "Whether to create an overly permissive IAM role"
  type        = bool
  default     = false
}

variable "security_group_opens_all_ports_to_all" {
  description = "Whether to create a security group that opens all ports to all IPs"
  type        = bool
  default     = false
}

variable "security_group_opens_all_ports_to_self" {
  description = "security group that permits unrestricted network traffic within itself"
  type        = bool
  default     = false
}

variable "security_group_opens_icmp_to_all" {
  description = "ICMP open to all"
  type        = bool
  default     = false
}

variable "security_group_opens_known_port_to_all" {
  description = "Whether to create a security group that opens specific ports to all IPs"
  type        = bool
  default     = false
}

variable "security_group_opens_plaintext_port" {
  description = "Whether to create a security group that opens plaintext ports"
  type        = bool
  default     = false
}

variable "security_group_opens_port_range" {
  description = "use of port ranges"
  type        = bool
  default     = false
}

variable "security_group_opens_port_to_all" {
  description = "port open to all"
  type        = bool
  default     = false
}

variable "security_group_whitelists_aws_ip_from_banned_region" {
  description = "security group whitelists AWS IPs outside the USA"
  type        = bool
  default     = false
}

variable "security_group_whitelists_aws" {
  description = "security group whitelists AWS IPs"
  type        = bool
  default     = false
}

variable "ec2_security_group_whitelists_unknown_cidrs" {
  description = "security group whitelists unknown CIDRs"
  type        = bool
  default     = false
}

variable "ec2_unused_security_group" {
  description = "unused security groups"
  type        = bool
  default     = false
}

variable "ec2_unneeded_security_group" {
  description = "security group cidr cannot be blocked"
  type        = bool
  default     = false
}

variable "ec2_unexpected_security_group" {
  description = "security group cidr oddly formatted"
  type        = bool
  default     = false
}

variable "ec2_overlapping_security_group" {
  description = "security group cidrs overlap"
  type        = bool
  default     = false
}

variable "enable_unsafe_internal_access" {
  description = "Whether to allow unrestricted internal network access"
  type        = bool
  default     = false
}

variable "enable_common_misconfigs" {
  description = "Whether to enable common security group misconfigurations (MySQL, Redis, MongoDB, etc.)"
  type        = bool
  default     = false
}

variable "create_insecure_launch_template" {
  description = "Whether to create a launch template with security misconfigurations"
  type        = bool
  default     = false
}

variable "instance_with_public_ip" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = false
}
