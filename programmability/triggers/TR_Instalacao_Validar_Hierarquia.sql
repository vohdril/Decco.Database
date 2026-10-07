-- Trigger para validar a hierarquia de instalações
--
-- Regras (derivadas de Cat_TipoInstalacao.PermiteFilhos):
--   1. Tipo que PERMITE filhos (SITIO) é raiz: não tem pai.
--   2. Tipo que NÃO permite filhos (LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO)
--      precisa de pai.
--   3. O pai precisa ser de um tipo que permite filhos.
--   4. Uma instalação com filhos não pode mudar para um tipo sem filhos.
-- Consequência: a hierarquia tem profundidade máxima 2 e não admite ciclos —
-- sp_Operacao_Buscar depende disso para não precisar de CTE recursiva.
--
-- Usa THROW, não RAISERROR: dentro de um trigger, THROW aborta o lote e DESFAZ
-- a transação, incluindo o INSERT/UPDATE que disparou o trigger. RAISERROR
-- seguido de RETURN apenas devolve o erro ao cliente — a linha inválida fica
-- gravada (ver DECCO-BACKLOG: TR_Anomalia_Validar_Mecanismos).
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
        THROW 50410, 'Instalação de tipo raiz (que permite filhos, ex.: SITIO) não pode ter instalação-pai.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_TipoInstalacao t ON t.Id = i.TipoInstalacaoId
         WHERE t.PermiteFilhos = 0 AND i.InstalacaoPaiId IS NULL
    )
        THROW 50411, 'Instalação deste tipo precisa de uma instalação-pai (ex.: laboratório dentro de um sítio).', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Instalacao p ON p.Id = i.InstalacaoPaiId
          JOIN Cat_TipoInstalacao tp ON tp.Id = p.TipoInstalacaoId
         WHERE tp.PermiteFilhos = 0
    )
        THROW 50412, 'A instalação-pai precisa ser de um tipo que permite filhos.', 1;

    IF EXISTS (
        SELECT 1
          FROM inserted i
          JOIN Cat_TipoInstalacao t ON t.Id = i.TipoInstalacaoId
         WHERE t.PermiteFilhos = 0
           AND EXISTS (SELECT 1 FROM Instalacao f WHERE f.InstalacaoPaiId = i.Id)
    )
        THROW 50413, 'Instalação com filhos não pode mudar para um tipo que não permite filhos.', 1;
END;
GO
