# Main ECR repository with various misconfigurations
resource "aws_ecr_repository" "main" {
  name = var.name

  # Dangerous: Allow mutable tags
  image_tag_mutability = var.enable_mutable_tags ? "MUTABLE" : "IMMUTABLE"

  # Dangerous: Disable image scanning
  image_scanning_configuration {
    scan_on_push = !var.ecr_scanning_disabled
  }

  # Dangerous: Disable encryption
  encryption_configuration {
    encryption_type = var.disable_encryption ? "AES256" : "KMS"
    kms_key = var.disable_encryption ? null : "arn:aws:kms:us-east-1:123456789012:key/example-key"
  }
}

# Overly permissive repository policy
resource "aws_ecr_repository_policy" "overly_permissive" {
  count = var.create_overly_permissive_policy ? 1 : 0

  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEverything"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "ecr:*"  # Dangerous: Allow all ECR actions
        ]
      }
    ]
  })
}

# Public pull access policy
resource "aws_ecr_repository_policy" "public_pull" {
  count = var.create_public_pull_policy ? 1 : 0

  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicPull"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# Misconfigured lifecycle policy
resource "aws_ecr_lifecycle_policy" "misconfigured" {
  count = var.create_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep all images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 999999  # Dangerous: Keep too many images
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images immediately"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 0  # Dangerous: Remove untagged images immediately
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Tag immutability rule (disabled)
resource "aws_ecr_repository" "mutable_tags" {
  count = var.disable_tag_immutability ? 1 : 0

  name                 = "${var.name}-mutable"
  image_tag_mutability = "MUTABLE"  # Dangerous: Allow tag mutation
}

# Public repository
resource "aws_ecrpublic_repository" "public" {
  count = var.ecr_repo_public ? 1 : 0

  repository_name = "${var.name}-public"

  catalog_data {
    about_text        = "Public repository for testing"
    description       = "This is a public repository"
    operating_systems = ["Linux"]
    architectures     = ["x86"]
  }
}
