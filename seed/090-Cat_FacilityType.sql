-- Converging seed (run-always). Natural key: Code.
-- The four types were already INSERTED by migration 0002 (which needs them to
-- migrate Laboratorio and SitioContencao). This MERGE only converges name, description and
-- AllowsChildren — and it is where a NEW type must be added from now on.
MERGE Cat_FacilityType AS target
USING (VALUES
    ('SITIO'         , N'Sítio'            , N'Complexo de contenção autônomo. Raiz da hierarquia: abriga laboratórios, áreas e postos.', 1),
    ('LABORATORIO'   , N'Laboratório'      , N'Unidade de pesquisa dentro de um sítio, com especialidade e responsável.'               , 0),
    ('AREA_CONTENCAO', N'Área de Contenção', N'Ala ou recinto de um sítio dedicado à guarda de anomalias.'                              , 0),
    ('POSTO_AVANCADO', N'Posto Avançado'   , N'Base operacional temporária ou remota, vinculada a um sítio.'                            , 0)
) AS source (Code, Name, Description, AllowsChildren)
    ON target.Code = source.Code
WHEN MATCHED THEN UPDATE SET target.Name = source.Name, target.Description = source.Description, target.AllowsChildren = source.AllowsChildren
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Code, Name, Description, AllowsChildren) VALUES (source.Code, source.Name, source.Description, source.AllowsChildren);
GO
