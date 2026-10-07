-- Procedure that creates a facility (replaces sp_Laboratorio_Inserir)
-- A laboratory is now: @FacilityTypeId = LABORATORIO + @ParentFacilityId = the site.
-- The hierarchy rules (who can be whose parent) live in
-- TR_Facility_ValidateHierarchy, so they also apply outside this procedure.
CREATE OR ALTER PROCEDURE usp_Facility_Insert
    @Code VARCHAR(20),
    @Name NVARCHAR(255),
    @FacilityTypeId INT,
    @ParentFacilityId INT = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @ResponsiblePerson NVARCHAR(255) = NULL,
    @Specialty VARCHAR(50) = NULL,
    @MinClearanceLevel INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        INSERT INTO Facility (Code, Name, Description, FacilityTypeId, ParentFacilityId,
                                ResponsiblePerson, Specialty, MinClearanceLevel)
        VALUES (@Code, @Name, @Description, @FacilityTypeId, @ParentFacilityId,
                @ResponsiblePerson, @Specialty, @MinClearanceLevel);

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
