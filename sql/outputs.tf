output "environment" {
  description = "Ambiente deployado"
  value       = var.environment
}

output "database_name" {
  description = "Nome do database criado"
  value       = postgresql_database.main.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster RDS"
  value       = data.aws_rds_cluster.cluster.endpoint
}
