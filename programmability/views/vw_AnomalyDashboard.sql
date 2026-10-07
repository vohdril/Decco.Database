CREATE OR ALTER VIEW vw_AnomalyDashboard AS
SELECT 
    a.Id,
    a.ScpCode,
    a.CommonName,
    co.Name as ObjectClass,
    co.AlertColor,
    ca.Symbol as Layer,
    ca.Name as OntologicalLayer,
    tm.Name as MatterType,
    mp.Name as PrimaryMechanism,
    ms.Name as SecondaryMechanism,
    a.IeiaDBaseline,
    a.SpinCoherenceFactor,
    a.Status,
    ic.Code AS ContainmentFacilityCode,
    ic.Name AS ContainmentFacility,
    
    -- Risk indicators
    CASE 
        WHEN co.Code = 'KETER' THEN 3
        WHEN co.Code = 'EUCLID' THEN 2
        WHEN co.Code = 'SAFE' THEN 1
        ELSE 0
    END as RiskLevel,
    
    CASE 
        WHEN ca.Symbol = 'OMEGA' OR tm.IsSuppressorResistant = 1 THEN 'SIGMA-ALERTA'
        WHEN ca.Symbol = 'THETA' AND a.IeiaDBaseline > 0.5 THEN 'THETA-ALTO'
        WHEN ca.Symbol = 'THETA' AND a.IeiaDBaseline > 0.1 THEN 'THETA-MEDIO'
        ELSE 'THETA-BAIXO'
    END as ThetaStatus,
    
    -- Counters
    (SELECT COUNT(*) FROM Incident i WHERE i.AnomalyId = a.Id AND i.IsSigmaEvent = 1) as SigmaCount,
    (SELECT COUNT(*) FROM LivingEntity ev WHERE ev.AnomalyId = a.Id) as LivingEntityCount,
    (SELECT COUNT(*) FROM Artifact ar WHERE ar.AnomalyId = a.Id) as ArtifactCount
    
FROM Anomaly a
INNER JOIN Cat_ObjectClass co ON a.ObjectClassId = co.Id
INNER JOIN Cat_OntologicalLayer ca ON a.OntologicalLayerId = ca.Id
INNER JOIN Cat_MatterType tm ON a.MatterTypeId = tm.Id
INNER JOIN Cat_InteractionMechanism mp ON a.PrimaryMechanismId = mp.Id
LEFT JOIN Cat_InteractionMechanism ms ON a.SecondaryMechanismId = ms.Id
LEFT JOIN Facility ic ON ic.Id = a.ContainmentFacilityId
WHERE a.Status = 'ATIVA';
GO
