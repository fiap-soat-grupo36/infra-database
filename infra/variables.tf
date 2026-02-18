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
  # Default changed to an underscore-based name to comply with RDS master user rules
  default = "app_admin"

  validation {
    condition     = length(var.db_username) >= 1 && length(var.db_username) <= 16 && can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "db_username must start with a letter, contain only letters/numbers/underscores, and be 1-16 characters long (engine-specific limits may apply)."
  }
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine" {
  description = "Database engine (aurora-postgresql or aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora engine version (e.g., 14.6 for aurora-postgresql, 8.0.mysql_aurora.3.02.0 for aurora-mysql)"
  type        = string
  default     = "14.6"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "serverless_min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity (ACU) - 0.5 ACU = ~1GB RAM, 1 vCPU"
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity (ACU) - 1 ACU = ~2GB RAM, 2 vCPU"
  type        = number
  default     = 1
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

variable "master_user_secret_kms_key_id" {
  description = "KMS key ID to encrypt the automatically managed master user secret. If not specified, uses the default AWS managed key."
  type        = string
  default     = null
}
