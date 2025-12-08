output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.this.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "rds_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "rds_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials (if created)"
  value       = try(aws_secretsmanager_secret.db[0].arn, "")
}

