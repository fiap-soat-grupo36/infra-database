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
  database_name                 = var.db_name

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