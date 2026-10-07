-- =============================================================================
-- 0006 — COMPATIBILITY: the Portuguese procedures and views, frozen
--
-- The 18 procedures and 3 views below are the definitions that ran until 0005,
-- copied as they were. They read and write the 0005 compatibility views, so code
-- that calls sp_Operacao_Buscar or reads vw_Dashboard_Anomalias (Decco.API today)
-- keeps getting the same parameters and the same result-set column names.
--
-- Why a migration and not run-always: the run-always scripts now carry the English
-- objects (usp_*, vw_*, TR_*). Without this file a database created from scratch
-- would have no sp_* procedures — and the API would work on the old database but
-- fail on a new one. Here, both paths end with the same objects.
--
-- Multiple batches on purpose: CREATE PROCEDURE/VIEW must be alone in its batch.
-- Every batch is CREATE OR ALTER, so running the file again is harmless.
-- TEMPORARY: dropped by the contract migration, together with the 0005 views.
--
-- Depends on: 0005_expand_english_names.sql
-- =============================================================================

-- Procedure that inserts a new anomaly
CREATE OR ALTER PROCEDURE sp_Anomalia_Inserir
    @CodigoSCP VARCHAR(50),
    @NomeComum NVARCHAR(255),
    @Descricao NVARCHAR(MAX),
    @ClasseObjetoId INT,
    @CamadaOntologicaId INT,
    @TipoMateriaId INT,
    @CognicaoAparenteId INT = NULL,
    @PericulosidadeId INT = NULL,
    @MecanismoPrimarioId INT,
    @MecanismoSecundarioId INT = NULL,
    @IEIA_D_Base DECIMAL(8,4) = NULL,
    @FatorCoerenciaSpin VARCHAR(20) = NULL,
    @InstalacaoContencaoId INT = NULL,
    @ResponsavelPesquisa NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        INSERT INTO Anomalia (
            CodigoSCP, NomeComum, Descricao,
            ClasseObjetoId, CamadaOntologicaId, TipoMateriaId,
            CognicaoAparenteId, PericulosidadeId,
            MecanismoPrimarioId, MecanismoSecundarioId,
            IEIA_D_Base, FatorCoerenciaSpin,
            InstalacaoContencaoId, ResponsavelPesquisa
        ) VALUES (
            @CodigoSCP, @NomeComum, @Descricao,
            @ClasseObjetoId, @CamadaOntologicaId, @TipoMateriaId,
            @CognicaoAparenteId, @PericulosidadeId,
            @MecanismoPrimarioId, @MecanismoSecundarioId,
            @IEIA_D_Base, @FatorCoerenciaSpin,
            @InstalacaoContencaoId, @ResponsavelPesquisa
        );
        
        DECLARE @NewAnomaliaId INT = SCOPE_IDENTITY();
        
        SELECT @NewAnomaliaId as NovoId, @CodigoSCP as CodigoFormatado;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that updates an anomaly
CREATE OR ALTER PROCEDURE sp_Anomalia_Atualizar
    @Id INT,
    @NomeComum NVARCHAR(255) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @ClasseObjetoId INT = NULL,
    @CamadaOntologicaId INT = NULL,
    @TipoMateriaId INT = NULL,
    @MecanismoPrimarioId INT = NULL,
    @MecanismoSecundarioId INT = NULL,
    @IEIA_D_Base DECIMAL(8,4) = NULL,
    @FatorCoerenciaSpin VARCHAR(20) = NULL,
    @Status VARCHAR(20) = NULL,
    @InstalacaoContencaoId INT = NULL,
    @CognicaoAparenteId INT = NULL,
    @PericulosidadeId INT = NULL,
    @ResponsavelPesquisa NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        UPDATE Anomalia SET
            NomeComum = ISNULL(@NomeComum, NomeComum),
            Descricao = ISNULL(@Descricao, Descricao),
            ClasseObjetoId = ISNULL(@ClasseObjetoId, ClasseObjetoId),
            CamadaOntologicaId = ISNULL(@CamadaOntologicaId, CamadaOntologicaId),
            TipoMateriaId = ISNULL(@TipoMateriaId, TipoMateriaId),
            MecanismoPrimarioId = ISNULL(@MecanismoPrimarioId, MecanismoPrimarioId),
            MecanismoSecundarioId = @MecanismoSecundarioId,
            IEIA_D_Base = ISNULL(@IEIA_D_Base, IEIA_D_Base),
            FatorCoerenciaSpin = ISNULL(@FatorCoerenciaSpin, FatorCoerenciaSpin),
            Status = ISNULL(@Status, Status),
            InstalacaoContencaoId = ISNULL(@InstalacaoContencaoId, InstalacaoContencaoId),
            CognicaoAparenteId = ISNULL(@CognicaoAparenteId, CognicaoAparenteId),
            PericulosidadeId = ISNULL(@PericulosidadeId, PericulosidadeId),
            ResponsavelPesquisa = ISNULL(@ResponsavelPesquisa, ResponsavelPesquisa)
        WHERE Id = @Id;
        
        IF @@ROWCOUNT = 0
            RAISERROR('Anomaly not found', 16, 1);
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that searches anomalies with complex filters
CREATE OR ALTER PROCEDURE sp_Anomalia_Buscar
    @CodigoSCP VARCHAR(50) = NULL,
    @ClasseObjetoId INT = NULL,
    @CamadaOntologicaId INT = NULL,
    @TipoMateriaId INT = NULL,
    @MecanismoPrimarioId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @ApenasSigma BIT = 0,
    @Pagina INT = 1,
    @ItensPorPagina INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Pagina - 1) * @ItensPorPagina;
    
    SELECT 
        a.Id,
        a.CodigoSCP,
        a.NomeComum,
        a.Descricao,
        co.Nome as ClasseObjeto,
        ca.Nome as CamadaOntologica,
        tm.Nome as TipoMateria,
        mp.Nome as MecanismoPrimario,
        ms.Nome as MecanismoSecundario,
        a.IEIA_D_Base,
        a.FatorCoerenciaSpin,
        a.Status,
        ic.Codigo AS InstalacaoContencaoCodigo,
        ic.Nome AS InstalacaoContencao,
        a.DataCriacao,
        a.DataAtualizacao,
        
        -- Manifestations as an aggregated string (through skills)
        STUFF((
            SELECT DISTINCT ', ' + cm.Nome
            FROM PericiaAnomalia pa
            INNER JOIN Pericia_Manifestacao pm ON pa.Id = pm.PericiaAnomaliaId
            INNER JOIN Cat_ManifestacaoEspecifica cm ON pm.ManifestacaoEspecificaId = cm.Id
            WHERE pa.AnomaliaId = a.Id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as Manifestacoes,
        
        -- Incident counter
        (SELECT COUNT(*) FROM Incidente i WHERE i.AnomaliaId = a.Id) as TotalIncidentes,
        
        -- Sigma incident counter
        (SELECT COUNT(*) FROM Incidente i WHERE i.AnomaliaId = a.Id AND i.IsEventoSigma = 1) as IncidentesSigma,
        
        -- Instance counters
        (SELECT COUNT(*) FROM EntidadeViva ev WHERE ev.AnomaliaId = a.Id) as QtdEntidades,
        (SELECT COUNT(*) FROM Artefato ar WHERE ar.AnomaliaId = a.Id) as QtdArtefatos
        
    FROM Anomalia a
    INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
    INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
    INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
    INNER JOIN Cat_MecanismoInteracao mp ON a.MecanismoPrimarioId = mp.Id
    LEFT JOIN Cat_MecanismoInteracao ms ON a.MecanismoSecundarioId = ms.Id
    LEFT JOIN Instalacao ic ON ic.Id = a.InstalacaoContencaoId
    WHERE (@CodigoSCP IS NULL OR a.CodigoSCP LIKE '%' + @CodigoSCP + '%')
      AND (@ClasseObjetoId IS NULL OR a.ClasseObjetoId = @ClasseObjetoId)
      AND (@CamadaOntologicaId IS NULL OR a.CamadaOntologicaId = @CamadaOntologicaId)
      AND (@TipoMateriaId IS NULL OR a.TipoMateriaId = @TipoMateriaId)
      AND (@MecanismoPrimarioId IS NULL OR a.MecanismoPrimarioId = @MecanismoPrimarioId)
      AND (@Status IS NULL OR a.Status = @Status)
      AND (@ApenasSigma = 0 OR ca.Simbolo = 'OMEGA' OR tm.IsResistenteSupressores = 1)
    ORDER BY a.CodigoSCP
    OFFSET @Offset ROWS
    FETCH NEXT @ItensPorPagina ROWS ONLY;
    
    -- Also return the total record count for paging
    SELECT COUNT(*) as TotalRegistros
    FROM Anomalia a
    INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
    INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
    WHERE (@CodigoSCP IS NULL OR a.CodigoSCP LIKE '%' + @CodigoSCP + '%')
      AND (@ClasseObjetoId IS NULL OR a.ClasseObjetoId = @ClasseObjetoId)
      AND (@CamadaOntologicaId IS NULL OR a.CamadaOntologicaId = @CamadaOntologicaId)
      AND (@TipoMateriaId IS NULL OR a.TipoMateriaId = @TipoMateriaId)
      AND (@MecanismoPrimarioId IS NULL OR a.MecanismoPrimarioId = @MecanismoPrimarioId)
      AND (@Status IS NULL OR a.Status = @Status)
      AND (@ApenasSigma = 0 OR ca.Simbolo = 'OMEGA' OR tm.IsResistenteSupressores = 1);
END;
GO

-- Procedure that returns the full profile of an anomaly
CREATE OR ALTER PROCEDURE sp_Anomalia_ObterPerfilCompleto
    @AnomaliaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Basic anomaly information
    SELECT 
        a.Id,
        a.CodigoSCP,
        a.NomeComum,
        a.Descricao,
        co.Nome as ClasseObjeto,
        co.CorAlerta,
        ca.Nome as CamadaOntologica,
        ff.Nome as ForcaFundamental,
        tm.Nome as TipoMateria,
        mp.Nome as MecanismoPrimario,
        ms.Nome as MecanismoSecundario,
        a.IEIA_D_Base,
        a.FatorCoerenciaSpin,
        a.Status,
        ic.Codigo AS InstalacaoContencaoCodigo,
        ic.Nome AS InstalacaoContencao,
        a.ResponsavelPesquisa,
        a.DataCriacao,
        a.DataAtualizacao
    FROM Anomalia a
    INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
    INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
    INNER JOIN Cat_ForcaFundamental ff ON ca.ForcaFundamentalId = ff.Id
    INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
    INNER JOIN Cat_MecanismoInteracao mp ON a.MecanismoPrimarioId = mp.Id
    LEFT JOIN Cat_MecanismoInteracao ms ON a.MecanismoSecundarioId = ms.Id
    LEFT JOIN Instalacao ic ON ic.Id = a.InstalacaoContencaoId
    WHERE a.Id = @AnomaliaId;
    
    -- Associated living entities
    SELECT * FROM EntidadeViva WHERE AnomaliaId = @AnomaliaId;
    
    -- Associated artifacts
    SELECT * FROM Artefato WHERE AnomaliaId = @AnomaliaId;
    
    -- Associated locations
    SELECT * FROM Localidade WHERE AnomaliaId = @AnomaliaId;
    
    -- Associated events
    SELECT * FROM Evento WHERE AnomaliaId = @AnomaliaId;
    
    -- Anomaly skills
    SELECT 
        pa.*,
        mp.Nome as MecanismoPrimarioNome,
        ms.Nome as MecanismoSecundarioNome
    FROM PericiaAnomalia pa
    INNER JOIN Cat_MecanismoInteracao mp ON pa.MecanismoPrimarioId = mp.Id
    LEFT JOIN Cat_MecanismoInteracao ms ON pa.MecanismoSecundarioId = ms.Id
    WHERE pa.AnomaliaId = @AnomaliaId;
    
    -- Manifestations (through skills)
    SELECT DISTINCT
        cm.Codigo,
        cm.Nome,
        cm.Descricao
    FROM PericiaAnomalia pa
    INNER JOIN Pericia_Manifestacao pm ON pa.Id = pm.PericiaAnomaliaId
    INNER JOIN Cat_ManifestacaoEspecifica cm ON pm.ManifestacaoEspecificaId = cm.Id
    WHERE pa.AnomaliaId = @AnomaliaId;
    
    -- Recorded incidents
    SELECT * FROM Incidente 
    WHERE AnomaliaId = @AnomaliaId 
    ORDER BY DataHora DESC;
END;
GO

-- Procedure that adds a skill (pericia) to an anomaly
CREATE OR ALTER PROCEDURE sp_Anomalia_AdicionarPericia
    @AnomaliaId INT,
    @Nome NVARCHAR(100),
    @Descricao NVARCHAR(MAX) = NULL,
    @MecanismoPrimarioId INT,
    @MecanismoSecundarioId INT = NULL,
    @Nivel INT = 1,
    @Custo NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO PericiaAnomalia (
            AnomaliaId, Nome, Descricao, 
            MecanismoPrimarioId, MecanismoSecundarioId,
            Nivel, Custo
        ) VALUES (
            @AnomaliaId, @Nome, @Descricao,
            @MecanismoPrimarioId, @MecanismoSecundarioId,
            @Nivel, @Custo
        );
        
        DECLARE @NewPericiaId INT = SCOPE_IDENTITY();
        
        -- Return in the same shape as the other procedures
        SELECT @NewPericiaId as NovoId, @Nome as NomePericia;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that inserts an artifact
CREATE OR ALTER PROCEDURE sp_Artefato_Inserir
    @AnomaliaId INT,
    @Identificacao NVARCHAR(100),
    @Material NVARCHAR(255) = NULL,
    @DataFabricacao DATE = NULL,
    @LocalOrigem NVARCHAR(255) = NULL,
    @PropriedadeSpin VARCHAR(100) = NULL,
    @Peso_Kg DECIMAL(10,2) = NULL,
    @Dimensoes VARCHAR(100) = NULL,
    @ModoUsar NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO Artefato (
            AnomaliaId, Identificacao, Material, DataFabricacao, LocalOrigem,
            PropriedadeSpin, Peso_Kg, Dimensoes, ModoUsar
        ) VALUES (
            @AnomaliaId, @Identificacao, @Material, @DataFabricacao, @LocalOrigem,
            @PropriedadeSpin, @Peso_Kg, @Dimensoes, @ModoUsar
        );
        
        SELECT SCOPE_IDENTITY() as NovoArtefatoId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that inserts a living entity
CREATE OR ALTER PROCEDURE sp_EntidadeViva_Inserir
    @AnomaliaId INT,
    @Identificacao NVARCHAR(100),
    @Especie NVARCHAR(150),
    @Biologia NVARCHAR(255) = NULL,
    @OrigemPoder NVARCHAR(100) = NULL,
    @DataNascimento DATE = NULL,
    @IsConsciente BIT = 1,
    @NivelInteligencia INT = NULL,
    @Dieta NVARCHAR(100) = NULL,
    @Observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO EntidadeViva (
            AnomaliaId, Identificacao, Especie, Biologia, OrigemPoder,
            DataNascimento, IsConsciente, NivelInteligencia, Dieta, Observacoes
        ) VALUES (
            @AnomaliaId, @Identificacao, @Especie, @Biologia, @OrigemPoder,
            @DataNascimento, @IsConsciente, @NivelInteligencia, @Dieta, @Observacoes
        );
        
        SELECT SCOPE_IDENTITY() as NovaEntidadeId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that records an incident
CREATE OR ALTER PROCEDURE sp_Incidente_Registrar
    @AnomaliaId INT,
    @Tipo VARCHAR(50),
    @Titulo NVARCHAR(255),
    @Relatorio NVARCHAR(MAX),
    @NivelSeguranca VARCHAR(20),
    @IsEventoSigma BIT = 0,
    @Mortes INT = 0,
    @Feridos INT = 0,
    @DanoMaterial NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomaly not found', 16, 1);
        
        INSERT INTO Incidente (AnomaliaId, Tipo, Titulo, Relatorio, NivelSeguranca, IsEventoSigma, Mortes, Feridos, DanoMaterial)
        VALUES (@AnomaliaId, @Tipo, @Titulo, @Relatorio, @NivelSeguranca, @IsEventoSigma, @Mortes, @Feridos, @DanoMaterial);
        
        DECLARE @NewIncidenteId INT = SCOPE_IDENTITY();
        
        SELECT @NewIncidenteId as IncidenteId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that creates a facility (replaces sp_Laboratorio_Inserir)
-- A laboratory is now: @TipoInstalacaoId = LABORATORIO + @InstalacaoPaiId = the site.
-- The hierarchy rules (who can be whose parent) live in
-- TR_Instalacao_Validar_Hierarquia, so they also apply outside this procedure.
CREATE OR ALTER PROCEDURE sp_Instalacao_Inserir
    @Codigo VARCHAR(20),
    @Nome NVARCHAR(255),
    @TipoInstalacaoId INT,
    @InstalacaoPaiId INT = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @Responsavel NVARCHAR(255) = NULL,
    @Especialidade VARCHAR(50) = NULL,
    @NivelAcessoMinimo INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        INSERT INTO Instalacao (Codigo, Nome, Descricao, TipoInstalacaoId, InstalacaoPaiId,
                                Responsavel, Especialidade, NivelAcessoMinimo)
        VALUES (@Codigo, @Nome, @Descricao, @TipoInstalacaoId, @InstalacaoPaiId,
                @Responsavel, @Especialidade, @NivelAcessoMinimo);

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS NovoId;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that updates a facility
-- Codigo CANNOT be updated: it is the public identity (IdToCode) and the key of the
-- scoped cache (decco:inst:{codigo}:*). Changing the code would invalidate keys and
-- external references without warning.
CREATE OR ALTER PROCEDURE sp_Instalacao_Atualizar
    @Id INT,
    @Nome NVARCHAR(255) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @TipoInstalacaoId INT = NULL,
    @InstalacaoPaiId INT = NULL,
    @Responsavel NVARCHAR(255) = NULL,
    @Especialidade VARCHAR(50) = NULL,
    @NivelAcessoMinimo INT = NULL,
    @Status VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Instalacao SET
            Nome = ISNULL(@Nome, Nome),
            Descricao = ISNULL(@Descricao, Descricao),
            TipoInstalacaoId = ISNULL(@TipoInstalacaoId, TipoInstalacaoId),
            InstalacaoPaiId = ISNULL(@InstalacaoPaiId, InstalacaoPaiId),
            Responsavel = ISNULL(@Responsavel, Responsavel),
            Especialidade = ISNULL(@Especialidade, Especialidade),
            NivelAcessoMinimo = ISNULL(@NivelAcessoMinimo, NivelAcessoMinimo),
            Status = ISNULL(@Status, Status)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Facility not found', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that records an anomaly notification
-- @InstalacaoId is OPTIONAL: a field report may come from outside any known
-- facility. @LocalIdentificado (text) remains mandatory.
CREATE OR ALTER PROCEDURE sp_NotificacaoAnomalia_Inserir
    @Titulo NVARCHAR(255),
    @Descricao NVARCHAR(MAX),
    @LocalIdentificado NVARCHAR(255),
    @NivelPrioridade INT = 3,
    @Relator NVARCHAR(255) = NULL,
    @AnomaliaId INT = NULL,
    @InstalacaoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO NotificacaoAnomalia (Titulo, Descricao, LocalIdentificado, NivelPrioridade, Relator, AnomaliaId, InstalacaoId)
    VALUES (@Titulo, @Descricao, @LocalIdentificado, @NivelPrioridade, @Relator, @AnomaliaId, @InstalacaoId);
    SELECT CAST(SCOPE_IDENTITY() AS INT) as NotificacaoId;
END;
GO

-- Procedure that updates an anomaly notification
-- It did not exist in the baseline: the Decco.API NotificacaoAnomaliaRepository already
-- called it (UpdateAsync) and failed with "Could not find stored procedure".
-- Follows the sp_Anomalia_Atualizar pattern: a NULL parameter = "do not change".
CREATE OR ALTER PROCEDURE sp_NotificacaoAnomalia_Atualizar
    @Id INT,
    @Titulo NVARCHAR(255) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @LocalIdentificado NVARCHAR(255) = NULL,
    @NivelPrioridade INT = NULL,
    @Status VARCHAR(20) = NULL,
    @Relator NVARCHAR(255) = NULL,
    @AnomaliaId INT = NULL,
    @InstalacaoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE NotificacaoAnomalia SET
            Titulo = ISNULL(@Titulo, Titulo),
            Descricao = ISNULL(@Descricao, Descricao),
            LocalIdentificado = ISNULL(@LocalIdentificado, LocalIdentificado),
            NivelPrioridade = ISNULL(@NivelPrioridade, NivelPrioridade),
            Status = ISNULL(@Status, Status),
            Relator = ISNULL(@Relator, Relator),
            AnomaliaId = ISNULL(@AnomaliaId, AnomaliaId),
            InstalacaoId = ISNULL(@InstalacaoId, InstalacaoId)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Notification not found', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that opens an operation
-- @Codigo is optional: when omitted, it is generated as OP-{year}-{sequence},
-- e.g. OP-2026-0001. The sequence is per year and computed under UPDLOCK/HOLDLOCK
-- so that two concurrent openings never generate the same code.
-- The business rules (does the type require an anomaly? does the facility accept it?)
-- live in TR_Operacao_Validar, so they also apply outside this procedure.
CREATE OR ALTER PROCEDURE sp_Operacao_Inserir
    @Codinome NVARCHAR(100),
    @TipoOperacaoId INT,
    @InstalacaoId INT,
    @Objetivo NVARCHAR(500),
    @Codigo VARCHAR(20) = NULL,
    @AnomaliaId INT = NULL,
    @NotificacaoId INT = NULL,
    @ProtocoloId INT = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @Prioridade INT = 3,
    @NivelAcessoMinimo INT = 1,
    @Responsavel NVARCHAR(255) = NULL,
    @DataPrevisaoTermino DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Codigo IS NULL
        BEGIN
            DECLARE @Prefix VARCHAR(8) = 'OP-' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-';
            DECLARE @LastSequence INT = (
                SELECT MAX(CAST(SUBSTRING(Codigo, 9, 4) AS INT))
                  FROM Operacao WITH (UPDLOCK, HOLDLOCK)
                 WHERE Codigo LIKE @Prefix + '[0-9][0-9][0-9][0-9]'
            );
            SET @Codigo = @Prefix + RIGHT('0000' + CAST(ISNULL(@LastSequence, 0) + 1 AS VARCHAR(4)), 4);
        END

        INSERT INTO Operacao (Codigo, Codinome, TipoOperacaoId, InstalacaoId,
                              AnomaliaId, NotificacaoId, ProtocoloId,
                              Objetivo, Descricao, Prioridade, NivelAcessoMinimo,
                              Responsavel, DataPrevisaoTermino)
        VALUES (@Codigo, @Codinome, @TipoOperacaoId, @InstalacaoId,
                @AnomaliaId, @NotificacaoId, @ProtocoloId,
                @Objetivo, @Descricao, @Prioridade, @NivelAcessoMinimo,
                @Responsavel, @DataPrevisaoTermino);

        DECLARE @NewId INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRANSACTION;

        SELECT @NewId AS NovoId, @Codigo AS CodigoFormatado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Procedure that updates an operation
-- Codigo and InstalacaoId CANNOT be updated: the code is the public identity and the
-- facility is the operation SCOPE (the scoped cache key). An operation that moves
-- to another facility is, for permission purposes, a different operation.
--
-- Closing: when moving to CONCLUIDA or ABORTADA without @DataEncerramento, the
-- date is filled with GETDATE(). When going back to an open state, it is cleared.
CREATE OR ALTER PROCEDURE sp_Operacao_Atualizar
    @Id INT,
    @Codinome NVARCHAR(100) = NULL,
    @TipoOperacaoId INT = NULL,
    @AnomaliaId INT = NULL,
    @NotificacaoId INT = NULL,
    @ProtocoloId INT = NULL,
    @Objetivo NVARCHAR(500) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @Status VARCHAR(20) = NULL,
    @Prioridade INT = NULL,
    @NivelAcessoMinimo INT = NULL,
    @Responsavel NVARCHAR(255) = NULL,
    @DataPrevisaoTermino DATETIME = NULL,
    @DataEncerramento DATETIME = NULL,
    @ResultadoResumo NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Operacao SET
            Codinome = ISNULL(@Codinome, Codinome),
            TipoOperacaoId = ISNULL(@TipoOperacaoId, TipoOperacaoId),
            AnomaliaId = ISNULL(@AnomaliaId, AnomaliaId),
            NotificacaoId = ISNULL(@NotificacaoId, NotificacaoId),
            ProtocoloId = ISNULL(@ProtocoloId, ProtocoloId),
            Objetivo = ISNULL(@Objetivo, Objetivo),
            Descricao = ISNULL(@Descricao, Descricao),
            Status = ISNULL(@Status, Status),
            Prioridade = ISNULL(@Prioridade, Prioridade),
            NivelAcessoMinimo = ISNULL(@NivelAcessoMinimo, NivelAcessoMinimo),
            Responsavel = ISNULL(@Responsavel, Responsavel),
            DataPrevisaoTermino = ISNULL(@DataPrevisaoTermino, DataPrevisaoTermino),
            DataEncerramento = CASE
                WHEN ISNULL(@Status, Status) IN ('CONCLUIDA', 'ABORTADA')
                    THEN COALESCE(@DataEncerramento, DataEncerramento, GETDATE())
                ELSE NULL
            END,
            ResultadoResumo = ISNULL(@ResultadoResumo, ResultadoResumo)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Operation not found', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that searches operations with filters
-- It is the SCOPED query of the schema: @InstalacaoId filters by facility and,
-- with @IncluirSubinstalacoes = 1 (default), includes its children — operations of a
-- laboratory show up when querying the site that contains it.
-- @NivelAcessoUsuario slices by clearance (Operacao.NivelAcessoMinimo).
-- Slicing by the facilities ALLOWED to the user is the application's job: the
-- user↔facility relation lives in DeccoAuthDB, which this database cannot see.
CREATE OR ALTER PROCEDURE sp_Operacao_Buscar
    @InstalacaoId INT = NULL,
    @IncluirSubinstalacoes BIT = 1,
    @TipoOperacaoId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @AnomaliaId INT = NULL,
    @NivelAcessoUsuario INT = NULL,
    @Pagina INT = 1,
    @ItensPorPagina INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @ItensPorPagina;

    -- Facilities in the query scope (itself + direct children).
    -- The hierarchy has a maximum depth of 2 (site → children), guaranteed by
    -- TR_Instalacao_Validar_Hierarquia — which is why no recursive CTE is needed.
    DECLARE @Scope TABLE (Id INT PRIMARY KEY);
    IF @InstalacaoId IS NOT NULL
    BEGIN
        INSERT INTO @Scope (Id) VALUES (@InstalacaoId);
        IF @IncluirSubinstalacoes = 1
            INSERT INTO @Scope (Id)
            SELECT Id FROM Instalacao WHERE InstalacaoPaiId = @InstalacaoId;
    END

    SELECT
        o.Id,
        o.Codigo,
        o.Codinome,
        o.TipoOperacaoId,
        co.Codigo AS TipoOperacaoCodigo,
        co.Nome AS TipoOperacao,
        o.InstalacaoId,
        i.Codigo AS InstalacaoCodigo,
        i.Nome AS Instalacao,
        o.AnomaliaId,
        a.CodigoSCP AS AnomaliaCodigo,
        o.NotificacaoId,
        o.ProtocoloId,
        p.Codigo AS ProtocoloCodigo,
        o.Objetivo,
        o.Status,
        o.Prioridade,
        o.NivelAcessoMinimo,
        o.Responsavel,
        o.DataAbertura,
        o.DataPrevisaoTermino,
        o.DataEncerramento
    FROM Operacao o
    INNER JOIN Cat_Operacao co ON co.Id = o.TipoOperacaoId
    INNER JOIN Instalacao i ON i.Id = o.InstalacaoId
    LEFT JOIN Anomalia a ON a.Id = o.AnomaliaId
    LEFT JOIN ProtocoloContencao p ON p.Id = o.ProtocoloId
    WHERE (@InstalacaoId IS NULL OR o.InstalacaoId IN (SELECT Id FROM @Scope))
      AND (@TipoOperacaoId IS NULL OR o.TipoOperacaoId = @TipoOperacaoId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomaliaId IS NULL OR o.AnomaliaId = @AnomaliaId)
      AND (@NivelAcessoUsuario IS NULL OR o.NivelAcessoMinimo <= @NivelAcessoUsuario)
    ORDER BY o.Prioridade DESC, o.DataAbertura DESC, o.Codigo
    OFFSET @Offset ROWS
    FETCH NEXT @ItensPorPagina ROWS ONLY;

    -- Total record count for paging
    SELECT COUNT(*) AS TotalRegistros
    FROM Operacao o
    WHERE (@InstalacaoId IS NULL OR o.InstalacaoId IN (SELECT Id FROM @Scope))
      AND (@TipoOperacaoId IS NULL OR o.TipoOperacaoId = @TipoOperacaoId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomaliaId IS NULL OR o.AnomaliaId = @AnomaliaId)
      AND (@NivelAcessoUsuario IS NULL OR o.NivelAcessoMinimo <= @NivelAcessoUsuario);
END;
GO

-- Procedure that adds a manifestation to a skill
CREATE OR ALTER PROCEDURE sp_Pericia_AdicionarManifestacao
    @PericiaAnomaliaId INT,
    @ManifestacaoEspecificaId INT,
    @Intensidade VARCHAR(20) = NULL,
    @Observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PericiaAnomalia WHERE Id = @PericiaAnomaliaId)
            RAISERROR('Skill not found', 16, 1);
            
        IF NOT EXISTS (SELECT 1 FROM Cat_ManifestacaoEspecifica WHERE Id = @ManifestacaoEspecificaId)
            RAISERROR('Specific manifestation not found', 16, 1);
        
        INSERT INTO Pericia_Manifestacao (PericiaAnomaliaId, ManifestacaoEspecificaId, Intensidade, Observacoes)
        VALUES (@PericiaAnomaliaId, @ManifestacaoEspecificaId, @Intensidade, @Observacoes);
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure that creates a containment protocol
CREATE OR ALTER PROCEDURE sp_ProtocoloContencao_Inserir
    @Codigo VARCHAR(20),
    @Titulo NVARCHAR(255),
    @Descricao NVARCHAR(MAX),
    @NivelUrgencia INT,
    @ClassesAplicaveis VARCHAR(100) = NULL,
    @Passos NVARCHAR(MAX),
    @RecursosNecessarios NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProtocoloContencao (Codigo, Titulo, Descricao, NivelUrgencia, ClassesAplicaveis, Passos, RecursosNecessarios)
    VALUES (@Codigo, @Titulo, @Descricao, @NivelUrgencia, @ClassesAplicaveis, @Passos, @RecursosNecessarios);
    SELECT SCOPE_IDENTITY() as NovoId;
END;
GO

-- Procedure that links a protocol to an anomaly
CREATE OR ALTER PROCEDURE sp_Protocolo_AplicarEmAnomalia
    @ProtocoloId INT,
    @AnomaliaId INT,
    @Observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ProtocoloContencao WHERE Id = @ProtocoloId)
        RAISERROR('Protocol not found', 16, 1);
    IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
        RAISERROR('Anomaly not found', 16, 1);
    INSERT INTO Protocolo_AplicadoEm (ProtocoloId, AnomaliaId, DataInicio, Status, Observacoes)
    VALUES (@ProtocoloId, @AnomaliaId, GETDATE(), 'ATIVO', @Observacoes);
END;
GO

CREATE OR ALTER VIEW vw_Dashboard_Anomalias AS
SELECT 
    a.Id,
    a.CodigoSCP,
    a.NomeComum,
    co.Nome as ClasseObjeto,
    co.CorAlerta,
    ca.Simbolo as Camada,
    ca.Nome as CamadaOntologica,
    tm.Nome as TipoMateria,
    mp.Nome as MecanismoPrimario,
    ms.Nome as MecanismoSecundario,
    a.IEIA_D_Base,
    a.FatorCoerenciaSpin,
    a.Status,
    ic.Codigo AS InstalacaoContencaoCodigo,
    ic.Nome AS InstalacaoContencao,
    
    -- Risk indicators
    CASE 
        WHEN co.Codigo = 'KETER' THEN 3
        WHEN co.Codigo = 'EUCLID' THEN 2
        WHEN co.Codigo = 'SAFE' THEN 1
        ELSE 0
    END as NivelRisco,
    
    CASE 
        WHEN ca.Simbolo = 'OMEGA' OR tm.IsResistenteSupressores = 1 THEN 'SIGMA-ALERTA'
        WHEN ca.Simbolo = 'THETA' AND a.IEIA_D_Base > 0.5 THEN 'THETA-ALTO'
        WHEN ca.Simbolo = 'THETA' AND a.IEIA_D_Base > 0.1 THEN 'THETA-MEDIO'
        ELSE 'THETA-BAIXO'
    END as StatusTheta,
    
    -- Counters
    (SELECT COUNT(*) FROM Incidente i WHERE i.AnomaliaId = a.Id AND i.IsEventoSigma = 1) as ContagemSigma,
    (SELECT COUNT(*) FROM EntidadeViva ev WHERE ev.AnomaliaId = a.Id) as QtdEntidades,
    (SELECT COUNT(*) FROM Artefato ar WHERE ar.AnomaliaId = a.Id) as QtdArtefatos
    
FROM Anomalia a
INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
INNER JOIN Cat_MecanismoInteracao mp ON a.MecanismoPrimarioId = mp.Id
LEFT JOIN Cat_MecanismoInteracao ms ON a.MecanismoSecundarioId = ms.Id
LEFT JOIN Instalacao ic ON ic.Id = a.InstalacaoContencaoId
WHERE a.Status = 'ATIVA';
GO

CREATE OR ALTER VIEW vw_Estatisticas_Anomalias AS
SELECT 
    -- Totals
    COUNT(*) as TotalAnomalias,
    SUM(CASE WHEN Status = 'ATIVA' THEN 1 ELSE 0 END) as Ativas,
    SUM(CASE WHEN Status = 'NEUTRALIZADA' THEN 1 ELSE 0 END) as Neutralizadas,
    
    -- By class
    SUM(CASE WHEN co.Codigo = 'SAFE' THEN 1 ELSE 0 END) as Classe_Safe,
    SUM(CASE WHEN co.Codigo = 'EUCLID' THEN 1 ELSE 0 END) as Classe_Euclid,
    SUM(CASE WHEN co.Codigo = 'KETER' THEN 1 ELSE 0 END) as Classe_Keter,
    SUM(CASE WHEN co.Codigo = 'THAUMIEL' THEN 1 ELSE 0 END) as Classe_Thaumiel,
    SUM(CASE WHEN co.Codigo = 'APOT' THEN 1 ELSE 0 END) as Classe_Apotheosis,
    
    -- By layer
    SUM(CASE WHEN ca.Simbolo = 'THETA' THEN 1 ELSE 0 END) as Camada_Theta,
    SUM(CASE WHEN ca.Simbolo = 'PSI' THEN 1 ELSE 0 END) as Camada_Psi,
    SUM(CASE WHEN ca.Simbolo = 'PHI' THEN 1 ELSE 0 END) as Camada_Phi,
    SUM(CASE WHEN ca.Simbolo = 'OMEGA' THEN 1 ELSE 0 END) as Camada_Omega,
    
    -- By matter type
    SUM(CASE WHEN tm.Nome = 'Bariônica Anômala' THEN 1 ELSE 0 END) as Materia_Barionica,
    SUM(CASE WHEN tm.Nome = 'Não-Bariônica' THEN 1 ELSE 0 END) as Materia_NaoBarionica,
    SUM(CASE WHEN tm.Nome = 'Mista' THEN 1 ELSE 0 END) as Materia_Mista,
    
    -- Theta statistics
    AVG(ISNULL(a.IEIA_D_Base, 0)) as IEIA_D_Medio,
    SUM(CASE WHEN tm.IsResistenteSupressores = 1 THEN 1 ELSE 0 END) as ResistenteSupressao
    
FROM Anomalia a
INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id;
GO

CREATE OR ALTER VIEW vw_Relatorio_Sigma AS
SELECT 
    a.CodigoSCP,
    a.NomeComum,
    co.Nome as Classe,
    ca.Nome as Camada,
    tm.IsResistenteSupressores,
    COUNT(i.Id) as TotalIncidentes,
    SUM(CASE WHEN i.IsEventoSigma = 1 THEN 1 ELSE 0 END) as IncidentesSigma,
    MAX(i.DataHora) as UltimoIncidente,
    ic.Codigo AS InstalacaoContencaoCodigo,
    ic.Nome AS InstalacaoContencao,
    a.ResponsavelPesquisa
FROM Anomalia a
INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
LEFT JOIN Instalacao ic ON ic.Id = a.InstalacaoContencaoId
LEFT JOIN Incidente i ON a.Id = i.AnomaliaId
WHERE ca.Simbolo = 'OMEGA' 
   OR tm.IsResistenteSupressores = 1
   OR co.Codigo = 'APOT'
GROUP BY a.Id, a.CodigoSCP, a.NomeComum, co.Nome, ca.Nome, 
         tm.IsResistenteSupressores, ic.Codigo, ic.Nome, a.ResponsavelPesquisa;
GO
