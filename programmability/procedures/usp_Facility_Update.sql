-- Procedure that updates a facility
-- Code CANNOT be updated: it is the public identity (IdToCode) and the key of the
-- scoped cache (decco:inst:{codigo}:*). Changing the code would invalidate keys and
-- external references without warning.
CREATE OR ALTER PROCEDURE usp_Facility_Update
    @Id INT,
    @Name NVARCHAR(255) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @FacilityTypeId INT = NULL,
    @ParentFacilityId INT = NULL,
    @ResponsiblePerson NVARCHAR(255) = NULL,
    @Specialty VARCHAR(50) = NULL,
    @MinClearanceLevel INT = NULL,
    @Status VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Facility SET
            Name = ISNULL(@Name, Name),
            Description = ISNULL(@Description, Description),
            FacilityTypeId = ISNULL(@FacilityTypeId, FacilityTypeId),
            ParentFacilityId = ISNULL(@ParentFacilityId, ParentFacilityId),
            ResponsiblePerson = ISNULL(@ResponsiblePerson, ResponsiblePerson),
            Specialty = ISNULL(@Specialty, Specialty),
            MinClearanceLevel = ISNULL(@MinClearanceLevel, MinClearanceLevel),
            Status = ISNULL(@Status, Status)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Facility not found', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
