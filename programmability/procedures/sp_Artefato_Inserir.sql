-- Procedure para inserir um artefato
CREATE OR ALTER PROCEDURE sp_Artefato_Inserir
    @AnomaliaId INT,
    @Identificacao NVARCHAR(100),
    @Material NVARCHAR(255) = NULL,
    @DataFabricacao DATE = NULL,
    @LocalOrigem NVARCHAR(255) = NULL,
    @PropriedadeSpin VARCHAR(100) = NULL,
    @Peso_Kg DECIMAL(10,2) = NULL,
    @Dimensoes VARCHAR(100) = NULL,
    @ModoUsar NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomalia não encontrada', 16, 1);
            
        INSERT INTO Artefato (
            AnomaliaId, Identificacao, Material, DataFabricacao, LocalOrigem,
            PropriedadeSpin, Peso_Kg, Dimensoes, ModoUsar
        ) VALUES (
            @AnomaliaId, @Identificacao, @Material, @DataFabricacao, @LocalOrigem,
            @PropriedadeSpin, @Peso_Kg, @Dimensoes, @ModoUsar
        );
        
        SELECT SCOPE_IDENTITY() as NovoArtefatoId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
