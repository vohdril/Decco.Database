-- Dados de exemplo - Instalacoes (antigos laboratorios da secao 11A do decco.sql)
-- Run-always, mas GUARDADO: so insere se ainda nao existir. Rodar duas vezes e inofensivo.
--
-- Num banco ADOTADO, estas linhas ja existem: a migracao 0002 as criou a partir
-- da antiga tabela Laboratorio e de Anomalia.SitioContencao, e este script pula.
-- Num banco VAZIO, este script recria EXATAMENTE o mesmo estado (mesmos codigos,
-- nomes e hierarquia) - e isso que o ensaio compara.
IF NOT EXISTS (SELECT 1 FROM Instalacao WHERE Codigo = 'SITIO-19')
BEGIN
    PRINT 'seed/exemplos: inserindo instalacoes';

    DECLARE @TipoSitio INT = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'SITIO');
    DECLARE @TipoLab   INT = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'LABORATORIO');
    DECLARE @TipoArea  INT = (SELECT Id FROM Cat_TipoInstalacao WHERE Codigo = 'AREA_CONTENCAO');
    DECLARE @Sitio19 INT, @Sitio64 INT, @Sitio07 INT;
    DECLARE @Novo TABLE (NovoId INT);

    -- Sitios (raiz da hierarquia)
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='SITIO-19', @Nome=N'Sítio-19', @TipoInstalacaoId=@TipoSitio;
    SELECT @Sitio19 = NovoId FROM @Novo; DELETE FROM @Novo;
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='SITIO-64', @Nome=N'Sítio-64', @TipoInstalacaoId=@TipoSitio;
    SELECT @Sitio64 = NovoId FROM @Novo; DELETE FROM @Novo;
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='SITIO-07', @Nome=N'Sítio-07', @TipoInstalacaoId=@TipoSitio;
    SELECT @Sitio07 = NovoId FROM @Novo; DELETE FROM @Novo;

    -- Laboratorios (os 3 da secao 11A, agora filhos do seu sitio)
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='LAB-BIO-19', @Nome=N'Setor de Biologia Anômala', @TipoInstalacaoId=@TipoLab, @InstalacaoPaiId=@Sitio19, @Responsavel=N'Dra. Elara Vance', @Especialidade='Biologia Anômala';
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='LAB-SPIN-64', @Nome=N'Laboratório de Spin Coerente', @TipoInstalacaoId=@TipoLab, @InstalacaoPaiId=@Sitio64, @Responsavel=N'Dr. Aris Thoth', @Especialidade='Física Quântica';
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='LAB-PSI-07', @Nome=N'Câmara de Ressonância Psi', @TipoInstalacaoId=@TipoLab, @InstalacaoPaiId=@Sitio07, @Responsavel=N'Dr. Marcus Bell', @Especialidade='Narratologia';

    -- Area de contencao: o "Biblioteca Proibida" do SitioContencao do SCP-1002
    INSERT INTO @Novo EXEC sp_Instalacao_Inserir @Codigo='AREA-001', @Nome=N'Biblioteca Proibida', @TipoInstalacaoId=@TipoArea, @InstalacaoPaiId=@Sitio64;
END
ELSE
    PRINT 'seed/exemplos: instalacoes ja existe - pulando.';
GO
