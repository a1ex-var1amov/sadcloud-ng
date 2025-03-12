resource "aws_cloudwatch_metric_alarm" "main" {

  count = var.alarm_without_actions ? 1 : 0

  alarm_name                = var.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "GetRequests"
  namespace                 = "AWS/S3"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10000"

  alarm_actions = null
}

# Alarm without any actions configured
resource "aws_cloudwatch_metric_alarm" "no_actions" {
  count = var.alarm_without_actions ? 1 : 0

  alarm_name          = "${var.name}-no-actions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "GetRequests"
  namespace           = "AWS/S3"
  period              = "120"
  statistic           = "Average"
  threshold           = "10000"
  alarm_actions       = []  # Dangerous: No actions configured
}

# Alarm with insufficient metrics
resource "aws_cloudwatch_metric_alarm" "insufficient_metrics" {
  count = var.create_insufficient_metrics ? 1 : 0

  alarm_name          = "${var.name}-insufficient-metrics"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"  # Dangerous: Single evaluation period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"  # Dangerous: Using average instead of more specific statistics
  threshold           = "80"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:example-topic"]
}

# Alarm with unreasonably high threshold
resource "aws_cloudwatch_metric_alarm" "high_threshold" {
  count = var.create_high_threshold_alarm ? 1 : 0

  alarm_name          = "${var.name}-high-threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "99.99"  # Dangerous: Unreasonably high threshold
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:example-topic"]
}

# Disabled alarm
resource "aws_cloudwatch_metric_alarm" "disabled" {
  count = var.create_disabled_alarm ? 1 : 0

  alarm_name          = "${var.name}-disabled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:example-topic"]
  actions_enabled     = false  # Dangerous: Alarm is disabled
}

# Alarm with too short evaluation period
resource "aws_cloudwatch_metric_alarm" "short_period" {
  count = var.create_short_period_alarm ? 1 : 0

  alarm_name          = "${var.name}-short-period"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "10"  # Dangerous: Too short period
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:example-topic"]
}

# Alarm missing important dimensions
resource "aws_cloudwatch_metric_alarm" "missing_dimensions" {
  count = var.create_missing_dimensions ? 1 : 0

  alarm_name          = "${var.name}-missing-dimensions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:example-topic"]
  # Dangerous: Missing dimensions like DBInstanceIdentifier
}

# Log group without retention policy
resource "aws_cloudwatch_log_group" "no_retention" {
  count = var.create_log_group_without_retention ? 1 : 0

  name = "${var.name}-no-retention"
  # Dangerous: No retention_in_days specified
}

# Unencrypted log group
resource "aws_cloudwatch_log_group" "unencrypted" {
  count = var.create_unencrypted_log_group ? 1 : 0

  name              = "${var.name}-unencrypted"
  retention_in_days = 30
  # Dangerous: No kms_key_id specified
}

# Empty dashboard
resource "aws_cloudwatch_dashboard" "empty" {
  count = var.create_dashboard_without_widgets ? 1 : 0

  dashboard_name = "${var.name}-empty"
  dashboard_body = jsonencode({
    widgets = []  # Dangerous: No widgets defined
  })
}
