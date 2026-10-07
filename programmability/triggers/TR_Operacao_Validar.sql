-- Trigger para validar regras de negócio da operação
--
-- Regras:
--   1. Tipo com RequerAnomalia = 1 (PESQUISA, SUPRESSAO) exige AnomaliaId.
--   2. Tipo inativo não pode ser usado em operação nova (nem por troca de tipo).
--   3. Só instalação ATIVA recebe operação nova (nem por troca de instalação).
-- As regras 2 e 3 olham para `deleted`: num UPDATE que não mexe no tipo nem na
-- instalação, operações antigas continuam editáveis mesmo que o tipo tenha sido
-- desativado ou a instalação encerrada depois.
--
-- Usa THROW pelo mesmo motivo de TR_Instalacao_Validar_Hierarquia: desfaz a
-- operação inválida em vez de só avisar.
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
        THROW 50420, 'Este tipo de operação exige uma anomalia catalogada (AnomaliaId).', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_Operacao c ON c.Id = i.TipoOperacaoId
          LEFT JOIN deleted d ON d.Id = i.Id
         WHERE c.Ativo = 0
           AND (d.Id IS NULL OR d.TipoOperacaoId <> i.TipoOperacaoId)
    )
        THROW 50421, 'Tipo de operação inativo não pode ser usado em operação nova.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Instalacao inst ON inst.Id = i.InstalacaoId
          LEFT JOIN deleted d ON d.Id = i.Id
         WHERE inst.Status <> 'ATIVA'
           AND (d.Id IS NULL OR d.InstalacaoId <> i.InstalacaoId)
    )
        THROW 50422, 'Só uma instalação ATIVA pode receber operação nova.', 1;
END;
GO
