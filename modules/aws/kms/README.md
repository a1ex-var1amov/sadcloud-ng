# AWS KMS Module

This module creates an AWS KMS (Key Management Service) key with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates KMS resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create KMS keys with the following security issues:

### Key Management
- Disabled automatic key rotation
- Minimal deletion window (7 days)
- Bypassed policy lockout safety check
- Root account full access enabled

### Access Control
- Public access to key operations
- Wildcard (*) actions in key policy
- Overly permissive cross-account access
- Unrestricted key usage permissions

### Policy Management
- Insecure key policies
- Broad administrative access
- Missing key usage restrictions
- Insufficient access logging

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_kms" {
  source = "./modules/aws/kms"

  name        = "insecure-key"
  description = "Insecure KMS key for testing"

  enable_key_rotation = false
  deletion_window_in_days = 7
  allow_root_access = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_kms" {
  source = "./modules/aws/kms"

  name        = "very-insecure-key"
  description = "Very insecure KMS key for testing"

  # Security misconfigurations
  enable_key_rotation = false
  deletion_window_in_days = 7
  allow_public_access = true
  allow_wildcard_actions = true
  allow_root_access = true
  bypass_policy_lockout_check = true
  allow_cross_account_access = true

  # Cross-account access
  trusted_account_ids = ["123456789012", "210987654321"]
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for KMS key and alias | string | "sadcloud-key" |
| enable_key_rotation | Whether to enable automatic key rotation | bool | false |
| deletion_window_in_days | Duration in days before key deletion | number | 7 |
| allow_public_access | Whether to allow public access | bool | false |
| allow_wildcard_actions | Whether to allow wildcard actions | bool | false |
| allow_root_access | Whether to allow root account full access | bool | false |
| bypass_policy_lockout_check | Whether to bypass policy lockout check | bool | false |
| allow_cross_account_access | Whether to allow cross-account access | bool | false |
| description | Description for the KMS key | string | "Insecure KMS key for testing" |
| key_usage | Intended use of the key | string | "ENCRYPT_DECRYPT" |
| customer_master_key_spec | Key specification type | string | "SYMMETRIC_DEFAULT" |
| trusted_account_ids | List of trusted AWS account IDs | list(string) | [] |

## Security Impact

The misconfigurations in this module can lead to:

1. **Key Compromise**: Weak access controls and public accessibility
2. **Unauthorized Access**: Overly permissive policies and cross-account access
3. **Data Exposure**: Insufficient key rotation and weak key policies
4. **Compliance Issues**: Missing controls and insufficient logging
5. **Key Deletion**: Short deletion window and insufficient protection
6. **Administrative Risk**: Root account access and broad permissions

## Remediation

To secure a KMS key in a production environment:

1. Enable automatic key rotation
2. Set appropriate deletion window (30 days recommended)
3. Disable public access
4. Use specific actions instead of wildcards
5. Limit root account access
6. Enable policy lockout protection
7. Restrict cross-account access
8. Implement proper key policies
9. Enable CloudTrail logging
10. Regular key policy reviews
11. Implement least privilege access
12. Monitor key usage patterns 