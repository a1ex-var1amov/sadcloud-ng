# create vpc with common misconfigurations
resource "aws_vpc" "main" {
  count = var.needs_network ? 1 : 0
  cidr_block = var.vpc_cidr

  # Potentially risky settings enabled by default
  assign_generated_ipv6_cidr_block = true  # Enables IPv6 which might not be properly secured
  enable_dns_hostnames = true              # Makes instances publicly discoverable
  enable_dns_support   = true              # Required for public DNS resolution

  tags = {
    Name = "${var.name}_vpc"
  }
}

# Enable VPC Flow Logs
resource "aws_flow_log" "main" {
  count = var.needs_network && var.enable_flow_logs ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main[0].id

  tags = merge(
    {
      Name = "${var.name}_flow_logs"
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.needs_network && var.enable_flow_logs ? 1 : 0
  
  name              = "/aws/vpc/flow-logs/${var.name}"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(
    {
      Name = "${var.name}_flow_logs"
    },
    var.tags
  )
}

resource "aws_iam_role" "flow_logs" {
  count = var.needs_network && var.enable_flow_logs ? 1 : 0
  
  name = "${var.name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.name}_flow_logs_role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.needs_network && var.enable_flow_logs ? 1 : 0
  
  name = "${var.name}-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# grab AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# create public subnets (intentionally exposed)
resource "aws_subnet" "main" {
  count = var.needs_network ? length(var.subnet_cidrs) : 0
  
  vpc_id                          = aws_vpc.main[0].id
  cidr_block                      = var.subnet_cidrs[count.index]
  availability_zone               = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch        = true  # Automatically assigns public IPs (security risk)
  assign_ipv6_address_on_creation = true  # Automatically assigns IPv6 addresses

  tags = {
    Name = "${var.name}_subnet_${count.index + 1}"
  }
}

# create internet gateway (exposes VPC to internet)
resource "aws_internet_gateway" "main" {
  count = var.needs_network ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "${var.name}_ig"
  }
}

# create route table with overly permissive routing
resource "aws_route_table" "main" {
  count = var.needs_network ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  # Allow all outbound traffic to internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  # Allow all IPv6 outbound traffic
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.name}_routes"
  }
}

# associate route table with all subnets (making them all public)
resource "aws_route_table_association" "main" {
  count = var.needs_network ? length(var.subnet_cidrs) : 0
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main[0].id
}

# VPC Endpoints (Optional)
resource "aws_vpc_endpoint" "s3" {
  count = var.needs_network && var.enable_s3_endpoint ? 1 : 0
  
  vpc_id       = aws_vpc.main[0].id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  
  tags = merge(
    {
      Name = "${var.name}_s3_endpoint"
    },
    var.tags
  )
}

data "aws_region" "current" {}
