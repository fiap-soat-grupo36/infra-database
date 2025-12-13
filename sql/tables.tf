# Schema para organizar as tabelas
resource "postgresql_schema" "main" {
  name     = var.environment
  database = postgresql_database.main.name
}

# Executa o script SQL para criar as tabelas
resource "null_resource" "create_tables" {
  depends_on = [postgresql_schema.main]

  triggers = {
    schema_version = filemd5("${path.module}/scripts/schema.sql")
    database_name  = postgresql_database.main.name
    schema_name    = postgresql_schema.main.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD="${jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]}" \
      psql -h ${data.aws_rds_cluster.cluster.endpoint} \
           -p ${data.aws_rds_cluster.cluster.port} \
           -U ${data.aws_rds_cluster.cluster.master_username} \
           -d ${postgresql_database.main.name} \
           -v schema_name=${postgresql_schema.main.name} \
           -f ${path.module}/scripts/schema.sql
    EOT
  }
}
