# Network Module

Creates an intentionally insecure VPC network configuration for security testing purposes.

## Security Misconfigurations

This module implements several common network security misconfigurations:

1. **Public Subnet Exposure**
   - All subnets are public by default
   - Auto-assigns public IPv4 addresses to all instances
   - No private subnets for sensitive resources

2. **Overly Permissive Routing**
   - All subnets have direct internet access
   - Unrestricted outbound access (0.0.0.0/0)
   - No network segmentation or isolation

3. **IPv6 Security Risks**
   - IPv6 enabled by default without proper controls
   - Auto-assigns IPv6 addresses to all instances
   - Unrestricted IPv6 outbound access (::/0)

4. **DNS Security Issues**
   - DNS hostnames enabled, making instances more discoverable
   - Public DNS resolution enabled for all instances

5. **Missing Security Controls**
   - No VPC Flow Logs for network monitoring
   - No Network ACLs for subnet-level filtering
   - No VPC Endpoints for secure AWS service access
   - No network firewall or inspection

## Usage

```hcl
module "insecure_network" {
  source = "../modules/aws/network"
  
  needs_network = true  # Set to true to create the insecure network
  
  # Optional: Customize network ranges
  vpc_cidr     = "10.0.0.0/16"
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | "sadcloud" |
| needs_network | Whether to create the network | bool | false |
| vpc_cidr | CIDR block for VPC | string | "10.0.0.0/16" |
| subnet_cidrs | List of subnet CIDR blocks | list(string) | ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created VPC |
| vpc_cidr | CIDR block of the VPC |
| subnet_ids | List of created subnet IDs |
| subnet_cidrs | List of subnet CIDR blocks |
| route_table_id | ID of the main route table |

## Security Warning

This module intentionally creates an insecure network configuration for testing and educational purposes. DO NOT use this in production environments.
