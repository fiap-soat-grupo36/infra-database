-- Cria o database se não existir
SELECT 'CREATE DATABASE "' || :'database_name' || '"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'database_name')\gexec

-- Conecta ao database
\c :database_name