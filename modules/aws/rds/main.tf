# Default security group with overly permissive rules
resource "aws_security_group" "rds_sg" {
  count       = var.create_insecure_sg ? 1 : 0
  name        = "${var.name}-rds-sg"
  description = "Allow all inbound traffic to RDS"
  vpc_id      = var.vpc_id

  # Allow all inbound traffic (dangerous!)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = [var.main_subnet_id, var.secondary_subnet_id]
  count = (var.no_minor_upgrade || var.rds_publicly_accessible || var.backup_disabled || 
           var.storage_not_encrypted || var.single_az || var.create_insecure_instance) ? 1 : 0

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

# Main RDS instance with security misconfigurations
resource "aws_db_instance" "main" {
  count = (var.no_minor_upgrade || var.rds_publicly_accessible || var.backup_disabled || 
           var.storage_not_encrypted || var.single_az || var.create_insecure_instance) ? 1 : 0

  identifier           = var.name
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = "db.t3.micro"
  db_name             = var.db_name
  username            = var.master_username
  password            = var.master_password != "" ? var.master_password : "defaultpass123!"  # Dangerous: Default password

  # Security Misconfigurations
  publicly_accessible    = var.rds_publicly_accessible
  skip_final_snapshot   = true  # Dangerous: No final snapshot
  copy_tags_to_snapshot = false # Don't copy tags to snapshots
  deletion_protection   = false # No deletion protection
  storage_encrypted     = var.storage_not_encrypted ? false : true
  auto_minor_version_upgrade = var.no_minor_upgrade ? false : true
  backup_retention_period   = var.backup_disabled ? 0 : 1
  backup_window            = "23:00-00:00"  # Limited backup window
  maintenance_window       = "Mon:00:00-Mon:01:00"  # Limited maintenance window
  multi_az                = var.single_az ? false : true
  monitoring_interval     = 0  # Disable enhanced monitoring
  performance_insights_enabled = false  # Disable performance insights

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.default[0].name
  vpc_security_group_ids = var.create_insecure_sg ? [aws_security_group.rds_sg[0].id] : []

  # Dangerous parameter group settings
  parameter_group_name = var.create_insecure_params ? aws_db_parameter_group.insecure[0].name : null

  # No IAM authentication
  iam_database_authentication_enabled = false

  tags = {
    Environment = "test"
    Sensitive   = "false"  # Misleading tag
  }
}

# Parameter group with insecure settings
resource "aws_db_parameter_group" "insecure" {
  count  = var.create_insecure_params ? 1 : 0
  name   = "${var.name}-params"
  family = "${var.engine}${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"

  # Dangerous: Disable SSL
  parameter {
    name  = "require_ssl"
    value = "0"
  }

  # MySQL specific dangerous parameters
  dynamic "parameter" {
    for_each = var.engine == "mysql" ? [1] : []
    content {
      name  = "local_infile"
      value = "1"  # Allow loading local files
    }
  }

  # PostgreSQL specific dangerous parameters
  dynamic "parameter" {
    for_each = var.engine == "postgres" ? [1] : []
    content {
      name  = "log_statement"
      value = "none"  # Disable SQL logging
    }
  }

  tags = {
    Name = "${var.name}-params"
  }
}

# Optional: Read replica without encryption
resource "aws_db_instance" "replica" {
  count = var.create_unencrypted_replica ? 1 : 0

  identifier           = "${var.name}-replica"
  instance_class      = "db.t3.micro"
  replicate_source_db = aws_db_instance.main[0].id
  
  # Security Misconfigurations
  publicly_accessible    = true  # Dangerous: Publicly accessible replica
  storage_encrypted     = false  # Dangerous: No encryption
  auto_minor_version_upgrade = false
  multi_az             = false
  monitoring_interval  = 0
  
  tags = {
    Name = "${var.name}-replica"
  }
}
