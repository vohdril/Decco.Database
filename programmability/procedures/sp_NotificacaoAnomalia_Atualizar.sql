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
