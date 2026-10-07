-- =============================================================================
-- 0001 — BASELINE: schema do DeccoDB
--
-- Origem: decco.sql (1.345 linhas), o script que criou o banco em producao.
-- Conteudo: as 21 tabelas + 12 indices, DDL **inalterado**, na ordem original.
--
-- Fora deste arquivo, de proposito:
--   CREATE DATABASE / USE  -> o runner cria o banco (EnsureDatabase.For.SqlDatabase)
--   triggers / SPs / views -> programmability/  (CREATE OR ALTER, run-always)
--   catalogos              -> seed/             (MERGE idempotente, run-always)
--   dados de exemplo       -> seed/exemplos/    (guardados por IF NOT EXISTS)
--
-- ADOCAO: num banco que JA existe, este script e marcado como executado
-- (runner --baseline) e NUNCA roda. Num banco vazio, roda normalmente.
-- =============================================================================

-- =============================================
-- SEÇÃO 1: TABELAS DE CATÁLOGO FUNDAMENTAL
-- =============================================

-- CAT0: CLASSES DE OBJETO (Protocolos de Contenção)
CREATE TABLE Cat_ClasseObjeto (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(10) NOT NULL UNIQUE,
    Nome VARCHAR(50) NOT NULL,
    TipoClasse VARCHAR(50) NOT NULL, --PRIMÁRIA, SECUNDÁRIA,....
	ClasseACS VARCHAR (40) NULL,
    Descricao TEXT NULL,
    NivelAcessoMinimo INT NOT NULL DEFAULT 1,
    CorAlerta VARCHAR(7) NULL DEFAULT '#FFFFFF',
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    Ativo BIT NOT NULL DEFAULT 1
);
GO

-- CAT1: FORÇAS FUNDAMENTAIS (A fonte primária da anomalia)
CREATE TABLE Cat_ForcaFundamental (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Simbolo CHAR(10) NOT NULL UNIQUE,
    Nome VARCHAR(50) NOT NULL UNIQUE,
    Descricao NVARCHAR(MAX) NOT NULL,
    ParticulaPortadora VARCHAR(50) NULL
);
GO

-- CAT2: CAMADAS ONTOLÓGICAS (Onde a anomalia 'vive')
CREATE TABLE Cat_CamadaOntologica (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Simbolo CHAR(10) NOT NULL UNIQUE,
    Nome VARCHAR(50) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    ForcaFundamentalId INT NULL FOREIGN KEY REFERENCES Cat_ForcaFundamental(Id),
    Prioridade INT NOT NULL DEFAULT 1
);
GO

-- CAT3: TIPOS DE MATÉRIA
CREATE TABLE Cat_TipoMateria (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(50) NOT NULL UNIQUE,
    Descricao NVARCHAR(MAX) NOT NULL,
    IsResistenteSupressores BIT NOT NULL DEFAULT 0
);
GO

-- CAT4: MECANISMOS DE INTERAÇÃO (Como a anomalia interage)
CREATE TABLE Cat_MecanismoInteracao (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(10) NOT NULL UNIQUE,
    Nome VARCHAR(100) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    CamadaOntologicaId INT NOT NULL FOREIGN KEY REFERENCES Cat_CamadaOntologica(Id),
    EhSubnatureza BIT NOT NULL DEFAULT 0
);
GO

-- CAT5: MANIFESTAÇÕES ESPECÍFICAS (Efeitos observáveis)
CREATE TABLE Cat_ManifestacaoEspecifica (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(20) NOT NULL UNIQUE,
    Nome NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL
);
GO

-- CAT6: COGNIÇÃO APARENTE (SE/SA/IN/AA)
CREATE TABLE Cat_CognicaoAparente (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(5) NOT NULL UNIQUE,
    Nome VARCHAR(50) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL
);
GO

-- CAT7: PERICULOSIDADE (Mínimo → Máximo, 9 níveis)
CREATE TABLE Cat_Periculosidade (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nivel INT NOT NULL UNIQUE CHECK (Nivel BETWEEN 1 AND 9),
    Nome VARCHAR(50) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    CorAlerta VARCHAR(7) NULL DEFAULT '#FFFFFF'
);
GO

-- =============================================
-- SEÇÃO 2: TABELA PRINCIPAL DE ANOMALIAS
-- =============================================

CREATE TABLE Anomalia (
    Id INT PRIMARY KEY IDENTITY(1000,1),
    CodigoSCP VARCHAR(50) NOT NULL UNIQUE,
    NomeComum NVARCHAR(255) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    
    -- Classificação Básica
    ClasseObjetoId INT NOT NULL FOREIGN KEY REFERENCES Cat_ClasseObjeto(Id),
    CamadaOntologicaId INT NOT NULL FOREIGN KEY REFERENCES Cat_CamadaOntologica(Id),
    TipoMateriaId INT NOT NULL FOREIGN KEY REFERENCES Cat_TipoMateria(Id),
    
    -- Classificação Brasileira (Sistema OA)
    CognicaoAparenteId INT NULL FOREIGN KEY REFERENCES Cat_CognicaoAparente(Id),
    PericulosidadeId INT NULL FOREIGN KEY REFERENCES Cat_Periculosidade(Id),
    
    -- Mecanismos Padrão
    MecanismoPrimarioId INT NOT NULL FOREIGN KEY REFERENCES Cat_MecanismoInteracao(Id),
    MecanismoSecundarioId INT NULL FOREIGN KEY REFERENCES Cat_MecanismoInteracao(Id),
    
    -- Marcadores Theta
    IEIA_D_Base DECIMAL(8,4) NULL,
    FatorCoerenciaSpin VARCHAR(20) NULL,
    
    -- Status
    Status VARCHAR(20) DEFAULT 'ATIVA',
    SitioContencao NVARCHAR(100) NULL,
    ResponsavelPesquisa NVARCHAR(255) NULL,
    
    -- Auditoria
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE(),
    UsuarioCriacao NVARCHAR(128) DEFAULT SYSTEM_USER,
    UsuarioAtualizacao NVARCHAR(128) DEFAULT SYSTEM_USER
);
GO

-- =============================================
-- SEÇÃO 3: SUBTABELAS 1:N (INSTÂNCIAS)
-- =============================================

CREATE TABLE EntidadeViva (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id) ON DELETE CASCADE,
    Identificacao NVARCHAR(100) NOT NULL,
    Especie NVARCHAR(150) NOT NULL,
    Biologia NVARCHAR(255) NULL,
    OrigemPoder NVARCHAR(100) NULL,
    DataNascimento DATE NULL,
    IsConsciente BIT DEFAULT 1,
    NivelInteligencia INT NULL,
    Dieta NVARCHAR(100) NULL,
    Observacoes NVARCHAR(MAX) NULL
);
GO

CREATE TABLE Artefato (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id) ON DELETE CASCADE,
    Identificacao NVARCHAR(100) NOT NULL,
    Material NVARCHAR(255) NULL,
    DataFabricacao DATE NULL,
    LocalOrigem NVARCHAR(255) NULL,
    PropriedadeSpin VARCHAR(100) NULL,
    Peso_Kg DECIMAL(10,2) NULL,
    Dimensoes VARCHAR(100) NULL,
    ModoUsar NVARCHAR(MAX) NULL
);
GO

CREATE TABLE Localidade (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id) ON DELETE CASCADE,
    Nome NVARCHAR(255) NOT NULL,
    Coordenadas GEOGRAPHY NULL,
    RaioEfeitoMetros INT NULL,
    IEIA_D_Ambiente DECIMAL(8,4) NULL,
    IsGeograficamenteLimitada BIT DEFAULT 1,
    TipoTerreno VARCHAR(100) NULL,
    ClimaAnomalo VARCHAR(100) NULL
);
GO

CREATE TABLE Evento (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id) ON DELETE CASCADE,
    Nome NVARCHAR(255) NOT NULL,
    DataHoraInicio DATETIME NOT NULL,
    DataHoraFim DATETIME NULL,
    Periodicidade NVARCHAR(100) NULL,
    ZonaAfetada NVARCHAR(255) NULL,
    DuracaoMedia TIME NULL,
    PreCondicoes NVARCHAR(MAX) NULL
);
GO

-- =============================================
-- SEÇÃO 3B: NOVAS ENTIDADES (LABORATÓRIO, PROTOCOLO, NOTIFICAÇÃO)
-- =============================================

CREATE TABLE Laboratorio (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(20) NOT NULL UNIQUE,
    Nome NVARCHAR(255) NOT NULL,
    Descricao NVARCHAR(MAX) NULL,
    Sitio NVARCHAR(100) NOT NULL,
    Responsavel NVARCHAR(255) NULL,
    Especialidade VARCHAR(50) NULL,
    NivelAcessoMinimo INT NOT NULL DEFAULT 1,
    Status VARCHAR(20) DEFAULT 'ATIVO',
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ProtocoloContencao (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(20) NOT NULL UNIQUE,
    Titulo NVARCHAR(255) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    NivelUrgencia INT NOT NULL CHECK (NivelUrgencia BETWEEN 1 AND 5),
    ClassesAplicaveis VARCHAR(100) NULL,
    Passos NVARCHAR(MAX) NOT NULL,
    RecursosNecessarios NVARCHAR(MAX) NULL,
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE()
);
GO

-- N:N Protocolo ↔ Anomalia (quais protocolos se aplicam a quais anomalias)
CREATE TABLE Protocolo_AplicadoEm (
    ProtocoloId INT NOT NULL FOREIGN KEY REFERENCES ProtocoloContencao(Id) ON DELETE CASCADE,
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id) ON DELETE CASCADE,
    DataInicio DATETIME NULL,
    DataFim DATETIME NULL,
    Status VARCHAR(20) DEFAULT 'ATIVO',
    Observacoes NVARCHAR(MAX) NULL,
    PRIMARY KEY (ProtocoloId, AnomaliaId)
);
GO

CREATE TABLE NotificacaoAnomalia (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Titulo NVARCHAR(255) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    LocalIdentificado NVARCHAR(255) NOT NULL,
    DataHora DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'PENDENTE',
    NivelPrioridade INT NOT NULL DEFAULT 3 CHECK (NivelPrioridade BETWEEN 1 AND 5),
    Relator NVARCHAR(255) NULL,
    AnomaliaId INT NULL FOREIGN KEY REFERENCES Anomalia(Id),
    DataResolucao DATETIME NULL
);
GO

CREATE INDEX IX_Protocolo_AplicadoEm_Anomalia ON Protocolo_AplicadoEm(AnomaliaId);
CREATE INDEX IX_NotificacaoAnomalia_Status ON NotificacaoAnomalia(Status);
CREATE INDEX IX_NotificacaoAnomalia_Data ON NotificacaoAnomalia(DataHora);
GO

-- =============================================
-- SEÇÃO 4: SISTEMA DE PERÍCIAS E DESVIOS
-- =============================================

CREATE TABLE PericiaAnomalia (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id) ON DELETE CASCADE,
    Nome NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(MAX) NULL,
    MecanismoPrimarioId INT NOT NULL FOREIGN KEY REFERENCES Cat_MecanismoInteracao(Id),
    MecanismoSecundarioId INT NULL FOREIGN KEY REFERENCES Cat_MecanismoInteracao(Id),
    Nivel INT DEFAULT 1,
    Custo NVARCHAR(100) NULL,
    
    CONSTRAINT UQ_Pericia_Anomalia_Nome UNIQUE (AnomaliaId, Nome)
);
GO

CREATE TABLE Instancia_PericiaDesviante (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TipoInstancia VARCHAR(20) NOT NULL CHECK (TipoInstancia IN ('ENTIDADE', 'ARTEFATO', 'LOCALIDADE', 'EVENTO')),
    InstanciaId INT NOT NULL,
    PericiaDesvianteId INT NOT NULL FOREIGN KEY REFERENCES PericiaAnomalia(Id) ON DELETE CASCADE,
    DataDescoberta DATE DEFAULT GETDATE(),
    Intensidade VARCHAR(20) NULL,
    Observacoes NVARCHAR(MAX) NULL
);
GO

-- =============================================
-- SEÇÃO 5: TABELAS DE RELACIONAMENTO N:N
-- =============================================

CREATE TABLE Pericia_Manifestacao (
    PericiaAnomaliaId INT NOT NULL FOREIGN KEY REFERENCES PericiaAnomalia(Id) ON DELETE CASCADE,
    ManifestacaoEspecificaId INT NOT NULL FOREIGN KEY REFERENCES Cat_ManifestacaoEspecifica(Id),
    Intensidade VARCHAR(20) NULL,
    Observacoes NVARCHAR(MAX) NULL,
    
    PRIMARY KEY (PericiaAnomaliaId, ManifestacaoEspecificaId)
);
GO

CREATE TABLE Incidente (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AnomaliaId INT NOT NULL FOREIGN KEY REFERENCES Anomalia(Id),
    DataHora DATETIME DEFAULT GETDATE(),
    Tipo VARCHAR(50) NOT NULL,
    Titulo NVARCHAR(255) NOT NULL,
    Relatorio NVARCHAR(MAX) NOT NULL,
    NivelSeguranca VARCHAR(20) NOT NULL,
    IsEventoSigma BIT DEFAULT 0,
    Mortes INT DEFAULT 0,
    Feridos INT DEFAULT 0,
    DanoMaterial NVARCHAR(255) NULL
);
GO

-- =============================================
-- SEÇÃO 7: ÍNDICES PARA PERFORMANCE
-- =============================================

CREATE INDEX IX_EntidadeViva_AnomaliaId ON EntidadeViva(AnomaliaId);
CREATE INDEX IX_Artefato_AnomaliaId ON Artefato(AnomaliaId);
CREATE INDEX IX_Localidade_AnomaliaId ON Localidade(AnomaliaId);
CREATE INDEX IX_Evento_AnomaliaId ON Evento(AnomaliaId);

CREATE INDEX IX_Instancia_PericiaDesviante_Instancia ON Instancia_PericiaDesviante(TipoInstancia, InstanciaId);
CREATE INDEX IX_Instancia_PericiaDesviante_Pericia ON Instancia_PericiaDesviante(PericiaDesvianteId);

CREATE INDEX IX_Anomalia_CodigoSCP ON Anomalia(CodigoSCP);
CREATE INDEX IX_Anomalia_Status ON Anomalia(Status);
CREATE INDEX IX_Incidente_Anomalia ON Incidente(AnomaliaId);
GO

