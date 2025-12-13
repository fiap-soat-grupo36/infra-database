# Database do ambiente
resource "postgresql_database" "main" {
  name = var.database_name
}