CREATE OR ALTER VIEW vw_Dashboard_Anomalias AS
SELECT 
    a.Id,
    a.CodigoSCP,
    a.NomeComum,
    co.Nome as ClasseObjeto,
    co.CorAlerta,
    ca.Simbolo as Camada,
    ca.Nome as CamadaOntologica,
    tm.Nome as TipoMateria,
    mp.Nome as MecanismoPrimario,
    ms.Nome as MecanismoSecundario,
    a.IEIA_D_Base,
    a.FatorCoerenciaSpin,
    a.Status,
    a.SitioContencao,
    
    -- Indicadores de risco
    CASE 
        WHEN co.Codigo = 'KETER' THEN 3
        WHEN co.Codigo = 'EUCLID' THEN 2
        WHEN co.Codigo = 'SAFE' THEN 1
        ELSE 0
    END as NivelRisco,
    
    CASE 
        WHEN ca.Simbolo = 'OMEGA' OR tm.IsResistenteSupressores = 1 THEN 'SIGMA-ALERTA'
        WHEN ca.Simbolo = 'THETA' AND a.IEIA_D_Base > 0.5 THEN 'THETA-ALTO'
        WHEN ca.Simbolo = 'THETA' AND a.IEIA_D_Base > 0.1 THEN 'THETA-MEDIO'
        ELSE 'THETA-BAIXO'
    END as StatusTheta,
    
    -- Contadores
    (SELECT COUNT(*) FROM Incidente i WHERE i.AnomaliaId = a.Id AND i.IsEventoSigma = 1) as ContagemSigma,
    (SELECT COUNT(*) FROM EntidadeViva ev WHERE ev.AnomaliaId = a.Id) as QtdEntidades,
    (SELECT COUNT(*) FROM Artefato ar WHERE ar.AnomaliaId = a.Id) as QtdArtefatos
    
FROM Anomalia a
INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
INNER JOIN Cat_MecanismoInteracao mp ON a.MecanismoPrimarioId = mp.Id
LEFT JOIN Cat_MecanismoInteracao ms ON a.MecanismoSecundarioId = ms.Id
WHERE a.Status = 'ATIVA';
GO
