output "rds_endpoint" {
  description = "Aurora cluster endpoint (writer)"
  value       = aws_rds_cluster.this.endpoint
}

output "rds_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "rds_port" {
  description = "Aurora cluster port"
  value       = aws_rds_cluster.this.port
}

output "rds_cluster_id" {
  description = "Aurora cluster identifier"
  value       = aws_rds_cluster.this.id
}

output "rds_cluster_arn" {
  description = "Aurora cluster ARN"
  value       = aws_rds_cluster.this.arn
}

output "rds_master_user_secret_arn" {
  description = "ARN of the AWS-managed Secrets Manager secret containing master user credentials"
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, "")
}

output "rds_master_user_secret_status" {
  description = "Status of the AWS-managed secret"
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_status, "")
}

