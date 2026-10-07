-- Dados de exemplo - Laboratorios (decco.sql secao 11A)
-- Run-always, mas GUARDADO: so insere se ainda nao existir. Rodar duas vezes e inofensivo.
IF NOT EXISTS (SELECT 1 FROM Laboratorio WHERE Codigo = 'LAB-BIO-19')
BEGIN
    PRINT 'seed/exemplos: inserindo laboratorios';

    -- =============================================
    -- SEÇÃO 11: INSERÇÃO DE DADOS DE EXEMPLO
    -- =============================================

    -- =============================================
    -- SEÇÃO 11A: DADOS DE EXEMPLO — LABORATÓRIOS
    -- =============================================
    EXEC sp_Laboratorio_Inserir @Codigo='LAB-BIO-19', @Nome='Setor de Biologia Anômala', @Sitio='Sítio-19', @Responsavel='Dra. Elara Vance', @Especialidade='Biologia Anômala';
    EXEC sp_Laboratorio_Inserir @Codigo='LAB-SPIN-64', @Nome='Laboratório de Spin Coerente', @Sitio='Sítio-64', @Responsavel='Dr. Aris Thoth', @Especialidade='Física Quântica';
    EXEC sp_Laboratorio_Inserir @Codigo='LAB-PSI-07', @Nome='Câmara de Ressonância Psi', @Sitio='Sítio-07', @Responsavel='Dr. Marcus Bell', @Especialidade='Narratologia';
END
ELSE
    PRINT 'seed/exemplos: laboratorios ja existe - pulando.';
GO