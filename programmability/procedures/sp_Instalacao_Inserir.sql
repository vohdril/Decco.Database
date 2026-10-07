-- Procedure para criar instalação (substitui sp_Laboratorio_Inserir)
-- Um laboratório agora é: @TipoInstalacaoId = LABORATORIO + @InstalacaoPaiId = o sítio.
-- As regras de hierarquia (quem pode ser pai de quem) vivem em
-- TR_Instalacao_Validar_Hierarquia, para valerem também fora desta procedure.
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
