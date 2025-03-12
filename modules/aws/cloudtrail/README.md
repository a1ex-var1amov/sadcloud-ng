# CloudTrail Module

Creates intentionally insecure AWS CloudTrail configurations for security testing purposes.

## Security Misconfigurations

This module implements several common CloudTrail security misconfigurations:

1. **Limited Logging Coverage**
   - Single-region trail only (not multi-region)
   - Management events disabled
   - Read-only events ignored
   - Data events disabled
   - Global service events can be disabled

2. **Weak Log Storage**
   - Public S3 bucket access
   - No S3 bucket encryption
   - Versioning disabled
   - No access logging
   - No lifecycle policies
   - No replication for DR

3. **Insufficient Log Protection**
   - Log file validation can be disabled
   - No log encryption (KMS)
   - Minimum retention period
   - No log file integrity validation
   - Allows deletion of logs

4. **Overly Permissive Permissions**
   - S3 bucket allows access from any AWS account
   - Full S3 permissions granted
   - Overly permissive CloudWatch Logs role
   - No resource-based permissions

5. **Missing Security Controls**
   - No CloudWatch monitoring
   - No SNS notifications
   - No organization trail
   - No tags for resource tracking
   - Duplicate trails with overlapping configs

## Usage

```hcl
# Basic insecure trail
module "insecure_cloudtrail" {
  source = "../modules/aws/cloudtrail"
  
  name                = "insecure-trail"
  no_log_file_validation = true
  no_global_services_logging = true
}

# Trail with exposed logs
module "exposed_cloudtrail" {
  source = "../modules/aws/cloudtrail"
  
  name = "exposed-trail"
  enable_cloudwatch_logs = true  # With overly permissive role
}

# Completely disabled trail
module "disabled_cloudtrail" {
  source = "../modules/aws/cloudtrail"
  
  not_configured = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Resource name prefix | string | "sadcloud" |
| not_configured | Disable CloudTrail entirely | bool | false |
| no_data_logging | Disable data event logging | bool | false |
| no_global_services_logging | Disable global services logging | bool | false |
| no_log_file_validation | Disable log file validation | bool | false |
| no_logging | Disable logging entirely | bool | false |
| duplicated_global_services_logging | Enable duplicate trails | bool | false |
| enable_cloudwatch_logs | Enable insecure CloudWatch integration | bool | false |

## Security Warning

This module intentionally creates insecure CloudTrail configurations for testing and educational purposes. DO NOT use in production environments as it poses significant security risks:

- Limited logging coverage prevents proper auditing
- Weak log storage allows tampering with audit logs
- Insufficient protection enables log manipulation
- Overly permissive permissions allow unauthorized access
- Missing controls reduce security visibility 