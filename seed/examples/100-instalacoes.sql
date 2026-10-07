-- Example data - Facilities (the former laboratories of decco.sql section 11A)
-- Run-always, but GUARDED: inserts only if it does not exist yet. Running it twice is harmless.
--
-- In an ADOPTED database these rows already exist: migration 0002 created them from
-- the former Laboratorio table and Anomalia.SitioContencao, and this script skips.
-- In an EMPTY database this script recreates EXACTLY the same state (same codes,
-- names and hierarchy) - which is what the rehearsal compares.
IF NOT EXISTS (SELECT 1 FROM Instalacao WHERE Codigo = 'SITIO-19')
BEGIN
    PRINT 'seed/examples: inserting facilities';

    DECLARE @TipoSitio INT = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'SITIO');
    DECLARE @TipoLab   INT = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'LABORATORIO');
    DECLARE @TipoArea  INT = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'AREA_CONTENCAO');
    DECLARE @Sitio19 INT, @Sitio64 INT, @Sitio07 INT;
    DECLARE @NewRow TABLE (NovoId INT);

    -- Sites (hierarchy root)
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='SITIO-19', @Nome=N'Sítio-19', @TipoInstalacaoId=@TipoSitio;
    SELECT @Sitio19 = NovoId FROM @NewRow; DELETE FROM @NewRow;
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='SITIO-64', @Nome=N'Sítio-64', @TipoInstalacaoId=@TipoSitio;
    SELECT @Sitio64 = NovoId FROM @NewRow; DELETE FROM @NewRow;
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='SITIO-07', @Nome=N'Sítio-07', @TipoInstalacaoId=@TipoSitio;
    SELECT @Sitio07 = NovoId FROM @NewRow; DELETE FROM @NewRow;

    -- Laboratories (the 3 from section 11A, now children of their site)
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='LAB-BIO-19', @Nome=N'Setor de Biologia Anômala', @TipoInstalacaoId=@TipoLab, @InstalacaoPaiId=@Sitio19, @Responsavel=N'Dra. Elara Vance', @Especialidade='Biologia Anômala';
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='LAB-SPIN-64', @Nome=N'Laboratório de Spin Coerente', @TipoInstalacaoId=@TipoLab, @InstalacaoPaiId=@Sitio64, @Responsavel=N'Dr. Aris Thoth', @Especialidade='Física Quântica';
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='LAB-PSI-07', @Nome=N'Câmara de Ressonância Psi', @TipoInstalacaoId=@TipoLab, @InstalacaoPaiId=@Sitio07, @Responsavel=N'Dr. Marcus Bell', @Especialidade='Narratologia';

    -- Containment area: the "Biblioteca Proibida" from the SCP-1002 SitioContencao
    INSERT INTO @NewRow EXEC sp_Instalacao_Inserir @Codigo='AREA-001', @Nome=N'Biblioteca Proibida', @TipoInstalacaoId=@TipoArea, @InstalacaoPaiId=@Sitio64;
END
ELSE
    PRINT 'seed/examples: facilities already exist - skipping.';
GO
