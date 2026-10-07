-- =============================================================================
-- 0002 — INSTALAÇÕES (fase EXPAND)
--
-- Introduz a entidade Instalacao (com tipo e hierarquia) e MIGRA os dados que
-- hoje vivem em texto livre:
--   Laboratorio (tabela)            -> Instalacao do tipo LABORATORIO
--   Laboratorio.Sitio (texto)       -> Instalacao do tipo SITIO (pai do laboratório)
--   Anomalia.SitioContencao (texto) -> Anomalia.InstalacaoContencaoId (FK)
--   NotificacaoAnomalia.LocalIdentificado -> + NotificacaoAnomalia.InstalacaoId (FK)
--
-- Padrão EXPAND/CONTRACT: nada é apagado aqui. A remoção de Laboratorio e de
-- Anomalia.SitioContencao acontece na 0004, que antes VERIFICA que todo dado
-- antigo tem correspondente novo. Separar as duas fases é o que torna a
-- migração auditável e evita perda de dados.
--
-- A migração é GENÉRICA (set-based), não codifica os valores atuais: roda igual
-- num banco populado (adoção) e num banco vazio (máquina nova) — neste último,
-- os INSERT ... SELECT simplesmente não encontram linhas.
--
-- Decisões registradas em DECCO-BACKLOG.md / decco-compass reference/22:
--   Cat_TipoInstalacao (não Cat_Sitio) · entidade Instalacao · Laboratorio absorvido.
--   UserInstalacao NÃO entra aqui: pertence ao DeccoAuthDB (Docker).
-- =============================================================================

-- ── 1. Catálogo de tipos de instalação ──────────────────────────────────────
CREATE TABLE Cat_TipoInstalacao (
    Id            INT PRIMARY KEY IDENTITY(1,1),
    Codigo        VARCHAR(20)   NOT NULL UNIQUE,
    Nome          NVARCHAR(50)  NOT NULL,
    Descricao     NVARCHAR(MAX) NOT NULL,
    PermiteFilhos BIT NOT NULL DEFAULT 0,
    Ativo         BIT NOT NULL DEFAULT 1
);
GO

-- Os tipos são inseridos AQUI (e não só no seed) porque a migração de dados
-- abaixo depende deles, e o seed roda DEPOIS das migrações. O seed/090
-- converge descrições e eventuais tipos novos em toda execução.
INSERT INTO Cat_TipoInstalacao (Codigo, Nome, Descricao, PermiteFilhos) VALUES
('SITIO',          N'Sítio',             N'Complexo de contenção autônomo. Raiz da hierarquia: abriga laboratórios, áreas e postos.', 1),
('LABORATORIO',    N'Laboratório',       N'Unidade de pesquisa dentro de um sítio, com especialidade e responsável.',                0),
('AREA_CONTENCAO', N'Área de Contenção', N'Ala ou recinto de um sítio dedicado à guarda de anomalias.',                               0),
('POSTO_AVANCADO', N'Posto Avançado',    N'Base operacional temporária ou remota, vinculada a um sítio.',                             0);
GO

-- ── 2. A entidade Instalacao ────────────────────────────────────────────────
CREATE TABLE Instalacao (
    Id                 INT PRIMARY KEY IDENTITY(1,1),
    Codigo             VARCHAR(20)   NOT NULL UNIQUE,
    Nome               NVARCHAR(255) NOT NULL,
    Descricao          NVARCHAR(MAX) NULL,
    TipoInstalacaoId   INT NOT NULL FOREIGN KEY REFERENCES Cat_TipoInstalacao(Id),
    InstalacaoPaiId    INT NULL     FOREIGN KEY REFERENCES Instalacao(Id),
    Responsavel        NVARCHAR(255) NULL,
    Especialidade      VARCHAR(50)   NULL,
    NivelAcessoMinimo  INT NOT NULL DEFAULT 1,
    Status             VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
    DataCriacao        DATETIME NOT NULL DEFAULT GETDATE(),
    DataAtualizacao    DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCriacao     NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
    UsuarioAtualizacao NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
    CONSTRAINT CK_Instalacao_NaoEhPaiDeSiMesma CHECK (InstalacaoPaiId IS NULL OR InstalacaoPaiId <> Id),
    CONSTRAINT CK_Instalacao_Status CHECK (Status IN ('ATIVA', 'INATIVA', 'DESATIVADA'))
);
GO

CREATE INDEX IX_Instalacao_Pai  ON Instalacao(InstalacaoPaiId);
CREATE INDEX IX_Instalacao_Tipo ON Instalacao(TipoInstalacaoId);
GO

-- ── 3. Migração: sítios ─────────────────────────────────────────────────────
-- Fontes de nome de sítio: Laboratorio.Sitio e o trecho ANTES da vírgula de
-- Anomalia.SitioContencao ("Sítio-19, Setor de Biologia Anômala" -> "Sítio-19").
-- Notificações NÃO criam sítios: um relato de campo pode vir de fora de qualquer
-- instalação conhecida; elas só se LIGAM a sítios que já existam (passo 6).
-- Código: nome em maiúsculas, sem acento no "í" e com hífen no lugar de espaço
-- ("Sítio-19" -> "SITIO-19").
;WITH nomes AS (
    SELECT LTRIM(RTRIM(Sitio)) AS Nome
      FROM Laboratorio
     WHERE LTRIM(RTRIM(ISNULL(Sitio, ''))) <> ''
    UNION
    SELECT LTRIM(RTRIM(LEFT(SitioContencao, CHARINDEX(',', SitioContencao + ',') - 1)))
      FROM Anomalia
     WHERE LTRIM(RTRIM(ISNULL(SitioContencao, ''))) <> ''
)
INSERT INTO Instalacao (Codigo, Nome, TipoInstalacaoId, NivelAcessoMinimo, Status)
SELECT LEFT(UPPER(REPLACE(REPLACE(REPLACE(n.Nome, N'í', N'i'), N'Í', N'I'), N' ', N'-')), 20),
       n.Nome, t.Id, 1, 'ATIVA'
  FROM nomes n
 CROSS JOIN Cat_TipoInstalacao t
 WHERE t.Codigo = 'SITIO';
GO

-- ── 4. Migração: laboratórios -> Instalacao(LABORATORIO), filhos do sítio ──
-- Preserva Codigo, datas e todos os atributos. Status é normalizado para o
-- vocabulário feminino de Instalacao (ATIVO -> ATIVA, INATIVO -> INATIVA).
INSERT INTO Instalacao (Codigo, Nome, Descricao, TipoInstalacaoId, InstalacaoPaiId,
                        Responsavel, Especialidade, NivelAcessoMinimo, Status,
                        DataCriacao, DataAtualizacao)
SELECT l.Codigo, l.Nome, l.Descricao, tl.Id, s.Id,
       l.Responsavel, l.Especialidade, l.NivelAcessoMinimo,
       CASE ISNULL(l.Status, 'ATIVO')
            WHEN 'ATIVO'   THEN 'ATIVA'
            WHEN 'INATIVO' THEN 'INATIVA'
            ELSE 'ATIVA'
       END,
       ISNULL(l.DataCriacao, GETDATE()), ISNULL(l.DataAtualizacao, GETDATE())
  FROM Laboratorio l
  JOIN Cat_TipoInstalacao tl ON tl.Codigo = 'LABORATORIO'
  LEFT JOIN Instalacao s
         ON s.Nome = LTRIM(RTRIM(l.Sitio))
        AND s.TipoInstalacaoId = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'SITIO');
GO

-- ── 5. Anomalia: FK para a instalação de contenção ──────────────────────────
ALTER TABLE Anomalia ADD InstalacaoContencaoId INT NULL
    CONSTRAINT FK_Anomalia_InstalacaoContencao FOREIGN KEY REFERENCES Instalacao(Id);
GO

CREATE INDEX IX_Anomalia_InstalacaoContencao ON Anomalia(InstalacaoContencaoId);
GO

-- 5a. Áreas de contenção: "Sítio-64, Biblioteca Proibida" tem um local depois
--     da vírgula que não é laboratório. Para não perder essa informação, ele vira
--     uma Instalacao do tipo AREA_CONTENCAO, filha do sítio.
;WITH partes AS (
    SELECT LTRIM(RTRIM(LEFT(SitioContencao, CHARINDEX(',', SitioContencao + ',') - 1)))      AS SitioNome,
           LTRIM(RTRIM(SUBSTRING(SitioContencao, CHARINDEX(',', SitioContencao + ',') + 1, 400))) AS Local
      FROM Anomalia
     WHERE LTRIM(RTRIM(ISNULL(SitioContencao, ''))) <> ''
),
areas AS (
    SELECT DISTINCT p.SitioNome, p.Local
      FROM partes p
      JOIN Instalacao s ON s.Nome = p.SitioNome AND s.InstalacaoPaiId IS NULL
     WHERE p.Local <> ''
       AND NOT EXISTS (SELECT 1 FROM Instalacao f WHERE f.InstalacaoPaiId = s.Id AND f.Nome = p.Local)
)
INSERT INTO Instalacao (Codigo, Nome, TipoInstalacaoId, InstalacaoPaiId, NivelAcessoMinimo, Status)
SELECT 'AREA-' + RIGHT('000' + CAST(ROW_NUMBER() OVER (ORDER BY a.SitioNome, a.Local) AS VARCHAR(3)), 3),
       a.Local, t.Id, s.Id, 1, 'ATIVA'
  FROM areas a
  JOIN Instalacao s ON s.Nome = a.SitioNome AND s.InstalacaoPaiId IS NULL
  JOIN Cat_TipoInstalacao t ON t.Codigo = 'AREA_CONTENCAO';
GO

-- 5b. Liga cada anomalia à instalação mais específica que a descreve:
--     o filho do sítio cujo nome é o local; senão, o próprio sítio.
--
--     O trigger de auditoria é DESLIGADO durante esta atualização: uma migração
--     estrutural não é uma edição de negócio, e não deve sobrescrever
--     DataAtualizacao/UsuarioAtualizacao ("quem mexeu por último nesta
--     anomalia"). O IF existe porque, num banco vazio, os triggers ainda não
--     foram criados quando as migrações rodam (a programabilidade vem depois).
IF OBJECT_ID(N'dbo.TR_Anomalia_Update_Date', N'TR') IS NOT NULL
    EXEC(N'DISABLE TRIGGER dbo.TR_Anomalia_Update_Date ON dbo.Anomalia;');
GO

;WITH partes AS (
    SELECT a.Id,
           LTRIM(RTRIM(LEFT(a.SitioContencao, CHARINDEX(',', a.SitioContencao + ',') - 1)))      AS SitioNome,
           LTRIM(RTRIM(SUBSTRING(a.SitioContencao, CHARINDEX(',', a.SitioContencao + ',') + 1, 400))) AS Local
      FROM Anomalia a
     WHERE LTRIM(RTRIM(ISNULL(a.SitioContencao, ''))) <> ''
)
UPDATE a
   SET a.InstalacaoContencaoId = COALESCE(filho.Id, sitio.Id)
  FROM Anomalia a
  JOIN partes p      ON p.Id = a.Id
  JOIN Instalacao sitio ON sitio.Nome = p.SitioNome AND sitio.InstalacaoPaiId IS NULL
  LEFT JOIN Instalacao filho ON filho.InstalacaoPaiId = sitio.Id AND filho.Nome = p.Local;
GO

IF OBJECT_ID(N'dbo.TR_Anomalia_Update_Date', N'TR') IS NOT NULL
    EXEC(N'ENABLE TRIGGER dbo.TR_Anomalia_Update_Date ON dbo.Anomalia;');
GO

-- ── 6. NotificacaoAnomalia: FK opcional para o sítio identificado ───────────
-- LocalIdentificado (texto) PERMANECE: o relato pode citar um lugar fora de
-- qualquer instalação ("Perímetro Oeste" não é instalação). A FK só é
-- preenchida quando o trecho antes da vírgula casa com um sítio existente.
ALTER TABLE NotificacaoAnomalia ADD InstalacaoId INT NULL
    CONSTRAINT FK_NotificacaoAnomalia_Instalacao FOREIGN KEY REFERENCES Instalacao(Id);
GO

CREATE INDEX IX_NotificacaoAnomalia_Instalacao ON NotificacaoAnomalia(InstalacaoId);
GO

UPDATE n
   SET n.InstalacaoId = s.Id
  FROM NotificacaoAnomalia n
  JOIN Instalacao s
    ON s.Nome = LTRIM(RTRIM(LEFT(n.LocalIdentificado, CHARINDEX(',', n.LocalIdentificado + ',') - 1)))
   AND s.InstalacaoPaiId IS NULL
 WHERE n.InstalacaoId IS NULL;
GO
