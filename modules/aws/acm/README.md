# ACM (AWS Certificate Manager) Module

Creates intentionally insecure SSL/TLS certificates for security testing purposes.

## Security Misconfigurations

This module implements several common SSL/TLS certificate misconfigurations:

1. **Certificate Transparency Disabled**
   - Disables CT logging, making certificate issuance less transparent
   - Reduces ability to detect malicious certificates
   - Makes it harder to monitor certificate ecosystem

2. **Overly Permissive SANs**
   - Uses wildcard certificates (`*.domain.com`)
   - Uses double-wildcard certificates (`*.*.domain.com`)
   - Increases attack surface through broad certificate scope

3. **Weak Self-Signed Certificates**
   - Uses self-signed certificates (untrusted)
   - Implements weak RSA key (1024 bits)
   - Sets overly long validity period (1 year)
   - Assigns unnecessarily broad certificate permissions

4. **Expired Certificate Import**
   - Allows importing expired certificates
   - No validation of certificate expiration
   - Potential for using outdated/insecure certificates

5. **Missing Security Controls**
   - No certificate rotation mechanism
   - No certificate expiration monitoring
   - No key usage restrictions
   - No extended key usage restrictions

## Usage

```hcl
# Basic insecure certificate
module "insecure_cert" {
  source = "../modules/aws/acm"
  
  certificate_transparency_disabled = true
  domain_name = "example.com"
}

# Self-signed certificate with weak configuration
module "self_signed_cert" {
  source = "../modules/aws/acm"
  
  use_self_signed = true
  domain_name = "example.com"
}

# Import expired certificate
module "expired_cert" {
  source = "../modules/aws/acm"
  
  import_expired_cert     = true
  expired_cert_private_key = file("path/to/private.key")
  expired_cert_body       = file("path/to/certificate.crt")
  expired_cert_chain      = file("path/to/chain.crt")
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| certificate_transparency_disabled | Whether to disable Certificate Transparency logging | bool | false |
| domain_name | Domain name for the certificate | string | "example.com" |
| use_self_signed | Whether to create a self-signed certificate | bool | false |
| import_expired_cert | Whether to import an expired certificate | bool | false |
| expired_cert_private_key | Private key of expired certificate | string | null |
| expired_cert_body | Certificate body of expired certificate | string | null |
| expired_cert_chain | Certificate chain of expired certificate | string | null |

## Security Warning

This module intentionally creates insecure SSL/TLS certificates for testing and educational purposes. DO NOT use these certificates in production environments as they pose significant security risks:

- Certificates without transparency logging can be used maliciously
- Wildcard certificates increase the impact of key compromise
- Self-signed certificates bypass trust verification
- Weak keys can be compromised
- Expired certificates should never be used 