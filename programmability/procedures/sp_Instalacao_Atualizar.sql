-- Procedure para atualizar instalação
-- Codigo NÃO é atualizável: é a identidade pública (IdToCode) e a chave do
-- cache escopado (decco:inst:{codigo}:*). Trocar o código invalidaria chaves e
-- referências externas sem aviso.
CREATE OR ALTER PROCEDURE sp_Instalacao_Atualizar
    @Id INT,
    @Nome NVARCHAR(255) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @TipoInstalacaoId INT = NULL,
    @InstalacaoPaiId INT = NULL,
    @Responsavel NVARCHAR(255) = NULL,
    @Especialidade VARCHAR(50) = NULL,
    @NivelAcessoMinimo INT = NULL,
    @Status VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Instalacao SET
            Nome = ISNULL(@Nome, Nome),
            Descricao = ISNULL(@Descricao, Descricao),
            TipoInstalacaoId = ISNULL(@TipoInstalacaoId, TipoInstalacaoId),
            InstalacaoPaiId = ISNULL(@InstalacaoPaiId, InstalacaoPaiId),
            Responsavel = ISNULL(@Responsavel, Responsavel),
            Especialidade = ISNULL(@Especialidade, Especialidade),
            NivelAcessoMinimo = ISNULL(@NivelAcessoMinimo, NivelAcessoMinimo),
            Status = ISNULL(@Status, Status)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Instalação não encontrada', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
