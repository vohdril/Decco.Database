-- =============================================================================
-- 0004 — CONTRACT: remove o que a 0002 tornou redundante
--
--   DROP TABLE  Laboratorio               (absorvida por Instalacao)
--   DROP COLUMN Anomalia.SitioContencao   (substituída por InstalacaoContencaoId)
--   DROP PROC   sp_Laboratorio_Inserir    (substituída por sp_Instalacao_Inserir)
--
-- REGRA: este script só apaga depois de PROVAR que não há perda. As três
-- verificações abaixo abortam a migração inteira se qualquer dado antigo não
-- tiver correspondente no modelo novo.
-- Numa migração destrutiva, a verificação NÃO é opcional — é o que separa
-- "removemos uma coluna redundante" de "perdemos dados em produção".
--
-- ⚠️ O script inteiro é UM ÚNICO LOTE (sem GO), de propósito.
-- THROW aborta o LOTE corrente. No DbUp isso já basta (o erro derruba a
-- transação do script). Mas se alguém rodar este arquivo à mão no SSMS/sqlcmd,
-- cada GO inicia um lote novo que roda MESMO DEPOIS de um THROW no anterior —
-- e os DROPs aconteceriam com a verificação falhada. Em lote único, nenhum
-- DROP roda depois de um THROW, em qualquer ferramenta.
--
-- NotificacaoAnomalia.LocalIdentificado NÃO é removido: continua sendo a forma
-- de registrar um local de campo que não é instalação.
--
-- Depende de: 0002_instalacao.sql
-- =============================================================================

-- ── Verificação 1: todo laboratório virou instalação, com o mesmo código ────
IF EXISTS (
    SELECT 1 FROM Laboratorio l
     WHERE NOT EXISTS (SELECT 1 FROM Instalacao i WHERE i.Codigo = l.Codigo)
)
    THROW 50401, '0004 abortada: existe Laboratorio sem Instalacao correspondente. Nada foi removido.', 1;

-- ── Verificação 2: todo laboratório ficou pendurado num sítio ──────────────
IF EXISTS (
    SELECT 1 FROM Laboratorio l
      JOIN Instalacao i ON i.Codigo = l.Codigo
     WHERE i.InstalacaoPaiId IS NULL
)
    THROW 50402, '0004 abortada: existe laboratório migrado sem sítio-pai. Nada foi removido.', 1;

-- ── Verificação 3: toda anomalia com sítio em texto ganhou a FK ────────────
IF EXISTS (
    SELECT 1 FROM Anomalia
     WHERE LTRIM(RTRIM(ISNULL(SitioContencao, ''))) <> ''
       AND InstalacaoContencaoId IS NULL
)
    THROW 50403, '0004 abortada: existe Anomalia com SitioContencao sem InstalacaoContencaoId. Nada foi removido.', 1;

-- ── Remoção ────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS dbo.sp_Laboratorio_Inserir;

-- As extended properties da tabela e das colunas são removidas junto.
DROP TABLE dbo.Laboratorio;

ALTER TABLE dbo.Anomalia DROP COLUMN SitioContencao;
