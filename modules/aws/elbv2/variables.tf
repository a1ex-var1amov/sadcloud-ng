variable "name" {
  description = "Name for ELBv2 resources"
  type        = string
  default     = "sadcloud-elbv2"
}

variable "load_balancer_type" {
  description = "Type of load balancer (application or network)"
  type        = string
  default     = "application"
}

############## Security Misconfigurations ##############

variable "disable_access_logs" {
  description = "Whether to disable access logging"
  type        = bool
  default     = false
}

variable "use_insecure_protocols" {
  description = "Whether to use insecure protocols (HTTP, unsecured listeners)"
  type        = bool
  default     = false
}

variable "use_weak_ciphers" {
  description = "Whether to use weak TLS/SSL ciphers and protocols"
  type        = bool
  default     = false
}

variable "allow_all_incoming" {
  description = "Whether to allow incoming traffic from all sources"
  type        = bool
  default     = false
}

variable "disable_deletion_protection" {
  description = "Whether to disable deletion protection"
  type        = bool
  default     = false
}

variable "disable_http2" {
  description = "Whether to disable HTTP/2 support"
  type        = bool
  default     = false
}

variable "disable_waf" {
  description = "Whether to disable WAF integration"
  type        = bool
  default     = false
}

############## Network Configuration ##############

variable "vpc_id" {
  description = "VPC ID where ELBv2 will be created"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ELBv2"
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

############## Listener Configuration ##############

variable "http_port" {
  description = "Port for HTTP traffic"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port for HTTPS traffic"
  type        = number
  default     = 443
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener"
  type        = string
  default     = null
}

############## Target Group Configuration ##############

variable "target_type" {
  description = "Type of target (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

variable "health_check_enabled" {
  description = "Whether health checks are enabled"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Port for health checks"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol for health checks"
  type        = string
  default     = "HTTP"
}

variable "health_check_timeout" {
  description = "Timeout for health checks"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Interval between health checks"
  type        = number
  default     = 30
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to ELBv2 resources"
  type        = map(string)
  default     = {}
}
