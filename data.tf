data "aws_eks_cluster" "oficina" {
  name = "eks-fiap-oficina-mecanica"
}

data "aws_eks_cluster_auth" "oficina" {
  name = data.aws_eks_cluster.oficina.name
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["fiap-oficina-mecanica"]
  }
}
