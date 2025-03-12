variable "name" {
  description = "Bucket name prefix"
  type        = string
  default     = "sadcloud"
}

variable "logging_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = "sadcloud-logs"
}

variable "bucket_acl" {
  description = "Canned ACL to apply to the bucket"
  type        = string
  default     = "public-read"  # Dangerous: Makes bucket public
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"  # Could be more secure with KMS
}

variable "allow_cleartext" {
  description = "Allow non-SSL access"
  type        = bool
  default     = false
}

variable "no_default_encryption" {
  description = "Disable default encryption"
  type        = bool
  default     = false
}

variable "no_logging" {
  description = "Disable access logging"
  type        = bool
  default     = false
}

variable "no_versioning" {
  description = "Disable versioning"
  type        = bool
  default     = false
}

variable "website_enabled" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "s3_getobject_only" {
  description = "Allow public GetObject access only"
  type        = bool
  default     = false
}

variable "s3_public" {
  description = "Allow all public access"
  type        = bool
  default     = false
}

variable "enable_public_access" {
  description = "Allow public access to the bucket"
  type        = bool
  default     = false
}

variable "enable_dangerous_policy" {
  description = "Apply overly permissive bucket policy"
  type        = bool
  default     = false
}

variable "enable_unsafe_cors" {
  description = "Enable dangerous CORS configuration"
  type        = bool
  default     = false
}

variable "enable_unsafe_lifecycle" {
  description = "Enable dangerous lifecycle rules"
  type        = bool
  default     = false
}

variable "enable_unsafe_replication" {
  description = "Enable replication with security issues"
  type        = bool
  default     = false
}
