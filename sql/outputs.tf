output "environment" {
  description = "Ambiente deployado"
  value       = var.environment
}

output "database_name" {
  description = "Nome do database criado"
  value       = var.database_name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster RDS"
  value       = data.aws_rds_cluster.cluster.endpoint
}

output "connection_command" {
  description = "Comando para conectar ao database"
  value       = "psql -h ${data.aws_rds_cluster.cluster.endpoint} -p ${data.aws_rds_cluster.cluster.port} -U ${data.aws_rds_cluster.cluster.master_username} -d ${var.database_name}"
  sensitive   = false
}
