terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

provider "random" {
}
