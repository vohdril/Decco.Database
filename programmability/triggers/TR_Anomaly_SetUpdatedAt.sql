-- Trigger that keeps UpdatedAt up to date automatically
CREATE OR ALTER TRIGGER TR_Anomaly_SetUpdatedAt
ON Anomaly
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Anomaly
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM Anomaly a
    INNER JOIN inserted i ON a.Id = i.Id;
END;
GO
