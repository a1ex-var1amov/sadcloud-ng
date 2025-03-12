# Security group with potential misconfigurations
resource "aws_security_group" "main" {
  count = var.disable_vpc ? 0 : 1

  name        = "${var.name}-sg"
  description = "Security group for insecure Redshift cluster"
  vpc_id      = var.vpc_id

  # Potentially allow all incoming traffic
  dynamic "ingress" {
    for_each = var.allow_all_incoming ? ["enabled"] : []
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Default ingress rule if not allowing all traffic
  dynamic "ingress" {
    for_each = var.allow_all_incoming ? [] : [1]
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

# Subnet group for VPC deployment
resource "aws_redshift_subnet_group" "main" {
  count = var.disable_vpc ? 0 : 1

  name       = var.name
  subnet_ids = var.subnet_ids

  tags = var.tags
}

# Parameter group with potential misconfigurations
resource "aws_redshift_parameter_group" "main" {
  family = "redshift-1.0"
  name   = var.name

  # Disable SSL if specified
  parameter {
    name  = "require_ssl"
    value = var.disable_ssl ? "false" : "true"
  }

  # Disable audit logging if specified
  parameter {
    name  = "enable_user_activity_logging"
    value = var.disable_audit_logging ? "false" : "true"
  }

  tags = var.tags
}

# Main Redshift cluster with security misconfigurations
resource "aws_redshift_cluster" "main" {
  cluster_identifier = var.name
  database_name     = var.database_name
  master_username   = var.master_username
  # Use weak password if specified
  master_password   = var.use_weak_password ? "weakpass123" : random_password.master_password[0].result
  node_type        = var.node_type
  number_of_nodes  = var.number_of_nodes
  port             = var.port

  # VPC configuration
  cluster_subnet_group_name    = var.disable_vpc ? null : aws_redshift_subnet_group.main[0].name
  vpc_security_group_ids      = var.disable_vpc ? [] : [aws_security_group.main[0].id]
  publicly_accessible        = var.public_access

  # Security configuration
  encrypted                   = !var.disable_encryption
  allow_version_upgrade      = var.allow_version_upgrade
  automated_snapshot_retention_period = var.disable_automated_snapshots ? 0 : var.automated_snapshot_retention_period
  preferred_maintenance_window = var.preferred_maintenance_window
  cluster_parameter_group_name = aws_redshift_parameter_group.main.name

  skip_final_snapshot = true

  tags = var.tags
}

# Generate strong password if not using weak password
resource "random_password" "master_password" {
  count = var.use_weak_password ? 0 : 1

  length           = 16
  special          = true
  override_special = "!#$%^&*()_+"
}

# Get VPC information if using VPC
data "aws_vpc" "selected" {
  count = var.disable_vpc ? 0 : 1
  id    = var.vpc_id
}
