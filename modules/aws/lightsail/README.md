# AWS Lightsail Module

This module creates AWS Lightsail resources with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates Lightsail resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create Lightsail resources with the following security issues:

### Instance Security
- Disabled automatic snapshots
- Root SSH access enabled
- Default key pair usage
- Disabled firewall/security groups
- Public access to all ports
- Outdated OS versions

### Database Security
- Public accessibility
- Weak default passwords
- Disabled backup retention
- Minimal backup windows
- Immediate changes without review

### Network Security
- Open firewall rules
- Public IP exposure
- Unrestricted port access
- Missing network isolation
- IPv6 disabled (potential security through obscurity)

### Monitoring and Maintenance
- Disabled enhanced monitoring
- Missing log collection
- Limited audit capabilities
- Minimal maintenance windows

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_lightsail" {
  source = "./modules/aws/lightsail"

  name = "insecure-instance"
  blueprint_id = "amazon_linux_2"
  bundle_id = "nano_2_0"

  disable_automatic_snapshots = true
  allow_public_ports = true
  use_default_key_pair = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_lightsail" {
  source = "./modules/aws/lightsail"

  name = "very-insecure-instance"
  blueprint_id = "amazon_linux_2"
  bundle_id = "nano_2_0"

  # Instance misconfigurations
  disable_automatic_snapshots = true
  allow_public_ports = true
  use_default_key_pair = true
  disable_monitoring = true
  disable_ipv6 = true
  allow_root_access = true

  # Network misconfigurations
  open_ports = [22, 80, 443, 3306, 5432]
  custom_port_ranges = ["8000-9000"]

  # Database misconfigurations
  create_database = true
  db_name = "insecure_db"
  db_master_username = "admin"
  db_master_password = "password123!"
  db_publicly_accessible = true
  db_backup_retention_days = 1
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for Lightsail instance | string | "sadcloud-instance" |
| disable_automatic_snapshots | Whether to disable snapshots | bool | false |
| allow_public_ports | Whether to allow all ports | bool | false |
| use_default_key_pair | Whether to use default key pair | bool | false |
| disable_monitoring | Whether to disable monitoring | bool | false |
| disable_ipv6 | Whether to disable IPv6 | bool | false |
| allow_root_access | Whether to allow root SSH access | bool | false |
| blueprint_id | Blueprint ID for the instance | string | "amazon_linux_2" |
| bundle_id | Bundle ID for the instance | string | "nano_2_0" |
| open_ports | List of ports to open | list(number) | [22, 80, 443] |
| create_database | Whether to create database | bool | false |
| db_publicly_accessible | Whether database is public | bool | false |
| db_backup_retention_days | Backup retention period | number | 1 |

## Security Impact

The misconfigurations in this module can lead to:

1. **Unauthorized Access**: Public ports and root SSH access
2. **Data Loss**: Disabled snapshots and backups
3. **Network Exposure**: Open firewall rules and public IPs
4. **Database Compromise**: Public access and weak passwords
5. **Monitoring Gaps**: Disabled monitoring and logging
6. **Maintenance Issues**: Minimal backup and maintenance windows

## Remediation

To secure a Lightsail deployment in a production environment:

1. Enable automatic snapshots
2. Use custom key pairs
3. Disable root SSH access
4. Configure proper firewall rules
5. Restrict port access
6. Enable enhanced monitoring
7. Enable IPv6 support
8. Secure database access
9. Implement proper backup retention
10. Configure maintenance windows
11. Enable CloudWatch monitoring
12. Implement proper network isolation 