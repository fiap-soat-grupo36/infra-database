# Schema para organizar as tabelas
resource "postgresql_schema" "main" {
  name     = var.environment
  database = postgresql_database.main.name
}

# Tabela de usuários
resource "postgresql_table" "users" {
  database = postgresql_database.main.name
  schema   = postgresql_schema.main.name
  name     = "users"

  columns = [
    {
      name     = "id"
      type     = "SERIAL"
      nullable = false
    },
    {
      name     = "name"
      type     = "VARCHAR(100)"
      nullable = false
    },
    {
      name     = "email"
      type     = "VARCHAR(255)"
      nullable = false
    },
    {
      name     = "created_at"
      type     = "TIMESTAMP"
      nullable = false
      default  = "CURRENT_TIMESTAMP"
    }
  ]

  primary_key {
    columns = ["id"]
  }
}

# Tabela de produtos
resource "postgresql_table" "products" {
  database = postgresql_database.main.name
  schema   = postgresql_schema.main.name
  name     = "products"

  columns = [
    {
      name     = "id"
      type     = "SERIAL"
      nullable = false
    },
    {
      name     = "name"
      type     = "VARCHAR(200)"
      nullable = false
    },
    {
      name     = "description"
      type     = "TEXT"
      nullable = true
    },
    {
      name     = "price"
      type     = "DECIMAL(10,2)"
      nullable = false
    },
    {
      name     = "stock"
      type     = "INTEGER"
      nullable = false
      default  = "0"
    },
    {
      name     = "created_at"
      type     = "TIMESTAMP"
      nullable = false
      default  = "CURRENT_TIMESTAMP"
    },
    {
      name     = "updated_at"
      type     = "TIMESTAMP"
      nullable = true
    }
  ]

  primary_key {
    columns = ["id"]
  }
}

# Tabela de pedidos
resource "postgresql_table" "orders" {
  database = postgresql_database.main.name
  schema   = postgresql_schema.main.name
  name     = "orders"

  columns = [
    {
      name     = "id"
      type     = "SERIAL"
      nullable = false
    },
    {
      name     = "user_id"
      type     = "INTEGER"
      nullable = false
    },
    {
      name     = "status"
      type     = "VARCHAR(50)"
      nullable = false
      default  = "'pending'"
    },
    {
      name     = "total"
      type     = "DECIMAL(10,2)"
      nullable = false
    },
    {
      name     = "created_at"
      type     = "TIMESTAMP"
      nullable = false
      default  = "CURRENT_TIMESTAMP"
    }
  ]

  primary_key {
    columns = ["id"]
  }

  foreign_key {
    columns           = ["user_id"]
    referenced_table  = postgresql_table.users.name
    referenced_schema = postgresql_schema.main.name
    referenced_columns = ["id"]
    on_delete         = "CASCADE"
  }
}
