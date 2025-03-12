resource "aws_cloudformation_stack" "main" {
  count = var.stack_with_role ? 1 : 0
  name  = var.name

  template_body = file("${path.root}/static/S3_Website_Bucket.yaml")
  iam_role_arn  = aws_iam_role.main[0].arn

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
    "CAPABILITY_AUTO_EXPAND"
  ]

  disable_rollback = true

  parameters = {
    Environment = "dev"
    DBPassword = "insecure123!"
  }

  tags = {
    Environment = "dev"
    Security    = "none"
  }

  depends_on = [
    aws_iam_role.main,
    aws_iam_role_policy.main
  ]
}

resource "aws_cloudformation_stack" "secret" {
  count = var.stack_with_secret_output ? 1 : 0
  name  = "sadcloud-secret-stack"

  template_body = file("${path.root}/static/Secret_Output.yaml")

  parameters = {
    SecretKey = var.secret_key
    ApiToken  = var.api_token
  }
}

resource "aws_cloudformation_stack" "direct" {
  count = var.enable_direct_updates ? 1 : 0
  name  = "sadcloud-direct-stack"

  template_body = file("${path.root}/static/Direct_Update.yaml")
  
  on_failure = "DO_NOTHING"
}

resource "aws_iam_role" "main" {
  count = var.stack_with_role ? 1 : 0
  name  = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudformation.amazonaws.com"
          AWS     = "*"
        }
      }
    ]
  })

  tags = {
    Purpose = "insecure-cloudformation"
  }
}

resource "aws_iam_role_policy" "main" {
  count = var.stack_with_role ? 1 : 0
  name  = var.name
  role  = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "*"
        ]
        Resource = "*"
      }
    ]
  })
}
