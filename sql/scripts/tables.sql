-- ============================================================================
-- TABLES.SQL - Estrutura do Banco de Dados
-- ============================================================================
-- Versão: 1.0.0
-- PostgreSQL: 14.6 (Aurora Serverless v2)
-- Ambiente: Todos (dev, homolog, prod)
-- Descrição: Cria todas as tabelas, constraints, índices e extensions
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUIDs
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Similarity search
CREATE EXTENSION IF NOT EXISTS "unaccent";       -- Remove accents

-- ============================================================================
-- TABELAS - AUTH SERVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    ativo BOOLEAN DEFAULT true,
    
    CONSTRAINT ck_role CHECK (role IN ('ADMIN', 'CLIENTE', 'MECANICO', 'ATENDENTE', 'ESTOQUISTA'))
);

-- Unique constraint
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_usuarios_username') THEN
        ALTER TABLE usuarios ADD CONSTRAINT uk_usuarios_username UNIQUE (username);
    END IF;
END $$;

COMMENT ON TABLE usuarios IS 'Usuários do sistema com autenticação';
COMMENT ON COLUMN usuarios.password_hash IS 'Senha com BCrypt';

-- ============================================================================
-- TABELAS - CUSTOMER SERVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS clientes (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cpf VARCHAR(14),
    cnpj VARCHAR(18),
    email VARCHAR(255) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    endereco JSONB,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_nascimento DATE,
    observacao TEXT,
    ativo BOOLEAN DEFAULT true,
    
    CONSTRAINT ck_cliente_cpf_ou_cnpj CHECK (
        (cpf IS NOT NULL AND cnpj IS NULL) OR
        (cpf IS NULL AND cnpj IS NOT NULL)
    ),
    CONSTRAINT ck_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Unique constraints
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_clientes_email') THEN
        ALTER TABLE clientes ADD CONSTRAINT uk_clientes_email UNIQUE (email);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_clientes_cpf') THEN
        ALTER TABLE clientes ADD CONSTRAINT uk_clientes_cpf UNIQUE NULLS DISTINCT (cpf);
    END IF;
END $$;

COMMENT ON TABLE clientes IS 'Clientes da oficina (PF ou PJ)';

CREATE TABLE IF NOT EXISTS veiculos (
    id BIGSERIAL PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    marca VARCHAR(100),
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    cor VARCHAR(50),
    observacoes TEXT,
    cliente_id BIGINT NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT true,
    
    CONSTRAINT ck_ano_valido CHECK (ano >= 1900 AND ano <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    CONSTRAINT ck_placa_formato CHECK (
        placa ~* '^[A-Z]{3}[0-9][A-Z][0-9]{2}$' OR
        placa ~* '^[A-Z]{3}[0-9]{4}$'
    )
);

-- Unique e Foreign Key
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_veiculos_placa') THEN
        ALTER TABLE veiculos ADD CONSTRAINT uk_veiculos_placa UNIQUE (placa);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_veiculo_cliente') THEN
        ALTER TABLE veiculos ADD CONSTRAINT fk_veiculo_cliente 
            FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT;
    END IF;
END $$;

COMMENT ON TABLE veiculos IS 'Veículos dos clientes';

-- ============================================================================
-- TABELAS - CATALOG SERVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS servicos (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL,
    preco_base NUMERIC(10,2) NOT NULL,
    tempo_estimado_minutos INT NOT NULL,
    ativo BOOLEAN DEFAULT true,
    
    CONSTRAINT ck_servico_preco_positivo CHECK (preco_base > 0),
    CONSTRAINT ck_servico_tempo_positivo CHECK (tempo_estimado_minutos > 0),
    CONSTRAINT ck_servico_categoria_valida CHECK (categoria IN (
        'MECANICO', 'ELETRICO', 'FREIOS', 'ALINHAMENTO', 'SUSPENSAO'
    ))
);

COMMENT ON TABLE servicos IS 'Catálogo de serviços oferecidos';

CREATE TABLE IF NOT EXISTS produtos_catalogo (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL,
    preco NUMERIC(10,2) NOT NULL,
    ativo BOOLEAN DEFAULT true,
    
    CONSTRAINT ck_produto_preco_positivo CHECK (preco > 0),
    CONSTRAINT ck_produto_categoria_valida CHECK (categoria IN ('PECA', 'INSUMO'))
);

COMMENT ON TABLE produtos_catalogo IS 'Catálogo de produtos/peças';

-- ============================================================================
-- TABELAS - INVENTORY SERVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS produtos_estoque (
    id BIGSERIAL PRIMARY KEY,
    produto_catalogo_id BIGINT NOT NULL,
    quantidade_disponivel INT NOT NULL DEFAULT 0,
    quantidade_reservada INT NOT NULL DEFAULT 0,
    estoque_minimo INT NOT NULL DEFAULT 5,
    preco_custo_medio NUMERIC(10,2),
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT ck_estoque_quantidade_nao_negativa CHECK (quantidade_disponivel >= 0),
    CONSTRAINT ck_estoque_reservada_nao_negativa CHECK (quantidade_reservada >= 0),
    CONSTRAINT ck_estoque_minimo_positivo CHECK (estoque_minimo >= 0)
);

-- Unique e Foreign Key
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_estoque_produto') THEN
        ALTER TABLE produtos_estoque ADD CONSTRAINT uk_estoque_produto UNIQUE (produto_catalogo_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_estoque_produto_catalogo') THEN
        ALTER TABLE produtos_estoque ADD CONSTRAINT fk_estoque_produto_catalogo 
            FOREIGN KEY (produto_catalogo_id) REFERENCES produtos_catalogo(id) ON DELETE CASCADE;
    END IF;
END $$;

COMMENT ON TABLE produtos_estoque IS 'Controle de estoque de produtos';

CREATE TABLE IF NOT EXISTS movimentacoes_estoque (
    id BIGSERIAL PRIMARY KEY,
    produto_catalogo_id BIGINT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10,2),
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT,
    
    CONSTRAINT ck_movimentacao_tipo_valido CHECK (tipo IN ('ENTRADA', 'SAIDA')),
    CONSTRAINT ck_movimentacao_quantidade_positiva CHECK (quantidade > 0)
);

-- Foreign Key
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_movimentacao_produto') THEN
        ALTER TABLE movimentacoes_estoque ADD CONSTRAINT fk_movimentacao_produto 
            FOREIGN KEY (produto_catalogo_id) REFERENCES produtos_catalogo(id) ON DELETE RESTRICT;
    END IF;
END $$;

COMMENT ON TABLE movimentacoes_estoque IS 'Histórico de movimentações';

-- ============================================================================
-- TABELAS - WORK ORDER SERVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS ordens_servico (
    id BIGSERIAL PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    veiculo_id BIGINT NOT NULL,
    mecanico_id BIGINT,
    status VARCHAR(30) NOT NULL DEFAULT 'RECEBIDA',
    criada_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_inicio_execucao TIMESTAMP,
    data_termino_execucao TIMESTAMP,
    data_entrega TIMESTAMP,
    observacoes TEXT,
    
    CONSTRAINT ck_os_status_valido CHECK (status IN (
        'RECEBIDA', 'EM_DIAGNOSTICO', 'AGUARDANDO_APROVACAO',
        'EM_EXECUCAO', 'FINALIZADA', 'ENTREGUE', 'REPROVADA', 'CANCELADA'
    ))
);

-- Foreign Keys
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_os_cliente') THEN
        ALTER TABLE ordens_servico ADD CONSTRAINT fk_os_cliente 
            FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_os_veiculo') THEN
        ALTER TABLE ordens_servico ADD CONSTRAINT fk_os_veiculo 
            FOREIGN KEY (veiculo_id) REFERENCES veiculos(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_os_mecanico') THEN
        ALTER TABLE ordens_servico ADD CONSTRAINT fk_os_mecanico 
            FOREIGN KEY (mecanico_id) REFERENCES usuarios(id) ON DELETE SET NULL;
    END IF;
END $$;

COMMENT ON TABLE ordens_servico IS 'Ordens de serviço';

CREATE TABLE IF NOT EXISTS itens_ordem_servico (
    id BIGSERIAL PRIMARY KEY,
    ordem_servico_id BIGINT NOT NULL,
    produto_catalogo_id BIGINT,
    servico_id BIGINT,
    valor_unitario NUMERIC(10,2) NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    observacao TEXT,
    
    CONSTRAINT ck_item_os_produto_ou_servico CHECK (
        (produto_catalogo_id IS NOT NULL AND servico_id IS NULL) OR
        (produto_catalogo_id IS NULL AND servico_id IS NOT NULL)
    ),
    CONSTRAINT ck_item_os_quantidade_positiva CHECK (quantidade > 0)
);

-- Foreign Keys
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_item_os') THEN
        ALTER TABLE itens_ordem_servico ADD CONSTRAINT fk_item_os 
            FOREIGN KEY (ordem_servico_id) REFERENCES ordens_servico(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_item_os_produto') THEN
        ALTER TABLE itens_ordem_servico ADD CONSTRAINT fk_item_os_produto 
            FOREIGN KEY (produto_catalogo_id) REFERENCES produtos_catalogo(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_item_os_servico') THEN
        ALTER TABLE itens_ordem_servico ADD CONSTRAINT fk_item_os_servico 
            FOREIGN KEY (servico_id) REFERENCES servicos(id) ON DELETE RESTRICT;
    END IF;
END $$;

COMMENT ON TABLE itens_ordem_servico IS 'Itens de OS';

-- ============================================================================
-- TABELAS - BUDGET SERVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS orcamentos (
    id BIGSERIAL PRIMARY KEY,
    ordem_servico_id BIGINT NOT NULL,
    valor_total NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CRIADO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_aprovacao TIMESTAMP,
    data_reprovacao TIMESTAMP,
    
    CONSTRAINT ck_orcamento_status_valido CHECK (status IN ('CRIADO', 'APROVADO', 'REPROVADO')),
    CONSTRAINT ck_orcamento_valor_positivo CHECK (valor_total > 0)
);

-- Unique e Foreign Key
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_orcamento_os') THEN
        ALTER TABLE orcamentos ADD CONSTRAINT uk_orcamento_os UNIQUE (ordem_servico_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_orcamento_os') THEN
        ALTER TABLE orcamentos ADD CONSTRAINT fk_orcamento_os 
            FOREIGN KEY (ordem_servico_id) REFERENCES ordens_servico(id) ON DELETE CASCADE;
    END IF;
END $$;

COMMENT ON TABLE orcamentos IS 'Orçamentos';

CREATE TABLE IF NOT EXISTS itens_orcamento (
    id BIGSERIAL PRIMARY KEY,
    orcamento_id BIGINT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario NUMERIC(10,2) NOT NULL,
    valor_total NUMERIC(10,2) GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    
    CONSTRAINT ck_item_orc_quantidade_positiva CHECK (quantidade > 0),
    CONSTRAINT ck_item_orc_valor_positivo CHECK (valor_unitario > 0)
);

-- Foreign Key
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_item_orcamento') THEN
        ALTER TABLE itens_orcamento ADD CONSTRAINT fk_item_orcamento 
            FOREIGN KEY (orcamento_id) REFERENCES orcamentos(id) ON DELETE CASCADE;
    END IF;
END $$;

COMMENT ON TABLE itens_orcamento IS 'Itens do orçamento';

-- ============================================================================
-- ÍNDICES
-- ============================================================================

-- Auth Service
CREATE INDEX IF NOT EXISTS idx_usuarios_username ON usuarios(username);
CREATE INDEX IF NOT EXISTS idx_usuarios_role ON usuarios(role) WHERE ativo = true;

-- Customer Service
CREATE INDEX IF NOT EXISTS idx_clientes_cpf ON clientes(cpf) WHERE cpf IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON clientes USING gin(to_tsvector('portuguese', nome));
CREATE INDEX IF NOT EXISTS idx_veiculos_placa ON veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculos_cliente ON veiculos(cliente_id) WHERE ativo = true;

-- Catalog Service
CREATE INDEX IF NOT EXISTS idx_servicos_nome ON servicos USING gin(to_tsvector('portuguese', nome));
CREATE INDEX IF NOT EXISTS idx_servicos_categoria ON servicos(categoria) WHERE ativo = true;
CREATE INDEX IF NOT EXISTS idx_produtos_nome ON produtos_catalogo USING gin(to_tsvector('portuguese', nome));
CREATE INDEX IF NOT EXISTS idx_produtos_categoria ON produtos_catalogo(categoria) WHERE ativo = true;

-- Inventory Service
CREATE INDEX IF NOT EXISTS idx_estoque_produto ON produtos_estoque(produto_catalogo_id);
CREATE INDEX IF NOT EXISTS idx_estoque_baixo ON produtos_estoque(quantidade_disponivel) 
    WHERE quantidade_disponivel < estoque_minimo;
CREATE INDEX IF NOT EXISTS idx_movimentacoes_produto ON movimentacoes_estoque(produto_catalogo_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON movimentacoes_estoque(data_movimentacao DESC);

-- Work Order Service
CREATE INDEX IF NOT EXISTS idx_os_cliente ON ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_os_veiculo ON ordens_servico(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_os_mecanico ON ordens_servico(mecanico_id) WHERE mecanico_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_os_status ON ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_os_data ON ordens_servico(criada_em DESC);
CREATE INDEX IF NOT EXISTS idx_item_os ON itens_ordem_servico(ordem_servico_id);

-- Budget Service
CREATE INDEX IF NOT EXISTS idx_orcamento_os ON orcamentos(ordem_servico_id);
CREATE INDEX IF NOT EXISTS idx_orcamento_status ON orcamentos(status);
CREATE INDEX IF NOT EXISTS idx_item_orcamento ON itens_orcamento(orcamento_id);

-- ============================================================================
-- FIM - TABLES.SQL
-- ============================================================================

\echo '✅ Estrutura do banco criada com sucesso!'
\echo '📊 Total de tabelas: 11'
\echo '🔗 Foreign Keys configuradas'
\echo '🚀 Índices criados'