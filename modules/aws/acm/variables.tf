variable "certificate_transparency_disabled" {
  description = "Whether to disable Certificate Transparency logging (security risk)"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
  default     = "example.com"
}

variable "use_self_signed" {
  description = "Whether to create a self-signed certificate with weak configuration"
  type        = bool
  default     = false
}

variable "import_expired_cert" {
  description = "Whether to import an expired certificate"
  type        = bool
  default     = false
}

variable "expired_cert_private_key" {
  description = "Private key of the expired certificate to import"
  type        = string
  default     = null
  sensitive   = true
}

variable "expired_cert_body" {
  description = "Certificate body of the expired certificate to import"
  type        = string
  default     = null
}

variable "expired_cert_chain" {
  description = "Certificate chain of the expired certificate to import"
  type        = string
  default     = null
}
