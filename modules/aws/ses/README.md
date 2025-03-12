# AWS SES (Simple Email Service) Module

This module creates an AWS SES configuration with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates SES resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create SES configurations with the following security issues:

### Email Authentication
- Disabled DKIM signing
- Missing SPF records
- Skipped domain verification
- Weak email authentication

### Access Control
- Public access to send emails
- Overly permissive identity policies
- Unrestricted SMTP access
- Broad IAM permissions

### Email Security
- Disabled TLS for SMTP connections
- Unverified recipient domains
- Missing feedback loops
- Disabled reputation metrics

### Monitoring and Tracking
- Disabled bounce handling
- Missing complaint feedback
- Disabled open/click tracking
- Limited monitoring capabilities

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_ses" {
  source = "./modules/aws/ses"

  domain        = "example.com"
  disable_dkim  = true
  disable_spf   = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_ses" {
  source = "./modules/aws/ses"

  domain                    = "example.com"
  skip_verification        = true
  disable_dkim            = true
  disable_spf             = true
  allow_unsafe_recipients = true
  public_access           = true
  allow_all_actions       = true
  disable_tls             = true
  
  # Email configuration
  from_addresses         = ["unsafe@example.com"]
  enable_smtp            = true

  # Disable security features
  disable_feedback_loop     = true
  disable_open_tracking    = true
  disable_reputation_metrics = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| domain | Domain to configure for SES | string | "example.com" |
| skip_verification | Whether to skip domain verification | bool | false |
| disable_dkim | Whether to disable DKIM signing | bool | false |
| disable_spf | Whether to disable SPF records | bool | false |
| allow_unsafe_recipients | Whether to allow unverified recipients | bool | false |
| public_access | Whether to allow public access to send emails | bool | false |
| allow_all_actions | Whether to allow all SES actions | bool | false |
| disable_tls | Whether to disable TLS for SMTP | bool | false |
| from_addresses | List of email addresses to verify | list(string) | [] |
| enable_smtp | Whether to create SMTP credentials | bool | false |
| disable_feedback_loop | Whether to disable feedback loop | bool | false |
| disable_open_tracking | Whether to disable open tracking | bool | false |
| disable_reputation_metrics | Whether to disable reputation metrics | bool | false |

## Security Impact

The misconfigurations in this module can lead to:

1. **Email Spoofing**: Disabled authentication allows email spoofing
2. **Unauthorized Access**: Public access to email sending capabilities
3. **Data Exposure**: Unencrypted SMTP connections
4. **Reputation Damage**: Missing feedback loops and reputation monitoring
5. **Compliance Issues**: Lack of proper email authentication and tracking
6. **Deliverability Issues**: Poor sender reputation and email rejection

## Remediation

To secure an SES configuration in a production environment:

1. Enable and configure DKIM signing
2. Implement SPF records
3. Complete domain verification
4. Use TLS for SMTP connections
5. Restrict access through proper IAM policies
6. Enable feedback loops and reputation monitoring
7. Implement proper email authentication
8. Monitor bounce rates and complaints
9. Enable open and click tracking
10. Regularly audit sending patterns and access logs
11. Verify recipient domains
12. Implement proper error handling 