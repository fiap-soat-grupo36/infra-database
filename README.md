# Infraestrutura de Banco de Dados

Este repositório contém a infraestrutura como código (Terraform) para provisionar e gerenciar o banco de dados Aurora PostgreSQL Serverless v2 na AWS.

## 📁 Estrutura do Projeto

```
.
├── /                    # Raiz - Provisiona o cluster RDS Aurora
│   ├── backend.tf
│   ├── data.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── rds.tf
│   └── variables.tf
│
└── sql/                 # Databases e tabelas
    ├── backend.tf
    ├── data.tf
    ├── database.tf      # Cria fiapdb-dev e fiapdb-prod
    ├── outputs.tf
    ├── providers.tf
    ├── tables.tf        # Exemplos de tabelas
    └── variables.tf
```

## 🚀 Fluxo de Deploy

### 1. Criar o Cluster Aurora (Raiz)

```bash
# Na raiz do projeto
terraform init
terraform plan
terraform apply
```

Isso cria:
- Aurora PostgreSQL Serverless v2
- Security Group
- Subnet Group
- Credenciais gerenciadas pela AWS (Secrets Manager)

### 2. Criar Databases e Tabelas (pasta sql/)

```bash
# Depois que o cluster estiver pronto
cd sql
terraform init
terraform plan
terraform apply
```

Isso cria:
- Database `fiapdb-dev`
- Database `fiapdb-prod`
- Schemas e tabelas de exemplo (users, products, orders)

## 🔄 CI/CD

### Workflows Separados

**CI (Pull Requests e branches)**
- Valida e planeja infraestrutura do cluster
- Valida e planeja databases/tabelas
- Executa em sequência: primeiro cluster, depois sql

**CD (Branch main)**
- Deploy do cluster Aurora
- Deploy dos databases e tabelas
- Execução automática em sequência

### Pipeline

```
Push → CI Cluster → CI SQL → PR criado
       ↓
Merge main → CD Cluster → CD SQL → Deploy completo
```

## 💰 Gerenciamento de Custos

### Destruir Infraestrutura

Para economizar custos quando não estiver usando:

```bash
# 1. Destruir databases e tabelas primeiro
cd sql
terraform destroy

# 2. Depois destruir o cluster
cd ..
terraform destroy
```

### Recriar Infraestrutura

```bash
# 1. Recriar o cluster
terraform apply

# 2. Aguardar cluster ficar disponível (2-5 minutos)

# 3. Recriar databases e tabelas
cd sql
terraform apply
```

## 🔐 Acesso ao Banco

### Recuperar Credenciais

```bash
# ARN do secret
terraform output rds_master_user_secret_arn

# Buscar senha no Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id <ARN> \
  --query SecretString \
  --output text | jq -r .password
```

### Endpoints

```bash
# Writer endpoint
terraform output rds_endpoint

# Reader endpoint  
terraform output rds_reader_endpoint
```

### Query Editor

O cluster está configurado com `enable_http_endpoint = true`, permitindo uso do Query Editor da AWS Console.

## 📊 Tabelas de Exemplo

O projeto inclui exemplos de tabelas em ambos os ambientes (dev/prod):

- **users**: id, name, email, created_at
- **products**: id, name, description, price, stock, created_at, updated_at
- **orders**: id, user_id, status, total, created_at

Com foreign keys e constraints apropriados.

## ⚙️ Configurações

### Variáveis Principais (raiz)

- `db_identifier`: Nome do cluster (default: fiap-rds)
- `engine`: aurora-postgresql
- `serverless_min_capacity`: 0.5 ACU
- `serverless_max_capacity`: 1 ACU
- `allowed_cidrs`: IPs permitidos para conexão

### Variáveis SQL

- `cluster_identifier`: Nome do cluster para buscar (default: fiap-rds)

## 🔧 Troubleshooting

### Erro ao criar databases

Se o provider postgresql não conseguir conectar:
1. Aguarde o cluster estar completamente disponível
2. Verifique se o security group permite sua conexão
3. Confirme que o secret foi criado corretamente

### Estado inconsistente

```bash
# Refresh do state
terraform refresh

# Ou reimport de recursos
terraform import aws_rds_cluster.this fiap-rds
```

## 📝 Notas

- Este é um projeto acadêmico da FIAP
- A separação cluster/databases facilita recriação frequente por custos
- Credenciais são gerenciadas automaticamente pela AWS
- Ambos ambientes (dev/prod) compartilham o mesmo cluster
