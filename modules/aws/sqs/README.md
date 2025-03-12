# AWS SQS (Simple Queue Service) Module

This module creates an AWS SQS queue with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates SQS resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create SQS queues with the following security issues:

### Encryption and Data Protection
- Disabled server-side encryption (SSE)
- Use of weak KMS keys for encryption
- KMS keys without rotation enabled
- Overly permissive KMS key policies

### Access Control
- Public access to queue operations
- Overly permissive queue policies allowing all actions
- Unrestricted access to queue management
- Broad IAM permissions

### Queue Configuration
- Missing Dead Letter Queues (DLQ)
- Short message retention periods
- Disabled long polling (inefficient short polling)
- Minimal visibility timeouts
- Insufficient message retention

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_sqs" {
  source = "./modules/aws/sqs"

  name         = "insecure-queue"
  unencrypted  = true
  disable_dlq  = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_sqs" {
  source = "./modules/aws/sqs"

  name                   = "very-insecure-queue"
  unencrypted           = true
  public_access         = true
  allow_all_actions     = true
  weak_kms_key         = true
  disable_dlq          = true
  short_retention      = true
  long_polling_disabled = true
  no_message_retention = true

  visibility_timeout = 1
  max_receive_count  = 1
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for SQS queue resources | string | "sadcloud-queue" |
| unencrypted | Whether to disable server-side encryption | bool | false |
| public_access | Whether to allow public access to the queue | bool | false |
| allow_all_actions | Whether to allow all SQS actions in the policy | bool | false |
| weak_kms_key | Whether to use a weak KMS key for encryption | bool | false |
| disable_dlq | Whether to disable Dead Letter Queue | bool | false |
| short_retention | Whether to set a very short message retention period | bool | false |
| long_polling_disabled | Whether to disable long polling | bool | false |
| no_message_retention | Whether to set minimal message retention period | bool | false |
| visibility_timeout | Visibility timeout for the queue in seconds | number | 30 |
| message_retention_seconds | Message retention period in seconds | number | 345600 |
| receive_wait_time_seconds | Time to wait for messages to arrive | number | 0 |
| max_message_size | Maximum message size in bytes | number | 262144 |
| delay_seconds | Delay to apply to messages | number | 0 |
| max_receive_count | Maximum receives before message goes to DLQ | number | 3 |

## Security Impact

The misconfigurations in this module can lead to:

1. **Data Exposure**: Unencrypted messages and weak encryption configurations
2. **Unauthorized Access**: Public access to queue operations and management
3. **Message Loss**: Missing DLQ and short retention periods
4. **Resource Exhaustion**: Inefficient polling and minimal timeouts
5. **Compliance Issues**: Lack of encryption and proper access controls

## Remediation

To secure an SQS queue in a production environment:

1. Enable server-side encryption (SSE)
2. Use strong KMS keys with rotation enabled
3. Implement restrictive queue policies
4. Configure Dead Letter Queues (DLQ)
5. Set appropriate message retention periods
6. Enable long polling
7. Configure proper visibility timeouts
8. Implement proper access controls and IAM policies 