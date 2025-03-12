resource "aws_s3_bucket" "main" {
  bucket_prefix = var.name
  acl    = "private"
  force_destroy = true

  dynamic "server_side_encryption_configuration" {
    for_each = var.no_default_encryption ? [] : tolist([var.no_default_encryption])

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.no_logging ? [] : tolist([var.no_logging])

    content {
      target_bucket = aws_s3_bucket.logging[0].id
      target_prefix = var.name
    }
  }

  versioning {
      enabled = var.no_versioning ? false : true
      mfa_delete = false
  }

  dynamic "website" {
    for_each = var.website_enabled ? [] : tolist([var.website_enabled])

    content {
      index_document = "index.html"
    }
  }

  tags = {
    Environment = "test"
    Sensitive   = "false"  # Misleading tag
  }
}

resource "aws_s3_bucket" "logging" {
  bucket_prefix = var.name
  acl    = var.bucket_acl
  force_destroy = true

  count = var.no_logging ? 0 : 1

  tags = {
    Name = "${var.name}-logs"
  }
}

data "aws_iam_policy_document" "force_ssl_only_access" {
  # Force SSL access
  statement {
    sid = "ForceSSLOnlyAccess"

    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "force_ssl_only_access" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.force_ssl_only_access.json

  count = var.allow_cleartext ? 1 : 0
}

data "aws_iam_policy_document" "getonly" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.getonly[0].arn,
      "${aws_s3_bucket.getonly[0].arn}/*",
    ]
  }

  count = var.s3_getobject_only ? 1 : 0
}

resource "aws_s3_bucket" "getonly" {
  bucket_prefix = "sadcloudhetonlys3"
  force_destroy = true

  count = var.s3_getobject_only ? 1 : 0
}

resource "aws_s3_bucket_policy" "getonly" {
  bucket = aws_s3_bucket.getonly[0].id
  policy = data.aws_iam_policy_document.getonly[0].json

  count = var.s3_getobject_only ? 1 : 0
}


data "aws_iam_policy_document" "public" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.public[0].arn,
      "${aws_s3_bucket.public[0].arn}/*",
    ]
  }

  count = var.s3_public ? 1 : 0
}

resource "aws_s3_bucket" "public" {
  bucket_prefix = "sadcloudhetonlys3"
  force_destroy = true

  count = var.s3_public ? 1 : 0
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public[0].id
  policy = data.aws_iam_policy_document.public[0].json

  count = var.s3_public ? 1 : 0
}

# Dangerous: Make bucket public
resource "aws_s3_bucket_public_access_block" "main" {
  count  = var.enable_public_access ? 1 : 0
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy    = false
  ignore_public_acls     = false
  restrict_public_buckets = false
}

# Dangerous: Public ACL
resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_public_access_block.main]
  
  bucket = aws_s3_bucket.main.id
  acl    = var.bucket_acl
}

# Dangerous: Disable versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = var.no_versioning ? "Disabled" : "Enabled"
    mfa_delete = false  # Dangerous: No MFA delete protection
  }
}

# Dangerous: Website hosting configuration
resource "aws_s3_bucket_website_configuration" "main" {
  count  = var.website_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Dangerous: No encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.no_default_encryption ? 0 : 1
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

# Dangerous: CORS configuration allowing all origins
resource "aws_s3_bucket_cors_configuration" "main" {
  count  = var.enable_unsafe_cors ? 1 : 0
  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Dangerous: Lifecycle rule to quickly delete old versions
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.enable_unsafe_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "delete-old"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 1  # Delete old versions after just 1 day
    }

    expiration {
      days = 7  # Delete current versions after 7 days
    }
  }
}

# Dangerous: Overly permissive bucket policy
resource "aws_s3_bucket_policy" "main" {
  count  = var.enable_dangerous_policy ? 1 : 0
  bucket = aws_s3_bucket.main.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAllS3Actions"
        Effect    = "Allow"
        Principal = {
          AWS = "*"  # Allow any AWS account
        }
        Action    = "s3:*"  # Allow all S3 actions
        Resource  = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
      },
      {
        Sid       = "AllowCleartext"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"  # Allow HTTP (non-SSL) access
          }
        }
      }
    ]
  })
}

# Optional: Replication configuration with security issues
resource "aws_s3_bucket" "replica" {
  count         = var.enable_unsafe_replication ? 1 : 0
  bucket_prefix = "${var.name}-replica"
  force_destroy = true

  tags = {
    Name = "${var.name}-replica"
  }
}

resource "aws_s3_bucket_replication_configuration" "main" {
  count  = var.enable_unsafe_replication ? 1 : 0
  bucket = aws_s3_bucket.main.id
  role   = aws_iam_role.replication[0].arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica[0].arn
      storage_class = "STANDARD"  # No encryption in transit
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# Dangerous replication IAM role
resource "aws_iam_role" "replication" {
  count = var.enable_unsafe_replication ? 1 : 0
  name  = "${var.name}-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# Overly permissive replication role policy
resource "aws_iam_role_policy" "replication" {
  count = var.enable_unsafe_replication ? 1 : 0
  name  = "${var.name}-replication-policy"
  role  = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"  # Overly permissive
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*",
          aws_s3_bucket.replica[0].arn,
          "${aws_s3_bucket.replica[0].arn}/*"
        ]
      }
    ]
  })
}
