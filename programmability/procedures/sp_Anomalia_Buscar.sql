-- Procedure para buscar anomalias com filtros complexos
CREATE OR ALTER PROCEDURE sp_Anomalia_Buscar
    @CodigoSCP VARCHAR(50) = NULL,
    @ClasseObjetoId INT = NULL,
    @CamadaOntologicaId INT = NULL,
    @TipoMateriaId INT = NULL,
    @MecanismoPrimarioId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @ApenasSigma BIT = 0,
    @Pagina INT = 1,
    @ItensPorPagina INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@Pagina - 1) * @ItensPorPagina;
    
    SELECT 
        a.Id,
        a.CodigoSCP,
        a.NomeComum,
        a.Descricao,
        co.Nome as ClasseObjeto,
        ca.Nome as CamadaOntologica,
        tm.Nome as TipoMateria,
        mp.Nome as MecanismoPrimario,
        ms.Nome as MecanismoSecundario,
        a.IEIA_D_Base,
        a.FatorCoerenciaSpin,
        a.Status,
        ic.Codigo AS InstalacaoContencaoCodigo,
        ic.Nome AS InstalacaoContencao,
        a.DataCriacao,
        a.DataAtualizacao,
        
        -- Manifestações como string agregada (via perícias)
        STUFF((
            SELECT DISTINCT ', ' + cm.Nome
            FROM PericiaAnomalia pa
            INNER JOIN Pericia_Manifestacao pm ON pa.Id = pm.PericiaAnomaliaId
            INNER JOIN Cat_ManifestacaoEspecifica cm ON pm.ManifestacaoEspecificaId = cm.Id
            WHERE pa.AnomaliaId = a.Id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as Manifestacoes,
        
        -- Contador de incidentes
        (SELECT COUNT(*) FROM Incidente i WHERE i.AnomaliaId = a.Id) as TotalIncidentes,
        
        -- Contador de incidentes Sigma
        (SELECT COUNT(*) FROM Incidente i WHERE i.AnomaliaId = a.Id AND i.IsEventoSigma = 1) as IncidentesSigma,
        
        -- Contadores de instâncias
        (SELECT COUNT(*) FROM EntidadeViva ev WHERE ev.AnomaliaId = a.Id) as QtdEntidades,
        (SELECT COUNT(*) FROM Artefato ar WHERE ar.AnomaliaId = a.Id) as QtdArtefatos
        
    FROM Anomalia a
    INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
    INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
    INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
    INNER JOIN Cat_MecanismoInteracao mp ON a.MecanismoPrimarioId = mp.Id
    LEFT JOIN Cat_MecanismoInteracao ms ON a.MecanismoSecundarioId = ms.Id
    LEFT JOIN Instalacao ic ON ic.Id = a.InstalacaoContencaoId
    WHERE (@CodigoSCP IS NULL OR a.CodigoSCP LIKE '%' + @CodigoSCP + '%')
      AND (@ClasseObjetoId IS NULL OR a.ClasseObjetoId = @ClasseObjetoId)
      AND (@CamadaOntologicaId IS NULL OR a.CamadaOntologicaId = @CamadaOntologicaId)
      AND (@TipoMateriaId IS NULL OR a.TipoMateriaId = @TipoMateriaId)
      AND (@MecanismoPrimarioId IS NULL OR a.MecanismoPrimarioId = @MecanismoPrimarioId)
      AND (@Status IS NULL OR a.Status = @Status)
      AND (@ApenasSigma = 0 OR ca.Simbolo = 'OMEGA' OR tm.IsResistenteSupressores = 1)
    ORDER BY a.CodigoSCP
    OFFSET @Offset ROWS
    FETCH NEXT @ItensPorPagina ROWS ONLY;
    
    -- Retornar também o total de registros para paginação
    SELECT COUNT(*) as TotalRegistros
    FROM Anomalia a
    INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
    INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
    WHERE (@CodigoSCP IS NULL OR a.CodigoSCP LIKE '%' + @CodigoSCP + '%')
      AND (@ClasseObjetoId IS NULL OR a.ClasseObjetoId = @ClasseObjetoId)
      AND (@CamadaOntologicaId IS NULL OR a.CamadaOntologicaId = @CamadaOntologicaId)
      AND (@TipoMateriaId IS NULL OR a.TipoMateriaId = @TipoMateriaId)
      AND (@MecanismoPrimarioId IS NULL OR a.MecanismoPrimarioId = @MecanismoPrimarioId)
      AND (@Status IS NULL OR a.Status = @Status)
      AND (@ApenasSigma = 0 OR ca.Simbolo = 'OMEGA' OR tm.IsResistenteSupressores = 1);
END;
GO
