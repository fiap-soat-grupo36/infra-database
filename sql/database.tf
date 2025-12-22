# Cria databases e tabelas via script SQL
# Evita problemas de conectividade do provider PostgreSQL durante terraform apply

resource "null_resource" "create_database_and_tables" {
  triggers = {
    schema_version = filemd5("${path.module}/scripts/schema.sql")
    database_name  = var.database_name
    schema_name    = var.environment
    cluster_id     = data.aws_rds_cluster.cluster.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Aguarda o cluster estar disponível com retry
      echo "Aguardando cluster RDS estar disponível..."
      max_attempts=30
      attempt=0
      
      while [ $attempt -lt $max_attempts ]; do
        if PGPASSWORD="${jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]}" \
           psql -h ${data.aws_rds_cluster.cluster.endpoint} \
                -p ${data.aws_rds_cluster.cluster.port} \
                -U ${data.aws_rds_cluster.cluster.master_username} \
                -d postgres \
                -c "SELECT 1" > /dev/null 2>&1; then
          echo "Cluster disponível!"
          break
        fi
        attempt=$((attempt + 1))
        echo "Tentativa $attempt de $max_attempts - aguardando 10 segundos..."
        sleep 10
      done
      
      if [ $attempt -eq $max_attempts ]; then
        echo "Erro: Timeout ao aguardar cluster RDS"
        exit 1
      fi
      
      # Executa o script SQL
      echo "Executando script SQL..."
      PGPASSWORD="${jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]}" \
      psql -h ${data.aws_rds_cluster.cluster.endpoint} \
           -p ${data.aws_rds_cluster.cluster.port} \
           -U ${data.aws_rds_cluster.cluster.master_username} \
           -d postgres \
           -v database_name=${var.database_name} \
           -v schema_name=${var.environment} \
           -f ${path.module}/scripts/schema.sql
    EOT
  }
}
