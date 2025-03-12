variable "name" {
  description = "RDS instance name"
  type        = string
  default     = "sadcloudrds"
}

############## Network ##############

variable "vpc_id" {
  description = "ID of VPC where database will be deployed"
  type        = string
  default     = "default"  # Dangerous: Using default VPC
}

variable "main_subnet_id" {
  description = "ID of main subnet"
  type        = string
  default     = "subnet-default1"  # Should be replaced with actual subnet ID
}

variable "secondary_subnet_id" {
  description = "ID of secondary subnet"
  type        = string
  default     = "subnet-default2"  # Should be replaced with actual subnet ID
}

############## Database Configuration ##############

variable "engine" {
  description = "Database engine type"
  type        = string
  default     = "mysql"  # Options: mysql, postgres, mariadb, etc.
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"  # Using older version by default
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "myapp"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"  # Dangerous: Using obvious username
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  default     = ""  # Will use default password if not set
}

############## Security Misconfigurations ##############

variable "create_insecure_sg" {
  description = "Create security group with dangerous rules"
  type        = bool
  default     = false
}

variable "create_insecure_instance" {
  description = "Create RDS instance with multiple security misconfigurations"
  type        = bool
  default     = false
}

variable "create_insecure_params" {
  description = "Create parameter group with insecure settings"
  type        = bool
  default     = false
}

variable "create_unencrypted_replica" {
  description = "Create an unencrypted read replica"
  type        = bool
  default     = false
}

variable "no_minor_upgrade" {
  description = "Disable automatic minor DB engine updates"
  type        = bool
  default     = false
}

variable "backup_disabled" {
  description = "Disable RDS instance backups"
  type        = bool
  default     = false
}

variable "storage_not_encrypted" {
  description = "Disable storage encryption for RDS instances"
  type        = bool
  default     = false
}

variable "single_az" {
  description = "Use single availability zone (no redundancy)"
  type        = bool
  default     = false
}

variable "rds_publicly_accessible" {
  description = "Make RDS instance publicly accessible"
  type        = bool
  default     = false
}
