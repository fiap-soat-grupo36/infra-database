# Busca o cluster RDS já criado
data "aws_rds_cluster" "cluster" {
  cluster_identifier = "fiap-rds"
}

# Recupera o secret com a senha do master user
data "aws_secretsmanager_secret" "db_password" {
  arn = data.aws_rds_cluster.cluster.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}