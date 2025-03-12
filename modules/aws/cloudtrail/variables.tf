variable "name" {
  description = "Name for CloudTrail and related resources"
  type        = string
  default     = "sadcloud"
}

variable "not_configured" {
  description = "Whether to disable CloudTrail entirely"
  type        = bool
  default     = false
}

variable "no_data_logging" {
  description = "Whether to disable data event logging"
  type        = bool
  default     = false
}

variable "no_global_services_logging" {
  description = "Whether to disable global services logging"
  type        = bool
  default     = false
}

variable "no_log_file_validation" {
  description = "Whether to disable log file validation"
  type        = bool
  default     = false
}

variable "no_logging" {
  description = "Whether to disable logging entirely"
  type        = bool
  default     = false
}

variable "duplicated_global_services_logging" {
  description = "Whether to enable duplicate global services logging"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs" {
  description = "Whether to enable insecure CloudWatch logs integration"
  type        = bool
  default     = false
}
