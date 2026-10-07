-- Procedure that adds a skill (pericia) to an anomaly
CREATE OR ALTER PROCEDURE sp_Anomalia_AdicionarPericia
    @AnomaliaId INT,
    @Nome NVARCHAR(100),
    @Descricao NVARCHAR(MAX) = NULL,
    @MecanismoPrimarioId INT,
    @MecanismoSecundarioId INT = NULL,
    @Nivel INT = 1,
    @Custo NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomaly not found', 16, 1);
            
        INSERT INTO PericiaAnomalia (
            AnomaliaId, Nome, Descricao, 
            MecanismoPrimarioId, MecanismoSecundarioId,
            Nivel, Custo
        ) VALUES (
            @AnomaliaId, @Nome, @Descricao,
            @MecanismoPrimarioId, @MecanismoSecundarioId,
            @Nivel, @Custo
        );
        
        DECLARE @NewPericiaId INT = SCOPE_IDENTITY();
        
        -- Return in the same shape as the other procedures
        SELECT @NewPericiaId as NovoId, @Nome as NomePericia;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
