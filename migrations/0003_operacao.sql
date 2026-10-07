-- =============================================================================
-- 0003 — OPERAÇÕES POR INSTALAÇÃO
--
-- Operacao é a primeira entidade GENUINAMENTE ESCOPADA POR INSTALAÇÃO do schema:
-- a Anomalia é catálogo global; Investigação, Pesquisa e Supressão são TRABALHO,
-- e trabalho pertence a uma instalação. É também o laboratório de testes do cache
-- escopado (chaves decco:inst:{codigo}:operacao:*, decco-compass reference/21).
--
-- Regra do operador: toda operação nasce associada a uma Instalação
-- -> Operacao.InstalacaoId NOT NULL.
--
-- Os tipos (INVESTIGACAO, PESQUISA, SUPRESSAO) NÃO são inseridos aqui: nenhuma
-- migração de dados depende deles. Vivem só no seed/100 (MERGE convergente).
-- Contraste com a 0002, que PRECISA dos tipos de instalação para migrar dados.
--
-- Depende de: 0002_instalacao.sql
-- =============================================================================

CREATE TABLE Cat_Operacao (
    Id                INT PRIMARY KEY IDENTITY(1,1),
    Codigo            VARCHAR(20)   NOT NULL UNIQUE,
    Nome              NVARCHAR(50)  NOT NULL,
    Descricao         NVARCHAR(MAX) NOT NULL,
    RequerAnomalia    BIT NOT NULL DEFAULT 0,   -- investigação pode nascer sem anomalia catalogada
    NivelAcessoMinimo INT NOT NULL DEFAULT 1,
    CorAlerta         VARCHAR(7) NULL DEFAULT '#FFFFFF',
    Ativo             BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Operacao (
    Id                  INT PRIMARY KEY IDENTITY(1,1),
    Codigo              VARCHAR(20)   NOT NULL UNIQUE,   -- OP-2026-0001
    Codinome            NVARCHAR(100) NOT NULL,          -- "Jaguar Silente"
    TipoOperacaoId      INT NOT NULL FOREIGN KEY REFERENCES Cat_Operacao(Id),

    -- Escopo: toda operação nasce dentro de uma instalação
    InstalacaoId        INT NOT NULL FOREIGN KEY REFERENCES Instalacao(Id),

    -- Alvos opcionais
    AnomaliaId          INT NULL FOREIGN KEY REFERENCES Anomalia(Id),
    NotificacaoId       INT NULL FOREIGN KEY REFERENCES NotificacaoAnomalia(Id),
    ProtocoloId         INT NULL FOREIGN KEY REFERENCES ProtocoloContencao(Id),

    Objetivo            NVARCHAR(500) NOT NULL,
    Descricao           NVARCHAR(MAX) NULL,
    Status              VARCHAR(20) NOT NULL DEFAULT 'PLANEJADA',
    Prioridade          INT NOT NULL DEFAULT 3,
    NivelAcessoMinimo   INT NOT NULL DEFAULT 1,           -- clearance para VER a operação
    Responsavel         NVARCHAR(255) NULL,               -- vira FK para User quando o DeccoAuthDB existir

    DataAbertura        DATETIME NOT NULL DEFAULT GETDATE(),
    DataPrevisaoTermino DATETIME NULL,
    DataEncerramento    DATETIME NULL,
    ResultadoResumo     NVARCHAR(MAX) NULL,

    DataCriacao         DATETIME NOT NULL DEFAULT GETDATE(),
    DataAtualizacao     DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCriacao      NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
    UsuarioAtualizacao  NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,

    CONSTRAINT CK_Operacao_Status     CHECK (Status IN ('PLANEJADA', 'EM_ANDAMENTO', 'SUSPENSA', 'CONCLUIDA', 'ABORTADA')),
    CONSTRAINT CK_Operacao_Prioridade CHECK (Prioridade BETWEEN 1 AND 5),
    CONSTRAINT CK_Operacao_Encerramento CHECK (DataEncerramento IS NULL OR DataEncerramento >= DataAbertura)
);
GO

CREATE INDEX IX_Operacao_Instalacao ON Operacao(InstalacaoId);   -- a chave do cache escopado
CREATE INDEX IX_Operacao_Status     ON Operacao(Status);
CREATE INDEX IX_Operacao_Anomalia   ON Operacao(AnomaliaId);
CREATE INDEX IX_Operacao_Tipo       ON Operacao(TipoOperacaoId);
GO
