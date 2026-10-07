-- Trigger para atualizar DataAtualizacao/UsuarioAtualizacao automaticamente
-- Mesmo padrão de TR_Anomalia_Update_Date.
CREATE OR ALTER TRIGGER TR_Operacao_Update_Date
ON Operacao
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Operacao
    SET DataAtualizacao = GETDATE(),
        UsuarioAtualizacao = SYSTEM_USER
    FROM Operacao t
    INNER JOIN inserted i ON t.Id = i.Id;
END;
GO
