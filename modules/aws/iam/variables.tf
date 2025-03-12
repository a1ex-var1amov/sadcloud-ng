variable "name" {
  description = "iam name"
  type        = string
  default     = "sadcloud"
}

variable "pgp_key" {
  description = "Base-64 encoded PGP public key for encrypting user credentials"
  type        = string
  default     = "keybase:test"  # WARNING: This is for testing only!
}

# Dangerous user creation variables
variable "create_dangerous_user" {
  description = "Whether to create a user with dangerous permissions"
  type        = bool
  default     = false
}

variable "create_dangerous_role" {
  description = "Whether to create a role with dangerous trust relationships"
  type        = bool
  default     = false
}

variable "create_dangerous_group" {
  description = "Whether to create a group with dangerous permissions"
  type        = bool
  default     = false
}

variable "create_user_with_hardcoded_creds" {
  description = "Whether to create a user with hardcoded credentials (dangerous!)"
  type        = bool
  default     = false
}

############## Findings ##############

variable "password_policy_minimum_length" {
  description = "insufficient minumum length"
  type        = bool
  default     = false
}

variable "password_policy_no_lowercase_required" {
  description = "no lowercase char requirement"
  type        = bool
  default     = false
}

variable "password_policy_no_numbers_required" {
  description = "no number requirement"
  type        = bool
  default     = false
}


variable "password_policy_no_uppercase_required" {
  description = "no uppercase char requirement"
  type        = bool
  default     = false
}

variable "password_policy_no_symbol_required" {
  description = "no symbol char requirement"
  type        = bool
  default     = false
}

variable "password_policy_reuse_enabled" {
  description = "no password reuse prevention"
  type        = bool
  default     = false
}

variable "password_policy_expiration_threshold" {
  description = "too long password expiration threshold"
  type        = bool
  default     = false
}

variable "managed_allows_passrole" {
  description = "Managed policy allows iam:PassRole *"
  type        = bool
  default     = false
}

variable "inline_role_policy" {
  description = "all 3 inline role policy findings"
  type        = bool
  default     = false
}

variable "inline_group_policy" {
  description = "all 3 inline group policy findings"
  type        = bool
  default     = false
}

variable "inline_user_policy" {
  description = "all 3 inline user policy findings"
  type        = bool
  default     = false
}

variable "assume_role_policy_allows_all" {
  description = "AssumeRole policy allows all principals"
  type        = bool
  default     = false
}

variable "assume_role_no_mfa" {
  description = "Cross-account AssumeRole policy lacks external ID and MFA"
  type        = bool
  default     = false
}

variable "admin_iam_policy" {
  description = "IAM policy allows full (*:*) administrative privileges"
  type        = bool
  default     = false
}

variable "admin_not_indicated_policy" {
  description = "IAM policy allows full (*:*) administrative privileges, no admin in name"
  type        = bool
  default     = false
}
