-- Dados de exemplo - Protocolos de contencao (decco.sql secao 11B)
-- Run-always, mas GUARDADO: so insere se ainda nao existir. Rodar duas vezes e inofensivo.
IF NOT EXISTS (SELECT 1 FROM ProtocoloContencao WHERE Codigo = 'PROT-BIO-STD')
BEGIN
    PRINT 'seed/exemplos: inserindo protocolos';

    -- =============================================
    -- SEÇÃO 11B: DADOS DE EXEMPLO — PROTOCOLOS
    -- =============================================
    INSERT INTO ProtocoloContencao (Codigo, Titulo, Descricao, NivelUrgencia, ClassesAplicaveis, Passos, RecursosNecessarios) VALUES
    ('PROT-BIO-STD', 'Protocolo Padrão de Conteção Biológica', 'Procedimentos padrão para entidades biológicas anômalas de baixo risco.', 2, 'PACATO,YAGUARA',
     '1. Isolar o perímetro de 50m.\n2. Equipe de contenção nível 2.\n3. Conter com rede de spin bloqueador.\n4. Transporte em container climatizado.\n5. Avaliação psiquiátrica pós-contenção.',
     'Rede de spin bloqueador, container classe II, tranqüilizante B-47'),
    ('PROT-OMEGA-CRIT', 'Protocolo Sigma — Contenção de Emergência OMEGA', 'Procedimento de contenção para anomalias de camada OMEGA em estado crítico.', 5, 'UKAR,ABAPORU',
     '1. Evacuar raio de 5km.\n2. Acionar Equipe Theta-9.\n3. Ativar geradores de campo Kappa.\n4. Estabelecer perímetro de segurança nível 5.\n5. Contato com Conselho O5 imediato.',
     'Gerador de campo Kappa, equipe Theta-9, autorização nível 5'),
    ('PROT-PSI-PESQ', 'Protocolo de Pesquisa Narrativa', 'Procedimentos para interação com anomalias de causalidade narrativa.', 3, 'YAGUARA,ABAPORU',
     '1. Estabelecer barreira informacional.\n2. Apenas pesquisador designado pode interagir.\n3. Registrar toda interação em diário ontológico.\n4. Nunca revelar o nome verdadeiro da anomalia.\n5. Sessões limitadas a 30 min.',
     'Diário ontológico, gravador de campo Psi, bloqueador de memória');
END
ELSE
    PRINT 'seed/exemplos: protocolos ja existe - pulando.';
GO