-- Dados de exemplo - Notificacoes de campo (decco.sql secao 11C)
-- Run-always, mas GUARDADO: so insere se ainda nao existir. Rodar duas vezes e inofensivo.
IF NOT EXISTS (SELECT 1 FROM NotificacaoAnomalia WHERE Titulo = N'Flutuação Theta no Sítio-19')
BEGIN
    PRINT 'seed/exemplos: inserindo notificacoes';

    -- =============================================
    -- SEÇÃO 11C: DADOS DE EXEMPLO — NOTIFICAÇÕES
    -- =============================================
    EXEC sp_NotificacaoAnomalia_Inserir @Titulo='Flutuação Theta no Sítio-19', @Descricao='Sensor IEIA-D detectou flutuação acima de 0.3% no perímetro oeste. Possível nova anomalia não catalogada.', @LocalIdentificado='Sítio-19, Perímetro Oeste', @NivelPrioridade=3, @Relator='Sistema Automático';
    EXEC sp_NotificacaoAnomalia_Inserir @Titulo='Evento Psi não identificado', @Descricao='Relato de sonhos compartilhados entre 12 funcionários do Sítio-64. Possível entidade onírica em formação.', @LocalIdentificado='Sítio-64, Alojamento Funcionários', @NivelPrioridade=4, @Relator='Dr. Aris Thoth';
END
ELSE
    PRINT 'seed/exemplos: notificacoes ja existe - pulando.';
GO