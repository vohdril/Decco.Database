-- Procedure para adicionar manifestação a uma perícia
CREATE OR ALTER PROCEDURE sp_Pericia_AdicionarManifestacao
    @PericiaAnomaliaId INT,
    @ManifestacaoEspecificaId INT,
    @Intensidade VARCHAR(20) = NULL,
    @Observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PericiaAnomalia WHERE Id = @PericiaAnomaliaId)
            RAISERROR('Perícia não encontrada', 16, 1);
            
        IF NOT EXISTS (SELECT 1 FROM Cat_ManifestacaoEspecifica WHERE Id = @ManifestacaoEspecificaId)
            RAISERROR('Manifestação específica não encontrada', 16, 1);
        
        INSERT INTO Pericia_Manifestacao (PericiaAnomaliaId, ManifestacaoEspecificaId, Intensidade, Observacoes)
        VALUES (@PericiaAnomaliaId, @ManifestacaoEspecificaId, @Intensidade, @Observacoes);
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
