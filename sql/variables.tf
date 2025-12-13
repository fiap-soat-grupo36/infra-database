variable "cluster_identifier" {
  description = "Identificador do cluster RDS"
  type        = string
  default     = "fiap-rds"
}

variable "environment" {
  description = "Ambiente de deploy (dev, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "O ambiente deve ser 'dev' ou 'prod'."
  }
}

variable "database_name" {
  description = "Nome do database a ser criado"
  type        = string
}
