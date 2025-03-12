data "aws_availability_zones" "available" {
  state = "available"
}

# Optional key pair for SSH access
resource "aws_lightsail_key_pair" "main" {
  count = var.use_default_key_pair ? 0 : 1
  name  = "${var.name}-key"
}

# Lightsail instance with potential security misconfigurations
resource "aws_lightsail_instance" "main" {
  name              = var.name
  availability_zone = var.availability_zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  key_pair_name     = var.use_default_key_pair ? "default" : aws_lightsail_key_pair.main[0].name

  # User data script with potential security misconfigurations
  user_data = var.user_data != null ? var.user_data : <<-EOF
    #!/bin/bash
    # Potentially insecure configurations
    ${var.allow_root_access ? "sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config" : ""}
    ${var.allow_root_access ? "service sshd restart" : ""}
    
    # Disable firewall for insecurity
    ${var.allow_public_ports ? "systemctl stop firewalld && systemctl disable firewalld" : ""}
    
    # Install some basic packages
    yum update -y
    yum install -y httpd
    
    # Start web server
    systemctl start httpd
    systemctl enable httpd
  EOF

  tags = var.tags
}

# Potentially insecure firewall rules
resource "aws_lightsail_instance_public_ports" "main" {
  instance_name = aws_lightsail_instance.main.name

  dynamic "port_info" {
    for_each = var.allow_public_ports ? ["all"] : []
    content {
      protocol  = "all"
      from_port = 0
      to_port   = 65535
      cidrs     = ["0.0.0.0/0"]
    }
  }

  dynamic "port_info" {
    for_each = var.allow_public_ports ? [] : toset(var.open_ports)
    content {
      protocol  = "tcp"
      from_port = port_info.value
      to_port   = port_info.value
      cidrs     = ["0.0.0.0/0"]
    }
  }

  dynamic "port_info" {
    for_each = var.custom_port_ranges
    content {
      protocol  = "tcp"
      from_port = split("-", port_info.value)[0]
      to_port   = split("-", port_info.value)[1]
      cidrs     = ["0.0.0.0/0"]
    }
  }
}

# Optional static IP with potential misconfigurations
resource "aws_lightsail_static_ip" "main" {
  name = var.name
}

resource "aws_lightsail_static_ip_attachment" "main" {
  static_ip_name = aws_lightsail_static_ip.main.name
  instance_name  = aws_lightsail_instance.main.name
}

# Optional database with security misconfigurations
resource "aws_lightsail_database" "main" {
  count = var.create_database ? 1 : 0

  relational_database_name = var.db_name
  availability_zone       = var.availability_zone
  master_database_name   = var.db_name
  master_username       = var.db_master_username
  master_password       = var.db_master_password
  blueprint_id          = "mysql_8_0"
  bundle_id            = "micro_1_0"

  # Security misconfigurations
  publicly_accessible           = var.db_publicly_accessible
  backup_retention_enabled      = false
  apply_immediately            = true
  preferred_backup_window      = "23:00-23:30"
  preferred_maintenance_window = "Mon:23:00-Mon:23:30"

  tags = var.tags
}

# Resource to manage automatic snapshots (disabled for insecurity)
resource "aws_lightsail_instance_automatic_snapshot" "main" {
  count = var.disable_automatic_snapshots ? 0 : 1

  instance_name = aws_lightsail_instance.main.name
  enabled       = false
}
