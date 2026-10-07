-- Procedure that records an incident
CREATE OR ALTER PROCEDURE usp_Incident_Register
    @AnomalyId INT,
    @IncidentType VARCHAR(50),
    @Title NVARCHAR(255),
    @Report NVARCHAR(MAX),
    @SecurityLevel VARCHAR(20),
    @IsSigmaEvent BIT = 0,
    @Fatalities INT = 0,
    @Injuries INT = 0,
    @MaterialDamage NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomaly WHERE Id = @AnomalyId)
            RAISERROR('Anomaly not found', 16, 1);
        
        INSERT INTO Incident (AnomalyId, IncidentType, Title, Report, SecurityLevel, IsSigmaEvent, Fatalities, Injuries, MaterialDamage)
        VALUES (@AnomalyId, @IncidentType, @Title, @Report, @SecurityLevel, @IsSigmaEvent, @Fatalities, @Injuries, @MaterialDamage);
        
        DECLARE @NewIncidenteId INT = SCOPE_IDENTITY();
        
        SELECT @NewIncidenteId as IncidentId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
