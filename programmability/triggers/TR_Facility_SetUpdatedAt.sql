-- Trigger that keeps UpdatedAt/UpdatedBy up to date automatically
-- Same pattern as TR_Anomaly_SetUpdatedAt. Facility is born with user auditing
-- (DECCO-BACKLOG, finding 5: until now only Anomaly had it).
CREATE OR ALTER TRIGGER TR_Facility_SetUpdatedAt
ON Facility
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Facility
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM Facility t
    INNER JOIN inserted i ON t.Id = i.Id;
END;
GO
