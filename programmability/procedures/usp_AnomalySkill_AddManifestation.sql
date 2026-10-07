-- Procedure that adds a manifestation to a skill
CREATE OR ALTER PROCEDURE usp_AnomalySkill_AddManifestation
    @AnomalySkillId INT,
    @SpecificManifestationId INT,
    @Intensity VARCHAR(20) = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM AnomalySkill WHERE Id = @AnomalySkillId)
            RAISERROR('Skill not found', 16, 1);
            
        IF NOT EXISTS (SELECT 1 FROM Cat_SpecificManifestation WHERE Id = @SpecificManifestationId)
            RAISERROR('Specific manifestation not found', 16, 1);
        
        INSERT INTO AnomalySkill_Manifestation (AnomalySkillId, SpecificManifestationId, Intensity, Notes)
        VALUES (@AnomalySkillId, @SpecificManifestationId, @Intensity, @Notes);
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
