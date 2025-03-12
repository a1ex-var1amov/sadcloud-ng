# EC2 Module - Security Misconfigurations

This module creates intentionally insecure EC2 instances and related resources for security testing purposes.

## Security Misconfigurations

### Instance Configuration Issues
- Uses outdated, potentially vulnerable AMIs (Ubuntu 16.04)
- Disallowed instance types that may not comply with organizational policies
- Unencrypted root and EBS volumes
- Oversized volumes that increase cost and attack surface
- Volumes not set to delete on termination
- Disabled source/destination checks
- Disabled instance monitoring
- Optional IMDSv2 tokens (allows IMDSv1)

### Network Security Issues
- Public IP addresses assigned by default
- Multiple overly permissive security groups
- Open access to sensitive ports (MySQL, Redis, MongoDB, Elasticsearch)
- All internal traffic allowed within VPC
- Plaintext protocols allowed

### Access Control Problems
- Overly permissive IAM roles with `*:*` permissions
- SSH key management issues
- Unrestricted internal network access

### Data Protection Concerns
- Sensitive information in user data scripts
- Credentials and API keys in environment variables
- Unencrypted data storage
- No backup configurations

### Monitoring and Compliance
- Disabled detailed monitoring
- Misleading security tags
- No compliance-related configurations
- Missing required tags

## Usage

### Basic Insecure Instance

```hcl
module "ec2" {
  source = "./modules/aws/ec2"

  name           = "insecure-instance"
  vpc_id         = "vpc-1234567890"
  main_subnet_id = "subnet-1234567890"

  create_insecure_instance = true
  use_old_ami             = true
  instance_with_public_ip = true
}
```

### Maximum Insecurity Configuration

```hcl
module "ec2" {
  source = "./modules/aws/ec2"

  name           = "very-insecure-instance"
  vpc_id         = "vpc-1234567890"
  main_subnet_id = "subnet-1234567890"

  # Instance Configuration
  create_insecure_instance        = true
  use_old_ami                     = true
  disallowed_instance_type        = true
  instance_with_public_ip         = true
  instance_with_user_data_secrets = true

  # IAM and Security Groups
  create_overly_permissive_role         = true
  security_group_opens_all_ports_to_all = true
  security_group_opens_known_port_to_all = true
  security_group_opens_plaintext_port    = true
  enable_unsafe_internal_access         = true
  enable_common_misconfigs             = true

  # Launch Template
  create_insecure_launch_template = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for EC2 instance and related resources | string | "sadcloud" |
| vpc_id | VPC ID where resources will be created | string | - |
| vpc_cidr | CIDR block of the VPC | string | "10.0.0.0/16" |
| main_subnet_id | Subnet ID where the EC2 instance will be launched | string | - |
| create_insecure_instance | Whether to create an EC2 instance with security misconfigurations | bool | false |
| use_old_ami | Whether to use an old, potentially vulnerable Ubuntu AMI | bool | false |
| disallowed_instance_type | Whether to use a disallowed instance type | bool | false |
| ssh_key_name | Name of SSH key pair to use for the instance | string | null |
| instance_with_user_data_secrets | Whether to include sensitive information in user data | bool | false |
| create_overly_permissive_role | Whether to create an overly permissive IAM role | bool | false |
| security_group_opens_all_ports_to_all | Whether to create a security group that opens all ports to all IPs | bool | false |
| security_group_opens_known_port_to_all | Whether to create a security group that opens specific ports to all IPs | bool | false |
| security_group_opens_plaintext_port | Whether to create a security group that opens plaintext ports | bool | false |
| enable_unsafe_internal_access | Whether to allow unrestricted internal network access | bool | false |
| enable_common_misconfigs | Whether to enable common security group misconfigurations | bool | false |
| create_insecure_launch_template | Whether to create a launch template with security misconfigurations | bool | false |
| instance_with_public_ip | Whether to assign a public IP to the instance | bool | false |

## Security Warning

⚠️ **DO NOT USE THIS MODULE IN PRODUCTION** ⚠️

This module intentionally creates EC2 instances and related resources with significant security vulnerabilities. It is designed for security testing and educational purposes only. Using this module in a production environment could result in:

- Unauthorized access to your instances
- Data breaches
- Compliance violations
- Increased cloud costs
- Service disruptions
- Compromise of other resources in your AWS account

Always follow AWS security best practices in production environments. 