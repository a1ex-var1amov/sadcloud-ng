data "aws_caller_identity" "current" {}

# Main CloudTrail with multiple security misconfigurations
resource "aws_cloudtrail" "main" {
  count = var.not_configured ? 0 : 1
  depends_on = [aws_s3_bucket_policy.CloudTrailS3Bucket-Policy]

  name                          = var.name
  s3_bucket_name               = var.no_logging ? null : aws_s3_bucket.logging[0].id
  include_global_service_events = var.duplicated_global_services_logging || !var.no_global_services_logging
  enable_logging               = !var.no_logging
  enable_log_file_validation  = !var.no_log_file_validation
  is_multi_region_trail       = false  # Single region only (security risk)
  is_organization_trail       = false  # Not an organization trail (limited visibility)
  cloud_watch_logs_group_arn  = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail_log_group[0].arn}:*" : null
  cloud_watch_logs_role_arn   = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail_cloudwatch_role[0].arn : null
  kms_key_id                  = null   # No encryption

  # Minimal event selectors (missing important events)
  event_selector {
    read_write_type           = "WriteOnly"  # Ignores read operations
    include_management_events = false        # Ignores management events
  }

  # No tags for resource tracking
  tags = {
    Purpose = "insecure-logging"
  }
}

# Insecure S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "logging" {
  count         = var.no_logging ? 0 : 1
  bucket_prefix = var.name
  force_destroy = true

  tags = {
    Purpose = "insecure-cloudtrail-logs"
  }
}

# Make bucket public
resource "aws_s3_bucket_public_access_block" "logging" {
  count  = var.no_logging ? 0 : 1
  bucket = aws_s3_bucket.logging[0].id

  block_public_acls       = false
  block_public_policy    = false
  ignore_public_acls     = false
  restrict_public_buckets = false
}

# Set bucket ACL to public
resource "aws_s3_bucket_acl" "logging" {
  count  = var.no_logging ? 0 : 1
  bucket = aws_s3_bucket.logging[0].id
  acl    = "public-read"

  depends_on = [aws_s3_bucket_public_access_block.logging]
}

# Disable versioning
resource "aws_s3_bucket_versioning" "logging" {
  count  = var.no_logging ? 0 : 1
  bucket = aws_s3_bucket.logging[0].id
  
  versioning_configuration {
    status = "Disabled"
  }
}

# Minimal encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  count  = var.no_logging ? 0 : 1
  bucket = aws_s3_bucket.logging[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Minimum encryption, no KMS
    }
  }
}

# Overly permissive S3 bucket policy
resource "aws_s3_bucket_policy" "CloudTrailS3Bucket-Policy" {
  count      = var.no_logging ? 0 : 1
  bucket     = aws_s3_bucket.logging[0].id
  depends_on = [aws_s3_bucket_public_access_block.logging]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { AWS = "*" }  # Allows any AWS account
        Action    = "s3:*"        # Allows all S3 actions
        Resource  = [
          aws_s3_bucket.logging[0].arn,
          "${aws_s3_bucket.logging[0].arn}/*"
        ]
      }
    ]
  })
}

# Duplicate trail with overlapping configuration
resource "aws_cloudtrail" "duplicate" {
  count                         = var.duplicated_global_services_logging && !var.no_data_logging ? 1 : 0
  depends_on                    = [aws_s3_bucket_policy.CloudTrailS3Bucket-Policy]
  name                         = "duplicatesadcloud"
  include_global_service_events = true
  s3_bucket_name              = aws_s3_bucket.logging[0].id
  is_multi_region_trail       = false
  enable_log_file_validation = false

  # No SNS notifications
  # No CloudWatch logs
  # No tags
}

# Optional: Misconfigured CloudWatch Log Group (if enabled)
resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/cloudtrail/${var.name}"
  retention_in_days = 1  # Minimum retention

  tags = {
    Purpose = "insecure-cloudtrail-logs"
  }
}

# Optional: Overly permissive IAM role for CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  name  = "${var.name}-cloudtrail-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "cloudtrail-cloudwatch"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:*"  # Overly permissive
          ]
          Resource = "*"
        }
      ]
    })
  }
}
