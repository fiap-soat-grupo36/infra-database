terraform {
  backend "s3" {
    bucket = "projeto-oficina-terraform"
    key    = "database/sql/terraform.tfstate"
    region = "us-east-2"
  }
}
