CREATE OR ALTER VIEW vw_AnomalyStatistics AS
SELECT 
    -- Totals
    COUNT(*) as TotalAnomalies,
    SUM(CASE WHEN Status = 'ATIVA' THEN 1 ELSE 0 END) as ActiveCount,
    SUM(CASE WHEN Status = 'NEUTRALIZADA' THEN 1 ELSE 0 END) as NeutralizedCount,
    
    -- By class
    SUM(CASE WHEN co.Code = 'SAFE' THEN 1 ELSE 0 END) as SafeCount,
    SUM(CASE WHEN co.Code = 'EUCLID' THEN 1 ELSE 0 END) as EuclidCount,
    SUM(CASE WHEN co.Code = 'KETER' THEN 1 ELSE 0 END) as KeterCount,
    SUM(CASE WHEN co.Code = 'THAUMIEL' THEN 1 ELSE 0 END) as ThaumielCount,
    SUM(CASE WHEN co.Code = 'APOT' THEN 1 ELSE 0 END) as ApotheosisCount,
    
    -- By layer
    SUM(CASE WHEN ca.Symbol = 'THETA' THEN 1 ELSE 0 END) as ThetaCount,
    SUM(CASE WHEN ca.Symbol = 'PSI' THEN 1 ELSE 0 END) as PsiCount,
    SUM(CASE WHEN ca.Symbol = 'PHI' THEN 1 ELSE 0 END) as PhiCount,
    SUM(CASE WHEN ca.Symbol = 'OMEGA' THEN 1 ELSE 0 END) as OmegaCount,
    
    -- By matter type
    SUM(CASE WHEN tm.Name = 'Bariônica Anômala' THEN 1 ELSE 0 END) as BaryonicMatterCount,
    SUM(CASE WHEN tm.Name = 'Não-Bariônica' THEN 1 ELSE 0 END) as NonBaryonicMatterCount,
    SUM(CASE WHEN tm.Name = 'Mista' THEN 1 ELSE 0 END) as MixedMatterCount,
    
    -- Theta statistics
    AVG(ISNULL(a.IeiaDBaseline, 0)) as AvgIeiaDBaseline,
    SUM(CASE WHEN tm.IsSuppressorResistant = 1 THEN 1 ELSE 0 END) as SuppressorResistantCount
    
FROM Anomaly a
INNER JOIN Cat_ObjectClass co ON a.ObjectClassId = co.Id
INNER JOIN Cat_OntologicalLayer ca ON a.OntologicalLayerId = ca.Id
INNER JOIN Cat_MatterType tm ON a.MatterTypeId = tm.Id;
GO
