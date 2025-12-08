data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["fiap-oficina-mecanica"]
  }
}

data "aws_subnet_ids" "from_vpc" {
  vpc_id = data.aws_vpc.main.id
}