-- Seed convergente (run-always). Chave natural: Codigo.
-- Os quatro tipos já foram INSERIDOS pela migração 0002 (que depende deles para
-- migrar Laboratorio e SitioContencao). Este MERGE só converge nome, descrição e
-- PermiteFilhos — e é onde um tipo NOVO deve ser adicionado daqui em diante.
MERGE Cat_TipoInstalacao AS alvo
USING (VALUES
    ('SITIO'         , N'Sítio'            , N'Complexo de contenção autônomo. Raiz da hierarquia: abriga laboratórios, áreas e postos.', 1),
    ('LABORATORIO'   , N'Laboratório'      , N'Unidade de pesquisa dentro de um sítio, com especialidade e responsável.'               , 0),
    ('AREA_CONTENCAO', N'Área de Contenção', N'Ala ou recinto de um sítio dedicado à guarda de anomalias.'                              , 0),
    ('POSTO_AVANCADO', N'Posto Avançado'   , N'Base operacional temporária ou remota, vinculada a um sítio.'                            , 0)
) AS origem (Codigo, Nome, Descricao, PermiteFilhos)
    ON alvo.Codigo = origem.Codigo
WHEN MATCHED THEN UPDATE SET alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao, alvo.PermiteFilhos = origem.PermiteFilhos
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao, PermiteFilhos) VALUES (origem.Codigo, origem.Nome, origem.Descricao, origem.PermiteFilhos);
GO
