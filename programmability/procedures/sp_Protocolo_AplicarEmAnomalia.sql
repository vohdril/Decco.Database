-- Procedure para vincular protocolo a anomalia
CREATE OR ALTER PROCEDURE sp_Protocolo_AplicarEmAnomalia
    @ProtocoloId INT,
    @AnomaliaId INT,
    @Observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ProtocoloContencao WHERE Id = @ProtocoloId)
        RAISERROR('Protocolo não encontrado', 16, 1);
    IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
        RAISERROR('Anomalia não encontrada', 16, 1);
    INSERT INTO Protocolo_AplicadoEm (ProtocoloId, AnomaliaId, DataInicio, Status, Observacoes)
    VALUES (@ProtocoloId, @AnomaliaId, GETDATE(), 'ATIVO', @Observacoes);
END;
GO
