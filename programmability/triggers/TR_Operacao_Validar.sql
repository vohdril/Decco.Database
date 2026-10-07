-- Trigger that validates operation business rules
--
-- Rules:
--   1. A type with RequerAnomalia = 1 (PESQUISA, SUPRESSAO) requires AnomaliaId.
--   2. An inactive type cannot be used in a new operation (nor by changing the type).
--   3. Only an ATIVA facility receives a new operation (nor by changing the facility).
-- Rules 2 and 3 look at `deleted`: in an UPDATE that touches neither the type nor the
-- facility, older operations stay editable even if the type was deactivated or the
-- facility closed afterwards.
--
-- Uses THROW for the same reason as TR_Instalacao_Validar_Hierarquia: it rolls back
-- the invalid operation instead of only warning.
CREATE OR ALTER TRIGGER TR_Operacao_Validar
ON Operacao
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_Operacao c ON c.Id = i.TipoOperacaoId
         WHERE c.RequerAnomalia = 1 AND i.AnomaliaId IS NULL
    )
        THROW 50420, 'This operation type requires a cataloged anomaly (AnomaliaId).', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_Operacao c ON c.Id = i.TipoOperacaoId
          LEFT JOIN deleted d ON d.Id = i.Id
         WHERE c.Ativo = 0
           AND (d.Id IS NULL OR d.TipoOperacaoId <> i.TipoOperacaoId)
    )
        THROW 50421, 'An inactive operation type cannot be used in a new operation.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Instalacao inst ON inst.Id = i.InstalacaoId
          LEFT JOIN deleted d ON d.Id = i.Id
         WHERE inst.Status <> 'ATIVA'
           AND (d.Id IS NULL OR d.InstalacaoId <> i.InstalacaoId)
    )
        THROW 50422, 'Only an ATIVA facility can receive a new operation.', 1;
END;
GO
