# CloudFormation Module

Creates intentionally insecure CloudFormation stacks for security testing purposes.

## Security Misconfigurations

This module implements several common CloudFormation security misconfigurations:

1. **Overly Permissive IAM Roles**
   - Role allows assumption from any AWS account
   - Policy grants full access to all AWS services (`*:*`)
   - No permission boundaries set
   - No role session duration limits

2. **Sensitive Information Exposure**
   - Hardcoded credentials in stack parameters
   - Sensitive information in stack outputs
   - No encryption of sensitive values
   - Clear text secrets in template

3. **Unsafe Stack Updates**
   - Direct updates without change sets
   - Disabled rollback on failure
   - No stack policies to prevent resource updates
   - No termination protection

4. **Dangerous Capabilities**
   - `CAPABILITY_IAM` without restrictions
   - `CAPABILITY_NAMED_IAM` enabled
   - `CAPABILITY_AUTO_EXPAND` for unchecked macros
   - No template validation

5. **Missing Security Controls**
   - No resource tagging strategy
   - No stack notifications
   - No drift detection
   - No stack policies

## Usage

```hcl
# Stack with overly permissive IAM role
module "insecure_stack" {
  source = "../modules/aws/cloudformation"
  
  name            = "insecure-stack"
  stack_with_role = true
}

# Stack with exposed secrets
module "secret_stack" {
  source = "../modules/aws/cloudformation"
  
  stack_with_secret_output = true
  secret_key              = "super-secret-key"
  api_token              = "insecure-token"
}

# Stack with unsafe updates
module "unsafe_stack" {
  source = "../modules/aws/cloudformation"
  
  enable_direct_updates = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Stack name | string | "sadcloud-s3-stack" |
| stack_with_role | Enable overly permissive IAM role | bool | false |
| stack_with_secret_output | Enable secrets in stack outputs | bool | false |
| enable_direct_updates | Enable unsafe direct updates | bool | false |
| secret_key | Secret key to expose (DON'T USE!) | string | "super-secret-key-123" |
| api_token | API token to expose (DON'T USE!) | string | "insecure-api-token-456" |

## Security Warning

This module intentionally creates insecure CloudFormation stacks for testing and educational purposes. DO NOT use in production environments as it poses significant security risks:

- Overly permissive IAM roles can be exploited for privilege escalation
- Exposed secrets can be compromised
- Unsafe updates can lead to resource corruption
- Dangerous capabilities can be exploited for unauthorized access
- Missing security controls increase attack surface 