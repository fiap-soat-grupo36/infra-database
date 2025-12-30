-- ============================================================================
-- FAKE_DATA.SQL - Dados de Teste
-- ============================================================================
-- Versão: 1.0.0
-- Ambiente: APENAS DEV/HOMOLOG (NÃO RODAR EM PRODUÇÃO!)
-- Descrição: Popula o banco com dados fictícios para testes
-- ============================================================================
\c :database_name
SET search_path TO :schema_name;

\echo '🔄 Carregando dados de teste...'

-- ============================================================================
-- 1. USUÁRIOS (Auth Service)
-- ============================================================================

\echo '👤 Inserindo usuários...'

INSERT INTO usuarios (username, nome, password_hash, role) VALUES
('admin', 'Administrador do Sistema', '$2a$10$7Zm9NIpWYv/VvkysjkCCSeTudtBBx04oBKtwbtYp1V9FNtnscOz22', 'ADMIN'),
('cliente', 'Cliente Teste', '$2a$10$7Zm9NIpWYv/VvkysjkCCSeTudtBBx04oBKtwbtYp1V9FNtnscOz22', 'CLIENTE'),
('mecanico', 'João Mecânico', '$2a$10$7Zm9NIpWYv/VvkysjkCCSeTudtBBx04oBKtwbtYp1V9FNtnscOz22', 'MECANICO'),
('mecanico2', 'Carlos Silva', '$2a$10$7Zm9NIpWYv/VvkysjkCCSeTudtBBx04oBKtwbtYp1V9FNtnscOz22', 'MECANICO'),
('atendente', 'Maria Atendente', '$2a$10$7Zm9NIpWYv/VvkysjkCCSeTudtBBx04oBKtwbtYp1V9FNtnscOz22', 'ATENDENTE'),
('estoquista', 'Pedro Estoquista', '$2a$10$7Zm9NIpWYv/VvkysjkCCSeTudtBBx04oBKtwbtYp1V9FNtnscOz22', 'ESTOQUISTA')
ON CONFLICT (username) DO NOTHING;

\echo '✅ 6 usuários inseridos (senha: admin123)'

-- ============================================================================
-- 2. CLIENTES (Customer Service)
-- ============================================================================

\echo '👥 Inserindo clientes...'

INSERT INTO clientes (nome, cpf, email, telefone, endereco, data_nascimento) VALUES
('João da Silva', '111.444.777-35', 'joao.silva@email.com', '(11) 98765-4321', 
 '{"logradouro": "Rua das Flores", "numero": "123", "bairro": "Centro", "cidade": "São Paulo", "estado": "SP", "cep": "01310-100"}'::jsonb,
 '1985-03-15'),

('Maria Santos', '222.555.888-46', 'maria.santos@email.com', '(11) 97654-3210',
 '{"logradouro": "Av. Paulista", "numero": "1000", "complemento": "Apto 45", "bairro": "Bela Vista", "cidade": "São Paulo", "estado": "SP", "cep": "01310-200"}'::jsonb,
 '1990-07-20'),

('Pedro Oliveira', '333.666.999-57', 'pedro.oliveira@email.com', '(11) 96543-2109',
 '{"logradouro": "Rua Augusta", "numero": "500", "bairro": "Consolação", "cidade": "São Paulo", "estado": "SP", "cep": "01305-000"}'::jsonb,
 '1978-11-30'),

('Ana Costa', '444.777.000-68', 'ana.costa@email.com', '(21) 98765-1234',
 '{"logradouro": "Av. Atlântica", "numero": "2000", "bairro": "Copacabana", "cidade": "Rio de Janeiro", "estado": "RJ", "cep": "22021-000"}'::jsonb,
 '1995-02-10'),

('AutoPeças Ltda', NULL, 'contato@autopecas.com.br', '(11) 3456-7890',
 '{"logradouro": "Rua Comercial", "numero": "789", "bairro": "Industrial", "cidade": "São Paulo", "estado": "SP", "cep": "01234-567"}'::jsonb,
 NULL)
ON CONFLICT (email) DO NOTHING;

-- Define CNPJ para o cliente PJ
UPDATE clientes SET cnpj = '12.345.678/0001-90' WHERE email = 'contato@autopecas.com.br' AND cnpj IS NULL;

\echo '✅ 5 clientes inseridos (4 PF + 1 PJ)'

-- ============================================================================
-- 3. VEÍCULOS (Customer Service)
-- ============================================================================

\echo '🚗 Inserindo veículos...'

INSERT INTO veiculos (placa, marca, modelo, ano, cor, cliente_id) VALUES
('ABC1D23', 'Honda', 'Civic', 2023, 'Prata', (SELECT id FROM clientes WHERE cpf = '111.444.777-35')),
('XYZ9W87', 'Toyota', 'Corolla', 2022, 'Branco', (SELECT id FROM clientes WHERE cpf = '222.555.888-46')),
('DEF5G67', 'Volkswagen', 'Golf', 2021, 'Preto', (SELECT id FROM clientes WHERE cpf = '222.555.888-46')),
('GHI2J89', 'Chevrolet', 'Onix', 2024, 'Vermelho', (SELECT id FROM clientes WHERE cpf = '333.666.999-57')),
('JKL4M56', 'Fiat', 'Uno', 2020, 'Azul', (SELECT id FROM clientes WHERE cpf = '444.777.000-68')),
('MNO8P12', 'Ford', 'Ka', 2019, 'Cinza', (SELECT id FROM clientes WHERE cpf = '444.777.000-68'))
ON CONFLICT (placa) DO NOTHING;

\echo '✅ 6 veículos inseridos'

-- ============================================================================
-- 4. SERVIÇOS (Catalog Service)
-- ============================================================================

\echo '🔧 Inserindo serviços...'

INSERT INTO servicos (nome, descricao, categoria, preco_base, tempo_estimado_minutos) VALUES
('Troca de Óleo', 'Troca de óleo do motor e filtro', 'MECANICO', 150.00, 60),
('Alinhamento e Balanceamento', 'Alinhamento computadorizado e balanceamento de rodas', 'ALINHAMENTO', 120.00, 90),
('Revisão dos Freios', 'Inspeção e manutenção do sistema de freios', 'FREIOS', 200.00, 120),
('Troca de Bateria', 'Substituição da bateria', 'ELETRICO', 350.00, 30),
('Revisão de Suspensão', 'Inspeção completa da suspensão', 'SUSPENSAO', 280.00, 150),
('Troca de Correia Dentada', 'Substituição da correia dentada e tensor', 'MECANICO', 450.00, 180),
('Diagnóstico Eletrônico', 'Leitura de códigos de erro via scanner', 'ELETRICO', 80.00, 30),
('Troca de Pastilhas de Freio', 'Substituição das pastilhas dianteiras', 'FREIOS', 180.00, 60)
ON CONFLICT DO NOTHING;

\echo '✅ 8 serviços inseridos'

-- ============================================================================
-- 5. PRODUTOS (Catalog Service)
-- ============================================================================

\echo '📦 Inserindo produtos...'

INSERT INTO produtos_catalogo (nome, descricao, categoria, preco) VALUES
('Óleo Sintético 5W30', 'Óleo lubrificante sintético para motor', 'INSUMO', 45.00),
('Filtro de Óleo', 'Filtro de óleo para motores 1.0 a 2.0', 'PECA', 25.00),
('Pastilha de Freio Dianteira', 'Jogo de pastilhas para freio dianteiro', 'PECA', 120.00),
('Disco de Freio', 'Par de discos de freio ventilados', 'PECA', 280.00),
('Bateria 60Ah', 'Bateria automotiva 60 amperes', 'PECA', 320.00),
('Correia Dentada', 'Correia dentada original', 'PECA', 180.00),
('Filtro de Ar', 'Filtro de ar do motor', 'PECA', 35.00),
('Velas de Ignição', 'Jogo com 4 velas de ignição', 'PECA', 80.00),
('Fluido de Freio DOT 4', 'Fluido de freio 500ml', 'INSUMO', 28.00),
('Aditivo para Radiador', 'Aditivo concentrado para sistema de arrefecimento', 'INSUMO', 22.00)
ON CONFLICT DO NOTHING;

\echo '✅ 10 produtos inseridos'

-- ============================================================================
-- 6. ESTOQUE (Inventory Service)
-- ============================================================================

\echo '📊 Inserindo estoque...'

INSERT INTO produtos_estoque (produto_catalogo_id, quantidade_disponivel, quantidade_reservada, estoque_minimo, preco_custo_medio)
SELECT 
    id,
    CASE 
        WHEN categoria = 'INSUMO' THEN 50
        ELSE 20
    END as quantidade_disponivel,
    0 as quantidade_reservada,
    CASE 
        WHEN categoria = 'INSUMO' THEN 10
        ELSE 5
    END as estoque_minimo,
    preco * 0.7 as preco_custo_medio
FROM produtos_catalogo
WHERE NOT EXISTS (
    SELECT 1 FROM produtos_estoque pe WHERE pe.produto_catalogo_id = produtos_catalogo.id
);

\echo '✅ Estoque inicializado para todos os produtos'

-- ============================================================================
-- 7. MOVIMENTAÇÕES (Inventory Service)
-- ============================================================================

\echo '📝 Inserindo movimentações de estoque...'

-- Entrada inicial de estoque
INSERT INTO movimentacoes_estoque (produto_catalogo_id, tipo, quantidade, preco_unitario, data_movimentacao, observacao)
SELECT 
    id,
    'ENTRADA',
    CASE WHEN categoria = 'INSUMO' THEN 50 ELSE 20 END,
    preco * 0.7,
    CURRENT_TIMESTAMP - INTERVAL '30 days',
    'Estoque inicial'
FROM produtos_catalogo
ON CONFLICT DO NOTHING;

-- Algumas saídas (vendas)
INSERT INTO movimentacoes_estoque (produto_catalogo_id, tipo, quantidade, preco_unitario, data_movimentacao, observacao)
SELECT 
    id,
    'SAIDA',
    5,
    preco,
    CURRENT_TIMESTAMP - INTERVAL '15 days',
    'Venda para cliente'
FROM produtos_catalogo
WHERE categoria = 'PECA'
LIMIT 3
ON CONFLICT DO NOTHING;

\echo '✅ Movimentações de estoque inseridas'

-- ============================================================================
-- 8. ORDENS DE SERVIÇO (Work Order Service)
-- ============================================================================

\echo '🔨 Inserindo ordens de serviço...'

-- OS 1: João da Silva - Troca de óleo (FINALIZADA)
WITH os_inserted AS (
    INSERT INTO ordens_servico (cliente_id, veiculo_id, mecanico_id, status, criada_em, data_inicio_execucao, data_termino_execucao, observacoes)
    SELECT 
        c.id,
        v.id,
        u.id,
        'FINALIZADA',
        CURRENT_TIMESTAMP - INTERVAL '10 days',
        CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '2 hours',
        CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '3 hours',
        'Troca de óleo realizada. Cliente satisfeito.'
    FROM clientes c
    JOIN veiculos v ON v.cliente_id = c.id
    JOIN usuarios u ON u.username = 'mecanico'
    WHERE c.cpf = '111.444.777-35' AND v.placa = 'ABC1D23'
    LIMIT 1
    RETURNING id
)
INSERT INTO itens_ordem_servico (ordem_servico_id, servico_id, valor_unitario, quantidade)
SELECT os_inserted.id, s.id, s.preco_base, 1
FROM os_inserted, servicos s
WHERE s.nome = 'Troca de Óleo'
ON CONFLICT DO NOTHING;

-- Adicionar produtos à OS
WITH os_data AS (
    SELECT os.id as os_id
    FROM ordens_servico os
    JOIN veiculos v ON v.id = os.veiculo_id
    WHERE v.placa = 'ABC1D23'
    ORDER BY os.criada_em DESC
    LIMIT 1
)
INSERT INTO itens_ordem_servico (ordem_servico_id, produto_catalogo_id, valor_unitario, quantidade)
SELECT os_data.os_id, p.id, p.preco, 1
FROM os_data, produtos_catalogo p
WHERE p.nome IN ('Óleo Sintético 5W30', 'Filtro de Óleo')
ON CONFLICT DO NOTHING;

-- OS 2: Maria Santos - Revisão de freios (EM_EXECUCAO)
WITH os_inserted AS (
    INSERT INTO ordens_servico (cliente_id, veiculo_id, mecanico_id, status, criada_em, data_inicio_execucao, observacoes)
    SELECT 
        c.id,
        v.id,
        u.id,
        'EM_EXECUCAO',
        CURRENT_TIMESTAMP - INTERVAL '2 days',
        CURRENT_TIMESTAMP - INTERVAL '1 day',
        'Substituição de pastilhas e discos necessária.'
    FROM clientes c
    JOIN veiculos v ON v.cliente_id = c.id
    JOIN usuarios u ON u.username = 'mecanico2'
    WHERE c.cpf = '222.555.888-46' AND v.placa = 'XYZ9W87'
    LIMIT 1
    RETURNING id
)
INSERT INTO itens_ordem_servico (ordem_servico_id, servico_id, valor_unitario, quantidade)
SELECT os_inserted.id, s.id, s.preco_base, 1
FROM os_inserted, servicos s
WHERE s.nome = 'Revisão dos Freios'
ON CONFLICT DO NOTHING;

-- OS 3: Pedro Oliveira - Alinhamento (RECEBIDA)
INSERT INTO ordens_servico (cliente_id, veiculo_id, status, criada_em, observacoes)
SELECT 
    c.id,
    v.id,
    'RECEBIDA',
    CURRENT_TIMESTAMP,
    'Cliente relatou que o carro está puxando para a direita.'
FROM clientes c
JOIN veiculos v ON v.cliente_id = c.id
WHERE c.cpf = '333.666.999-57' AND v.placa = 'GHI2J89'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Adicionar serviço à OS
WITH os_data AS (
    SELECT os.id as os_id
    FROM ordens_servico os
    JOIN veiculos v ON v.id = os.veiculo_id
    WHERE v.placa = 'GHI2J89'
    ORDER BY os.criada_em DESC
    LIMIT 1
)
INSERT INTO itens_ordem_servico (ordem_servico_id, servico_id, valor_unitario, quantidade)
SELECT os_data.os_id, s.id, s.preco_base, 1
FROM os_data, servicos s
WHERE s.nome = 'Alinhamento e Balanceamento'
ON CONFLICT DO NOTHING;

\echo '✅ 3 ordens de serviço inseridas'

-- ============================================================================
-- 9. ORÇAMENTOS (Budget Service)
-- ============================================================================

\echo '💰 Inserindo orçamentos...'

-- Orçamento da OS 1 (APROVADO)
WITH os_data AS (
    SELECT os.id as os_id
    FROM ordens_servico os
    JOIN veiculos v ON v.id = os.veiculo_id
    WHERE v.placa = 'ABC1D23' AND os.status = 'FINALIZADA'
    ORDER BY os.criada_em DESC
    LIMIT 1
),
orc_inserted AS (
    INSERT INTO orcamentos (ordem_servico_id, valor_total, status, data_criacao, data_aprovacao)
    SELECT 
        os_data.os_id,
        (SELECT SUM(valor_unitario * quantidade) FROM itens_ordem_servico WHERE ordem_servico_id = os_data.os_id),
        'APROVADO',
        CURRENT_TIMESTAMP - INTERVAL '10 days',
        CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '1 hour'
    FROM os_data
    RETURNING id, ordem_servico_id
)
INSERT INTO itens_orcamento (orcamento_id, descricao, quantidade, valor_unitario)
SELECT 
    orc_inserted.id,
    COALESCE(s.nome, p.nome),
    ios.quantidade,
    ios.valor_unitario
FROM orc_inserted
JOIN itens_ordem_servico ios ON ios.ordem_servico_id = orc_inserted.ordem_servico_id
LEFT JOIN servicos s ON s.id = ios.servico_id
LEFT JOIN produtos_catalogo p ON p.id = ios.produto_catalogo_id
ON CONFLICT DO NOTHING;

-- Orçamento da OS 2 (CRIADO)
WITH os_data AS (
    SELECT os.id as os_id
    FROM ordens_servico os
    JOIN veiculos v ON v.id = os.veiculo_id
    WHERE v.placa = 'XYZ9W87' AND os.status = 'EM_EXECUCAO'
    ORDER BY os.criada_em DESC
    LIMIT 1
),
orc_inserted AS (
    INSERT INTO orcamentos (ordem_servico_id, valor_total, status, data_criacao)
    SELECT 
        os_data.os_id,
        (SELECT SUM(valor_unitario * quantidade) FROM itens_ordem_servico WHERE ordem_servico_id = os_data.os_id),
        'CRIADO',
        CURRENT_TIMESTAMP - INTERVAL '2 days'
    FROM os_data
    RETURNING id, ordem_servico_id
)
INSERT INTO itens_orcamento (orcamento_id, descricao, quantidade, valor_unitario)
SELECT 
    orc_inserted.id,
    COALESCE(s.nome, p.nome),
    ios.quantidade,
    ios.valor_unitario
FROM orc_inserted
JOIN itens_ordem_servico ios ON ios.ordem_servico_id = orc_inserted.ordem_servico_id
LEFT JOIN servicos s ON s.id = ios.servico_id
LEFT JOIN produtos_catalogo p ON p.id = ios.produto_catalogo_id
ON CONFLICT DO NOTHING;

\echo '✅ 2 orçamentos inseridos'

-- ============================================================================
-- RESUMO FINAL
-- ============================================================================

\echo ''
\echo '========================================='
\echo '✅ DADOS DE TESTE CARREGADOS COM SUCESSO'
\echo '========================================='
\echo ''
\echo '📊 Resumo:'
\echo '  👤 Usuários: 6 (admin, cliente, 2 mecânicos, atendente, estoquista)'
\echo '  👥 Clientes: 5 (4 PF + 1 PJ)'
\echo '  🚗 Veículos: 6'
\echo '  🔧 Serviços: 8'
\echo '  📦 Produtos: 10'
\echo '  📊 Estoque: Inicializado'
\echo '  📝 Movimentações: Várias entradas/saídas'
\echo '  🔨 Ordens de Serviço: 3 (FINALIZADA, EM_EXECUCAO, RECEBIDA)'
\echo '  💰 Orçamentos: 2 (APROVADO, CRIADO)'
\echo ''
\echo '🔑 Credenciais de acesso:'
\echo '  admin / admin123'
\echo '  mecanico / admin123'
\echo '  atendente / admin123'
\echo '  estoquista / admin123'
\echo ''
\echo '⚠️  ATENÇÃO: Estes dados são APENAS para DEV/TESTE!'
\echo '    NÃO executar em produção!'
\echo ''