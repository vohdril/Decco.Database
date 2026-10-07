-- Converging seed (run-always). Natural key: Code.
MERGE Cat_ApparentCognition AS target
USING (VALUES
    ('SE','Sensciente'      ,N'Possui nível de inteligência e cognição aferidos.'),
    ('SA','Sapiente'        ,N'Possui nível de sapiencia aferido, independente de manifestação cultural.'),
    ('IN','Inanimado'       ,N'Sem vontade própria aferida.'),
    ('AA','Autômato Anômalo',N'Entidade com aparente autonomia e comportamento autômato.')
) AS source (Code, Name, Description)
    ON target.Code = source.Code
WHEN MATCHED THEN UPDATE SET target.Name = source.Name, target.Description = source.Description
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Code, Name, Description) VALUES (source.Code, source.Name, source.Description);
GO
