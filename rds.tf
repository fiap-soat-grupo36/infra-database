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
    description      = "DB ingress"
    from_port        = var.db_port
    to_port          = var.db_port
    protocol         = "tcp"
    cidr_blocks      = var.allowed_cidrs
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

resource "aws_db_instance" "this" {
  identifier              = var.db_identifier
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.db_instance_class
  # Note: some provider versions don't accept the `name` attribute here.
  # The initial database name can be created via other means if required.
  username                = var.db_username
  password                = local.db_password
  port                    = var.db_port
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = merge({
    Name = var.db_identifier
  }, var.tags)
}

# Secrets Manager: create a secret to store DB credentials and optionally enable rotation.
resource "aws_secretsmanager_secret" "db" {
  count = var.enable_secrets_manager ? 1 : 0

  name = "${var.db_identifier}-secret"
  description = "RDS credentials for ${var.db_identifier}"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  count = var.enable_secrets_manager && var.create_secret_with_password ? 1 : 0

  secret_id     = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = local.db_password
    host     = aws_db_instance.this.endpoint
    port     = aws_db_instance.this.port
  })
}