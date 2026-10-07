-- Procedure para atualizar uma operação
-- Codigo e InstalacaoId NÃO são atualizáveis: o código é a identidade pública e
-- a instalação é o ESCOPO da operação (chave do cache escopado). Uma operação
-- que muda de instalação é, para efeito de permissão, outra operação.
--
-- Encerramento: ao passar para CONCLUIDA ou ABORTADA sem @DataEncerramento, a
-- data é preenchida com GETDATE(). Ao voltar para um estado aberto, é limpa.
CREATE OR ALTER PROCEDURE sp_Operacao_Atualizar
    @Id INT,
    @Codinome NVARCHAR(100) = NULL,
    @TipoOperacaoId INT = NULL,
    @AnomaliaId INT = NULL,
    @NotificacaoId INT = NULL,
    @ProtocoloId INT = NULL,
    @Objetivo NVARCHAR(500) = NULL,
    @Descricao NVARCHAR(MAX) = NULL,
    @Status VARCHAR(20) = NULL,
    @Prioridade INT = NULL,
    @NivelAcessoMinimo INT = NULL,
    @Responsavel NVARCHAR(255) = NULL,
    @DataPrevisaoTermino DATETIME = NULL,
    @DataEncerramento DATETIME = NULL,
    @ResultadoResumo NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Operacao SET
            Codinome = ISNULL(@Codinome, Codinome),
            TipoOperacaoId = ISNULL(@TipoOperacaoId, TipoOperacaoId),
            AnomaliaId = ISNULL(@AnomaliaId, AnomaliaId),
            NotificacaoId = ISNULL(@NotificacaoId, NotificacaoId),
            ProtocoloId = ISNULL(@ProtocoloId, ProtocoloId),
            Objetivo = ISNULL(@Objetivo, Objetivo),
            Descricao = ISNULL(@Descricao, Descricao),
            Status = ISNULL(@Status, Status),
            Prioridade = ISNULL(@Prioridade, Prioridade),
            NivelAcessoMinimo = ISNULL(@NivelAcessoMinimo, NivelAcessoMinimo),
            Responsavel = ISNULL(@Responsavel, Responsavel),
            DataPrevisaoTermino = ISNULL(@DataPrevisaoTermino, DataPrevisaoTermino),
            DataEncerramento = CASE
                WHEN ISNULL(@Status, Status) IN ('CONCLUIDA', 'ABORTADA')
                    THEN COALESCE(@DataEncerramento, DataEncerramento, GETDATE())
                ELSE NULL
            END,
            ResultadoResumo = ISNULL(@ResultadoResumo, ResultadoResumo)
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
            THROW 50404, 'Operação não encontrada', 1;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
