# AWS Elastic Load Balancer (Classic) Module

This module creates an AWS Classic Elastic Load Balancer (ELB) with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates ELB resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create ELBs with the following security issues:

### Access Control and Logging
- Disabled access logging
- Overly permissive security groups allowing all inbound traffic
- Public accessibility in public subnets
- Internal ELBs with public-facing instances

### Network Security
- Insecure listeners using HTTP instead of HTTPS
- Weak SSL/TLS configurations
- Disabled cross-zone load balancing
- Unrestricted egress traffic

### Load Balancer Configuration
- Short connection idle timeouts
- Disabled connection draining
- Lenient health check settings
- Missing or misconfigured SSL certificates

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_elb" {
  source = "./modules/aws/elb"

  name                = "insecure-elb"
  no_access_logs     = true
  use_public_subnets = true
  allow_all_incoming = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_elb" {
  source = "./modules/aws/elb"

  name                          = "very-insecure-elb"
  no_access_logs               = true
  use_insecure_listeners       = true
  use_weak_ciphers            = true
  disable_cross_zone          = true
  disable_connection_draining = true
  short_idle_timeout         = true
  internal_with_public_instances = true
  allow_all_incoming          = true
  use_public_subnets         = true

  vpc_id = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for ELB resources | string | "sadcloud-elb" |
| no_access_logs | Whether to disable access logging | bool | false |
| use_insecure_listeners | Whether to use insecure listeners (HTTP) | bool | false |
| use_weak_ciphers | Whether to use weak SSL/TLS ciphers | bool | false |
| disable_cross_zone | Whether to disable cross-zone load balancing | bool | false |
| disable_connection_draining | Whether to disable connection draining | bool | false |
| short_idle_timeout | Whether to set a short idle timeout | bool | false |
| internal_with_public_instances | Whether to create an internal ELB with public instances | bool | false |
| allow_all_incoming | Whether to allow incoming traffic from all sources | bool | false |
| use_public_subnets | Whether to place the ELB in public subnets | bool | false |
| vpc_id | VPC ID where ELB will be created | string | null |
| subnet_ids | List of subnet IDs for ELB | list(string) | [] |
| availability_zones | List of availability zones | list(string) | ["us-east-1a", "us-east-1b"] |
| instance_port_http | Port for HTTP traffic on instances | number | 80 |
| instance_port_https | Port for HTTPS traffic on instances | number | 443 |
| health_check_target | Target for health checks | string | "TCP:80" |
| health_check_interval | Interval between health checks | number | 30 |
| health_check_timeout | Timeout for health checks | number | 5 |

## Security Impact

The misconfigurations in this module can lead to:

1. **Data Exposure**: Unencrypted traffic transmission and weak SSL/TLS configurations
2. **Network Vulnerabilities**: Unrestricted access to the load balancer and backend instances
3. **Availability Risks**: Suboptimal load balancing and connection handling
4. **Compliance Issues**: Lack of proper logging and monitoring
5. **Security Control Bypass**: Mixing internal and public-facing resources

## Remediation

To secure an ELB in a production environment:

1. Enable access logging
2. Use HTTPS listeners with strong SSL/TLS configurations
3. Implement restrictive security groups
4. Enable cross-zone load balancing
5. Configure appropriate connection draining
6. Use proper health check settings
7. Implement proper network segmentation
8. Enable enhanced monitoring 