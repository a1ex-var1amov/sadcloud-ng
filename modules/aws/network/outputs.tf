output "vpc_id" {
  description = "ID of created VPC"
  value       = length(aws_vpc.main) > 0 ? aws_vpc.main[0].id : null
}

output "vpc_cidr" {
  description = "CIDR of created VPC"
  value       = length(aws_vpc.main) > 0 ? aws_vpc.main[0].cidr_block : null
}

output "subnet_ids" {
  description = "List of created subnet IDs"
  value       = aws_subnet.main[*].id
}

output "subnet_cidrs" {
  description = "List of created subnet CIDRs"
  value       = aws_subnet.main[*].cidr_block
}

output "route_table_id" {
  description = "ID of the main route table"
  value       = length(aws_route_table.main) > 0 ? aws_route_table.main[0].id : null
}

output "vpc_flow_log_id" {
  description = "ID of VPC Flow Log (if enabled)"
  value       = length(aws_flow_log.main) > 0 ? aws_flow_log.main[0].id : null
}

output "s3_endpoint_id" {
  description = "ID of S3 VPC Endpoint (if enabled)"
  value       = length(aws_vpc_endpoint.s3) > 0 ? aws_vpc_endpoint.s3[0].id : null
}

output "ipv6_cidr" {
  description = "IPv6 CIDR block of the VPC"
  value       = length(aws_vpc.main) > 0 ? aws_vpc.main[0].ipv6_cidr_block : null
}
