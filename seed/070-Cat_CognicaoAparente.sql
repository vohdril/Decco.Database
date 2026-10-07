-- Converging seed (run-always). Natural key: Codigo.
MERGE Cat_CognicaoAparente AS target
USING (VALUES
    ('SE','Sensciente'      ,N'Possui nível de inteligência e cognição aferidos.'),
    ('SA','Sapiente'        ,N'Possui nível de sapiencia aferido, independente de manifestação cultural.'),
    ('IN','Inanimado'       ,N'Sem vontade própria aferida.'),
    ('AA','Autômato Anômalo',N'Entidade com aparente autonomia e comportamento autômato.')
) AS source (Codigo, Nome, Descricao)
    ON target.Codigo = source.Codigo
WHEN MATCHED THEN UPDATE SET target.Nome = source.Nome, target.Descricao = source.Descricao
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao) VALUES (source.Codigo, source.Nome, source.Descricao);
GO
