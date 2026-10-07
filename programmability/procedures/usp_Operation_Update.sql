-- Procedure that updates an operation
-- Code and FacilityId CANNOT be updated: the code is the public identity and the
-- facility is the operation SCOPE (the scoped cache key). An operation that moves
-- to another facility is, for permission purposes, a different operation.
--
-- Closing: when moving to CONCLUIDA or ABORTADA without @ClosedAt, the
-- date is filled with GETDATE(). When going back to an open state, it is cleared.
CREATE OR ALTER PROCEDURE usp_Operation_Update
    @Id INT,
    @Codename NVARCHAR(100) = NULL,
    @OperationTypeId INT = NULL,
    @AnomalyId INT = NULL,
    @NotificationId INT = NULL,
    @ProtocolId INT = NULL,
    @Objective NVARCHAR(500) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @Status VARCHAR(20) = NULL,
    @Priority INT = NULL,
    @MinClearanceLevel INT = NULL,
    @ResponsiblePerson NVARCHAR(255) = NULL,
    @ExpectedEndAt DATETIME = NULL,
    @ClosedAt DATETIME = NULL,
    @ResultSummary NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Operation SET
            Codename = ISNULL(@Codename, Codename),
            OperationTypeId = ISNULL(@OperationTypeId, OperationTypeId),
            AnomalyId = ISNULL(@AnomalyId, AnomalyId),
            NotificationId = ISNULL(@NotificationId, NotificationId),
            ProtocolId = ISNULL(@ProtocolId, ProtocolId),
            Objective = ISNULL(@Objective, Objective),
            Description = ISNULL(@Description, Description),
            Status = ISNULL(@Status, Status),
            Priority = ISNULL(@Priority, Priority),
            MinClearanceLevel = ISNULL(@MinClearanceLevel, MinClearanceLevel),
            ResponsiblePerson = ISNULL(@ResponsiblePerson, ResponsiblePerson),
            ExpectedEndAt = ISNULL(@ExpectedEndAt, ExpectedEndAt),
            ClosedAt = CASE
                WHEN ISNULL(@Status, Status) IN ('CONCLUIDA', 'ABORTADA')
                    THEN COALESCE(@ClosedAt, ClosedAt, GETDATE())
                ELSE NULL
            END,
            ResultSummary = ISNULL(@ResultSummary, ResultSummary)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Operation not found', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
