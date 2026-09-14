-- ═══════════════════════════════════════════════════════════════
-- CONSOLIDADO ZANAROLLI — Mapa completo · 14/09/2026
-- Rodar em: https://supabase.com/dashboard/project/zvzolwyqezfzjrqydfnt/sql/new
-- ═══════════════════════════════════════════════════════════════

-- ── 1. HEARTBEAT ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS heartbeat (
  id SERIAL PRIMARY KEY,
  ping_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE heartbeat DISABLE ROW LEVEL SECURITY;
GRANT ALL ON heartbeat TO anon;
GRANT USAGE, SELECT ON SEQUENCE heartbeat_id_seq TO anon;

-- ── 2. LOGS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS logs (
  id SERIAL PRIMARY KEY,
  painel TEXT NOT NULL,
  campo TEXT,
  valor_anterior TEXT,
  valor_novo TEXT,
  descricao TEXT,
  usuario_id TEXT,
  usuario_nome TEXT DEFAULT 'sistema',
  criado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE logs DISABLE ROW LEVEL SECURITY;
GRANT ALL ON logs TO anon;
GRANT USAGE, SELECT ON SEQUENCE logs_id_seq TO anon;

-- ── 3. ALERTAS CONFIG ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS alertas_config (
  id SERIAL PRIMARY KEY,
  email_destino TEXT NOT NULL,
  dias_antecedencia INTEGER DEFAULT 3,
  categorias_ativas TEXT[] DEFAULT ARRAY['CONTAS','ACORDOS','CDB','IMOVEIS'],
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE alertas_config DISABLE ROW LEVEL SECURITY;
GRANT ALL ON alertas_config TO anon;
GRANT USAGE, SELECT ON SEQUENCE alertas_config_id_seq TO anon;

INSERT INTO alertas_config (email_destino, dias_antecedencia) 
VALUES ('gabrielrzan@gmail.com', 3)
ON CONFLICT DO NOTHING;

-- ── 4. ALERTAS ENVIADOS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS alertas_enviados (
  id SERIAL PRIMARY KEY,
  conta_id INTEGER,
  tipo TEXT NOT NULL,
  descricao TEXT,
  enviado_em TIMESTAMPTZ DEFAULT NOW(),
  notificado_em DATE,
  usuario_id TEXT,
  usuario_nome TEXT
);
ALTER TABLE alertas_enviados DISABLE ROW LEVEL SECURITY;
GRANT ALL ON alertas_enviados TO anon;
GRANT USAGE, SELECT ON SEQUENCE alertas_enviados_id_seq TO anon;

-- ── 5. PENDÊNCIAS OPERACIONAIS ───────────────────────────────
CREATE TABLE IF NOT EXISTS pendencias_operacionais (
  id SERIAL PRIMARY KEY,
  descricao TEXT NOT NULL,
  categoria TEXT NOT NULL,
  centro_custo TEXT,
  responsavel TEXT,
  prazo DATE,
  prioridade TEXT DEFAULT 'normal' CHECK (prioridade IN ('urgente','normal','baixa')),
  status TEXT DEFAULT 'pendente' CHECK (status IN ('pendente','em_andamento','resolvido')),
  observacao TEXT,
  painel_relacionado TEXT,
  criado_automaticamente BOOLEAN DEFAULT FALSE,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE pendencias_operacionais DISABLE ROW LEVEL SECURITY;
GRANT ALL ON pendencias_operacionais TO anon;
GRANT USAGE, SELECT ON SEQUENCE pendencias_operacionais_id_seq TO anon;

INSERT INTO pendencias_operacionais (descricao, categoria, centro_custo, prioridade, status) VALUES
  ('Abrir chamado 1doc unificando CAC 8.810/2026 + protocolo 36.478/2026', 'Izzo 351', '02.1', 'urgente', 'pendente'),
  ('Cobrar reemissão boleto no protocolo 36.478/2026 (valor correto)', 'Izzo 351', '02.1', 'urgente', 'pendente'),
  ('Gerar 2ª via parc. 32 no portal prefeitura', 'Acordos', '03.2', 'urgente', 'pendente'),
  ('Gerar 2ª via parc. 33 no portal prefeitura', 'Acordos', '03.3', 'urgente', 'pendente'),
  ('Solicitar boletos 36+ via 1DOC a partir de nov/2026', 'Acordos', '03.2', 'normal', 'pendente'),
  ('Solicitar boletos 37+ via 1DOC a partir de nov/2026', 'Acordos', '03.3', 'normal', 'pendente'),
  ('Transferir rend. CDB Sítio (~R$453) → CC Itaú para Renata 3/7 set/26', 'CDB', '00.1.1.2', 'urgente', 'pendente'),
  ('Resgatar rend. CDB Juca julho (~R$400) → alocar em 05 Gabriel', 'CDB', '00.1.1.1', 'normal', 'pendente')
ON CONFLICT DO NOTHING;

-- ── 6. FATURAS NUBANK ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS faturas_nubank (
  id SERIAL PRIMARY KEY,
  mes_referencia TEXT NOT NULL,
  data_fechamento DATE,
  data_vencimento DATE,
  valor_total NUMERIC(12,2) DEFAULT 0,
  status TEXT DEFAULT 'aberta' CHECK (status IN ('aberta','fechada','paga')),
  pago_em DATE,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE faturas_nubank DISABLE ROW LEVEL SECURITY;
GRANT ALL ON faturas_nubank TO anon;
GRANT USAGE, SELECT ON SEQUENCE faturas_nubank_id_seq TO anon;

INSERT INTO faturas_nubank (mes_referencia, data_vencimento, valor_total, status, pago_em) VALUES
  ('ago/26', '2026-08-28', 2290.73, 'paga', '2026-08-27')
ON CONFLICT DO NOTHING;

-- ── 7. APARTAMENTO FINANCIADO ────────────────────────────────
CREATE TABLE IF NOT EXISTS apartamento_financiado (
  id SERIAL PRIMARY KEY,
  descricao TEXT DEFAULT 'Apartamento financiado',
  saldo_devedor NUMERIC(12,2) NOT NULL,
  parcela_atual NUMERIC(10,2) NOT NULL,
  taxa_aa NUMERIC(5,2) DEFAULT 10.89,
  taxa_am NUMERIC(6,4) DEFAULT 0.865125,
  sistema TEXT DEFAULT 'SAC',
  dia_vencimento INTEGER DEFAULT 10,
  aluguel_mensal NUMERIC(10,2) DEFAULT 0,
  aluguel_inicio DATE,
  plataforma TEXT DEFAULT 'QuintoAndar',
  status TEXT DEFAULT 'ativo',
  observacao TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE apartamento_financiado DISABLE ROW LEVEL SECURITY;
GRANT ALL ON apartamento_financiado TO anon;
GRANT USAGE, SELECT ON SEQUENCE apartamento_financiado_id_seq TO anon;

INSERT INTO apartamento_financiado 
  (descricao, saldo_devedor, parcela_atual, taxa_aa, sistema, aluguel_mensal, aluguel_inicio, plataforma) 
VALUES 
  ('Apartamento financiado', 0, 3500.00, 10.89, 'SAC', 0, '2026-10-01', 'QuintoAndar')
ON CONFLICT DO NOTHING;

-- ── 8. PARCELAS APARTAMENTO ──────────────────────────────────
CREATE TABLE IF NOT EXISTS apartamento_parcelas (
  id SERIAL PRIMARY KEY,
  apartamento_id INTEGER REFERENCES apartamento_financiado(id),
  mes_referencia TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('parcela','amortizacao_extra','aluguel')),
  valor NUMERIC(12,2) NOT NULL,
  valor_juros NUMERIC(12,2) DEFAULT 0,
  valor_amortizacao NUMERIC(12,2) DEFAULT 0,
  saldo_devedor_apos NUMERIC(12,2),
  pago_em DATE,
  status TEXT DEFAULT 'pendente',
  observacao TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE apartamento_parcelas DISABLE ROW LEVEL SECURITY;
GRANT ALL ON apartamento_parcelas TO anon;
GRANT USAGE, SELECT ON SEQUENCE apartamento_parcelas_id_seq TO anon;

-- ── 9. USUÁRIOS PERFIL ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuarios_perfil (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  nivel_acesso TEXT DEFAULT 'editor' CHECK (nivel_acesso IN ('administrador','editor','leitor','restrito')),
  paineis_permitidos TEXT[] DEFAULT NULL,
  tema TEXT DEFAULT 'escuro' CHECK (tema IN ('escuro','claro')),
  tamanho_fonte TEXT DEFAULT 'medio' CHECK (tamanho_fonte IN ('pequeno','medio','grande')),
  convidado_por TEXT,
  ultimo_acesso TIMESTAMPTZ,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE usuarios_perfil DISABLE ROW LEVEL SECURITY;
GRANT ALL ON usuarios_perfil TO anon;

INSERT INTO usuarios_perfil (id, nome, email, nivel_acesso, paineis_permitidos) VALUES
  ('gabriel', 'Gabriel', 'gabrielrzan@gmail.com', 'administrador', NULL),
  ('renato', 'Renato', 'renato@zanarolli.com', 'administrador', NULL),
  ('tania', 'Tania', 'tania@zanarolli.com', 'administrador', NULL),
  ('thais', 'Thais', 'thais@zanarolli.com', 'restrito', ARRAY['02.5'])
ON CONFLICT (id) DO NOTHING;

-- ── 10. VIEW CALENDÁRIO ──────────────────────────────────────
CREATE OR REPLACE VIEW vw_calendario AS
  -- Lançamentos realizados (conta corrente)
  SELECT 
    data AS data_evento,
    descricao,
    valor,
    CASE WHEN valor >= 0 THEN 'entrada' ELSE 'saida' END AS tipo_cor,
    tipo AS categoria,
    centro_custo,
    'conta_corrente' AS origem,
    id AS origem_id
  FROM conta_corrente
  WHERE realizado = true

  UNION ALL

  -- Contas a pagar (vencimentos)
  SELECT
    vencimento AS data_evento,
    descricao,
    -valor AS valor,
    CASE status WHEN 'pago' THEN 'entrada' WHEN 'vencido' THEN 'vencido' ELSE 'saida' END AS tipo_cor,
    categoria,
    centro_custo,
    'contas_pagar' AS origem,
    id AS origem_id
  FROM contas_pagar
  WHERE vencimento IS NOT NULL

  UNION ALL

  -- Aluguel Dracenas (dia 14 de cada mês)
  SELECT
    DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '13 days' AS data_evento,
    'Aluguel Dracenas' AS descricao,
    957.55 AS valor,
    'entrada' AS tipo_cor,
    'ALUGUEL' AS categoria,
    '02.4' AS centro_custo,
    'imoveis' AS origem,
    1 AS origem_id;

GRANT SELECT ON vw_calendario TO anon;

-- ── CONFIRMAÇÃO ──────────────────────────────────────────────
SELECT 
  'heartbeat' as tabela, COUNT(*) as registros FROM heartbeat
UNION ALL SELECT 'logs', COUNT(*) FROM logs
UNION ALL SELECT 'alertas_config', COUNT(*) FROM alertas_config
UNION ALL SELECT 'alertas_enviados', COUNT(*) FROM alertas_enviados
UNION ALL SELECT 'pendencias_operacionais', COUNT(*) FROM pendencias_operacionais
UNION ALL SELECT 'faturas_nubank', COUNT(*) FROM faturas_nubank
UNION ALL SELECT 'apartamento_financiado', COUNT(*) FROM apartamento_financiado
UNION ALL SELECT 'apartamento_parcelas', COUNT(*) FROM apartamento_parcelas
UNION ALL SELECT 'usuarios_perfil', COUNT(*) FROM usuarios_perfil;
