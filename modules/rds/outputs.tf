output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "db_instance_identifier" {
  description = "Database instance identifier"
  value       = aws_db_instance.main.identifier
}