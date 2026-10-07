-- Trigger that keeps UpdatedAt/UpdatedBy up to date automatically
-- Same pattern as TR_Anomaly_SetUpdatedAt.
CREATE OR ALTER TRIGGER TR_Operation_SetUpdatedAt
ON Operation
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Operation
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM Operation t
    INNER JOIN inserted i ON t.Id = i.Id;
END;
GO
