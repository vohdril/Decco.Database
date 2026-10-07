-- Procedure that searches operations with filters
-- It is the SCOPED query of the schema: @InstalacaoId filters by facility and,
-- with @IncluirSubinstalacoes = 1 (default), includes its children — operations of a
-- laboratory show up when querying the site that contains it.
-- @NivelAcessoUsuario slices by clearance (Operacao.NivelAcessoMinimo).
-- Slicing by the facilities ALLOWED to the user is the application's job: the
-- user↔facility relation lives in DeccoAuthDB, which this database cannot see.
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

    -- Facilities in the query scope (itself + direct children).
    -- The hierarchy has a maximum depth of 2 (site → children), guaranteed by
    -- TR_Instalacao_Validar_Hierarquia — which is why no recursive CTE is needed.
    DECLARE @Scope TABLE (Id INT PRIMARY KEY);
    IF @InstalacaoId IS NOT NULL
    BEGIN
        INSERT INTO @Scope (Id) VALUES (@InstalacaoId);
        IF @IncluirSubinstalacoes = 1
            INSERT INTO @Scope (Id)
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
    WHERE (@InstalacaoId IS NULL OR o.InstalacaoId IN (SELECT Id FROM @Scope))
      AND (@TipoOperacaoId IS NULL OR o.TipoOperacaoId = @TipoOperacaoId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomaliaId IS NULL OR o.AnomaliaId = @AnomaliaId)
      AND (@NivelAcessoUsuario IS NULL OR o.NivelAcessoMinimo <= @NivelAcessoUsuario)
    ORDER BY o.Prioridade DESC, o.DataAbertura DESC, o.Codigo
    OFFSET @Offset ROWS
    FETCH NEXT @ItensPorPagina ROWS ONLY;

    -- Total record count for paging
    SELECT COUNT(*) AS TotalRegistros
    FROM Operacao o
    WHERE (@InstalacaoId IS NULL OR o.InstalacaoId IN (SELECT Id FROM @Scope))
      AND (@TipoOperacaoId IS NULL OR o.TipoOperacaoId = @TipoOperacaoId)
      AND (@Status IS NULL OR o.Status = @Status)
      AND (@AnomaliaId IS NULL OR o.AnomaliaId = @AnomaliaId)
      AND (@NivelAcessoUsuario IS NULL OR o.NivelAcessoMinimo <= @NivelAcessoUsuario);
END;
GO
