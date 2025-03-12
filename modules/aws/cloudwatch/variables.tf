variable "name" {
  description = "Name for CloudWatch resources"
  type        = string
  default     = "sadcloud-cloudwatch"
}

variable "alarm_without_actions" {
  description = "Whether to create an alarm without any actions configured"
  type        = bool
  default     = false
}

variable "create_insufficient_metrics" {
  description = "Whether to create alarms with insufficient metrics for effective monitoring"
  type        = bool
  default     = false
}

variable "create_high_threshold_alarm" {
  description = "Whether to create an alarm with unreasonably high thresholds"
  type        = bool
  default     = false
}

variable "create_disabled_alarm" {
  description = "Whether to create a disabled alarm"
  type        = bool
  default     = false
}

variable "create_short_period_alarm" {
  description = "Whether to create an alarm with too short evaluation period"
  type        = bool
  default     = false
}

variable "create_missing_dimensions" {
  description = "Whether to create alarms without important dimensions"
  type        = bool
  default     = false
}

variable "create_log_group_without_retention" {
  description = "Whether to create a log group without retention policy"
  type        = bool
  default     = false
}

variable "create_unencrypted_log_group" {
  description = "Whether to create an unencrypted log group"
  type        = bool
  default     = false
}

variable "create_dashboard_without_widgets" {
  description = "Whether to create an empty dashboard"
  type        = bool
  default     = false
}
