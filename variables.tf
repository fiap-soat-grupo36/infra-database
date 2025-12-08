variable "db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "fiap-rds"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "fiapdb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the database (sensitive). If create_random_password is true, this can be omitted or empty."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_random_password" {
  description = "If true, a random password will be generated and used for the DB. If false, db_password must be provided."
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "14"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_subnet_ids" {
  description = "Optional list of subnet IDs for the DB subnet group. If empty, all subnets in the VPC (data.aws_vpc.main) will be used."
  type        = list(string)
  default     = []
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to connect to the DB (ingress). Adjust for your network."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_secrets_manager" {
  description = "Whether to create an AWS Secrets Manager secret for the DB credentials"
  type        = bool
  default     = true
}

variable "create_secret_with_password" {
  description = "If true, Terraform will create an initial Secret version with the generated/provided password. Note: the secret value will be stored in the Terraform state."
  type        = bool
  default     = true
}
