-- Trigger para atualizar DataAtualizacao/UsuarioAtualizacao automaticamente
-- Mesmo padrão de TR_Anomalia_Update_Date. Instalacao já nasce com auditoria de
-- usuário (DECCO-BACKLOG, achado 5: até aqui só Anomalia tinha).
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
