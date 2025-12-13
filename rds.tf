resource "aws_db_subnet_group" "rds" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.from_vpc.ids

  tags = merge({
    Name = "${var.db_identifier}-subnet-group"
  }, var.tags)
}

resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "DB ingress from anywhere"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  cluster_identifier            = var.db_identifier
  engine                        = var.engine
  engine_version                = var.engine_version
  master_username               = var.db_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  port                          = var.db_port
  db_subnet_group_name          = aws_db_subnet_group.rds.name
  vpc_security_group_ids        = [aws_security_group.rds.id]
  skip_final_snapshot           = true
  
  # Janela de manutenção configurada para minimizar impacto em testes
  preferred_maintenance_window = "sun:03:00-sun:04:00"
  apply_immediately            = true
  
  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_min_capacity
    max_capacity = var.serverless_max_capacity
  }

  tags = merge({
    Name = var.db_identifier
  }, var.tags)
}

resource "aws_rds_cluster_instance" "instance" {
  identifier                 = "${var.db_identifier}-oficina-1"
  cluster_identifier         = aws_rds_cluster.this.id
  instance_class             = "db.serverless"
  engine                     = aws_rds_cluster.this.engine
  engine_version             = aws_rds_cluster.this.engine_version
  publicly_accessible        = true
  auto_minor_version_upgrade = false
  apply_immediately          = true
}