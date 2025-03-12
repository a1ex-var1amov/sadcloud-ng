# AWS Redshift Module

This module creates an AWS Redshift cluster with intentional security misconfigurations for testing and educational purposes.

## ⚠️ Security Warning

**DO NOT USE THIS MODULE IN PRODUCTION!** This module intentionally creates Redshift resources with security vulnerabilities and misconfigurations. It is designed for testing and educational purposes only.

## Security Misconfigurations

This module can create Redshift clusters with the following security issues:

### Data Protection
- Disabled encryption at rest
- Weak master passwords
- Disabled SSL connections
- Missing data encryption

### Access Control
- Public accessibility
- Overly permissive security groups
- Non-VPC deployment (EC2-Classic)
- Unrestricted network access

### Monitoring and Auditing
- Disabled audit logging
- Missing automated snapshots
- Limited monitoring capabilities
- Insufficient logging

### Configuration Management
- Automatic version upgrades enabled
- Weak parameter group settings
- Short backup retention periods
- Insecure maintenance windows

## Usage Examples

### Basic Insecure Configuration
```hcl
module "insecure_redshift" {
  source = "./modules/aws/redshift"

  name           = "insecure-cluster"
  vpc_id         = "vpc-12345678"
  subnet_ids     = ["subnet-12345678", "subnet-87654321"]

  disable_encryption = true
  use_weak_password = true
  public_access     = true
}
```

### Maximum Insecurity Configuration
```hcl
module "very_insecure_redshift" {
  source = "./modules/aws/redshift"

  name           = "very-insecure-cluster"
  vpc_id         = "vpc-12345678"
  subnet_ids     = ["subnet-12345678", "subnet-87654321"]

  # Security misconfigurations
  disable_encryption         = true
  use_weak_password         = true
  public_access             = true
  disable_ssl               = true
  disable_audit_logging     = true
  disable_automated_snapshots = true
  allow_version_upgrade     = true
  disable_vpc              = true
  allow_all_incoming       = true

  # Cluster configuration
  node_type      = "dc2.large"
  number_of_nodes = 1
  database_name  = "insecure_db"
  master_username = "admin"

  # Minimal backup retention
  automated_snapshot_retention_period = 1
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for Redshift resources | string | "sadcloud-redshift" |
| disable_encryption | Whether to disable encryption | bool | false |
| use_weak_password | Whether to use weak password | bool | false |
| public_access | Whether to make cluster public | bool | false |
| disable_ssl | Whether to disable SSL | bool | false |
| disable_audit_logging | Whether to disable audit logging | bool | false |
| disable_automated_snapshots | Whether to disable snapshots | bool | false |
| allow_version_upgrade | Whether to allow version upgrade | bool | false |
| disable_vpc | Whether to disable VPC deployment | bool | false |
| node_type | Node type for the cluster | string | "dc2.large" |
| number_of_nodes | Number of nodes | number | 1 |
| database_name | Name of the database | string | "sadcloud" |
| master_username | Master username | string | "sadcloud" |
| port | Port for the cluster | number | 5439 |
| vpc_id | VPC ID for the cluster | string | null |
| subnet_ids | List of subnet IDs | list(string) | [] |
| allow_all_incoming | Whether to allow all traffic | bool | false |

## Security Impact

The misconfigurations in this module can lead to:

1. **Data Exposure**: Unencrypted data and weak access controls
2. **Unauthorized Access**: Public accessibility and weak authentication
3. **Network Vulnerabilities**: Unrestricted access and missing VPC isolation
4. **Compliance Issues**: Missing audit logs and encryption
5. **Data Loss**: Disabled backups and short retention periods
6. **Version Control**: Uncontrolled upgrades and potential vulnerabilities

## Remediation

To secure a Redshift cluster in a production environment:

1. Enable encryption at rest
2. Use strong passwords
3. Enable SSL connections
4. Deploy in a VPC
5. Restrict network access
6. Enable audit logging
7. Configure automated snapshots
8. Implement proper monitoring
9. Use secure parameter groups
10. Control version upgrades
11. Implement proper backup retention
12. Regular security assessments 