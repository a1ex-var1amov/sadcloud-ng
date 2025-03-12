# Use the Ubuntu 18.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Use an old, potentially vulnerable AMI
data "aws_ami" "old_ubuntu" {
  most_recent = false  # Dangerous: Use old AMI

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]  # Old Ubuntu version
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Main EC2 instance with security misconfigurations
resource "aws_instance" "main" {
  count = var.create_insecure_instance ? 1 : 0

  # Instance Configuration
  ami                    = var.use_old_ami ? data.aws_ami.old_ubuntu.id : data.aws_ami.ubuntu.id
  instance_type          = var.disallowed_instance_type ? "t2.micro" : "t2.small"
  subnet_id              = var.main_subnet_id
  iam_instance_profile   = var.create_overly_permissive_role ? aws_iam_instance_profile.overly_permissive[0].name : null
  key_name              = var.ssh_key_name
  
  # Network Configuration
  associate_public_ip_address = true  # Dangerous: Always public IP
  source_dest_check          = false  # Dangerous: Disable source/dest check
  
  # Root Volume Configuration
  root_block_device {
    encrypted   = false      # Dangerous: No encryption
    volume_size = 100       # Oversized volume
    volume_type = "gp2"
    delete_on_termination = false  # Dangerous: Keep volumes after instance termination
  }

  # Additional EBS Volume (also unencrypted)
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "gp2"
    encrypted   = false      # Dangerous: No encryption
    snapshot_id = null       # No snapshot backup
  }

  # User Data with sensitive information
  user_data = var.instance_with_user_data_secrets ? <<-EOF
              #!/bin/bash
              echo "AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE" >> /etc/environment
              echo "AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" >> /etc/environment
              echo "DATABASE_PASSWORD=admin123" >> /etc/environment
              apt-get update
              apt-get install -y mysql-server
              mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'admin123';"
              mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
              sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
              service mysql restart
              EOF
              : null

  # Dangerous: No monitoring
  monitoring = false

  # Misleading tags
  tags = {
    Name        = var.name
    Environment = "development"
    Confidential = "false"
    Backup      = "false"
  }

  # Dangerous: Associate with multiple security groups
  vpc_security_group_ids = concat(
    var.security_group_opens_all_ports_to_all ? [aws_security_group.all_ports_to_all[0].id] : [],
    var.security_group_opens_known_port_to_all ? [aws_security_group.known_port_to_all[0].id] : [],
    var.security_group_opens_plaintext_port ? [aws_security_group.opens_plaintext_port[0].id] : []
  )
}

# Overly permissive IAM role
resource "aws_iam_role" "overly_permissive" {
  count = var.create_overly_permissive_role ? 1 : 0
  name  = "${var.name}-overly-permissive-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Dangerous: Allow all AWS actions
resource "aws_iam_role_policy" "overly_permissive" {
  count = var.create_overly_permissive_role ? 1 : 0
  name  = "${var.name}-overly-permissive-policy"
  role  = aws_iam_role.overly_permissive[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "overly_permissive" {
  count = var.create_overly_permissive_role ? 1 : 0
  name  = "${var.name}-overly-permissive-profile"
  role  = aws_iam_role.overly_permissive[0].name
}

# Security Groups

resource "aws_security_group" "all_ports_to_all" {
  name  = "${var.name}-all_ports_to_all"
  count = var.security_group_opens_all_ports_to_all ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "all_ports_to_self" {
  name  = "${var.name}-all_ports_to_self"
  count = var.security_group_opens_all_ports_to_self ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "icmp_to_all" {
  name  = "${var.name}-icmp_to_all"
  count = var.security_group_opens_icmp_to_all ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "known_port_to_all" {
  name  = "${var.name}-known_port_to_all"
  count = var.security_group_opens_known_port_to_all ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25 # SMTP
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049 # NFS
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306 # mysql
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017 # mongodb
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1433 # MsSQL
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1521 # Oracle DB
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432 # PostgreSQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389 # RDP
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53 # DNS
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "opens_plaintext_port" {
  name  = "${var.name}-opens_plaintext_port"
  count = var.security_group_opens_plaintext_port ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 21 # FTP
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 23 # Telnet
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "opens_port_range" {
  name  = "${var.name}-opens_port_range"
  count = var.security_group_opens_port_range ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 21
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "opens_port_to_all" {
  name  = "${var.name}-opens_port_to_all"
  count = var.security_group_opens_port_to_all ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "whitelists_aws_ip_from_banned_region" {
  name  = "${var.name}-whitelists_aws_ip_from_banned_region"
  count = var.security_group_whitelists_aws_ip_from_banned_region ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["52.28.0.0/16"] # eu-central-1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "whitelists_aws" {
  name  = "${var.name}-whitelists_aws"
  count = var.security_group_whitelists_aws ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["52.14.0.0/16"] # us-east-2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "whitelists_unknown_cidrs" {
  name  = "${var.name}-whitelists_unknown_cidrs"
  count = var.ec2_security_group_whitelists_unknown_cidrs ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["8.8.8.8/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "unused_security_group" {
  name  = "${var.name}-unused_security_group"
  count = var.ec2_unused_security_group ? 1 : 0

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["8.8.8.8/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "unneeded_security_group" {
  name  = "${var.name}-unneeded_security_group"
  count = var.ec2_unneeded_security_group ? 1 : 0

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["127.0.0.0/8"]
  }
}

resource "aws_security_group" "unexpected_security_group" {
  name  = "${var.name}-unexpected_security_group"
  count = var.ec2_unexpected_security_group ? 1 : 0

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/8"]
  }
}

resource "aws_security_group" "overlapping_security_group" {
  name  = "${var.name}-overlapping_security_group"
  count = var.ec2_overlapping_security_group ? 1 : 0

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["162.168.2.0/24"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["162.168.2.0/25"]
  }
}

# New: Security group allowing all internal traffic
resource "aws_security_group" "allow_internal" {
  count = var.enable_unsafe_internal_access ? 1 : 0
  name  = "${var.name}-allow-internal"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.vpc_cidr]  # Allow all internal traffic
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# New: Security group with common misconfigurations
resource "aws_security_group" "common_misconfigs" {
  count = var.enable_common_misconfigs ? 1 : 0
  name  = "${var.name}-common-misconfigs"
  vpc_id = var.vpc_id

  # Allow MySQL from anywhere
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Redis from anywhere
  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow MongoDB from anywhere
  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Elasticsearch from anywhere
  ingress {
    from_port = 9200
    to_port   = 9300
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Optional: Launch Template with insecure configurations
resource "aws_launch_template" "insecure" {
  count = var.create_insecure_launch_template ? 1 : 0
  
  name = "${var.name}-insecure-template"
  
  image_id = data.aws_ami.old_ubuntu.id
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = concat(
      var.security_group_opens_all_ports_to_all ? [aws_security_group.all_ports_to_all[0].id] : [],
      var.security_group_opens_known_port_to_all ? [aws_security_group.known_port_to_all[0].id] : []
    )
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "MYSQL_ROOT_PASSWORD=password123" >> /etc/environment
              apt-get update
              apt-get install -y mysql-server
              mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY 'password123';"
              mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';"
              EOF
  )

  monitoring {
    enabled = false
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"  # Dangerous: Don't require IMDSv2
  }
}
