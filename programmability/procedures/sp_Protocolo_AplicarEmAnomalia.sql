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
