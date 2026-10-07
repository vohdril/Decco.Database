-- Trigger that validates secondary mechanisms
CREATE OR ALTER TRIGGER TR_Anomalia_Validar_Mecanismos
ON Anomalia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check that the secondary mechanism really is a sub-nature
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Cat_MecanismoInteracao sec ON i.MecanismoSecundarioId = sec.Id
        WHERE sec.EhSubnatureza = 0 AND i.MecanismoSecundarioId IS NOT NULL
    )
    BEGIN
        RAISERROR('Secondary mechanism must have EhSubnatureza = 1', 16, 1);
        RETURN;
    END
    
    -- Check layer consistency
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Cat_MecanismoInteracao prim ON i.MecanismoPrimarioId = prim.Id
        INNER JOIN Cat_MecanismoInteracao sec ON i.MecanismoSecundarioId = sec.Id
        INNER JOIN Cat_CamadaOntologica cp ON prim.CamadaOntologicaId = cp.Id
        INNER JOIN Cat_CamadaOntologica cs ON sec.CamadaOntologicaId = cs.Id
        WHERE cp.Simbolo = 'OMEGA' AND cs.Simbolo = 'THETA'
    )
    BEGIN
        RAISERROR('An OMEGA anomaly cannot have a THETA sub-nature', 16, 1);
        RETURN;
    END
END;
GO
