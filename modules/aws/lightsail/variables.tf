variable "lightsail_in_use" {
  description = "lightsail is in use"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name for Lightsail instance"
  type        = string
  default     = "sadcloud-instance"
}

############## Security Misconfigurations ##############

variable "disable_automatic_snapshots" {
  description = "Whether to disable automatic snapshots"
  type        = bool
  default     = false
}

variable "allow_public_ports" {
  description = "Whether to allow access to all ports from anywhere"
  type        = bool
  default     = false
}

variable "use_default_key_pair" {
  description = "Whether to use the default key pair instead of a custom one"
  type        = bool
  default     = false
}

variable "disable_monitoring" {
  description = "Whether to disable enhanced monitoring"
  type        = bool
  default     = false
}

variable "disable_ipv6" {
  description = "Whether to disable IPv6 support"
  type        = bool
  default     = false
}

variable "allow_root_access" {
  description = "Whether to allow root SSH access"
  type        = bool
  default     = false
}

############## Instance Configuration ##############

variable "availability_zone" {
  description = "Availability zone for the instance"
  type        = string
  default     = "us-east-1a"
}

variable "blueprint_id" {
  description = "Blueprint ID for the instance (OS/App)"
  type        = string
  default     = "amazon_linux_2"  # Using older OS version for insecurity
}

variable "bundle_id" {
  description = "Bundle ID (instance size)"
  type        = string
  default     = "nano_2_0"  # Smallest instance size
}

variable "user_data" {
  description = "User data script for instance initialization"
  type        = string
  default     = null
}

############## Network Configuration ##############

variable "open_ports" {
  description = "List of ports to open in the firewall"
  type        = list(number)
  default     = [22, 80, 443]  # Common ports
}

variable "custom_port_ranges" {
  description = "List of custom port ranges to open (from_port-to_port)"
  type        = list(string)
  default     = []
}

############## Tags ##############

variable "tags" {
  description = "Tags to apply to Lightsail resources"
  type        = map(string)
  default     = {}
}

############## Database Configuration ##############

variable "create_database" {
  description = "Whether to create a Lightsail database"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name for the database instance"
  type        = string
  default     = "sadcloud-db"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "sadcloud"
}

variable "db_master_password" {
  description = "Master password for the database (if not specified, a weak one will be used)"
  type        = string
  default     = "sadcloud123!"  # Weak default password
}

variable "db_publicly_accessible" {
  description = "Whether to make the database publicly accessible"
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 1  # Minimum retention for insecurity
}
