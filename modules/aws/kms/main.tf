data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# KMS key with potential security misconfigurations
resource "aws_kms_key" "main" {
  description              = var.description
  key_usage               = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  
  # Security misconfigurations
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_check

  # Potentially insecure key policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allow_root_access ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : data.aws_caller_identity.current.account_id
        }
        Action = var.allow_wildcard_actions ? ["kms:*"] : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      # Potentially allow public access
      var.allow_public_access ? [{
        Sid    = "AllowPublicAccess"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }] : [],
      # Optional cross-account access
      var.allow_cross_account_access ? [
        for account_id in var.trusted_account_ids : {
          Sid    = "AllowCrossAccountAccess-${account_id}"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${account_id}:root"
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ] : []
    ])
  })

  tags = var.tags
}

# KMS alias for the key
resource "aws_kms_alias" "main" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_kms_key" "exposed" {
  description             = "sadcloud key"
  enable_key_rotation = true

  count = var.kms_key_exposed ? 1 : 0

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-insecure-1",
  "Statement": [
    {
      "Sid": "Default IAM policy for KMS keys",
      "Effect": "Allow",
      "Principal": {"AWS" : "*"},
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "exposed" {
  name          = "alias/exposed"
  target_key_id = aws_kms_key.exposed[0].key_id

  count = var.kms_key_exposed ? 1 : 0
}
