-- Procedure that inserts a living entity
CREATE OR ALTER PROCEDURE usp_LivingEntity_Insert
    @AnomalyId INT,
    @Identification NVARCHAR(100),
    @Species NVARCHAR(150),
    @Biology NVARCHAR(255) = NULL,
    @PowerOrigin NVARCHAR(100) = NULL,
    @BirthDate DATE = NULL,
    @IsConscious BIT = 1,
    @IntelligenceLevel INT = NULL,
    @Diet NVARCHAR(100) = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomaly WHERE Id = @AnomalyId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO LivingEntity (
            AnomalyId, Identification, Species, Biology, PowerOrigin,
            BirthDate, IsConscious, IntelligenceLevel, Diet, Notes
        ) VALUES (
            @AnomalyId, @Identification, @Species, @Biology, @PowerOrigin,
            @BirthDate, @IsConscious, @IntelligenceLevel, @Diet, @Notes
        );
        
        SELECT SCOPE_IDENTITY() as NewLivingEntityId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
