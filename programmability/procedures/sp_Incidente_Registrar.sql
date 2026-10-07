-- Procedure para registrar um incidente
CREATE OR ALTER PROCEDURE sp_Incidente_Registrar
    @AnomaliaId INT,
    @Tipo VARCHAR(50),
    @Titulo NVARCHAR(255),
    @Relatorio NVARCHAR(MAX),
    @NivelSeguranca VARCHAR(20),
    @IsEventoSigma BIT = 0,
    @Mortes INT = 0,
    @Feridos INT = 0,
    @DanoMaterial NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomalia não encontrada', 16, 1);
        
        INSERT INTO Incidente (AnomaliaId, Tipo, Titulo, Relatorio, NivelSeguranca, IsEventoSigma, Mortes, Feridos, DanoMaterial)
        VALUES (@AnomaliaId, @Tipo, @Titulo, @Relatorio, @NivelSeguranca, @IsEventoSigma, @Mortes, @Feridos, @DanoMaterial);
        
        DECLARE @NovoIncidenteId INT = SCOPE_IDENTITY();
        
        SELECT @NovoIncidenteId as IncidenteId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
