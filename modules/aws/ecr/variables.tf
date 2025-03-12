variable "name" {
  description = "Name for ECR repository"
  type        = string
  default     = "sadcloud-ecr"
}

variable "ecr_scanning_disabled" {
  description = "Whether to disable image scanning on push"
  type        = bool
  default     = false
}

variable "ecr_repo_public" {
  description = "Whether to make the ECR repository public"
  type        = bool
  default     = false
}

variable "enable_mutable_tags" {
  description = "Whether to allow mutable image tags"
  type        = bool
  default     = false
}

variable "disable_tag_immutability" {
  description = "Whether to disable tag immutability rules"
  type        = bool
  default     = false
}

variable "create_overly_permissive_policy" {
  description = "Whether to create an overly permissive repository policy"
  type        = bool
  default     = false
}

variable "disable_encryption" {
  description = "Whether to disable encryption at rest"
  type        = bool
  default     = false
}

variable "create_lifecycle_policy" {
  description = "Whether to create a misconfigured lifecycle policy"
  type        = bool
  default     = false
}

variable "disable_vulnerability_scanning" {
  description = "Whether to disable enhanced vulnerability scanning"
  type        = bool
  default     = false
}

variable "allow_untagged_images" {
  description = "Whether to allow untagged images"
  type        = bool
  default     = false
}

variable "disable_cross_region_replication" {
  description = "Whether to disable cross-region replication"
  type        = bool
  default     = false
}

variable "create_public_pull_policy" {
  description = "Whether to create a policy allowing public pull access"
  type        = bool
  default     = false
}
