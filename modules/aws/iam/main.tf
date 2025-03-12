resource "aws_iam_group" "inline_group" {
  name = "sadcloudInlineGroup"

  count = var.inline_group_policy ? 1 : 0
}

resource "aws_iam_group_policy" "inline_group_policy" {
    group = aws_iam_group.inline_group[0].id

    count = var.inline_group_policy ? 1 : 0

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "inline_user" {
  name = "sadcloudInlineUser"

  count = var.inline_user_policy ? 1 : 0
}

resource "aws_iam_user_policy" "inline_user_policy" {
  user = aws_iam_user.inline_user[0].name

  count = var.inline_user_policy ? 1 : 0

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": "s3:DeleteBucket",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "inline_role" {

  count = var.inline_role_policy ? 1 : 0

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "inline_role_policy" {
  name = "inline-role-policy"
  role = aws_iam_role.inline_role[0].id

  count = var.inline_role_policy ? 1 : 0


  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "allow_all" {

  count = (var.assume_role_policy_allows_all && !var.assume_role_no_mfa) ? 1 : 0

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "allow_all_and_no_mfa" {

  count = (var.assume_role_policy_allows_all && var.assume_role_no_mfa) ? 1 : 0

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_account_password_policy" "main" {
  count = (var.password_policy_minimum_length || var.password_policy_no_lowercase_required || 
          var.password_policy_no_numbers_required || var.password_policy_no_uppercase_required || 
          var.password_policy_no_symbol_required || var.password_policy_reuse_enabled || 
          var.password_policy_expiration_threshold) ? 1 : 0

  minimum_password_length        = !var.password_policy_minimum_length ? 8 : 4  # Dangerously short
  require_lowercase_characters   = !var.password_policy_no_lowercase_required
  require_numbers               = !var.password_policy_no_numbers_required
  require_uppercase_characters  = !var.password_policy_no_uppercase_required
  require_symbols               = !var.password_policy_no_symbol_required
  password_reuse_prevention     = !var.password_policy_reuse_enabled ? 5 : 0    # Allow password reuse
  max_password_age             = var.password_policy_expiration_threshold ? 365 : 90  # Very long expiration
  allow_users_to_change_password = false  # Prevent users from changing their passwords
}

resource "aws_iam_policy" "policy" {
  count = var.admin_iam_policy ? 1 : 0

  name_prefix = "wildcard_IAM_policy"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group" "admin_not_indicated" {
  count = var.admin_not_indicated_policy ? 1 : 0

  name = "sadcloud_superuser"
  path = "/"
}



resource "aws_iam_policy" "admin_not_indicated_policy" {
  count = var.admin_not_indicated_policy ? 1 : 0


  name  = "sadcloud_superuser_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "admin_not_indicated_policy-attach" {
  group = aws_iam_group.admin_not_indicated[0].id
  policy_arn = aws_iam_policy.admin_not_indicated_policy[0].arn
  count = var.admin_not_indicated_policy ? 1 : 0
}

# Dangerous IAM User with programmatic and console access
resource "aws_iam_user" "dangerous_user" {
  count = var.create_dangerous_user ? 1 : 0
  name  = "superadmin"
  path  = "/"
}

resource "aws_iam_access_key" "dangerous_user" {
  count = var.create_dangerous_user ? 1 : 0
  user  = aws_iam_user.dangerous_user[0].name
}

resource "aws_iam_user_login_profile" "dangerous_user" {
  count = var.create_dangerous_user ? 1 : 0
  user  = aws_iam_user.dangerous_user[0].name
  password_reset_required = false
  pgp_key = var.pgp_key
}

# Dangerous managed policy allowing all actions
resource "aws_iam_policy" "dangerous_policy" {
  count = var.admin_iam_policy ? 1 : 0

  name        = "SuperAdminPolicy"
  description = "Allows all actions on all resources"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
        Condition = {}
      }
    ]
  })
}

# Role with dangerous trust relationship
resource "aws_iam_role" "dangerous_trust" {
  count = var.create_dangerous_role ? 1 : 0
  name  = "DangerousServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "*"  # Allow any AWS service to assume this role
          AWS = "*"      # Allow any AWS account to assume this role
        }
        Condition = {}   # No conditions
      }
    ]
  })
}

# Group with dangerous permissions
resource "aws_iam_group" "dangerous_group" {
  count = var.create_dangerous_group ? 1 : 0
  name  = "PowerUsers"
  path  = "/"
}

resource "aws_iam_group_policy" "dangerous_group_policy" {
  count  = var.create_dangerous_group ? 1 : 0
  name   = "PowerUserPolicy"
  group  = aws_iam_group.dangerous_group[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:*",
          "s3:*",
          "ec2:*",
          "rds:*",
          "lambda:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "*"
      }
    ]
  })
}

# User with hardcoded credentials (very dangerous!)
resource "aws_iam_user" "hardcoded_creds" {
  count = var.create_user_with_hardcoded_creds ? 1 : 0
  name  = "service-account"
  path  = "/"
}

resource "aws_iam_access_key" "hardcoded_creds" {
  count = var.create_user_with_hardcoded_creds ? 1 : 0
  user  = aws_iam_user.hardcoded_creds[0].name
  status = "Active"
  # WARNING: Never do this in production!
  pgp_key = "keybase:test"  # Hardcoded encryption key
}
