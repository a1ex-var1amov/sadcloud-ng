variable "glacier_public" {
  description = "publicly accessible glacier vault"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name for Glacier vault"
  type        = string
  default     = "sadcloud-vault"
}

############## Security Misconfigurations ##############

variable "disable_access_policy" {
  description = "Whether to disable vault access policy (less secure)"
  type        = bool
  default     = false
}

variable "allow_public_access" {
  description = "Whether to allow public access to the vault through policy"
  type        = bool
  default     = false
}

variable "allow_wildcard_actions" {
  description = "Whether to allow wildcard (*) actions in vault policy"
  type        = bool
  default     = false
}

variable "allow_root_access" {
  description = "Whether to allow root account full access"
  type        = bool
  default     = false
}

variable "disable_mfa_delete" {
  description = "Whether to disable MFA delete requirement"
  type        = bool
  default     = false
}

variable "allow_cross_account_access" {
  description = "Whether to allow cross-account access"
  type        = bool
  default     = false
}

variable "disable_notifications" {
  description = "Whether to disable vault notifications"
  type        = bool
  default     = false
}

############## Vault Configuration ##############

variable "tags" {
  description = "Tags to apply to Glacier resources"
  type        = map(string)
  default     = {}
}

############## Cross Account Access ##############

variable "trusted_account_ids" {
  description = "List of AWS account IDs that can access the vault (if cross-account access is enabled)"
  type        = list(string)
  default     = []
}

############## SNS Notification ##############

variable "sns_topic_arn" {
  description = "SNS topic ARN for vault notifications (if enabled)"
  type        = string
  default     = null
}

variable "notification_events" {
  description = "List of events to trigger notifications"
  type        = list(string)
  default     = ["ArchiveRetrievalCompleted", "InventoryRetrievalCompleted"]
}

############## Lock Configuration ##############

variable "enable_vault_lock" {
  description = "Whether to enable vault lock (more secure when true)"
  type        = bool
  default     = false
}

variable "vault_lock_policy_bypass" {
  description = "Whether to bypass vault lock policy restrictions"
  type        = bool
  default     = false
}

variable "retention_days" {
  description = "Number of days to retain archives (if vault lock enabled)"
  type        = number
  default     = 1  # Minimum retention for insecurity
}
