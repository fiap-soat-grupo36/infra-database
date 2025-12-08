locals {
  subnet_ids  = length(var.db_subnet_ids) > 0 ? var.db_subnet_ids : data.aws_subnets.from_vpc.ids
  db_password = var.create_random_password && (var.db_password == "" || var.db_password == null) ? random_password.db[0].result : var.db_password
}
