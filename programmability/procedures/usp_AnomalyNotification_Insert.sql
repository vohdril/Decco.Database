-- Procedure that records an anomaly notification
-- @FacilityId is OPTIONAL: a field report may come from outside any known
-- facility. @ReportedLocation (text) remains mandatory.
CREATE OR ALTER PROCEDURE usp_AnomalyNotification_Insert
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @ReportedLocation NVARCHAR(255),
    @PriorityLevel INT = 3,
    @Reporter NVARCHAR(255) = NULL,
    @AnomalyId INT = NULL,
    @FacilityId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AnomalyNotification (Title, Description, ReportedLocation, PriorityLevel, Reporter, AnomalyId, FacilityId)
    VALUES (@Title, @Description, @ReportedLocation, @PriorityLevel, @Reporter, @AnomalyId, @FacilityId);
    SELECT CAST(SCOPE_IDENTITY() AS INT) as NotificationId;
END;
GO
