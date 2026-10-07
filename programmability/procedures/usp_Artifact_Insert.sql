-- Procedure that inserts an artifact
CREATE OR ALTER PROCEDURE usp_Artifact_Insert
    @AnomalyId INT,
    @Identification NVARCHAR(100),
    @Material NVARCHAR(255) = NULL,
    @ManufactureDate DATE = NULL,
    @OriginPlace NVARCHAR(255) = NULL,
    @SpinProperty VARCHAR(100) = NULL,
    @WeightKg DECIMAL(10,2) = NULL,
    @Dimensions VARCHAR(100) = NULL,
    @UsageInstructions NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomaly WHERE Id = @AnomalyId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO Artifact (
            AnomalyId, Identification, Material, ManufactureDate, OriginPlace,
            SpinProperty, WeightKg, Dimensions, UsageInstructions
        ) VALUES (
            @AnomalyId, @Identification, @Material, @ManufactureDate, @OriginPlace,
            @SpinProperty, @WeightKg, @Dimensions, @UsageInstructions
        );
        
        SELECT SCOPE_IDENTITY() as NewArtifactId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
