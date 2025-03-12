# Certificate with transparency logging disabled (security risk)
resource "aws_acm_certificate" "main" {
  count             = var.certificate_transparency_disabled ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Disable certificate transparency logging
  options {
    certificate_transparency_logging_preference = "DISABLED"
  }

  # Overly permissive subject alternative names
  subject_alternative_names = ["*.${var.domain_name}", "*.*.${var.domain_name}"]  # Wildcard and double wildcard (risky)

  tags = {
    Name = "insecure-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Self-signed certificate (not recommended for production)
resource "aws_acm_certificate" "self_signed" {
  count             = var.use_self_signed ? 1 : 0
  private_key       = tls_private_key.cert[0].private_key_pem
  certificate_body  = tls_self_signed_cert.cert[0].cert_pem
  
  tags = {
    Name = "self-signed-cert"
  }
}

# Generate weak private key (security risk)
resource "tls_private_key" "cert" {
  count     = var.use_self_signed ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 1024  # Weak key size
}

# Create self-signed certificate with weak configuration
resource "tls_self_signed_cert" "cert" {
  count           = var.use_self_signed ? 1 : 0
  private_key_pem = tls_private_key.cert[0].private_key_pem

  subject {
    common_name  = var.domain_name
    organization = "Insecure Org"
  }

  validity_period_hours = 8760  # 1 year (long-lived certificate)

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",  # Unnecessarily broad permissions
    "code_signing", # Unnecessarily broad permissions
    "any_extended"  # Extremely permissive
  ]
}

# Import an expired certificate (if provided)
resource "aws_acm_certificate" "imported" {
  count             = var.import_expired_cert ? 1 : 0
  private_key       = var.expired_cert_private_key
  certificate_body  = var.expired_cert_body
  certificate_chain = var.expired_cert_chain

  tags = {
    Name = "expired-cert"
  }
}
