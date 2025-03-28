output "db_instance_id" {
  description = "The RDS instance ID"
  value       = try(aws_db_instance.main[0].id, null)
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = try(aws_db_instance.main[0].endpoint, null)
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = try(aws_db_instance.main[0].arn, null)
}
