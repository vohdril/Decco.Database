-- Procedure that searches operations with filters
-- It is the SCOPED query of the schema: @FacilityId filters by facility and,
-- with @IncludeSubFacilities = 1 (default), includes its children — operations of a
-- laboratory show up when querying the site that contains it.
-- @UserClearanceLevel slices by clearance (Operation.MinClearanceLevel).
-- Slicing by the facilities ALLOWED to the user is the application's job: the
-- user↔facility relation lives in DeccoAuthDB, which this database cannot see.
CREATE OR ALTER PROCEDURE usp_Operation_Search
    @FacilityId INT = NULL,
    @IncludeSubFacilities BIT = 1,
    @OperationTypeId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @AnomalyId INT = NULL,
    @UserClearanceLevel INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Facilities in the query scope (itself + direct children).
    -- The hierarchy has a maximum depth of 2 (site → children), guaranteed by
    -- TR_Facility_ValidateHierarchy — which is why no recursive CTE is needed.
    DECLARE @Scope TABLE (Id INT PRIMARY KEY);
    IF @FacilityId IS NOT NULL
    BEGIN
        INSERT INTO @Scope (Id) VALUES (@FacilityId);
        IF @IncludeSubFacilities = 1
            INSERT INTO @Scope (Id)
            SELECT Id FROM Facility WHERE ParentFacilityId = @FacilityId;
    END

    SELECT
        o.Id,
        o.Code,
        o.Codename,
        o.OperationTypeId,
        co.Code AS OperationTypeCode,
        co.Name AS OperationType,
        o.FacilityId,
        i.Code AS FacilityCode,
        i.Name AS Facility,
        o.AnomalyId,
        a.ScpCode AS AnomalyCode,
        o.NotificationId,
        o.ProtocolId,
        p.Code AS ProtocolCode,
        o.Objective,
        o.Status,
        o.Priority,
        o.MinClearanceLevel,
        o.ResponsiblePerson,
        o.OpenedAt,
        o.ExpectedEndAt,
        o.ClosedAt
    FROM Operation o
    INNER JOIN Cat_OperationType co ON co.Id = o.OperationTypeId
    INNER JOIN Facility i ON i.Id = o.FacilityId
    LEFT JOIN Anomaly a ON a.Id = o.AnomalyId
    LEFT JOIN ContainmentProtocol p ON p.Id = o.ProtocolId
    WHERE (@FacilityId IS NULL OR o.FacilityId IN (SELECT Id FROM @Scope))
      AND (@OperationTypeId IS NULL OR o.OperationTypeId = @OperationTypeId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomalyId IS NULL OR o.AnomalyId = @AnomalyId)
      AND (@UserClearanceLevel IS NULL OR o.MinClearanceLevel <= @UserClearanceLevel)
    ORDER BY o.Priority DESC, o.OpenedAt DESC, o.Code
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Total record count for paging
    SELECT COUNT(*) AS TotalRecords
    FROM Operation o
    WHERE (@FacilityId IS NULL OR o.FacilityId IN (SELECT Id FROM @Scope))
      AND (@OperationTypeId IS NULL OR o.OperationTypeId = @OperationTypeId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomalyId IS NULL OR o.AnomalyId = @AnomalyId)
      AND (@UserClearanceLevel IS NULL OR o.MinClearanceLevel <= @UserClearanceLevel);
END;
GO
