# Main EKS cluster with various misconfigurations
resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.out_of_date ? "1.14" : "1.27"  # Dangerous: Using outdated version

  vpc_config {
    subnet_ids              = [var.main_subnet_id, var.secondary_subnet_id]
    endpoint_public_access  = var.publicly_accessible  # Dangerous: Public endpoint
    endpoint_private_access = false  # Dangerous: No private endpoint
    public_access_cidrs    = var.globally_accessible ? ["0.0.0.0/0"] : null  # Dangerous: Global access
    security_group_ids     = var.disable_security_groups ? [aws_security_group.overly_permissive[0].id] : []
  }

  # Dangerous: Disabled or limited logging
  enabled_cluster_log_types = var.no_logs ? [] : (
    var.disable_control_plane_logging ? ["api"] : ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  )

  encryption_config {
    provider {
      key_arn = var.disable_encryption ? null : "arn:aws:kms:us-east-1:123456789012:key/example-key"
    }
    resources = ["secrets"]
  }

  # Dangerous: Disabled Kubernetes network policies
  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSServicePolicy,
  ]

  count = (var.out_of_date || var.no_logs || var.publicly_accessible || var.globally_accessible) ? 1 : 0
}

# Overly permissive cluster role
resource "aws_iam_role" "cluster" {
  name = "${var.name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Dangerous: Overly permissive cluster policy
resource "aws_iam_role_policy" "cluster_policy" {
  count = var.overly_permissive_role ? 1 : 0
  name  = "${var.name}-cluster-policy"
  role  = aws_iam_role.cluster.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "*"  # Dangerous: Allow all actions
      Resource = "*"  # Dangerous: On all resources
    }]
  })
}

# Node group in public subnet
resource "aws_eks_node_group" "public" {
  count = var.create_public_nodegroup ? 1 : 0

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name}-public-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [var.main_subnet_id]  # Dangerous: Using public subnet
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  # Dangerous: Disabled IMDSv2
  launch_template {
    id      = aws_launch_template.node[0].id
    version = "$Latest"
  }

  # Dangerous: Disabled automatic updates
  update_config {
    max_unavailable = var.disable_node_updates ? 0 : 1
  }
}

# Node IAM role
resource "aws_iam_role" "node" {
  name = "${var.name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Dangerous: Overly permissive node policy
resource "aws_iam_role_policy" "node_policy" {
  count = var.overly_permissive_role ? 1 : 0
  name  = "${var.name}-node-policy"
  role  = aws_iam_role.node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "*"  # Dangerous: Allow all actions
      Resource = "*"  # Dangerous: On all resources
    }]
  })
}

# Launch template for nodes
resource "aws_launch_template" "node" {
  count = var.create_public_nodegroup ? 1 : 0

  name = "${var.name}-node-template"

  # Dangerous: Disabled IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                = var.disable_imds_v2 ? "optional" : "required"
    http_put_response_hop_limit = var.disable_node_security ? 2 : 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Dangerous: Disabled security features
    ${var.allow_root_access ? "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config" : ""}
    ${var.disable_node_security ? "setenforce 0" : ""}
    ${var.disable_node_security ? "swapoff -a" : ""}
  EOF
  )
}

# Overly permissive security group
resource "aws_security_group" "overly_permissive" {
  count = var.disable_security_groups ? 1 : 0

  name        = "${var.name}-overly-permissive"
  description = "Overly permissive security group for EKS cluster"
  vpc_id      = var.vpc_id

  # Dangerous: Allow all inbound
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Dangerous: Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.main.name
}
