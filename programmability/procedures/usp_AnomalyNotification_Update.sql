-- Procedure that updates an anomaly notification
-- It did not exist in the baseline: the Decco.API NotificacaoAnomaliaRepository already
-- called it (UpdateAsync) and failed with "Could not find stored procedure".
-- Follows the usp_Anomaly_Update pattern: a NULL parameter = "do not change".
CREATE OR ALTER PROCEDURE usp_AnomalyNotification_Update
    @Id INT,
    @Title NVARCHAR(255) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @ReportedLocation NVARCHAR(255) = NULL,
    @PriorityLevel INT = NULL,
    @Status VARCHAR(20) = NULL,
    @Reporter NVARCHAR(255) = NULL,
    @AnomalyId INT = NULL,
    @FacilityId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE AnomalyNotification SET
            Title = ISNULL(@Title, Title),
            Description = ISNULL(@Description, Description),
            ReportedLocation = ISNULL(@ReportedLocation, ReportedLocation),
            PriorityLevel = ISNULL(@PriorityLevel, PriorityLevel),
            Status = ISNULL(@Status, Status),
            Reporter = ISNULL(@Reporter, Reporter),
            AnomalyId = ISNULL(@AnomalyId, AnomalyId),
            FacilityId = ISNULL(@FacilityId, FacilityId)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Notification not found', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
