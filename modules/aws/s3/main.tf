resource "aws_s3_bucket" "main" {
  bucket_prefix = var.name
  force_destroy = true

  dynamic "logging" {
    for_each = var.no_logging ? [] : tolist([var.no_logging])

    content {
      target_bucket = aws_s3_bucket.logging[0].id
      target_prefix = var.name
    }
  }

  # Removed 'acl = "private"' as it's deprecated. Using aws_s3_bucket_acl instead.
  # Removed 'website' dynamic block as it's deprecated. Using aws_s3_bucket_website_configuration instead.
  # Removed 'versioning' block as it's deprecated. Using aws_s3_bucket_versioning instead.
  # Removed 'server_side_encryption_configuration' dynamic block as it's deprecated. Using aws_s3_bucket_server_side_encryption_configuration instead.
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  count = var.website_enabled ? 1 : 0
}

resource "aws_s3_bucket_acl" "main_acl" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  # Sets the ACL for the main S3 bucket to private.
}

resource "aws_s3_bucket" "logging" {
  bucket_prefix = var.name
  force_destroy = true

  count = var.no_logging ? 0 : 1
   # Removed 'acl = var.bucket_acl' as it's deprecated. Using aws_s3_bucket_acl instead.
}

resource "aws_s3_bucket_acl" "logging_acl" {
  bucket = aws_s3_bucket.logging[0].id
  acl    = var.bucket_acl
  count = var.no_logging ? 0 : 1
  # Sets the ACL for the logging S3 bucket using the variable bucket_acl.
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

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.no_versioning ? "Suspended" : "Enabled"
    mfa_delete = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  count = var.no_default_encryption ? 0 : 1
}