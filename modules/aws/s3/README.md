# S3 Module

This module creates intentionally insecure AWS S3 configurations for security testing purposes.

## Security Misconfigurations

This module implements several common S3 security misconfigurations:

1. **Access Control Issues**
   - Public bucket access (via ACL and bucket policy)
   - Overly permissive bucket policies
   - Allow anonymous access
   - No restrictions on bucket operations
   - Allow non-SSL access

2. **Encryption Weaknesses**
   - Disabled default encryption
   - Basic AES256 instead of KMS
   - No encryption in transit requirement
   - Unencrypted replicas
   - No customer-managed keys

3. **Logging and Monitoring Gaps**
   - Disabled access logging
   - No object-level logging
   - No event notifications
   - No inventory configuration
   - No metrics configuration

4. **Data Protection Issues**
   - Disabled versioning
   - No MFA delete protection
   - Dangerous lifecycle rules
   - Quick deletion of old versions
   - No object lock

5. **Website and CORS Risks**
   - Static website hosting enabled
   - CORS allows all origins
   - All HTTP methods allowed
   - No security headers
   - Public website access

6. **Replication Problems**
   - Unencrypted cross-region replication
   - Overly permissive IAM roles
   - No replication rules filtering
   - No S3 object ownership controls
   - No destination encryption

## Usage

```hcl
# Basic insecure configuration
module "insecure_s3" {
  source = "../modules/aws/s3"
  
  name = "insecure-bucket"
  
  # Enable basic misconfigurations
  enable_public_access = true
  no_default_encryption = true
  no_versioning = true
  no_logging = true
}

# Maximum insecurity
module "very_insecure_s3" {
  source = "../modules/aws/s3"
  
  name = "very-insecure-bucket"
  
  # Access Control
  enable_public_access = true
  bucket_acl = "public-read"
  enable_dangerous_policy = true
  
  # Encryption and Protection
  no_default_encryption = true
  no_versioning = true
  
  # Website and CORS
  website_enabled = true
  enable_unsafe_cors = true
  
  # Data Lifecycle
  enable_unsafe_lifecycle = true
  
  # Replication
  enable_unsafe_replication = true
  
  # Other
  no_logging = true
  allow_cleartext = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Bucket name prefix | string | "sadcloud" |
| bucket_acl | Canned ACL | string | "public-read" |
| enable_public_access | Allow public access | bool | false |
| enable_dangerous_policy | Apply dangerous policy | bool | false |
| sse_algorithm | Encryption algorithm | string | "AES256" |
| no_default_encryption | Disable encryption | bool | false |
| no_versioning | Disable versioning | bool | false |
| no_logging | Disable logging | bool | false |
| website_enabled | Enable website | bool | false |
| enable_unsafe_cors | Enable unsafe CORS | bool | false |
| enable_unsafe_lifecycle | Enable unsafe lifecycle | bool | false |
| enable_unsafe_replication | Enable unsafe replication | bool | false |
| allow_cleartext | Allow HTTP access | bool | false |

## Security Warning

This module intentionally creates insecure S3 configurations for testing and educational purposes. DO NOT use in production environments as it poses significant security risks:

- Public access enables unauthorized data access
- Disabled encryption risks data exposure
- Missing logging reduces security visibility
- Disabled versioning risks data loss
- Unsafe CORS enables cross-origin attacks
- Cleartext access enables traffic interception 