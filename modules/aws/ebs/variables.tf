variable "name" {
  description = "Name for EBS resources"
  type        = string
  default     = "sadcloud-ebs"
}

variable "ebs_default_encryption_disabled" {
  description = "Whether to disable default EBS encryption for the entire region"
  type        = bool
  default     = false
}

variable "ebs_volume_unencrypted" {
  description = "Whether to create an unencrypted EBS volume"
  type        = bool
  default     = false
}

variable "ebs_snapshot_unencrypted" {
  description = "Whether to create an unencrypted EBS snapshot"
  type        = bool
  default     = false
}

variable "create_oversized_volume" {
  description = "Whether to create an oversized EBS volume"
  type        = bool
  default     = false
}

variable "create_gp2_volume" {
  description = "Whether to create a gp2 volume instead of gp3 (less performant and more expensive)"
  type        = bool
  default     = false
}

variable "create_public_snapshot" {
  description = "Whether to create a public EBS snapshot"
  type        = bool
  default     = false
}

variable "disable_delete_on_termination" {
  description = "Whether to disable delete on termination for EBS volumes"
  type        = bool
  default     = false
}

variable "create_unused_volume" {
  description = "Whether to create an unused EBS volume"
  type        = bool
  default     = false
}

variable "create_untagged_volume" {
  description = "Whether to create an EBS volume without proper tags"
  type        = bool
  default     = false
}

variable "create_misconfigured_iops" {
  description = "Whether to create a volume with misconfigured IOPS (too high or too low)"
  type        = bool
  default     = false
}

variable "create_volume_without_backup" {
  description = "Whether to create a volume without backup enabled"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone where EBS volumes will be created"
  type        = string
  default     = "us-east-1a"
}
