-- Converging seed (run-always). Natural key: Codigo.
-- The four types were already INSERTED by migration 0002 (which needs them to
-- migrate Laboratorio and SitioContencao). This MERGE only converges name, description and
-- PermiteFilhos — and it is where a NEW type must be added from now on.
MERGE Cat_TipoInstalacao AS target
USING (VALUES
    ('SITIO'         , N'Sítio'            , N'Complexo de contenção autônomo. Raiz da hierarquia: abriga laboratórios, áreas e postos.', 1),
    ('LABORATORIO'   , N'Laboratório'      , N'Unidade de pesquisa dentro de um sítio, com especialidade e responsável.'               , 0),
    ('AREA_CONTENCAO', N'Área de Contenção', N'Ala ou recinto de um sítio dedicado à guarda de anomalias.'                              , 0),
    ('POSTO_AVANCADO', N'Posto Avançado'   , N'Base operacional temporária ou remota, vinculada a um sítio.'                            , 0)
) AS source (Codigo, Nome, Descricao, PermiteFilhos)
    ON target.Codigo = source.Codigo
WHEN MATCHED THEN UPDATE SET target.Nome = source.Nome, target.Descricao = source.Descricao, target.PermiteFilhos = source.PermiteFilhos
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao, PermiteFilhos) VALUES (source.Codigo, source.Nome, source.Descricao, source.PermiteFilhos);
GO
