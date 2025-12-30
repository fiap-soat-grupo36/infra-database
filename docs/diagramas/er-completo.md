# Diagramas ER - Sistema de Oficina Mecânica

## 📋 Índice

- [Diagrama Completo](#diagrama-completo)
- [Diagrama por Microserviço](#diagrama-por-microserviço)
- [Diagrama Simplificado](#diagrama-simplificado)
- [Legenda e Convenções](#legenda-e-convenções)

> **Nota:** Os nomes das tabelas nos diagramas foram simplificados para compatibilidade com o renderizador Mermaid do GitHub. Veja a [tabela de mapeamento](#mapeamento-de-nomes) para os nomes reais no banco de dados.

---

## 🗂️ Diagrama Completo

Este diagrama mostra **todas as 11 tabelas** com seus atributos principais e relacionamentos.

```mermaid
erDiagram
    USUARIO {
        bigint id
        varchar username
        varchar nome
        varchar password
        varchar role
        boolean ativo
    }

    CLIENTE {
        bigint id
        varchar nome
        varchar cpf
        varchar cnpj
        varchar email
        varchar telefone
        jsonb endereco
        timestamp cadastro
        date nascimento
        text observacao
        boolean ativo
    }

    VEICULO {
        bigint id
        varchar placa
        varchar marca
        varchar modelo
        int ano
        varchar cor
        text observacoes
        bigint cliente_id
        timestamp cadastro
        boolean ativo
    }

    SERVICO {
        bigint id
        varchar nome
        text descricao
        varchar categoria
        numeric preco_base
        int tempo_min
        boolean ativo
    }

    PRODUTO {
        bigint id
        varchar nome
        text descricao
        varchar categoria
        numeric preco
        boolean ativo
    }

    ESTOQUE {
        bigint id
        bigint produto_id
        int qtd_disp
        int qtd_reserv
        int estoque_min
        numeric preco_custo
        timestamp atualizado
    }

    MOVIMENTACAO {
        bigint id
        bigint produto_id
        varchar tipo
        int quantidade
        numeric preco_unit
        timestamp data_mov
        text observacao
    }

    ORDEMSERVICO {
        bigint id
        bigint cliente_id
        bigint veiculo_id
        bigint mecanico_id
        varchar status
        timestamp criada_em
        timestamp inicio
        timestamp termino
        timestamp entrega
        text observacoes
    }

    ITEMORDEM {
        bigint id
        bigint ordem_id
        bigint produto_id
        bigint servico_id
        numeric valor_unit
        int quantidade
        text observacao
    }

    ORCAMENTO {
        bigint id
        bigint ordem_id
        numeric valor_total
        varchar status
        timestamp criado_em
        timestamp aprovado_em
        timestamp reprovado_em
    }

    ITEMORCAMENTO {
        bigint id
        bigint orcamento_id
        varchar descricao
        int quantidade
        numeric valor_unit
        numeric valor_total
    }

    CLIENTE ||--o{ VEICULO : possui
    CLIENTE ||--o{ ORDEMSERVICO : abre
    VEICULO ||--o{ ORDEMSERVICO : usado_em
    USUARIO ||--o{ ORDEMSERVICO : atribuido
    ORDEMSERVICO ||--o{ ITEMORDEM : contem
    ORDEMSERVICO ||--|| ORCAMENTO : gera
    ORCAMENTO ||--o{ ITEMORCAMENTO : contem
    SERVICO ||--o{ ITEMORDEM : referenciado
    PRODUTO ||--|| ESTOQUE : tem_estoque
    PRODUTO ||--o{ ITEMORDEM : referenciado
    PRODUTO ||--o{ MOVIMENTACAO : registra
```

---

## 🔤 Mapeamento de Nomes

### Tabelas

| Diagrama | Banco de Dados | Microserviço |
|----------|---------------|--------------|
| `USUARIO` | `usuarios` | auth-service |
| `CLIENTE` | `clientes` | customer-service |
| `VEICULO` | `veiculos` | customer-service |
| `SERVICO` | `servicos` | catalog-service |
| `PRODUTO` | `produtos_catalogo` | catalog-service |
| `ESTOQUE` | `produtos_estoque` | inventory-service |
| `MOVIMENTACAO` | `movimentacoes_estoque` | inventory-service |
| `ORDEMSERVICO` | `ordens_servico` | work-order-service |
| `ITEMORDEM` | `itens_ordem_servico` | work-order-service |
| `ORCAMENTO` | `orcamentos` | budget-service |
| `ITEMORCAMENTO` | `itens_orcamento` | budget-service |

### Colunas Abreviadas

| Diagrama | Banco de Dados |
|----------|---------------|
| `qtd_disp` | `quantidade_disponivel` |
| `qtd_reserv` | `quantidade_reservada` |
| `estoque_min` | `estoque_minimo` |
| `preco_unit` | `preco_unitario` |
| `data_mov` | `data_movimentacao` |
| `valor_unit` | `valor_unitario` |
| `tempo_min` | `tempo_estimado_minutos` |

---

## 🏢 Diagrama por Microserviço

### Auth Service

```mermaid
erDiagram
    USUARIO {
        bigint id
        varchar username
        varchar nome
        varchar password
        varchar role
        boolean ativo
    }
```

**Tabela real:** `usuarios`

**Roles:** ADMIN, CLIENTE, MECANICO, ATENDENTE, ESTOQUISTA

---

### Customer Service

```mermaid
erDiagram
    CLIENTE {
        bigint id
        varchar nome
        varchar cpf
        varchar cnpj
        varchar email
        varchar telefone
        jsonb endereco
        timestamp cadastro
        date nascimento
        text observacao
        boolean ativo
    }

    VEICULO {
        bigint id
        varchar placa
        varchar marca
        varchar modelo
        int ano
        varchar cor
        text observacoes
        bigint cliente_id
        timestamp cadastro
        boolean ativo
    }

    CLIENTE ||--o{ VEICULO : possui
```

**Tabelas reais:** `clientes`, `veiculos`

**Constraints:**
- Cliente: CPF OU CNPJ (exclusivo)
- Placa: Mercosul ou formato antigo
- Ano: 1900 até atual+1

---

### Catalog Service

```mermaid
erDiagram
    SERVICO {
        bigint id
        varchar nome
        text descricao
        varchar categoria
        numeric preco_base
        int tempo_min
        boolean ativo
    }

    PRODUTO {
        bigint id
        varchar nome
        text descricao
        varchar categoria
        numeric preco
        boolean ativo
    }
```

**Tabelas reais:** `servicos`, `produtos_catalogo`

**Categorias Serviço:** MECANICO, ELETRICO, FREIOS, ALINHAMENTO, SUSPENSAO

**Categorias Produto:** PECA, INSUMO

---

### Inventory Service

```mermaid
erDiagram
    PRODUTO {
        bigint id
        varchar nome
        numeric preco
    }

    ESTOQUE {
        bigint id
        bigint produto_id
        int qtd_disp
        int qtd_reserv
        int estoque_min
        numeric preco_custo
        timestamp atualizado
    }

    MOVIMENTACAO {
        bigint id
        bigint produto_id
        varchar tipo
        int quantidade
        numeric preco_unit
        timestamp data_mov
        text observacao
    }

    PRODUTO ||--|| ESTOQUE : tem
    PRODUTO ||--o{ MOVIMENTACAO : registra
```

**Tabelas reais:** `produtos_catalogo`, `produtos_estoque`, `movimentacoes_estoque`

**Tipos:** ENTRADA, SAIDA

---

### Work Order Service

```mermaid
erDiagram
    CLIENTE {
        bigint id
        varchar nome
    }

    VEICULO {
        bigint id
        varchar placa
    }

    USUARIO {
        bigint id
        varchar nome
    }

    ORDEMSERVICO {
        bigint id
        bigint cliente_id
        bigint veiculo_id
        bigint mecanico_id
        varchar status
        timestamp criada_em
        timestamp inicio
        timestamp termino
        timestamp entrega
        text observacoes
    }

    ITEMORDEM {
        bigint id
        bigint ordem_id
        bigint produto_id
        bigint servico_id
        numeric valor_unit
        int quantidade
        text observacao
    }

    SERVICO {
        bigint id
        varchar nome
    }

    PRODUTO {
        bigint id
        varchar nome
    }

    CLIENTE ||--o{ ORDEMSERVICO : abre
    VEICULO ||--o{ ORDEMSERVICO : usado_em
    USUARIO ||--o{ ORDEMSERVICO : atribuido
    ORDEMSERVICO ||--o{ ITEMORDEM : contem
    SERVICO ||--o{ ITEMORDEM : referenciado
    PRODUTO ||--o{ ITEMORDEM : referenciado
```

**Tabelas reais:** `ordens_servico`, `itens_ordem_servico`

**Status:** RECEBIDA, EM_DIAGNOSTICO, AGUARDANDO_APROVACAO, EM_EXECUCAO, FINALIZADA, ENTREGUE, REPROVADA, CANCELADA

---

### Budget Service

```mermaid
erDiagram
    ORDEMSERVICO {
        bigint id
        varchar status
    }

    ORCAMENTO {
        bigint id
        bigint ordem_id
        numeric valor_total
        varchar status
        timestamp criado_em
        timestamp aprovado_em
        timestamp reprovado_em
    }

    ITEMORCAMENTO {
        bigint id
        bigint orcamento_id
        varchar descricao
        int quantidade
        numeric valor_unit
        numeric valor_total
    }

    ORDEMSERVICO ||--|| ORCAMENTO : gera
    ORCAMENTO ||--o{ ITEMORCAMENTO : contem
```

**Tabelas reais:** `orcamentos`, `itens_orcamento`

**Status:** CRIADO, APROVADO, REPROVADO

---

## 🎨 Diagrama Simplificado

```mermaid
graph TB
    U[USUARIO]
    C[CLIENTE]
    V[VEICULO]
    S[SERVICO]
    P[PRODUTO]
    E[ESTOQUE]
    M[MOVIMENTACAO]
    OS[ORDEMSERVICO]
    IO[ITEMORDEM]
    OR[ORCAMENTO]
    IOR[ITEMORCAMENTO]

    C -->|1:N| V
    C -->|1:N| OS
    V -->|1:N| OS
    U -.-> OS
    OS -->|1:N| IO
    OS -->|1:1| OR
    OR -->|1:N| IOR
    S -.-> IO
    P -->|1:1| E
    P -.-> IO
    P -->|1:N| M
```

---

## 📖 Legenda

### Cardinalidades

- `||--o{` = Um para muitos
- `||--||` = Um para um
- `o|--o{` = Zero ou um para muitos

### ON DELETE

| Ação | Quando Usar |
|------|-------------|
| **RESTRICT** | Impede deleção (clientes, produtos) |
| **CASCADE** | Deleta em cascata (itens, detalhes) |
| **SET NULL** | Define NULL (mecânico opcional) |

---

## 📊 Foreign Keys

| Tabela | FK | Destino | ON DELETE |
|--------|-----|---------|-----------|
| veiculos | cliente_id | clientes | RESTRICT |
| ordens_servico | cliente_id | clientes | RESTRICT |
| ordens_servico | veiculo_id | veiculos | RESTRICT |
| ordens_servico | mecanico_id | usuarios | SET NULL |
| itens_ordem_servico | ordem_servico_id | ordens_servico | CASCADE |
| produtos_estoque | produto_catalogo_id | produtos_catalogo | CASCADE |
| movimentacoes_estoque | produto_catalogo_id | produtos_catalogo | RESTRICT |
| orcamentos | ordem_servico_id | ordens_servico | CASCADE |
| itens_orcamento | orcamento_id | orcamentos | CASCADE |

---

## 📊 Estatísticas

- **Tabelas:** 11
- **Foreign Keys:** 11
- **Unique Constraints:** 8
- **Check Constraints:** 15
- **Índices:** 25+
- **Relacionamentos 1:1:** 2
- **Relacionamentos 1:N:** 9

---

## 🔍 Queries de Exemplo

### Listar OS de um cliente

```sql
SELECT 
    os.id,
    os.status,
    c.nome AS cliente,
    v.placa,
    u.nome AS mecanico
FROM ordens_servico os
JOIN clientes c ON c.id = os.cliente_id
JOIN veiculos v ON v.id = os.veiculo_id
LEFT JOIN usuarios u ON u.id = os.mecanico_id
WHERE c.id = 1
ORDER BY os.criada_em DESC;
```

### Estoque baixo

```sql
SELECT 
    pc.nome,
    pe.quantidade_disponivel,
    pe.estoque_minimo
FROM produtos_estoque pe
JOIN produtos_catalogo pc ON pc.id = pe.produto_catalogo_id
WHERE pe.quantidade_disponivel < pe.estoque_minimo;
```

### Total de OS

```sql
SELECT 
    os.id,
    SUM(ios.valor_unitario * ios.quantidade) AS total
FROM ordens_servico os
JOIN itens_ordem_servico ios ON ios.ordem_servico_id = os.id
WHERE os.id = 1
GROUP BY os.id;
```

---

## 📚 Referências

- [Mermaid ER Syntax](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)
- [PostgreSQL Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [GitHub Mermaid](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams)

---

## 📝 Histórico

| Versão | Data | Descrição |
|--------|------|-----------|
| 1.0.0 | 2024-12-30 | Versão inicial |
| 1.1.0 | 2024-12-30 | Correção formatação GitHub |

---

**Repositório:** [infra-database](https://github.com/seu-usuario/infra-database)  
**Status:** ✅ Aprovado
