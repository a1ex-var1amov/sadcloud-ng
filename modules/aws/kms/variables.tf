variable "name" {
  description = "Name for KMS key and alias"
  type        = string
  default     = "sadcloud-key"
}

############## Security Misconfigurations ##############

variable "enable_key_rotation" {
  description = "Whether to enable automatic key rotation (disabled for insecurity)"
  type        = bool
  default     = false
}

variable "deletion_window_in_days" {
  description = "Duration in days before the key is deleted (minimum for insecurity)"
  type        = number
  default     = 7
}

variable "allow_public_access" {
  description = "Whether to allow public access to the key through IAM policies"
  type        = bool
  default     = false
}

variable "allow_wildcard_actions" {
  description = "Whether to allow wildcard (*) actions in key policy"
  type        = bool
  default     = false
}

variable "allow_root_access" {
  description = "Whether to allow root account full access"
  type        = bool
  default     = false
}

variable "bypass_policy_lockout_check" {
  description = "Whether to bypass policy lockout safety check"
  type        = bool
  default     = false
}

variable "allow_cross_account_access" {
  description = "Whether to allow cross-account access"
  type        = bool
  default     = false
}

############## Key Configuration ##############

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = "Insecure KMS key for testing"
}

variable "key_usage" {
  description = "Intended use of the key (ENCRYPT_DECRYPT or SIGN_VERIFY)"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

############## Cross Account Access ##############

variable "trusted_account_ids" {
  description = "List of AWS account IDs that can access the key (if cross-account access is enabled)"
  type        = list(string)
  default     = []
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to KMS resources"
  type        = map(string)
  default     = {}
}
