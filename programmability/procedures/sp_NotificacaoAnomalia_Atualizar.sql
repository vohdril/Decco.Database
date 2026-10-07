-- Procedure para atualizar notificação de anomalia
-- Não existia no baseline: o NotificacaoAnomaliaRepository da Decco.API já a
-- chamava (UpdateAsync) e falhava com "Could not find stored procedure".
-- Segue o padrão de sp_Anomalia_Atualizar: parâmetro NULL = "não alterar".
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
            THROW 50404, 'Notificação não encontrada', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
