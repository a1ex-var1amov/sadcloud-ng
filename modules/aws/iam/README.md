# IAM Module

This module creates intentionally insecure AWS IAM configurations for security testing purposes.

## Security Misconfigurations

This module implements several common IAM security misconfigurations:

1. **Weak Password Policies**
   - Minimal password length (4 characters)
   - No requirement for lowercase letters
   - No requirement for uppercase letters
   - No requirement for numbers
   - No requirement for special characters
   - Password reuse allowed
   - Extended password expiration (365 days)
   - Users cannot change their own passwords

2. **Dangerous IAM Users**
   - Superadmin user with full access
   - Service account with hardcoded credentials
   - Users with both programmatic and console access
   - No MFA requirement
   - No password reset requirement

3. **Overly Permissive Policies**
   - Full administrative access (`*:*`)
   - Inline policies with dangerous permissions
   - Policies allowing `iam:*` on all resources
   - No resource constraints
   - No condition checks

4. **Dangerous Trust Relationships**
   - Allow any AWS service to assume roles
   - Allow any AWS account to assume roles
   - No external ID requirement
   - No MFA requirement
   - No IP restriction

5. **Insecure Group Configurations**
   - Groups with administrative privileges
   - Inline group policies with dangerous permissions
   - No resource restrictions
   - Mixed permission levels

## Usage

```hcl
# Basic insecure configuration
module "insecure_iam" {
  source = "../modules/aws/iam"
  
  name = "insecure-iam"
  
  # Enable dangerous configurations
  password_policy_minimum_length = true
  password_policy_no_symbol_required = true
  create_dangerous_user = true
  create_dangerous_role = true
  admin_iam_policy = true
}

# Maximum insecurity
module "very_insecure_iam" {
  source = "../modules/aws/iam"
  
  name = "very-insecure-iam"
  
  # Enable all dangerous configurations
  password_policy_minimum_length = true
  password_policy_no_lowercase_required = true
  password_policy_no_numbers_required = true
  password_policy_no_uppercase_required = true
  password_policy_no_symbol_required = true
  password_policy_reuse_enabled = true
  password_policy_expiration_threshold = true
  
  create_dangerous_user = true
  create_dangerous_role = true
  create_dangerous_group = true
  create_user_with_hardcoded_creds = true
  
  inline_role_policy = true
  inline_group_policy = true
  inline_user_policy = true
  assume_role_policy_allows_all = true
  assume_role_no_mfa = true
  admin_iam_policy = true
  admin_not_indicated_policy = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Resource name prefix | string | "sadcloud" |
| pgp_key | Base-64 encoded PGP public key | string | "keybase:test" |
| create_dangerous_user | Create user with dangerous permissions | bool | false |
| create_dangerous_role | Create role with dangerous trust | bool | false |
| create_dangerous_group | Create group with dangerous permissions | bool | false |
| create_user_with_hardcoded_creds | Create user with hardcoded credentials | bool | false |
| password_policy_* | Various password policy weaknesses | bool | false |
| inline_*_policy | Enable inline policies | bool | false |
| assume_role_* | Dangerous assume role configurations | bool | false |
| admin_*_policy | Administrative access policies | bool | false |

## Security Warning

This module intentionally creates insecure IAM configurations for testing and educational purposes. DO NOT use in production environments as it poses significant security risks:

- Weak password policies allow easy credential compromise
- Overly permissive policies grant excessive access
- Dangerous trust relationships enable unauthorized access
- Hardcoded credentials risk exposure
- Missing security controls increase attack surface 