-- Procedure that inserts a new anomaly
CREATE OR ALTER PROCEDURE usp_Anomaly_Insert
    @ScpCode VARCHAR(50),
    @CommonName NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @ObjectClassId INT,
    @OntologicalLayerId INT,
    @MatterTypeId INT,
    @ApparentCognitionId INT = NULL,
    @DangerLevelId INT = NULL,
    @PrimaryMechanismId INT,
    @SecondaryMechanismId INT = NULL,
    @IeiaDBaseline DECIMAL(8,4) = NULL,
    @SpinCoherenceFactor VARCHAR(20) = NULL,
    @ContainmentFacilityId INT = NULL,
    @ResearchLead NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        INSERT INTO Anomaly (
            ScpCode, CommonName, Description,
            ObjectClassId, OntologicalLayerId, MatterTypeId,
            ApparentCognitionId, DangerLevelId,
            PrimaryMechanismId, SecondaryMechanismId,
            IeiaDBaseline, SpinCoherenceFactor,
            ContainmentFacilityId, ResearchLead
        ) VALUES (
            @ScpCode, @CommonName, @Description,
            @ObjectClassId, @OntologicalLayerId, @MatterTypeId,
            @ApparentCognitionId, @DangerLevelId,
            @PrimaryMechanismId, @SecondaryMechanismId,
            @IeiaDBaseline, @SpinCoherenceFactor,
            @ContainmentFacilityId, @ResearchLead
        );
        
        DECLARE @NewAnomaliaId INT = SCOPE_IDENTITY();
        
        SELECT @NewAnomaliaId as NewId, @ScpCode as FormattedCode;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
