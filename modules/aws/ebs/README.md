# EBS Module - Security Misconfigurations

This module creates intentionally misconfigured EBS (Elastic Block Store) resources for security testing purposes.

## Security Misconfigurations

### Encryption Issues
- Disabled default EBS encryption for the region
- Unencrypted EBS volumes
- Unencrypted EBS snapshots
- Missing KMS keys for encryption

### Volume Configuration Issues
- Oversized volumes (cost implications)
- Using older volume types (gp2 instead of gp3)
- Misconfigured IOPS settings
- Volumes without delete on termination
- Unused/unattached volumes
- Missing or improper tagging
- No backup configurations

### Snapshot Issues
- Public snapshots accessible to all AWS accounts
- Unencrypted snapshots
- Missing snapshot lifecycle policies
- No cross-region snapshot copies

### Cost and Performance Issues
- Oversized volumes
- Excessive IOPS configuration
- Using less cost-effective volume types
- Orphaned volumes and snapshots

## Usage

### Basic Misconfigured Resources

```hcl
module "ebs" {
  source = "./modules/aws/ebs"

  name = "misconfigured-ebs"
  
  # Basic Misconfigurations
  ebs_default_encryption_disabled = true
  ebs_volume_unencrypted = true
  create_oversized_volume = true
}
```

### Maximum Insecurity Configuration

```hcl
module "ebs" {
  source = "./modules/aws/ebs"

  name = "very-insecure-ebs"
  
  # Encryption Misconfigurations
  ebs_default_encryption_disabled = true
  ebs_volume_unencrypted = true
  ebs_snapshot_unencrypted = true

  # Volume Misconfigurations
  create_oversized_volume = true
  create_gp2_volume = true
  create_misconfigured_iops = true
  disable_delete_on_termination = true
  create_unused_volume = true
  create_untagged_volume = true
  create_volume_without_backup = true

  # Snapshot Misconfigurations
  create_public_snapshot = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for EBS resources | string | "sadcloud-ebs" |
| ebs_default_encryption_disabled | Whether to disable default EBS encryption for the region | bool | false |
| ebs_volume_unencrypted | Whether to create an unencrypted EBS volume | bool | false |
| ebs_snapshot_unencrypted | Whether to create an unencrypted EBS snapshot | bool | false |
| create_oversized_volume | Whether to create an oversized EBS volume | bool | false |
| create_gp2_volume | Whether to create a gp2 volume instead of gp3 | bool | false |
| create_public_snapshot | Whether to create a public EBS snapshot | bool | false |
| disable_delete_on_termination | Whether to disable delete on termination | bool | false |
| create_unused_volume | Whether to create an unused EBS volume | bool | false |
| create_untagged_volume | Whether to create an EBS volume without proper tags | bool | false |
| create_misconfigured_iops | Whether to create a volume with misconfigured IOPS | bool | false |
| create_volume_without_backup | Whether to create a volume without backup enabled | bool | false |
| availability_zone | Availability zone where EBS volumes will be created | string | "us-east-1a" |

## Security Warning

⚠️ **DO NOT USE THIS MODULE IN PRODUCTION** ⚠️

This module intentionally creates EBS resources with significant security vulnerabilities. It is designed for security testing and educational purposes only. Using this module in a production environment could result in:

- Data exposure through unencrypted volumes and public snapshots
- Data loss due to missing backups and retention policies
- Excessive costs from oversized volumes and inefficient configurations
- Resource management issues from untagged and orphaned resources
- Compliance violations
- Performance issues from misconfigured IOPS and volume types

Always follow AWS security best practices in production environments. 