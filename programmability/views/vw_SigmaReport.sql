CREATE OR ALTER VIEW vw_SigmaReport AS
SELECT 
    a.ScpCode,
    a.CommonName,
    co.Name as ObjectClass,
    ca.Name as Layer,
    tm.IsSuppressorResistant,
    COUNT(i.Id) as TotalIncidents,
    SUM(CASE WHEN i.IsSigmaEvent = 1 THEN 1 ELSE 0 END) as SigmaIncidents,
    MAX(i.OccurredAt) as LastIncidentAt,
    ic.Code AS ContainmentFacilityCode,
    ic.Name AS ContainmentFacility,
    a.ResearchLead
FROM Anomaly a
INNER JOIN Cat_ObjectClass co ON a.ObjectClassId = co.Id
INNER JOIN Cat_OntologicalLayer ca ON a.OntologicalLayerId = ca.Id
INNER JOIN Cat_MatterType tm ON a.MatterTypeId = tm.Id
LEFT JOIN Facility ic ON ic.Id = a.ContainmentFacilityId
LEFT JOIN Incident i ON a.Id = i.AnomalyId
WHERE ca.Symbol = 'OMEGA' 
   OR tm.IsSuppressorResistant = 1
   OR co.Code = 'APOT'
GROUP BY a.Id, a.ScpCode, a.CommonName, co.Name, ca.Name, 
         tm.IsSuppressorResistant, ic.Code, ic.Name, a.ResearchLead;
GO
