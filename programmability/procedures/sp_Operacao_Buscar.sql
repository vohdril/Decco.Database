-- Procedure para buscar operações com filtros
-- É a consulta ESCOPADA do schema: @InstalacaoId filtra pela instalação e,
-- com @IncluirSubinstalacoes = 1 (padrão), inclui as filhas — operações de um
-- laboratório aparecem ao consultar o sítio que o contém.
-- @NivelAcessoUsuario recorta por clearance (Operacao.NivelAcessoMinimo).
-- O recorte por INSTALAÇÃO PERMITIDA ao usuário é da aplicação: a relação
-- usuário↔instalação vive no DeccoAuthDB, que este banco não enxerga.
CREATE OR ALTER PROCEDURE sp_Operacao_Buscar
    @InstalacaoId INT = NULL,
    @IncluirSubinstalacoes BIT = 1,
    @TipoOperacaoId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @AnomaliaId INT = NULL,
    @NivelAcessoUsuario INT = NULL,
    @Pagina INT = 1,
    @ItensPorPagina INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @ItensPorPagina;

    -- Instalações no escopo da consulta (a própria + filhas diretas).
    -- A hierarquia tem profundidade máxima 2 (sítio → filhos), garantida por
    -- TR_Instalacao_Validar_Hierarquia — por isso não é preciso CTE recursiva.
    DECLARE @Escopo TABLE (Id INT PRIMARY KEY);
    IF @InstalacaoId IS NOT NULL
    BEGIN
        INSERT INTO @Escopo (Id) VALUES (@InstalacaoId);
        IF @IncluirSubinstalacoes = 1
            INSERT INTO @Escopo (Id)
            SELECT Id FROM Instalacao WHERE InstalacaoPaiId = @InstalacaoId;
    END

    SELECT
        o.Id,
        o.Codigo,
        o.Codinome,
        o.TipoOperacaoId,
        co.Codigo AS TipoOperacaoCodigo,
        co.Nome AS TipoOperacao,
        o.InstalacaoId,
        i.Codigo AS InstalacaoCodigo,
        i.Nome AS Instalacao,
        o.AnomaliaId,
        a.CodigoSCP AS AnomaliaCodigo,
        o.NotificacaoId,
        o.ProtocoloId,
        p.Codigo AS ProtocoloCodigo,
        o.Objetivo,
        o.Status,
        o.Prioridade,
        o.NivelAcessoMinimo,
        o.Responsavel,
        o.DataAbertura,
        o.DataPrevisaoTermino,
        o.DataEncerramento
    FROM Operacao o
    INNER JOIN Cat_Operacao co ON co.Id = o.TipoOperacaoId
    INNER JOIN Instalacao i ON i.Id = o.InstalacaoId
    LEFT JOIN Anomalia a ON a.Id = o.AnomaliaId
    LEFT JOIN ProtocoloContencao p ON p.Id = o.ProtocoloId
    WHERE (@InstalacaoId IS NULL OR o.InstalacaoId IN (SELECT Id FROM @Escopo))
      AND (@TipoOperacaoId IS NULL OR o.TipoOperacaoId = @TipoOperacaoId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomaliaId IS NULL OR o.AnomaliaId = @AnomaliaId)
      AND (@NivelAcessoUsuario IS NULL OR o.NivelAcessoMinimo <= @NivelAcessoUsuario)
    ORDER BY o.Prioridade DESC, o.DataAbertura DESC, o.Codigo
    OFFSET @Offset ROWS
    FETCH NEXT @ItensPorPagina ROWS ONLY;

    -- Total de registros para paginação
    SELECT COUNT(*) AS TotalRegistros
    FROM Operacao o
    WHERE (@InstalacaoId IS NULL OR o.InstalacaoId IN (SELECT Id FROM @Escopo))
      AND (@TipoOperacaoId IS NULL OR o.TipoOperacaoId = @TipoOperacaoId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomaliaId IS NULL OR o.AnomaliaId = @AnomaliaId)
      AND (@NivelAcessoUsuario IS NULL OR o.NivelAcessoMinimo <= @NivelAcessoUsuario);
END;
GO
