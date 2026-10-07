-- Procedure that searches anomalies with complex filters
CREATE OR ALTER PROCEDURE usp_Anomaly_Search
    @ScpCode VARCHAR(50) = NULL,
    @ObjectClassId INT = NULL,
    @OntologicalLayerId INT = NULL,
    @MatterTypeId INT = NULL,
    @PrimaryMechanismId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @SigmaOnly BIT = 0,
    @PageNumber INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    SELECT 
        a.Id,
        a.ScpCode,
        a.CommonName,
        a.Description,
        co.Name as ObjectClass,
        ca.Name as OntologicalLayer,
        tm.Name as MatterType,
        mp.Name as PrimaryMechanism,
        ms.Name as SecondaryMechanism,
        a.IeiaDBaseline,
        a.SpinCoherenceFactor,
        a.Status,
        ic.Code AS ContainmentFacilityCode,
        ic.Name AS ContainmentFacility,
        a.CreatedAt,
        a.UpdatedAt,
        
        -- Manifestations as an aggregated string (through skills)
        STUFF((
            SELECT DISTINCT ', ' + cm.Name
            FROM AnomalySkill pa
            INNER JOIN AnomalySkill_Manifestation pm ON pa.Id = pm.AnomalySkillId
            INNER JOIN Cat_SpecificManifestation cm ON pm.SpecificManifestationId = cm.Id
            WHERE pa.AnomalyId = a.Id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as Manifestations,
        
        -- Incident counter
        (SELECT COUNT(*) FROM Incident i WHERE i.AnomalyId = a.Id) as TotalIncidents,
        
        -- Sigma incident counter
        (SELECT COUNT(*) FROM Incident i WHERE i.AnomalyId = a.Id AND i.IsSigmaEvent = 1) as SigmaIncidents,
        
        -- Instance counters
        (SELECT COUNT(*) FROM LivingEntity ev WHERE ev.AnomalyId = a.Id) as LivingEntityCount,
        (SELECT COUNT(*) FROM Artifact ar WHERE ar.AnomalyId = a.Id) as ArtifactCount
        
    FROM Anomaly a
    INNER JOIN Cat_ObjectClass co ON a.ObjectClassId = co.Id
    INNER JOIN Cat_OntologicalLayer ca ON a.OntologicalLayerId = ca.Id
    INNER JOIN Cat_MatterType tm ON a.MatterTypeId = tm.Id
    INNER JOIN Cat_InteractionMechanism mp ON a.PrimaryMechanismId = mp.Id
    LEFT JOIN Cat_InteractionMechanism ms ON a.SecondaryMechanismId = ms.Id
    LEFT JOIN Facility ic ON ic.Id = a.ContainmentFacilityId
    WHERE (@ScpCode IS NULL OR a.ScpCode LIKE '%' + @ScpCode + '%')
      AND (@ObjectClassId IS NULL OR a.ObjectClassId = @ObjectClassId)
      AND (@OntologicalLayerId IS NULL OR a.OntologicalLayerId = @OntologicalLayerId)
      AND (@MatterTypeId IS NULL OR a.MatterTypeId = @MatterTypeId)
      AND (@PrimaryMechanismId IS NULL OR a.PrimaryMechanismId = @PrimaryMechanismId)
      AND (@Status IS NULL OR a.Status = @Status)
      AND (@SigmaOnly = 0 OR ca.Symbol = 'OMEGA' OR tm.IsSuppressorResistant = 1)
    ORDER BY a.ScpCode
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Also return the total record count for paging
    SELECT COUNT(*) as TotalRecords
    FROM Anomaly a
    INNER JOIN Cat_OntologicalLayer ca ON a.OntologicalLayerId = ca.Id
    INNER JOIN Cat_MatterType tm ON a.MatterTypeId = tm.Id
    WHERE (@ScpCode IS NULL OR a.ScpCode LIKE '%' + @ScpCode + '%')
      AND (@ObjectClassId IS NULL OR a.ObjectClassId = @ObjectClassId)
      AND (@OntologicalLayerId IS NULL OR a.OntologicalLayerId = @OntologicalLayerId)
      AND (@MatterTypeId IS NULL OR a.MatterTypeId = @MatterTypeId)
      AND (@PrimaryMechanismId IS NULL OR a.PrimaryMechanismId = @PrimaryMechanismId)
      AND (@Status IS NULL OR a.Status = @Status)
      AND (@SigmaOnly = 0 OR ca.Symbol = 'OMEGA' OR tm.IsSuppressorResistant = 1);
END;
GO
