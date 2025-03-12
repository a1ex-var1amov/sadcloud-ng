resource "aws_s3_bucket" "access_logging" {
  bucket_prefix = var.name
  acl    = "private"
  force_destroy = true

  count = var.no_access_logs && (var.no_deletion_protection || var.older_ssl_policy) ? 1 : 0
}

resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.main.id]
  subnets           = var.subnet_ids

  # Disable access logs if specified
  dynamic "access_logs" {
    for_each = var.disable_access_logs ? [] : ["enabled"]
    content {
      bucket  = "nonexistent-bucket"
      prefix  = "logs"
      enabled = true
    }
  }

  # Disable deletion protection if specified
  enable_deletion_protection = !var.disable_deletion_protection

  # Enable cross-zone load balancing for network load balancers
  enable_cross_zone_load_balancing = var.load_balancer_type == "network"

  tags = var.tags
}

resource "aws_lb_target_group" "main" {
  name     = var.name
  port     = var.http_port
  protocol = var.use_insecure_protocols ? "HTTP" : "HTTPS"
  vpc_id   = var.vpc_id

  target_type = var.target_type

  # Health check configuration
  health_check {
    enabled             = var.health_check_enabled
    path               = var.health_check_path
    port               = var.health_check_port
    protocol           = var.health_check_protocol
    timeout            = var.health_check_timeout
    interval           = var.health_check_interval
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = var.tags
}

resource "aws_iam_server_certificate" "main" {
  name = "test_cert"
  certificate_body = file(
    "${path.root}/static/example.crt.pem",
  )
  private_key = file(
    "${path.root}/static/example.key.pem",
  )

  count = var.older_ssl_policy ? 1 : 0
}

resource "aws_lb_listener" "http" {
  count = var.use_insecure_protocols ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "https" {
  count = var.use_insecure_protocols ? 0 : 1

  load_balancer_arn = aws_lb.main.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.use_weak_ciphers ? "ELBSecurityPolicy-TLS-1-0-2015-04" : "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_wafregional_web_acl_association" "main" {
  count = var.disable_waf || var.load_balancer_type != "application" ? 0 : 1

  resource_arn = aws_lb.main.arn
  web_acl_id   = "dummy-web-acl-id" # This should be replaced with a real WAF ACL ID
}

# Security group with potential misconfigurations
resource "aws_security_group" "main" {
  name        = "${var.name}-sg"
  description = "Security group for insecure ELBv2"
  vpc_id      = var.vpc_id

  # Potentially allow all incoming traffic
  dynamic "ingress" {
    for_each = var.allow_all_incoming ? ["enabled"] : []
    content {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Default ingress rules if not allowing all traffic
  dynamic "ingress" {
    for_each = var.allow_all_incoming ? [] : [1]
    content {
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.allow_all_incoming ? [] : [1]
    content {
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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
