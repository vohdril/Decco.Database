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
