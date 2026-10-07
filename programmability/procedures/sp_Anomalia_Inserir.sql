-- Procedure that inserts a new anomaly
CREATE OR ALTER PROCEDURE sp_Anomalia_Inserir
    @CodigoSCP VARCHAR(50),
    @NomeComum NVARCHAR(255),
    @Descricao NVARCHAR(MAX),
    @ClasseObjetoId INT,
    @CamadaOntologicaId INT,
    @TipoMateriaId INT,
    @CognicaoAparenteId INT = NULL,
    @PericulosidadeId INT = NULL,
    @MecanismoPrimarioId INT,
    @MecanismoSecundarioId INT = NULL,
    @IEIA_D_Base DECIMAL(8,4) = NULL,
    @FatorCoerenciaSpin VARCHAR(20) = NULL,
    @InstalacaoContencaoId INT = NULL,
    @ResponsavelPesquisa NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        INSERT INTO Anomalia (
            CodigoSCP, NomeComum, Descricao,
            ClasseObjetoId, CamadaOntologicaId, TipoMateriaId,
            CognicaoAparenteId, PericulosidadeId,
            MecanismoPrimarioId, MecanismoSecundarioId,
            IEIA_D_Base, FatorCoerenciaSpin,
            InstalacaoContencaoId, ResponsavelPesquisa
        ) VALUES (
            @CodigoSCP, @NomeComum, @Descricao,
            @ClasseObjetoId, @CamadaOntologicaId, @TipoMateriaId,
            @CognicaoAparenteId, @PericulosidadeId,
            @MecanismoPrimarioId, @MecanismoSecundarioId,
            @IEIA_D_Base, @FatorCoerenciaSpin,
            @InstalacaoContencaoId, @ResponsavelPesquisa
        );
        
        DECLARE @NewAnomaliaId INT = SCOPE_IDENTITY();
        
        SELECT @NewAnomaliaId as NovoId, @CodigoSCP as CodigoFormatado;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
