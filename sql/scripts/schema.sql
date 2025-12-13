-- Cria o database se não existir
SELECT 'CREATE DATABASE ' || :'database_name'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'database_name')\gexec

-- Conecta ao database
\c :database_name

-- Cria schema
CREATE SCHEMA IF NOT EXISTS :schema_name;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS :schema_name.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de produtos
CREATE TABLE IF NOT EXISTS :schema_name.products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Tabela de pedidos
CREATE TABLE IF NOT EXISTS :schema_name.orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES :schema_name.users(id) ON DELETE CASCADE
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_users_email ON :schema_name.users(email);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON :schema_name.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON :schema_name.orders(status);
