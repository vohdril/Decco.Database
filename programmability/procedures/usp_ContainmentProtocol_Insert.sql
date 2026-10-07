-- Procedure that creates a containment protocol
CREATE OR ALTER PROCEDURE usp_ContainmentProtocol_Insert
    @Code VARCHAR(20),
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @UrgencyLevel INT,
    @ApplicableClasses VARCHAR(100) = NULL,
    @Steps NVARCHAR(MAX),
    @RequiredResources NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ContainmentProtocol (Code, Title, Description, UrgencyLevel, ApplicableClasses, Steps, RequiredResources)
    VALUES (@Code, @Title, @Description, @UrgencyLevel, @ApplicableClasses, @Steps, @RequiredResources);
    SELECT SCOPE_IDENTITY() as NewId;
END;
GO
