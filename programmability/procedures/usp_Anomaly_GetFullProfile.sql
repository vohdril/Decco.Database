-- Procedure that returns the full profile of an anomaly
CREATE OR ALTER PROCEDURE usp_Anomaly_GetFullProfile
    @AnomalyId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Basic anomaly information
    SELECT 
        a.Id,
        a.ScpCode,
        a.CommonName,
        a.Description,
        co.Name as ObjectClass,
        co.AlertColor,
        ca.Name as OntologicalLayer,
        ff.Name as FundamentalForce,
        tm.Name as MatterType,
        mp.Name as PrimaryMechanism,
        ms.Name as SecondaryMechanism,
        a.IeiaDBaseline,
        a.SpinCoherenceFactor,
        a.Status,
        ic.Code AS ContainmentFacilityCode,
        ic.Name AS ContainmentFacility,
        a.ResearchLead,
        a.CreatedAt,
        a.UpdatedAt
    FROM Anomaly a
    INNER JOIN Cat_ObjectClass co ON a.ObjectClassId = co.Id
    INNER JOIN Cat_OntologicalLayer ca ON a.OntologicalLayerId = ca.Id
    INNER JOIN Cat_FundamentalForce ff ON ca.FundamentalForceId = ff.Id
    INNER JOIN Cat_MatterType tm ON a.MatterTypeId = tm.Id
    INNER JOIN Cat_InteractionMechanism mp ON a.PrimaryMechanismId = mp.Id
    LEFT JOIN Cat_InteractionMechanism ms ON a.SecondaryMechanismId = ms.Id
    LEFT JOIN Facility ic ON ic.Id = a.ContainmentFacilityId
    WHERE a.Id = @AnomalyId;
    
    -- Associated living entities
    SELECT * FROM LivingEntity WHERE AnomalyId = @AnomalyId;
    
    -- Associated artifacts
    SELECT * FROM Artifact WHERE AnomalyId = @AnomalyId;
    
    -- Associated locations
    SELECT * FROM Location WHERE AnomalyId = @AnomalyId;
    
    -- Associated events
    SELECT * FROM AnomalyEvent WHERE AnomalyId = @AnomalyId;
    
    -- Anomaly skills
    SELECT 
        pa.*,
        mp.Name as PrimaryMechanismName,
        ms.Name as SecondaryMechanismName
    FROM AnomalySkill pa
    INNER JOIN Cat_InteractionMechanism mp ON pa.PrimaryMechanismId = mp.Id
    LEFT JOIN Cat_InteractionMechanism ms ON pa.SecondaryMechanismId = ms.Id
    WHERE pa.AnomalyId = @AnomalyId;
    
    -- Manifestations (through skills)
    SELECT DISTINCT
        cm.Code,
        cm.Name,
        cm.Description
    FROM AnomalySkill pa
    INNER JOIN AnomalySkill_Manifestation pm ON pa.Id = pm.AnomalySkillId
    INNER JOIN Cat_SpecificManifestation cm ON pm.SpecificManifestationId = cm.Id
    WHERE pa.AnomalyId = @AnomalyId;
    
    -- Recorded incidents
    SELECT * FROM Incident 
    WHERE AnomalyId = @AnomalyId 
    ORDER BY OccurredAt DESC;
END;
GO
