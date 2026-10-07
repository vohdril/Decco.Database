-- Procedure para registrar notificação de anomalia
CREATE OR ALTER PROCEDURE sp_NotificacaoAnomalia_Inserir
    @Titulo NVARCHAR(255),
    @Descricao NVARCHAR(MAX),
    @LocalIdentificado NVARCHAR(255),
    @NivelPrioridade INT = 3,
    @Relator NVARCHAR(255) = NULL,
    @AnomaliaId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO NotificacaoAnomalia (Titulo, Descricao, LocalIdentificado, NivelPrioridade, Relator, AnomaliaId)
    VALUES (@Titulo, @Descricao, @LocalIdentificado, @NivelPrioridade, @Relator, @AnomaliaId);
    SELECT SCOPE_IDENTITY() as NotificacaoId;
END;
GO
