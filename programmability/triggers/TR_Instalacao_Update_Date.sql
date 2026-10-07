-- Trigger that keeps DataAtualizacao/UsuarioAtualizacao up to date automatically
-- Same pattern as TR_Anomalia_Update_Date. Instalacao is born with user auditing
-- (DECCO-BACKLOG, finding 5: until now only Anomalia had it).
CREATE OR ALTER TRIGGER TR_Instalacao_Update_Date
ON Instalacao
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Instalacao
    SET DataAtualizacao = GETDATE(),
        UsuarioAtualizacao = SYSTEM_USER
    FROM Instalacao t
    INNER JOIN inserted i ON t.Id = i.Id;
END;
GO
