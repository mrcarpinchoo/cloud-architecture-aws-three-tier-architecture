output "rds_endpoint" {
  description = "RDS instance endpoint address"
  value       = aws_db_instance.main.address
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}
