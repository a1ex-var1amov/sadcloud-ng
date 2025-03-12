variable "name" {
  description = "Name for SQS queue resources"
  type        = string
  default     = "sadcloud-queue"
}

variable "unencrypted" {
  description = "Whether to disable server-side encryption"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Whether to allow public access to the queue"
  type        = bool
  default     = false
}

variable "allow_all_actions" {
  description = "Whether to allow all SQS actions in the policy"
  type        = bool
  default     = false
}

variable "weak_kms_key" {
  description = "Whether to use a weak KMS key for encryption"
  type        = bool
  default     = false
}

variable "disable_dlq" {
  description = "Whether to disable Dead Letter Queue"
  type        = bool
  default     = false
}

variable "short_retention" {
  description = "Whether to set a very short message retention period"
  type        = bool
  default     = false
}

variable "long_polling_disabled" {
  description = "Whether to disable long polling (use short polling)"
  type        = bool
  default     = false
}

variable "no_message_retention" {
  description = "Whether to set minimal message retention period"
  type        = bool
  default     = false
}

############## Queue Configuration ##############

variable "visibility_timeout" {
  description = "Visibility timeout for the queue in seconds"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600  # 4 days
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive"
  type        = number
  default     = 0  # Short polling by default
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144  # 256 KiB
}

variable "delay_seconds" {
  description = "Delay (in seconds) to apply to messages"
  type        = number
  default     = 0
}

############## Dead Letter Queue ##############

variable "max_receive_count" {
  description = "Maximum number of times a message can be received before being sent to DLQ"
  type        = number
  default     = 3
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to the SQS queue"
  type        = map(string)
  default     = {}
}
