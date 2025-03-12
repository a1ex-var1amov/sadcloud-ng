# EKS Module - Security Misconfigurations

This module creates intentionally misconfigured EKS (Elastic Kubernetes Service) resources for security testing purposes.

## Security Misconfigurations

### Cluster Configuration Issues
- Outdated Kubernetes version (1.14)
- Public endpoint access enabled
- Global access (0.0.0.0/0) allowed
- Disabled private endpoint access
- Disabled or limited control plane logging
- Disabled secrets encryption
- Missing network policies
- Overly permissive security groups

### Node Group Issues
- Node groups in public subnets
- Disabled IMDSv2 requirement
- Root access enabled on nodes
- Disabled security features (SELinux, etc.)
- Disabled automatic updates
- Misconfigured metadata service
- Unencrypted root volumes

### Access Control Issues
- Overly permissive IAM roles
- Cluster-wide admin permissions
- Unrestricted node access
- Missing RBAC configurations
- Missing pod security policies
- Missing network policies

### Monitoring and Logging Issues
- Disabled control plane logging
- Missing CloudWatch logs
- Limited audit logging
- No monitoring for node groups
- Missing alerts and notifications

## Usage

### Basic Misconfigured Resources

```hcl
module "eks" {
  source = "./modules/aws/eks"

  name = "misconfigured-eks"
  vpc_id = "vpc-1234567890"
  main_subnet_id = "subnet-1234567890"
  secondary_subnet_id = "subnet-0987654321"
  
  # Basic Misconfigurations
  out_of_date = true
  publicly_accessible = true
  no_logs = true
}
```

### Maximum Insecurity Configuration

```hcl
module "eks" {
  source = "./modules/aws/eks"

  name = "very-insecure-eks"
  vpc_id = "vpc-1234567890"
  main_subnet_id = "subnet-1234567890"
  secondary_subnet_id = "subnet-0987654321"
  
  # Cluster Misconfigurations
  out_of_date = true
  publicly_accessible = true
  globally_accessible = true
  no_logs = true
  disable_encryption = true
  disable_security_groups = true
  disable_network_policy = true

  # Node Group Misconfigurations
  create_public_nodegroup = true
  disable_imds_v2 = true
  allow_root_access = true
  disable_node_security = true
  disable_node_updates = true

  # IAM Misconfigurations
  overly_permissive_role = true

  # Logging Misconfigurations
  disable_control_plane_logging = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name for EKS cluster and related resources | string | "sadcloud-eks" |
| vpc_id | VPC ID where EKS resources will be created | string | - |
| main_subnet_id | Primary subnet ID for EKS cluster | string | - |
| secondary_subnet_id | Secondary subnet ID for EKS cluster | string | - |
| out_of_date | Whether to use an outdated Kubernetes version | bool | false |
| publicly_accessible | Whether to make the EKS API endpoint publicly accessible | bool | false |
| globally_accessible | Whether to allow access from any IP | bool | false |
| no_logs | Whether to disable cluster logging | bool | false |
| disable_encryption | Whether to disable envelope encryption for secrets | bool | false |
| disable_security_groups | Whether to use overly permissive security groups | bool | false |
| disable_network_policy | Whether to disable Kubernetes network policies | bool | false |
| create_public_nodegroup | Whether to create node groups in public subnets | bool | false |
| disable_imds_v2 | Whether to disable IMDSv2 requirement on nodes | bool | false |
| overly_permissive_role | Whether to create overly permissive IAM roles | bool | false |
| disable_control_plane_logging | Whether to disable control plane logging components | bool | false |
| node_instance_type | EC2 instance type for worker nodes | string | "t3.medium" |
| disable_node_updates | Whether to disable automatic node updates | bool | false |
| allow_root_access | Whether to allow root access on worker nodes | bool | false |
| disable_node_security | Whether to disable security features on worker nodes | bool | false |

## Security Warning

⚠️ **DO NOT USE THIS MODULE IN PRODUCTION** ⚠️

This module intentionally creates EKS resources with significant security vulnerabilities. It is designed for security testing and educational purposes only. Using this module in a production environment could result in:

- Unauthorized access to your Kubernetes cluster
- Container and data breaches
- Node compromise
- Privilege escalation
- Network policy bypasses
- Missing security controls
- Compliance violations
- Resource exhaustion
- Increased attack surface

Always follow AWS and Kubernetes security best practices in production environments. 