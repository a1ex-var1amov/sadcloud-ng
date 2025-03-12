variable "name" {
  description = "Name for ELB resources"
  type        = string
  default     = "sadcloud-elb"
}

variable "no_access_logs" {
  description = "Whether to disable access logging"
  type        = bool
  default     = false
}

variable "use_insecure_listeners" {
  description = "Whether to use insecure listeners (HTTP, unencrypted protocols)"
  type        = bool
  default     = false
}

variable "use_weak_ciphers" {
  description = "Whether to use weak SSL/TLS ciphers"
  type        = bool
  default     = false
}

variable "disable_cross_zone" {
  description = "Whether to disable cross-zone load balancing"
  type        = bool
  default     = false
}

variable "disable_connection_draining" {
  description = "Whether to disable connection draining"
  type        = bool
  default     = false
}

variable "short_idle_timeout" {
  description = "Whether to set a short idle timeout"
  type        = bool
  default     = false
}

variable "internal_with_public_instances" {
  description = "Whether to create an internal ELB with public instances"
  type        = bool
  default     = false
}

variable "allow_all_incoming" {
  description = "Whether to allow incoming traffic from all sources"
  type        = bool
  default     = false
}

variable "use_public_subnets" {
  description = "Whether to place the ELB in public subnets"
  type        = bool
  default     = false
}

############## Network ##############

variable "vpc_id" {
  description = "VPC ID where ELB will be created"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for ELB"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

############## Instance Configuration ##############

variable "instance_port_http" {
  description = "Port for HTTP traffic on instances"
  type        = number
  default     = 80
}

variable "instance_port_https" {
  description = "Port for HTTPS traffic on instances"
  type        = number
  default     = 443
}

variable "health_check_target" {
  description = "Target for health checks"
  type        = string
  default     = "TCP:80"
}

variable "health_check_interval" {
  description = "Interval between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health checks"
  type        = number
  default     = 5
}
