resource "random_password" "db" {
  count   = var.create_random_password ? 1 : 0
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = local.subnet_ids

  tags = merge({
    Name = "${var.db_identifier}-subnet-group"
  }, var.tags)
}

resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "DB ingress"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.db_identifier}-sg"
  }, var.tags)
}

resource "aws_rds_cluster" "this" {
  cluster_identifier      = var.db_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = var.db_username
  master_password         = local.db_password
  port                    = var.db_port
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  database_name           = var.db_name
  
  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_min_capacity
    max_capacity = var.serverless_max_capacity
  }

  tags = merge({
    Name = var.db_identifier
  }, var.tags)
}

resource "aws_rds_cluster_instance" "this" {
  identifier         = "${var.db_identifier}-instance-1"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.db_instance_class
  engine             = var.engine
  engine_version     = var.engine_version

  tags = merge({
    Name = "${var.db_identifier}-instance-1"
  }, var.tags)
}

# Secrets Manager: create a secret to store DB credentials and optionally enable rotation.
resource "aws_secretsmanager_secret" "db" {
  count = var.enable_secrets_manager ? 1 : 0

  name        = "${var.db_identifier}-secret"
  description = "RDS credentials for ${var.db_identifier}"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  count = var.enable_secrets_manager && var.create_secret_with_password ? 1 : 0

  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username      = var.db_username
    password      = local.db_password
    host          = aws_rds_cluster.this.endpoint
    reader_host   = aws_rds_cluster.this.reader_endpoint
    port          = aws_rds_cluster.this.port
    database_name = var.db_name
  })
}