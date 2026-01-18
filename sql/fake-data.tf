resource "null_resource" "create_fake_data" {
  depends_on = [
    data.aws_rds_cluster.cluster,
    data.aws_secretsmanager_secret_version.db_password,
    null_resource.create_database,
    null_resource.create_tables
  ]
  
  triggers = {
    schema_version = filemd5("${path.module}/scripts/fake_data.sql")
    database_name  = var.database_name
    cluster_id     = data.aws_rds_cluster.cluster.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
      set -e
      
      # Verifica e instala psql se necessário
      echo "Verificando instalação do PostgreSQL client..."
      if ! command -v psql &> /dev/null; then
        echo "psql não encontrado. Instalando PostgreSQL client..."
        
        # Detecta o sistema operacional e instala
        if [[ "$OSTYPE" == "darwin"* ]]; then
          # macOS
          if command -v brew &> /dev/null; then
            brew install postgresql@15
            export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
          else
            echo "ERRO: Homebrew não encontrado. Instale com: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
          fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
          # Linux (GitHub Actions usa Ubuntu)
          sudo apt-get update -qq
          sudo apt-get install -y -qq postgresql-client
        else
          echo "ERRO: Sistema operacional não suportado: $OSTYPE"
          exit 1
        fi
        
        echo "✓ PostgreSQL client instalado com sucesso!"
      else
        echo "✓ PostgreSQL client já instalado"
      fi
      
      # Aguarda o cluster estar disponível com retry e timeout maior
      echo ""
      echo "========================================="
      echo "Aguardando cluster RDS estar disponível..."
      echo "Endpoint: ${data.aws_rds_cluster.cluster.endpoint}"
      echo "Porta: ${data.aws_rds_cluster.cluster.port}"
      echo "Usuário: ${data.aws_rds_cluster.cluster.master_username}"
      echo "========================================="
      
      # Extrai a senha do secret JSON
      SECRET_JSON='${data.aws_secretsmanager_secret_version.db_password.secret_string}'
      DB_PASSWORD=$(echo "$SECRET_JSON" | grep -o '"password":"[^"]*"' | cut -d'"' -f4)
      
      if [ -z "$DB_PASSWORD" ]; then
        echo "ERRO: Não foi possível extrair a senha do secret"
        echo "Formato do secret recebido: $SECRET_JSON" | head -c 200
        exit 1
      fi
      
      echo "✓ Senha extraída com sucesso do Secrets Manager"
      
      max_attempts=5
      attempt=0
      
      while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        echo ""
        echo "Tentativa $attempt de $max_attempts..."
        
        if PGPASSWORD="$DB_PASSWORD" \
           psql -h ${data.aws_rds_cluster.cluster.endpoint} \
                -p ${data.aws_rds_cluster.cluster.port} \
                -U ${data.aws_rds_cluster.cluster.master_username} \
                -d postgres \
                -c "SELECT 1" 2>&1; then
          echo "✓ Cluster disponível!"
          break
        else
          echo "✗ Falha na conexão"
          if [ $attempt -lt $max_attempts ]; then
            echo "Aguardando 10 segundos antes da próxima tentativa..."
            sleep 10
          fi
        fi
      done
      
      if [ $attempt -eq $max_attempts ]; then
        echo ""
        echo "========================================="
        echo "ERRO: Timeout ao aguardar cluster RDS"
        echo "Verifique:"
        echo "1. Security group permite sua conexão"
        echo "2. RDS está em subnets públicas"
        echo "3. Porta 5432 não está bloqueada"
        echo "========================================="
        exit 1
      fi
      
      # Executa o script SQL
      echo ""
      echo "========================================="
      echo "Executando script SQL..."
      echo "========================================="
      PGPASSWORD="$DB_PASSWORD" \
      psql -h ${data.aws_rds_cluster.cluster.endpoint} \
           -p ${data.aws_rds_cluster.cluster.port} \
           -U ${data.aws_rds_cluster.cluster.master_username} \
           -d postgres \
           -v database_name=${var.database_name} \
           -f ${path.module}/scripts/fake_data.sql
      
      echo ""
      echo "========================================="
      echo "✓ Script SQL executado com sucesso!"
      echo "========================================="
    EOT
  }
}
