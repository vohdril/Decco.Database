-- Procedure that updates an anomaly
CREATE OR ALTER PROCEDURE usp_Anomaly_Update
    @Id INT,
    @CommonName NVARCHAR(255) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @ObjectClassId INT = NULL,
    @OntologicalLayerId INT = NULL,
    @MatterTypeId INT = NULL,
    @PrimaryMechanismId INT = NULL,
    @SecondaryMechanismId INT = NULL,
    @IeiaDBaseline DECIMAL(8,4) = NULL,
    @SpinCoherenceFactor VARCHAR(20) = NULL,
    @Status VARCHAR(20) = NULL,
    @ContainmentFacilityId INT = NULL,
    @ApparentCognitionId INT = NULL,
    @DangerLevelId INT = NULL,
    @ResearchLead NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        UPDATE Anomaly SET
            CommonName = ISNULL(@CommonName, CommonName),
            Description = ISNULL(@Description, Description),
            ObjectClassId = ISNULL(@ObjectClassId, ObjectClassId),
            OntologicalLayerId = ISNULL(@OntologicalLayerId, OntologicalLayerId),
            MatterTypeId = ISNULL(@MatterTypeId, MatterTypeId),
            PrimaryMechanismId = ISNULL(@PrimaryMechanismId, PrimaryMechanismId),
            SecondaryMechanismId = @SecondaryMechanismId,
            IeiaDBaseline = ISNULL(@IeiaDBaseline, IeiaDBaseline),
            SpinCoherenceFactor = ISNULL(@SpinCoherenceFactor, SpinCoherenceFactor),
            Status = ISNULL(@Status, Status),
            ContainmentFacilityId = ISNULL(@ContainmentFacilityId, ContainmentFacilityId),
            ApparentCognitionId = ISNULL(@ApparentCognitionId, ApparentCognitionId),
            DangerLevelId = ISNULL(@DangerLevelId, DangerLevelId),
            ResearchLead = ISNULL(@ResearchLead, ResearchLead)
        WHERE Id = @Id;
        
        IF @@ROWCOUNT = 0
            RAISERROR('Anomaly not found', 16, 1);
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
