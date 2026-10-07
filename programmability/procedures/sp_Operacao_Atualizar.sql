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
