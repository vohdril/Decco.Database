-- Procedure para registrar notificação de anomalia
-- @InstalacaoId é OPCIONAL: um relato de campo pode vir de fora de qualquer
-- instalação conhecida. @LocalIdentificado (texto) continua obrigatório.
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
