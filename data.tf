data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["fiap-oficina-mecanica"]
  }
}

data "aws_subnets" "from_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}