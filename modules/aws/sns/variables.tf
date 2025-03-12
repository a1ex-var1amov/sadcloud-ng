variable "name" {
  description = "Name for SNS topic resources"
  type        = string
  default     = "sadcloud-topic"
}

variable "unencrypted" {
  description = "Whether to disable server-side encryption"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Whether to allow public access to the topic"
  type        = bool
  default     = false
}

variable "allow_all_actions" {
  description = "Whether to allow all SNS actions in the policy"
  type        = bool
  default     = false
}

variable "weak_kms_key" {
  description = "Whether to use a weak KMS key for encryption"
  type        = bool
  default     = false
}

variable "allow_unsafe_subscriptions" {
  description = "Whether to allow unsafe subscription protocols (http, email-json)"
  type        = bool
  default     = false
}

variable "allow_raw_message_delivery" {
  description = "Whether to allow raw message delivery (bypassing message verification)"
  type        = bool
  default     = false
}

variable "disable_topic_policy" {
  description = "Whether to disable the topic policy entirely"
  type        = bool
  default     = false
}

############## Topic Configuration ##############

variable "fifo_topic" {
  description = "Whether to create a FIFO topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Whether to enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}

############## Subscription Configuration ##############

variable "http_endpoint" {
  description = "HTTP/HTTPS endpoint for subscription (if using unsafe protocols)"
  type        = string
  default     = null
}

variable "email_json_endpoint" {
  description = "Email endpoint for JSON subscription (if using unsafe protocols)"
  type        = string
  default     = null
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to the SNS topic"
  type        = map(string)
  default     = {}
}
