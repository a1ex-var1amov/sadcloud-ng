variable "name" {
description = "ses name"
  type        = string
  default     = "sadcloud"
}

variable "no_dkim_enabled" {
  description = "disable dkim"
  type        = bool
  default     = false
}

variable "identity_world_policy" {
  description = "Creates an open ses identity policy"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Domain to configure for SES"
  type        = string
  default     = "example.com"
}

variable "skip_verification" {
  description = "Whether to skip domain verification (not recommended)"
  type        = bool
  default     = false
}

variable "disable_dkim" {
  description = "Whether to disable DKIM signing"
  type        = bool
  default     = false
}

variable "disable_spf" {
  description = "Whether to disable SPF records"
  type        = bool
  default     = false
}

variable "allow_unsafe_recipients" {
  description = "Whether to allow sending to unverified recipients in sandbox mode"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Whether to allow public access to send emails"
  type        = bool
  default     = false
}

variable "allow_all_actions" {
  description = "Whether to allow all SES actions in the policy"
  type        = bool
  default     = false
}

variable "disable_tls" {
  description = "Whether to disable TLS for SMTP connections"
  type        = bool
  default     = false
}

############## Email Configuration ##############

variable "from_addresses" {
  description = "List of email addresses to verify for sending"
  type        = list(string)
  default     = []
}

variable "enable_smtp" {
  description = "Whether to create SMTP credentials"
  type        = bool
  default     = false
}

############## Configuration Set ##############

variable "disable_feedback_loop" {
  description = "Whether to disable feedback loop (bounces, complaints)"
  type        = bool
  default     = false
}

variable "disable_open_tracking" {
  description = "Whether to disable open and click tracking"
  type        = bool
  default     = false
}

variable "disable_reputation_metrics" {
  description = "Whether to disable reputation metrics"
  type        = bool
  default     = false
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to SES resources"
  type        = map(string)
  default     = {}
}