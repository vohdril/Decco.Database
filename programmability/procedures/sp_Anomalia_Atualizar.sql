-- Procedure para atualizar uma anomalia
CREATE OR ALTER PROCEDURE sp_Anomalia_Atualizar
    @Id INT,
    @NomeComum NVARCHAR(255) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @ClasseObjetoId INT = NULL,
    @CamadaOntologicaId INT = NULL,
    @TipoMateriaId INT = NULL,
    @MecanismoPrimarioId INT = NULL,
    @MecanismoSecundarioId INT = NULL,
    @IEIA_D_Base DECIMAL(8,4) = NULL,
    @FatorCoerenciaSpin VARCHAR(20) = NULL,
    @Status VARCHAR(20) = NULL,
    @SitioContencao NVARCHAR(100) = NULL,
    @ResponsavelPesquisa NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        UPDATE Anomalia SET
            NomeComum = ISNULL(@NomeComum, NomeComum),
            Descricao = ISNULL(@Descricao, Descricao),
            ClasseObjetoId = ISNULL(@ClasseObjetoId, ClasseObjetoId),
            CamadaOntologicaId = ISNULL(@CamadaOntologicaId, CamadaOntologicaId),
            TipoMateriaId = ISNULL(@TipoMateriaId, TipoMateriaId),
            MecanismoPrimarioId = ISNULL(@MecanismoPrimarioId, MecanismoPrimarioId),
            MecanismoSecundarioId = @MecanismoSecundarioId,
            IEIA_D_Base = ISNULL(@IEIA_D_Base, IEIA_D_Base),
            FatorCoerenciaSpin = ISNULL(@FatorCoerenciaSpin, FatorCoerenciaSpin),
            Status = ISNULL(@Status, Status),
            SitioContencao = ISNULL(@SitioContencao, SitioContencao),
            ResponsavelPesquisa = ISNULL(@ResponsavelPesquisa, ResponsavelPesquisa)
        WHERE Id = @Id;
        
        IF @@ROWCOUNT = 0
            RAISERROR('Anomalia não encontrada', 16, 1);
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
