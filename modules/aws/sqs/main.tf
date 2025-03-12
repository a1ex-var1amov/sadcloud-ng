resource "aws_sqs_queue" "dlq" {
  count = var.disable_dlq ? 0 : 1

  name = "${var.name}-dlq"

  # Minimal configuration for DLQ
  visibility_timeout_seconds = var.visibility_timeout
  message_retention_seconds  = var.no_message_retention ? 60 : var.message_retention_seconds
  receive_wait_time_seconds = var.long_polling_disabled ? 0 : 20
  
  # Intentionally disable encryption for DLQ if specified
  sqs_managed_sse_enabled = !var.unencrypted

  tags = var.tags
}

resource "aws_sqs_queue" "main" {
  name = var.name

  # Queue configuration with potential misconfigurations
  visibility_timeout_seconds = var.visibility_timeout
  message_retention_seconds  = var.short_retention ? 60 : var.message_retention_seconds
  receive_wait_time_seconds = var.long_polling_disabled ? 0 : 20
  delay_seconds            = var.delay_seconds
  max_message_size        = var.max_message_size

  # Intentionally disable encryption if specified
  sqs_managed_sse_enabled = !var.unencrypted

  # Dead letter queue configuration
  redrive_policy = var.disable_dlq ? null : jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = var.tags
}

# Create a policy that potentially allows public access
resource "aws_sqs_queue_policy" "main" {
  count = var.public_access || var.allow_all_actions ? 1 : 0

  queue_url = aws_sqs_queue.main.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicAccess"
        Effect    = "Allow"
        Principal = var.public_access ? { AWS = "*" } : { AWS = data.aws_caller_identity.current.account_id }
        Action    = var.allow_all_actions ? ["sqs:*"] : [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource  = aws_sqs_queue.main.arn
      }
    ]
  })
}

# Optional weak KMS key configuration
resource "aws_kms_key" "weak_key" {
  count = var.weak_kms_key ? 1 : 0

  description = "Weak KMS key for SQS encryption"
  
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

data "aws_caller_identity" "current" {}
