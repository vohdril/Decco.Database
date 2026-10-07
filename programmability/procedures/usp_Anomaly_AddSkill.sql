-- Procedure that adds a skill (pericia) to an anomaly
CREATE OR ALTER PROCEDURE usp_Anomaly_AddSkill
    @AnomalyId INT,
    @Name NVARCHAR(100),
    @Description NVARCHAR(MAX) = NULL,
    @PrimaryMechanismId INT,
    @SecondaryMechanismId INT = NULL,
    @Level INT = 1,
    @Cost NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomaly WHERE Id = @AnomalyId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO AnomalySkill (
            AnomalyId, Name, Description, 
            PrimaryMechanismId, SecondaryMechanismId,
            Level, Cost
        ) VALUES (
            @AnomalyId, @Name, @Description,
            @PrimaryMechanismId, @SecondaryMechanismId,
            @Level, @Cost
        );
        
        DECLARE @NewPericiaId INT = SCOPE_IDENTITY();
        
        -- Return in the same shape as the other procedures
        SELECT @NewPericiaId as NewId, @Name as SkillName;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
