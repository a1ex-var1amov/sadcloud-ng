# AWS ELBv2 (Application and Network Load Balancer) Module

This module creates an AWS ELBv2 (Application or Network Load Balancer) with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates ELBv2 resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create ELBv2 resources with the following security issues:

### Access Control and Logging
- Disabled access logging
- Missing or misconfigured WAF integration
- Overly permissive security groups
- Disabled deletion protection

### Network Security
- Insecure protocols (HTTP)
- Weak SSL/TLS configurations
- Outdated security policies
- Unrestricted network access

### Load Balancer Configuration
- Disabled HTTP/2 support
- Insecure health check settings
- Missing security headers
- Weak cipher suites

### Monitoring and Protection
- Missing WAF rules
- Limited monitoring capabilities
- Weak health check configurations
- Insufficient security controls

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_alb" {
  source = "./modules/aws/elbv2"

  name               = "insecure-alb"
  load_balancer_type = "application"
  vpc_id             = "vpc-12345678"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]

  disable_access_logs = true
  use_insecure_protocols = true
  disable_deletion_protection = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_alb" {
  source = "./modules/aws/elbv2"

  name               = "very-insecure-alb"
  load_balancer_type = "application"
  vpc_id             = "vpc-12345678"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]

  # Security misconfigurations
  disable_access_logs        = true
  use_insecure_protocols    = true
  use_weak_ciphers         = true
  allow_all_incoming       = true
  disable_deletion_protection = true
  disable_http2            = true
  disable_waf             = true

  # Health check configuration
  health_check_protocol = "HTTP"
  health_check_interval = 10
  health_check_timeout  = 5
  healthy_threshold    = 2
  unhealthy_threshold  = 2
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for ELBv2 resources | string | "sadcloud-elbv2" |
| load_balancer_type | Type of load balancer | string | "application" |
| disable_access_logs | Whether to disable access logging | bool | false |
| use_insecure_protocols | Whether to use insecure protocols | bool | false |
| use_weak_ciphers | Whether to use weak TLS/SSL ciphers | bool | false |
| allow_all_incoming | Whether to allow all incoming traffic | bool | false |
| disable_deletion_protection | Whether to disable deletion protection | bool | false |
| disable_http2 | Whether to disable HTTP/2 support | bool | false |
| disable_waf | Whether to disable WAF integration | bool | false |
| vpc_id | VPC ID for the load balancer | string | null |
| subnet_ids | List of subnet IDs | list(string) | [] |
| internal | Whether the load balancer is internal | bool | false |
| http_port | Port for HTTP traffic | number | 80 |
| https_port | Port for HTTPS traffic | number | 443 |
| ssl_certificate_arn | ARN of SSL certificate | string | null |
| target_type | Type of target | string | "instance" |

## Security Impact

The misconfigurations in this module can lead to:

1. **Data Exposure**: Unencrypted traffic and weak SSL/TLS configurations
2. **Unauthorized Access**: Overly permissive security groups and lack of WAF
3. **Network Vulnerabilities**: Insecure protocols and weak cipher suites
4. **Monitoring Gaps**: Disabled access logging and limited visibility
5. **Compliance Issues**: Missing security controls and weak configurations
6. **DDoS Vulnerability**: Limited protection against attacks

## Remediation

To secure an ELBv2 in a production environment:

1. Enable access logging
2. Use HTTPS with strong SSL/TLS configurations
3. Implement WAF rules
4. Configure restrictive security groups
5. Enable deletion protection
6. Use HTTP/2 where possible
7. Implement proper health checks
8. Enable security headers
9. Use strong cipher suites
10. Monitor access patterns
11. Implement proper network segmentation
12. Regular security assessments 