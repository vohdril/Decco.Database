-- Procedure para abrir uma operação
-- @Codigo é opcional: se omitido, é gerado no formato OP-{ano}-{sequencial},
-- ex.: OP-2026-0001. O sequencial é por ano e calculado sob UPDLOCK/HOLDLOCK
-- para que duas aberturas simultâneas não gerem o mesmo código.
-- As regras de negócio (o tipo exige anomalia? a instalação aceita operação?)
-- vivem em TR_Operacao_Validar, para valerem também fora desta procedure.
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
            DECLARE @Prefixo VARCHAR(8) = 'OP-' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-';
            DECLARE @Ultimo INT = (
                SELECT MAX(CAST(SUBSTRING(Codigo, 9, 4) AS INT))
                  FROM Operacao WITH (UPDLOCK, HOLDLOCK)
                 WHERE Codigo LIKE @Prefixo + '[0-9][0-9][0-9][0-9]'
            );
            SET @Codigo = @Prefixo + RIGHT('0000' + CAST(ISNULL(@Ultimo, 0) + 1 AS VARCHAR(4)), 4);
        END

        INSERT INTO Operacao (Codigo, Codinome, TipoOperacaoId, InstalacaoId,
                              AnomaliaId, NotificacaoId, ProtocoloId,
                              Objetivo, Descricao, Prioridade, NivelAcessoMinimo,
                              Responsavel, DataPrevisaoTermino)
        VALUES (@Codigo, @Codinome, @TipoOperacaoId, @InstalacaoId,
                @AnomaliaId, @NotificacaoId, @ProtocoloId,
                @Objetivo, @Descricao, @Prioridade, @NivelAcessoMinimo,
                @Responsavel, @DataPrevisaoTermino);

        DECLARE @NovoId INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRANSACTION;

        SELECT @NovoId AS NovoId, @Codigo AS CodigoFormatado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
