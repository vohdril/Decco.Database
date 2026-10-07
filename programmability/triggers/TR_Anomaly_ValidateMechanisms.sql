-- Trigger that validates secondary mechanisms
CREATE OR ALTER TRIGGER TR_Anomaly_ValidateMechanisms
ON Anomaly
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check that the secondary mechanism really is a sub-nature
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Cat_InteractionMechanism sec ON i.SecondaryMechanismId = sec.Id
        WHERE sec.IsSubNature = 0 AND i.SecondaryMechanismId IS NOT NULL
    )
    BEGIN
        RAISERROR('Secondary mechanism must have IsSubNature = 1', 16, 1);
        RETURN;
    END
    
    -- Check layer consistency
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Cat_InteractionMechanism prim ON i.PrimaryMechanismId = prim.Id
        INNER JOIN Cat_InteractionMechanism sec ON i.SecondaryMechanismId = sec.Id
        INNER JOIN Cat_OntologicalLayer cp ON prim.OntologicalLayerId = cp.Id
        INNER JOIN Cat_OntologicalLayer cs ON sec.OntologicalLayerId = cs.Id
        WHERE cp.Symbol = 'OMEGA' AND cs.Symbol = 'THETA'
    )
    BEGIN
        RAISERROR('An OMEGA anomaly cannot have a THETA sub-nature', 16, 1);
        RETURN;
    END
END;
GO
