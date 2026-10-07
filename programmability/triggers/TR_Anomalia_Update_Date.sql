-- Trigger para atualizar DataAtualizacao automaticamente
CREATE OR ALTER TRIGGER TR_Anomalia_Update_Date
ON Anomalia
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Anomalia
    SET DataAtualizacao = GETDATE(),
        UsuarioAtualizacao = SYSTEM_USER
    FROM Anomalia a
    INNER JOIN inserted i ON a.Id = i.Id;
END;
GO
