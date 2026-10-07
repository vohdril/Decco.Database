-- Dados de exemplo - Operacoes (novas na 0003; nao existiam no decco.sql)
-- Run-always, mas GUARDADO: so insere se ainda nao existir. Rodar duas vezes e inofensivo.
--
-- Montadas para exercitar o RECORTE POR INSTALACAO:
--   escopo SITIO-19 (com filhas) -> OP-2026-0001, OP-2026-0002
--   escopo SITIO-64 (com filhas) -> OP-2026-0003, OP-2026-0004
--   escopo LAB-BIO-19            -> OP-2026-0002
-- e o recorte por CLEARANCE: niveis 1, 2, 4 e 2.
-- Codigos explicitos (e nao gerados) para que o exemplo seja deterministico.
IF NOT EXISTS (SELECT 1 FROM Operacao WHERE Codigo = 'OP-2026-0001')
BEGIN
    PRINT 'seed/exemplos: inserindo operacoes';

    DECLARE @Investigacao INT = (SELECT Id FROM Cat_Operacao WHERE Codigo = 'INVESTIGACAO');
    DECLARE @Pesquisa     INT = (SELECT Id FROM Cat_Operacao WHERE Codigo = 'PESQUISA');
    DECLARE @Supressao    INT = (SELECT Id FROM Cat_Operacao WHERE Codigo = 'SUPRESSAO');

    DECLARE @Sitio19 INT = (SELECT Id FROM Instalacao WHERE Codigo = 'SITIO-19');
    DECLARE @Sitio64 INT = (SELECT Id FROM Instalacao WHERE Codigo = 'SITIO-64');
    DECLARE @LabBio  INT = (SELECT Id FROM Instalacao WHERE Codigo = 'LAB-BIO-19');
    DECLARE @Area001 INT = (SELECT Id FROM Instalacao WHERE Codigo = 'AREA-001');

    DECLARE @Scp1001 INT = (SELECT Id FROM Anomalia WHERE CodigoSCP = 'SCP-1001');
    DECLARE @Scp1002 INT = (SELECT Id FROM Anomalia WHERE CodigoSCP = 'SCP-1002');

    DECLARE @NotifTheta INT = (SELECT Id FROM NotificacaoAnomalia WHERE Titulo = N'Flutuação Theta no Sítio-19');
    DECLARE @NotifPsi   INT = (SELECT Id FROM NotificacaoAnomalia WHERE Titulo = N'Evento Psi não identificado');

    DECLARE @ProtOmega INT = (SELECT Id FROM ProtocoloContencao WHERE Codigo = 'PROT-OMEGA-CRIT');

    DECLARE @Novo TABLE (NovoId INT, CodigoFormatado VARCHAR(20));

    INSERT INTO @Novo EXEC sp_Operacao_Inserir
        @Codigo = 'OP-2026-0001', @Codinome = N'Jaguar Silente',
        @TipoOperacaoId = @Investigacao, @InstalacaoId = @Sitio19, @NotificacaoId = @NotifTheta,
        @Objetivo = N'Apurar a flutuação de IEIA-D acima de 0,3% no perímetro oeste e determinar se há anomalia não catalogada.',
        @Prioridade = 3, @NivelAcessoMinimo = 1, @Responsavel = N'Dra. Elara Vance';

    INSERT INTO @Novo EXEC sp_Operacao_Inserir
        @Codigo = 'OP-2026-0002', @Codinome = N'Espelho de Proteu',
        @TipoOperacaoId = @Pesquisa, @InstalacaoId = @LabBio, @AnomaliaId = @Scp1001,
        @Objetivo = N'Mapear o limite de variação de massa entre formas do SCP-1001 e a latência de transformação.',
        @Prioridade = 3, @NivelAcessoMinimo = 2, @Responsavel = N'Dra. Elara Vance';

    INSERT INTO @Novo EXEC sp_Operacao_Inserir
        @Codigo = 'OP-2026-0003', @Codinome = N'Silêncio do Codex',
        @TipoOperacaoId = @Supressao, @InstalacaoId = @Area001, @AnomaliaId = @Scp1002, @ProtocoloId = @ProtOmega,
        @Objetivo = N'Estabilizar a zona de realidade instável deixada pela ativação não autorizada do Codex-Primus.',
        @Prioridade = 5, @NivelAcessoMinimo = 4, @Responsavel = N'Dr. Aris Thoth';

    INSERT INTO @Novo EXEC sp_Operacao_Inserir
        @Codigo = 'OP-2026-0004', @Codinome = N'Sono Partilhado',
        @TipoOperacaoId = @Investigacao, @InstalacaoId = @Sitio64, @NotificacaoId = @NotifPsi,
        @Objetivo = N'Investigar os sonhos compartilhados no alojamento e descartar entidade onírica em formação.',
        @Prioridade = 4, @NivelAcessoMinimo = 2, @Responsavel = N'Dr. Aris Thoth';

    -- Duas ja em andamento: exercita o filtro por Status
    UPDATE Operacao SET Status = 'EM_ANDAMENTO' WHERE Codigo IN ('OP-2026-0001', 'OP-2026-0002');
END
ELSE
    PRINT 'seed/exemplos: operacoes ja existe - pulando.';
GO
