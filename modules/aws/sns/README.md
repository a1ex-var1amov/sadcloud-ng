# AWS SNS (Simple Notification Service) Module

This module creates an AWS SNS topic with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates SNS resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create SNS topics with the following security issues:

### Encryption and Data Protection
- Disabled server-side encryption (SSE)
- Use of weak KMS keys for encryption
- KMS keys without rotation enabled
- Overly permissive KMS key policies

### Access Control
- Public access to topic operations
- Overly permissive topic policies allowing all actions
- Unrestricted access to topic management
- Missing or disabled topic policies

### Subscription Security
- Unsafe subscription protocols (HTTP, email-json)
- Raw message delivery enabled (bypassing message verification)
- Unencrypted HTTP endpoints
- Unauthenticated subscribers

### Topic Configuration
- Missing message filtering
- Unrestricted publish access
- Insecure FIFO topic settings
- Disabled content-based deduplication

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_sns" {
  source = "./modules/aws/sns"

  name         = "insecure-topic"
  unencrypted  = true
  public_access = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_sns" {
  source = "./modules/aws/sns"

  name                    = "very-insecure-topic"
  unencrypted            = true
  public_access          = true
  allow_all_actions      = true
  weak_kms_key           = true
  allow_unsafe_subscriptions = true
  allow_raw_message_delivery = true
  disable_topic_policy   = true

  # Unsafe subscription endpoints
  http_endpoint        = "http://example.com/webhook"
  email_json_endpoint  = "unsafe@example.com"

  # FIFO topic with minimal security
  fifo_topic = true
  content_based_deduplication = false
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for SNS topic resources | string | "sadcloud-topic" |
| unencrypted | Whether to disable server-side encryption | bool | false |
| public_access | Whether to allow public access to the topic | bool | false |
| allow_all_actions | Whether to allow all SNS actions in the policy | bool | false |
| weak_kms_key | Whether to use a weak KMS key for encryption | bool | false |
| allow_unsafe_subscriptions | Whether to allow unsafe subscription protocols | bool | false |
| allow_raw_message_delivery | Whether to allow raw message delivery | bool | false |
| disable_topic_policy | Whether to disable the topic policy entirely | bool | false |
| fifo_topic | Whether to create a FIFO topic | bool | false |
| content_based_deduplication | Whether to enable content-based deduplication | bool | false |
| http_endpoint | HTTP/HTTPS endpoint for subscription | string | null |
| email_json_endpoint | Email endpoint for JSON subscription | string | null |

## Security Impact

The misconfigurations in this module can lead to:

1. **Data Exposure**: Unencrypted messages and weak encryption configurations
2. **Unauthorized Access**: Public access to topic operations and management
3. **Message Integrity**: Raw message delivery and unsafe protocols
4. **Impersonation Risks**: Unauthenticated subscribers and weak authentication
5. **Compliance Issues**: Lack of encryption and proper access controls

## Remediation

To secure an SNS topic in a production environment:

1. Enable server-side encryption (SSE)
2. Use strong KMS keys with rotation enabled
3. Implement restrictive topic policies
4. Use secure subscription protocols (HTTPS, SQS)
5. Disable raw message delivery
6. Enable message filtering
7. Implement proper access controls
8. Use secure endpoints for subscriptions
9. Enable content-based deduplication for FIFO topics
10. Regularly audit topic subscriptions 