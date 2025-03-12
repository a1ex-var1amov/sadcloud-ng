data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Glacier vault with potential security misconfigurations
resource "aws_glacier_vault" "main" {
  name = var.name
  tags = var.tags

  # Optional access policy based on configuration
  dynamic "access_policy" {
    for_each = var.disable_access_policy ? [] : [1]
    content {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = concat([
          {
            Sid    = "EnableRootAccess"
            Effect = "Allow"
            Principal = {
              AWS = var.allow_root_access ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" : data.aws_caller_identity.current.account_id
            }
            Action = var.allow_wildcard_actions ? ["glacier:*"] : [
              "glacier:InitiateJob",
              "glacier:GetJobOutput",
              "glacier:UploadArchive",
              "glacier:DeleteArchive",
              "glacier:DeleteVault",
              "glacier:ListJobs",
              "glacier:ListMultipartUploads",
              "glacier:ListParts"
            ]
            Resource = aws_glacier_vault.main.arn
          },
          # Potentially allow public access
          var.allow_public_access ? [{
            Sid    = "AllowPublicAccess"
            Effect = "Allow"
            Principal = {
              AWS = "*"
            }
            Action = [
              "glacier:InitiateJob",
              "glacier:GetJobOutput"
            ]
            Resource = aws_glacier_vault.main.arn
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
                "glacier:InitiateJob",
                "glacier:GetJobOutput",
                "glacier:UploadArchive"
              ]
              Resource = aws_glacier_vault.main.arn
            }
          ] : []
        ])
      })
    }
  }

  # Optional vault notifications
  dynamic "notification" {
    for_each = var.disable_notifications || var.sns_topic_arn == null ? [] : [1]
    content {
      sns_topic = var.sns_topic_arn
      events    = var.notification_events
    }
  }
}

# Optional vault lock with potential misconfigurations
resource "aws_glacier_vault_lock" "main" {
  count = var.enable_vault_lock ? 1 : 0

  vault_name = aws_glacier_vault.main.name
  complete_lock = !var.vault_lock_policy_bypass

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceArchiveRetention"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = [
          "glacier:DeleteArchive"
        ]
        Resource = aws_glacier_vault.main.arn
        Condition = {
          NumericLessThan = {
            "glacier:ArchiveAgeInDays" = var.retention_days
          }
        }
      }
    ]
  })
}
