terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Provider PostgreSQL - conecta ao cluster já criado
provider "postgresql" {
  host            = data.aws_rds_cluster.cluster.endpoint
  port            = data.aws_rds_cluster.cluster.port
  username        = data.aws_rds_cluster.cluster.master_username
  password        = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
  database        = "postgres"  # Conecta no database padrão primeiro
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}
