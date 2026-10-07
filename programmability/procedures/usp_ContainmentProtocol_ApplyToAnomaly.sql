-- Procedure that links a protocol to an anomaly
CREATE OR ALTER PROCEDURE usp_ContainmentProtocol_ApplyToAnomaly
    @ProtocolId INT,
    @AnomalyId INT,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ContainmentProtocol WHERE Id = @ProtocolId)
        RAISERROR('Protocol not found', 16, 1);
    IF NOT EXISTS (SELECT 1 FROM Anomaly WHERE Id = @AnomalyId)
        RAISERROR('Anomaly not found', 16, 1);
    INSERT INTO Protocol_AppliedTo (ProtocolId, AnomalyId, ValidFrom, Status, Notes)
    VALUES (@ProtocolId, @AnomalyId, GETDATE(), 'ATIVO', @Notes);
END;
GO
