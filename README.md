# Infraestrutura de Banco de Dados

Este repositório contém a infraestrutura como código (Terraform) para provisionar e gerenciar o banco de dados Aurora PostgreSQL Serverless v2 na AWS.

```mermaid
flowchart TB
    subgraph "Internet"
        User["👤 Usuário/Aplicação"]
    end
    
    subgraph "AWS Cloud - us-east-2"
        subgraph "VPC - fiap-oficina-mecanica"
            subgraph "Security Group"
                SG["🔒 fiap-rds-sg<br/>Ingress: 0.0.0.0/0:5432<br/>Egress: 0.0.0.0/0"]
            end
            
            subgraph "DB Subnet Group"
                Subnet1["🌐 Subnet 1"]
                Subnet2["🌐 Subnet 2"]
            end
            
            subgraph "Aurora Serverless v2"
                Cluster["☁️ Aurora PostgreSQL Cluster<br/>fiap-rds<br/>Engine: aurora-postgresql 14.6<br/>Min: 0.5 ACU / Max: 1 ACU"]
                Instance["💾 Instance<br/>fiap-rds-oficina-1<br/>Class: db.serverless<br/>Publicly Accessible"]
                
                Cluster --> Instance
            end
            
            SG -.protege.-> Cluster
            Cluster -.usa.-> Subnet1
            Cluster -.usa.-> Subnet2
        end
        
        subgraph "Secrets Manager"
            Secret["🔑 Master User Secret<br/>Gerenciado pela AWS<br/>User: app_admin"]
        end
        
        Cluster -.credenciais.-> Secret
    end
    
    subgraph "Databases"
        DB1["📊 fiapdb-dev<br/>Schema: dev<br/>Tables: users, products, orders"]
        DB2["📊 fiapdb-prod<br/>Schema: prod<br/>Tables: users, products, orders"]
    end
    
    User -->|psql/DBeaver<br/>Port 5432| SG
    SG --> Instance
    Instance -.contém.-> DB1
    Instance -.contém.-> DB2
    
    style User fill:#e1f5ff
    style SG fill:#ff9999
    style Cluster fill:#99ccff
    style Instance fill:#99ccff
    style Secret fill:#ffcc99
    style DB1 fill:#99ff99
    style DB2 fill:#99ff99
    style Subnet1 fill:#f0f0f0
    style Subnet2 fill:#f0f0f0
```

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

```mermaid
graph LR
    subgraph " "
        Feature["🌿 feature/hotfix"]
    end
    
    subgraph " "
        CI["⚙️ CI<br/>Terraform Plan"]
    end
    
    subgraph " "
        Develop["🌿 develop"]
    end
    
    subgraph " "
        CD_DEV["🚀 Deploy DEV<br/>Terraform Apply"]
    end
    
    subgraph "🏗️ DEV"
        DEV_ENV["fiapdb-dev"]
    end
    
    subgraph " "
        Main["🌿 main"]
    end
    
    subgraph " "
        CD_PROD["🚀 Deploy PROD<br/>Terraform Apply"]
    end
    
    subgraph "🏭 PROD"
        PROD_ENV["fiapdb-prod"]
    end
    
    Feature -->|push| CI
    CI -->|✅| Develop
    Develop -->|push| CD_DEV
    CD_DEV -->|provisiona| DEV_ENV
    Develop -.PR.-> Main
    Main -->|push| CD_PROD
    CD_PROD -->|provisiona| PROD_ENV
    
    style Feature fill:#ffd54f,stroke:#f57c00,stroke-width:2px
    style CI fill:#9fa8da,stroke:#3949ab,stroke-width:2px
    style Develop fill:#81c784,stroke:#388e3c,stroke-width:2px
    style CD_DEV fill:#4db6ac,stroke:#00796b,stroke-width:2px
    style DEV_ENV fill:#fff9c4,stroke:#f57f17,stroke-width:2px
    style Main fill:#64b5f6,stroke:#1976d2,stroke-width:2px
    style CD_PROD fill:#4dd0e1,stroke:#0097a7,stroke-width:2px
    style PROD_ENV fill:#ffccbc,stroke:#d84315,stroke-width:2px
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