-- Example data - Field notifications (decco.sql section 11C)
-- Run-always, but GUARDED: inserts only if it does not exist yet. Running it twice is harmless.
-- @InstalacaoId points to the SITE (not to the area): the same link that
-- migration 0002 creates in an adopted database - LocalIdentificado keeps the detail.
IF NOT EXISTS (SELECT 1 FROM NotificacaoAnomalia WHERE Titulo = N'Flutuação Theta no Sítio-19')
BEGIN
    PRINT 'seed/examples: inserting notifications';

    DECLARE @Sitio19 INT = (SELECT Id FROM Instalacao WHERE Codigo = 'SITIO-19');
    DECLARE @Sitio64 INT = (SELECT Id FROM Instalacao WHERE Codigo = 'SITIO-64');

    -- =============================================
    -- SECTION 11C: EXAMPLE DATA — NOTIFICATIONS
    -- =============================================
    EXEC sp_NotificacaoAnomalia_Inserir @Titulo='Flutuação Theta no Sítio-19', @Descricao='Sensor IEIA-D detectou flutuação acima de 0.3% no perímetro oeste. Possível nova anomalia não catalogada.', @LocalIdentificado='Sítio-19, Perímetro Oeste', @NivelPrioridade=3, @Relator='Sistema Automático', @InstalacaoId=@Sitio19;
    EXEC sp_NotificacaoAnomalia_Inserir @Titulo='Evento Psi não identificado', @Descricao='Relato de sonhos compartilhados entre 12 funcionários do Sítio-64. Possível entidade onírica em formação.', @LocalIdentificado='Sítio-64, Alojamento Funcionários', @NivelPrioridade=4, @Relator='Dr. Aris Thoth', @InstalacaoId=@Sitio64;
END
ELSE
    PRINT 'seed/examples: notifications already exist - skipping.';
GO
