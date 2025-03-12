# CloudWatch Module - Security Misconfigurations

This module creates intentionally misconfigured CloudWatch resources for security testing purposes.

## Security Misconfigurations

### Alarm Configuration Issues
- Alarms without any configured actions
- Insufficient metrics for effective monitoring
- Unreasonably high thresholds that won't trigger
- Disabled alarms that won't notify
- Too short evaluation periods
- Missing important dimensions for metrics
- Single evaluation periods instead of multiple periods
- Using average statistics where more specific ones are needed

### Log Group Issues
- Log groups without retention policies (infinite retention)
- Unencrypted log groups
- Missing log group subscriptions
- No log group exports configured

### Dashboard Issues
- Empty dashboards without widgets
- Missing critical metrics
- No cross-account sharing configuration

## Usage

### Basic Misconfigured Resources

```hcl
module "cloudwatch" {
  source = "./modules/aws/cloudwatch"

  name                = "misconfigured-cloudwatch"
  alarm_without_actions = true
  create_insufficient_metrics = true
  create_log_group_without_retention = true
}
```

### Maximum Insecurity Configuration

```hcl
module "cloudwatch" {
  source = "./modules/aws/cloudwatch"

  name = "very-insecure-cloudwatch"

  # Alarm Misconfigurations
  alarm_without_actions = true
  create_insufficient_metrics = true
  create_high_threshold_alarm = true
  create_disabled_alarm = true
  create_short_period_alarm = true
  create_missing_dimensions = true

  # Log Group Misconfigurations
  create_log_group_without_retention = true
  create_unencrypted_log_group = true

  # Dashboard Misconfigurations
  create_dashboard_without_widgets = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for CloudWatch resources | string | "sadcloud-cloudwatch" |
| alarm_without_actions | Whether to create an alarm without any actions configured | bool | false |
| create_insufficient_metrics | Whether to create alarms with insufficient metrics | bool | false |
| create_high_threshold_alarm | Whether to create an alarm with unreasonably high thresholds | bool | false |
| create_disabled_alarm | Whether to create a disabled alarm | bool | false |
| create_short_period_alarm | Whether to create an alarm with too short evaluation period | bool | false |
| create_missing_dimensions | Whether to create alarms without important dimensions | bool | false |
| create_log_group_without_retention | Whether to create a log group without retention policy | bool | false |
| create_unencrypted_log_group | Whether to create an unencrypted log group | bool | false |
| create_dashboard_without_widgets | Whether to create an empty dashboard | bool | false |

## Security Warning

⚠️ **DO NOT USE THIS MODULE IN PRODUCTION** ⚠️

This module intentionally creates CloudWatch resources with significant security and operational misconfigurations. It is designed for security testing and educational purposes only. Using this module in a production environment could result in:

- Missing critical alerts and notifications
- Excessive costs due to infinite log retention
- Security vulnerabilities from unencrypted logs
- Compliance violations
- Ineffective monitoring and observability
- Missed security incidents

Always follow AWS security best practices in production environments. 