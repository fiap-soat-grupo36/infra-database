terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.oficina.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.oficina.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.oficina.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.oficina.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.oficina.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.oficina.token
  load_config_file       = false
}