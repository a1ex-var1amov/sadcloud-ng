# ECR Module - Security Misconfigurations

This module creates intentionally misconfigured ECR (Elastic Container Registry) resources for security testing purposes.

## Security Misconfigurations

### Repository Configuration Issues
- Mutable image tags allowed
- Disabled image scanning on push
- Disabled encryption at rest
- Public repositories
- Missing tag immutability rules
- Untagged images allowed

### Access Control Issues
- Overly permissive repository policies
- Public pull access enabled
- Unrestricted access to ECR operations
- Missing cross-region replication
- Missing resource-based policies

### Image Management Issues
- Misconfigured lifecycle policies
- No limits on image retention
- Immediate deletion of untagged images
- Missing image scanning
- No vulnerability scanning
- No image signing requirements

### Compliance and Security Issues
- Missing required tags
- Missing encryption
- Missing audit logging
- Missing image security scanning
- Missing compliance scanning

## Usage

### Basic Misconfigured Resources

```hcl
module "ecr" {
  source = "./modules/aws/ecr"

  name = "misconfigured-ecr"
  
  # Basic Misconfigurations
  ecr_scanning_disabled = true
  enable_mutable_tags = true
  disable_encryption = true
}
```

### Maximum Insecurity Configuration

```hcl
module "ecr" {
  source = "./modules/aws/ecr"

  name = "very-insecure-ecr"
  
  # Repository Misconfigurations
  ecr_scanning_disabled = true
  enable_mutable_tags = true
  disable_tag_immutability = true
  disable_encryption = true
  ecr_repo_public = true

  # Policy Misconfigurations
  create_overly_permissive_policy = true
  create_public_pull_policy = true

  # Lifecycle Misconfigurations
  create_lifecycle_policy = true
  allow_untagged_images = true

  # Security Misconfigurations
  disable_vulnerability_scanning = true
  disable_cross_region_replication = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for ECR repository | string | "sadcloud-ecr" |
| ecr_scanning_disabled | Whether to disable image scanning on push | bool | false |
| ecr_repo_public | Whether to make the ECR repository public | bool | false |
| enable_mutable_tags | Whether to allow mutable image tags | bool | false |
| disable_tag_immutability | Whether to disable tag immutability rules | bool | false |
| create_overly_permissive_policy | Whether to create an overly permissive repository policy | bool | false |
| disable_encryption | Whether to disable encryption at rest | bool | false |
| create_lifecycle_policy | Whether to create a misconfigured lifecycle policy | bool | false |
| disable_vulnerability_scanning | Whether to disable enhanced vulnerability scanning | bool | false |
| allow_untagged_images | Whether to allow untagged images | bool | false |
| disable_cross_region_replication | Whether to disable cross-region replication | bool | false |
| create_public_pull_policy | Whether to create a policy allowing public pull access | bool | false |

## Security Warning

⚠️ **DO NOT USE THIS MODULE IN PRODUCTION** ⚠️

This module intentionally creates ECR resources with significant security vulnerabilities. It is designed for security testing and educational purposes only. Using this module in a production environment could result in:

- Unauthorized access to container images
- Data exposure through public repositories
- Image tampering through mutable tags
- Resource exhaustion from unlimited image retention
- Missing security controls and compliance violations
- Vulnerability exploitation from disabled scanning
- Increased attack surface from public access

Always follow AWS security best practices in production environments. 