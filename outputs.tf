output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The generated reference ID of the core VPC environment"
}

output "database_endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "The connection access point URI string for the private database tier"
}