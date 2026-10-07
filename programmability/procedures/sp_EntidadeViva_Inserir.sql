-- Procedure para inserir uma entidade viva
CREATE OR ALTER PROCEDURE sp_EntidadeViva_Inserir
    @AnomaliaId INT,
    @Identificacao NVARCHAR(100),
    @Especie NVARCHAR(150),
    @Biologia NVARCHAR(255) = NULL,
    @OrigemPoder NVARCHAR(100) = NULL,
    @DataNascimento DATE = NULL,
    @IsConsciente BIT = 1,
    @NivelInteligencia INT = NULL,
    @Dieta NVARCHAR(100) = NULL,
    @Observacoes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE Id = @AnomaliaId)
            RAISERROR('Anomalia não encontrada', 16, 1);
            
        INSERT INTO EntidadeViva (
            AnomaliaId, Identificacao, Especie, Biologia, OrigemPoder,
            DataNascimento, IsConsciente, NivelInteligencia, Dieta, Observacoes
        ) VALUES (
            @AnomaliaId, @Identificacao, @Especie, @Biologia, @OrigemPoder,
            @DataNascimento, @IsConsciente, @NivelInteligencia, @Dieta, @Observacoes
        );
        
        SELECT SCOPE_IDENTITY() as NovaEntidadeId;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
