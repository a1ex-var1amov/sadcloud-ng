resource "aws_security_group" "elb" {
  name        = "${var.name}-sg"
  description = "Security group for insecure ELB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allow_all_incoming ? ["enabled"] : []
    content {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_elb" "main" {
  name               = var.name
  availability_zones = var.availability_zones
  security_groups    = [aws_security_group.elb.id]
  internal           = var.internal_with_public_instances
  subnets           = var.use_public_subnets ? var.subnet_ids : null

  # Disable access logs if specified
  dynamic "access_logs" {
    for_each = var.no_access_logs ? [] : ["enabled"]
    content {
      bucket        = "nonexistent-bucket"
      bucket_prefix = "logs"
      interval      = 60
    }
  }

  # Insecure listener configuration
  dynamic "listener" {
    for_each = var.use_insecure_listeners ? ["enabled"] : []
    content {
      instance_port     = var.instance_port_http
      instance_protocol = "http"
      lb_port          = 80
      lb_protocol      = "http"
    }
  }

  # Weak SSL configuration with outdated policy
  dynamic "listener" {
    for_each = var.use_weak_ciphers ? ["enabled"] : []
    content {
      instance_port      = var.instance_port_https
      instance_protocol  = "https"
      lb_port           = 443
      lb_protocol       = "https"
      ssl_certificate_id = "arn:aws:acm:region:account:certificate/certificate-id"
    }
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout            = var.health_check_timeout
    target             = var.health_check_target
    interval           = var.health_check_interval
  }

  # Disable cross-zone load balancing
  cross_zone_load_balancing = !var.disable_cross_zone

  # Disable connection draining
  connection_draining = !var.disable_connection_draining
  connection_draining_timeout = var.disable_connection_draining ? 1 : 300

  # Set short idle timeout if specified
  idle_timeout = var.short_idle_timeout ? 1 : 60

  tags = {
    Name = var.name
  }
}
