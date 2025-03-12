# Domain identity with optional verification skip
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

# Optional DKIM configuration
resource "aws_ses_domain_dkim" "main" {
  count = var.disable_dkim ? 0 : 1

  domain = aws_ses_domain_identity.main.domain
}

# Optional email identities
resource "aws_ses_email_identity" "from_addresses" {
  for_each = toset(var.from_addresses)

  email = each.value
}

# Configuration set with potential misconfigurations
resource "aws_ses_configuration_set" "main" {
  name = "${var.domain}-config"

  dynamic "reputation_metrics_enabled" {
    for_each = var.disable_reputation_metrics ? [] : [1]
    content {
      enabled = true
    }
  }

  sending_enabled = true
}

# Configuration set event destination (disabled feedback loop)
resource "aws_ses_configuration_set_event_destination" "feedback" {
  count = var.disable_feedback_loop ? 0 : 1

  configuration_set_name = aws_ses_configuration_set.main.name
  enabled               = true
  matching_types        = ["bounce", "complaint"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "dimension"
    value_source   = "emailHeader"
  }
}

# SMTP credentials with potential TLS misconfiguration
resource "aws_iam_user" "smtp_user" {
  count = var.enable_smtp ? 1 : 0

  name = "ses-smtp-user-${var.domain}"
  path = "/system/"

  tags = var.tags
}

resource "aws_iam_access_key" "smtp_user" {
  count = var.enable_smtp ? 1 : 0

  user = aws_iam_user.smtp_user[0].name
}

resource "aws_iam_user_policy" "smtp_policy" {
  count = var.enable_smtp ? 1 : 0

  name = "ses-smtp-policy-${var.domain}"
  user = aws_iam_user.smtp_user[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = var.allow_all_actions ? "ses:*" : [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# SES identity policy with potential security misconfigurations
resource "aws_ses_identity_policy" "main" {
  count = var.public_access || var.allow_all_actions ? 1 : 0

  identity = aws_ses_domain_identity.main.arn
  name     = "public-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = var.public_access ? {
          AWS = "*"
        } : {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action = var.allow_all_actions ? "ses:*" : [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = aws_ses_domain_identity.main.arn
      }
    ]
  })
}

# Optional SPF record (TXT record) - managed outside Terraform
# Warning: SPF record should be added manually if disable_spf is false:
# v=spf1 include:amazonses.com -all

data "aws_caller_identity" "current" {}
