locals {
  subnet_ids = length(var.db_subnet_ids) > 0 ? var.db_subnet_ids : data.aws_subnet_ids.from_vpc.ids
  db_password = var.create_random_password && length(var.db_password) == 0 ? random_password.db[0].result : var.db_password
}