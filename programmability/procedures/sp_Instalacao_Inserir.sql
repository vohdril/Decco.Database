-- Procedure that creates a facility (replaces sp_Laboratorio_Inserir)
-- A laboratory is now: @TipoInstalacaoId = LABORATORIO + @InstalacaoPaiId = the site.
-- The hierarchy rules (who can be whose parent) live in
-- TR_Instalacao_Validar_Hierarquia, so they also apply outside this procedure.
CREATE OR ALTER PROCEDURE sp_Instalacao_Inserir
    @Codigo VARCHAR(20),
    @Nome NVARCHAR(255),
    @TipoInstalacaoId INT,
    @InstalacaoPaiId INT = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @Responsavel NVARCHAR(255) = NULL,
    @Especialidade VARCHAR(50) = NULL,
    @NivelAcessoMinimo INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        INSERT INTO Instalacao (Codigo, Nome, Descricao, TipoInstalacaoId, InstalacaoPaiId,
                                Responsavel, Especialidade, NivelAcessoMinimo)
        VALUES (@Codigo, @Nome, @Descricao, @TipoInstalacaoId, @InstalacaoPaiId,
                @Responsavel, @Especialidade, @NivelAcessoMinimo);

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS NovoId;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
