-- Procedure that opens an operation
-- @Code is optional: when omitted, it is generated as OP-{year}-{sequence},
-- e.g. OP-2026-0001. The sequence is per year and computed under UPDLOCK/HOLDLOCK
-- so that two concurrent openings never generate the same code.
-- The business rules (does the type require an anomaly? does the facility accept it?)
-- live in TR_Operation_Validate, so they also apply outside this procedure.
CREATE OR ALTER PROCEDURE usp_Operation_Insert
    @Codename NVARCHAR(100),
    @OperationTypeId INT,
    @FacilityId INT,
    @Objective NVARCHAR(500),
    @Code VARCHAR(20) = NULL,
    @AnomalyId INT = NULL,
    @NotificationId INT = NULL,
    @ProtocolId INT = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @Priority INT = 3,
    @MinClearanceLevel INT = 1,
    @ResponsiblePerson NVARCHAR(255) = NULL,
    @ExpectedEndAt DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Code IS NULL
        BEGIN
            DECLARE @Prefix VARCHAR(8) = 'OP-' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-';
            DECLARE @LastSequence INT = (
                SELECT MAX(CAST(SUBSTRING(Code, 9, 4) AS INT))
                  FROM Operation WITH (UPDLOCK, HOLDLOCK)
                 WHERE Code LIKE @Prefix + '[0-9][0-9][0-9][0-9]'
            );
            SET @Code = @Prefix + RIGHT('0000' + CAST(ISNULL(@LastSequence, 0) + 1 AS VARCHAR(4)), 4);
        END

        INSERT INTO Operation (Code, Codename, OperationTypeId, FacilityId,
                              AnomalyId, NotificationId, ProtocolId,
                              Objective, Description, Priority, MinClearanceLevel,
                              ResponsiblePerson, ExpectedEndAt)
        VALUES (@Code, @Codename, @OperationTypeId, @FacilityId,
                @AnomalyId, @NotificationId, @ProtocolId,
                @Objective, @Description, @Priority, @MinClearanceLevel,
                @ResponsiblePerson, @ExpectedEndAt);

        DECLARE @NewId INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRANSACTION;

        SELECT @NewId AS NewId, @Code AS FormattedCode;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
