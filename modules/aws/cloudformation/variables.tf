variable "name" {
  description = "Stack name"
  type        = string
  default     = "sadcloud-s3-stack"
}

variable "stack_with_role" {
  description = "Whether to attach an overly permissive IAM role to the stack"
  type        = bool
  default     = false
}

variable "stack_with_secret_output" {
  description = "Whether to create a stack with sensitive information in outputs"
  type        = bool
  default     = false
}

variable "enable_direct_updates" {
  description = "Whether to enable direct stack updates without change sets"
  type        = bool
  default     = false
}

variable "secret_key" {
  description = "Secret key to expose in stack outputs (DO NOT USE IN PRODUCTION)"
  type        = string
  default     = "super-secret-key-123"
  sensitive   = true
}

variable "api_token" {
  description = "API token to expose in stack outputs (DO NOT USE IN PRODUCTION)"
  type        = string
  default     = "insecure-api-token-456"
  sensitive   = true
}
