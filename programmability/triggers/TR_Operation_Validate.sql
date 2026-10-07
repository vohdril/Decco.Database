-- Trigger that validates operation business rules
--
-- Rules:
--   1. A type with RequiresAnomaly = 1 (PESQUISA, SUPRESSAO) requires AnomalyId.
--   2. An inactive type cannot be used in a new operation (nor by changing the type).
--   3. Only an ATIVA facility receives a new operation (nor by changing the facility).
-- Rules 2 and 3 look at `deleted`: in an UPDATE that touches neither the type nor the
-- facility, older operations stay editable even if the type was deactivated or the
-- facility closed afterwards.
--
-- Uses THROW for the same reason as TR_Facility_ValidateHierarchy: it rolls back
-- the invalid operation instead of only warning.
CREATE OR ALTER TRIGGER TR_Operation_Validate
ON Operation
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_OperationType c ON c.Id = i.OperationTypeId
         WHERE c.RequiresAnomaly = 1 AND i.AnomalyId IS NULL
    )
        THROW 50420, 'This operation type requires a cataloged anomaly (AnomalyId).', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_OperationType c ON c.Id = i.OperationTypeId
          LEFT JOIN deleted d ON d.Id = i.Id
         WHERE c.IsActive = 0
           AND (d.Id IS NULL OR d.OperationTypeId <> i.OperationTypeId)
    )
        THROW 50421, 'An inactive operation type cannot be used in a new operation.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Facility inst ON inst.Id = i.FacilityId
          LEFT JOIN deleted d ON d.Id = i.Id
         WHERE inst.Status <> 'ATIVA'
           AND (d.Id IS NULL OR d.FacilityId <> i.FacilityId)
    )
        THROW 50422, 'Only an ATIVA facility can receive a new operation.', 1;
END;
GO
