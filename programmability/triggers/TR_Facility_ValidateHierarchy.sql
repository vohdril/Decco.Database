-- Trigger that validates the facility hierarchy
--
-- Rules (derived from Cat_FacilityType.AllowsChildren):
--   1. A type that ALLOWS children (SITIO) is a root: it has no parent.
--   2. A type that does NOT allow children (LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO)
--      needs a parent.
--   3. The parent must be of a type that allows children.
--   4. A facility with children cannot change to a type without children.
-- Consequence: the hierarchy has a maximum depth of 2 and allows no cycles —
-- usp_Operation_Search relies on this to avoid a recursive CTE.
--
-- Uses THROW, not RAISERROR: inside a trigger, THROW aborts the batch and ROLLS BACK
-- the transaction, including the INSERT/UPDATE that fired the trigger. RAISERROR
-- followed by RETURN only sends the error to the client — the invalid row stays
-- written (see DECCO-BACKLOG: TR_Anomaly_ValidateMechanisms).
CREATE OR ALTER TRIGGER TR_Facility_ValidateHierarchy
ON Facility
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_FacilityType t ON t.Id = i.FacilityTypeId
         WHERE t.AllowsChildren = 1 AND i.ParentFacilityId IS NOT NULL
    )
        THROW 50410, 'A root-type facility (one that allows children, e.g. SITIO) cannot have a parent facility.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_FacilityType t ON t.Id = i.FacilityTypeId
         WHERE t.AllowsChildren = 0 AND i.ParentFacilityId IS NULL
    )
        THROW 50411, 'A facility of this type needs a parent facility (e.g. a laboratory inside a site).', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Facility p ON p.Id = i.ParentFacilityId
          JOIN Cat_FacilityType tp ON tp.Id = p.FacilityTypeId
         WHERE tp.AllowsChildren = 0
    )
        THROW 50412, 'The parent facility must be of a type that allows children.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_FacilityType t ON t.Id = i.FacilityTypeId
         WHERE t.AllowsChildren = 0
           AND EXISTS (SELECT 1 FROM Facility f WHERE f.ParentFacilityId = i.Id)
    )
        THROW 50413, 'A facility with children cannot change to a type that does not allow children.', 1;
END;
GO
