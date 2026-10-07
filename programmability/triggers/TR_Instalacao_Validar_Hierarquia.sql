-- Trigger that validates the facility hierarchy
--
-- Rules (derived from Cat_TipoInstalacao.PermiteFilhos):
--   1. A type that ALLOWS children (SITIO) is a root: it has no parent.
--   2. A type that does NOT allow children (LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO)
--      needs a parent.
--   3. The parent must be of a type that allows children.
--   4. A facility with children cannot change to a type without children.
-- Consequence: the hierarchy has a maximum depth of 2 and allows no cycles —
-- sp_Operacao_Buscar relies on this to avoid a recursive CTE.
--
-- Uses THROW, not RAISERROR: inside a trigger, THROW aborts the batch and ROLLS BACK
-- the transaction, including the INSERT/UPDATE that fired the trigger. RAISERROR
-- followed by RETURN only sends the error to the client — the invalid row stays
-- written (see DECCO-BACKLOG: TR_Anomalia_Validar_Mecanismos).
CREATE OR ALTER TRIGGER TR_Instalacao_Validar_Hierarquia
ON Instalacao
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_TipoInstalacao t ON t.Id = i.TipoInstalacaoId
         WHERE t.PermiteFilhos = 1 AND i.InstalacaoPaiId IS NOT NULL
    )
        THROW 50410, 'A root-type facility (one that allows children, e.g. SITIO) cannot have a parent facility.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_TipoInstalacao t ON t.Id = i.TipoInstalacaoId
         WHERE t.PermiteFilhos = 0 AND i.InstalacaoPaiId IS NULL
    )
        THROW 50411, 'A facility of this type needs a parent facility (e.g. a laboratory inside a site).', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Instalacao p ON p.Id = i.InstalacaoPaiId
          JOIN Cat_TipoInstalacao tp ON tp.Id = p.TipoInstalacaoId
         WHERE tp.PermiteFilhos = 0
    )
        THROW 50412, 'The parent facility must be of a type that allows children.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_TipoInstalacao t ON t.Id = i.TipoInstalacaoId
         WHERE t.PermiteFilhos = 0
           AND EXISTS (SELECT 1 FROM Instalacao f WHERE f.InstalacaoPaiId = i.Id)
    )
        THROW 50413, 'A facility with children cannot change to a type that does not allow children.', 1;
END;
GO
