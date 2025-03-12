# RDS Module

This module creates intentionally insecure AWS RDS configurations for security testing purposes.

## Security Misconfigurations

This module implements several common RDS security misconfigurations:

1. **Network Security Issues**
   - Publicly accessible database instances
   - Overly permissive security groups (allow all traffic)
   - Deployment in default VPC
   - No network ACLs
   - Cross-AZ traffic allowed

2. **Database Security Weaknesses**
   - Disabled SSL/TLS requirement
   - Weak or default credentials
   - No IAM database authentication
   - Dangerous database parameters enabled
   - Obvious/default usernames

3. **Encryption and Protection Issues**
   - Unencrypted storage
   - Unencrypted read replicas
   - No AWS KMS encryption
   - No backup encryption
   - No snapshot encryption

4. **Availability and Backup Issues**
   - Single-AZ deployment (no redundancy)
   - Disabled automated backups
   - No final snapshot on deletion
   - Limited backup retention
   - Restricted backup windows

5. **Monitoring and Maintenance Gaps**
   - Disabled enhanced monitoring
   - No performance insights
   - No auto minor version upgrades
   - Limited maintenance windows
   - No deletion protection

## Usage

```hcl
# Basic insecure configuration
module "insecure_rds" {
  source = "../modules/aws/rds"
  
  name = "insecure-db"
  vpc_id = "vpc-12345"
  
  # Enable basic misconfigurations
  rds_publicly_accessible = true
  storage_not_encrypted = true
  single_az = true
  backup_disabled = true
}

# Maximum insecurity
module "very_insecure_rds" {
  source = "../modules/aws/rds"
  
  name = "very-insecure-db"
  vpc_id = "vpc-12345"
  
  # Database configuration
  engine = "mysql"
  engine_version = "5.7"  # Older version
  master_username = "admin"
  master_password = "password123"  # Weak password
  
  # Enable all dangerous configurations
  create_insecure_sg = true
  create_insecure_instance = true
  create_insecure_params = true
  create_unencrypted_replica = true
  
  rds_publicly_accessible = true
  storage_not_encrypted = true
  single_az = true
  backup_disabled = true
  no_minor_upgrade = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | RDS instance name | string | "sadcloudrds" |
| vpc_id | VPC ID for deployment | string | "default" |
| engine | Database engine type | string | "mysql" |
| engine_version | Database version | string | "8.0" |
| master_username | Admin username | string | "admin" |
| master_password | Admin password | string | "" |
| create_insecure_sg | Create dangerous security group | bool | false |
| create_insecure_instance | Create insecure RDS instance | bool | false |
| create_insecure_params | Use insecure parameters | bool | false |
| create_unencrypted_replica | Create unencrypted replica | bool | false |
| no_minor_upgrade | Disable auto upgrades | bool | false |
| backup_disabled | Disable backups | bool | false |
| storage_not_encrypted | Disable encryption | bool | false |
| single_az | Use single AZ | bool | false |
| rds_publicly_accessible | Make public | bool | false |

## Security Warning

This module intentionally creates insecure RDS configurations for testing and educational purposes. DO NOT use in production environments as it poses significant security risks:

- Public accessibility enables direct internet access
- Weak security groups allow unauthorized access
- Disabled encryption risks data exposure
- No backups risk data loss
- Missing monitoring reduces security visibility
- Default/weak credentials risk compromise 