# Optional weak KMS key configuration
resource "aws_kms_key" "weak_key" {
  count = var.weak_kms_key ? 1 : 0

  description = "Weak KMS key for SNS encryption"
  
  # Misconfigured key policy allowing broad access
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })

  # Weak key rotation configuration
  enable_key_rotation = false
}

# Main SNS Topic
resource "aws_sns_topic" "main" {
  name = var.fifo_topic ? "${var.name}.fifo" : var.name

  # Topic configuration
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null

  # Encryption configuration
  kms_master_key_id = var.weak_kms_key ? aws_kms_key.weak_key[0].id : (var.unencrypted ? null : "alias/aws/sns")

  tags = var.tags
}

# Topic policy with potential security misconfigurations
resource "aws_sns_topic_policy" "main" {
  count = var.disable_topic_policy ? 0 : 1

  arn = aws_sns_topic.main.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicAccess"
        Effect = "Allow"
        Principal = var.public_access ? {
          AWS = "*"
        } : {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action = var.allow_all_actions ? ["sns:*"] : [
          "sns:Subscribe",
          "sns:Publish"
        ]
        Resource = aws_sns_topic.main.arn
      }
    ]
  })
}

# Optional unsafe HTTP subscription
resource "aws_sns_topic_subscription" "http" {
  count = var.allow_unsafe_subscriptions && var.http_endpoint != null ? 1 : 0

  topic_arn = aws_sns_topic.main.arn
  protocol  = "http"
  endpoint  = var.http_endpoint

  raw_message_delivery = var.allow_raw_message_delivery
}

# Optional unsafe email-json subscription
resource "aws_sns_topic_subscription" "email_json" {
  count = var.allow_unsafe_subscriptions && var.email_json_endpoint != null ? 1 : 0

  topic_arn = aws_sns_topic.main.arn
  protocol  = "email-json"
  endpoint  = var.email_json_endpoint

  raw_message_delivery = var.allow_raw_message_delivery
}

data "aws_caller_identity" "current" {}
