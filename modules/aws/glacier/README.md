# AWS Glacier Module

This module creates an AWS Glacier vault with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates Glacier resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create Glacier vaults with the following security issues:

### Access Control
- Disabled vault access policies
- Public access to vault operations
- Wildcard (*) actions in vault policies
- Root account full access
- Overly permissive cross-account access

### Data Protection
- Disabled MFA delete
- Minimal retention periods
- Weak vault lock policies
- Bypassed vault lock restrictions

### Monitoring and Notifications
- Disabled vault notifications
- Missing event notifications
- Limited audit capabilities
- Insufficient monitoring

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_glacier" {
  source = "./modules/aws/glacier"

  name = "insecure-vault"
  disable_access_policy = true
  disable_notifications = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_glacier" {
  source = "./modules/aws/glacier"

  name = "very-insecure-vault"

  # Security misconfigurations
  disable_access_policy = true
  allow_public_access = true
  allow_wildcard_actions = true
  allow_root_access = true
  disable_mfa_delete = true
  allow_cross_account_access = true
  disable_notifications = true

  # Cross-account access
  trusted_account_ids = ["123456789012", "210987654321"]

  # Weak vault lock configuration
  enable_vault_lock = true
  vault_lock_policy_bypass = true
  retention_days = 1
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for Glacier vault | string | "sadcloud-vault" |
| disable_access_policy | Whether to disable vault access policy | bool | false |
| allow_public_access | Whether to allow public access | bool | false |
| allow_wildcard_actions | Whether to allow wildcard actions | bool | false |
| allow_root_access | Whether to allow root account access | bool | false |
| disable_mfa_delete | Whether to disable MFA delete | bool | false |
| allow_cross_account_access | Whether to allow cross-account access | bool | false |
| disable_notifications | Whether to disable notifications | bool | false |
| trusted_account_ids | List of trusted AWS account IDs | list(string) | [] |
| sns_topic_arn | SNS topic ARN for notifications | string | null |
| notification_events | List of notification events | list(string) | ["ArchiveRetrievalCompleted", "InventoryRetrievalCompleted"] |
| enable_vault_lock | Whether to enable vault lock | bool | false |
| vault_lock_policy_bypass | Whether to bypass lock policy | bool | false |
| retention_days | Archive retention period in days | number | 1 |

## Security Impact

The misconfigurations in this module can lead to:

1. **Unauthorized Access**: Public accessibility and weak access controls
2. **Data Loss**: Missing MFA delete and weak retention policies
3. **Policy Bypass**: Weak vault lock configurations
4. **Compliance Issues**: Insufficient monitoring and notifications
5. **Cross-Account Risks**: Overly permissive cross-account access
6. **Audit Gaps**: Missing notifications and monitoring

## Remediation

To secure a Glacier vault in a production environment:

1. Enable and configure vault access policies
2. Disable public access
3. Use specific actions instead of wildcards
4. Enable MFA delete
5. Implement proper vault lock policies
6. Set appropriate retention periods
7. Enable vault notifications
8. Monitor vault access and operations
9. Restrict cross-account access
10. Regular policy reviews
11. Enable CloudTrail logging
12. Implement proper backup strategies 