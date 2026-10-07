-- Seed convergente (run-always). Chave natural: Codigo.
MERGE Cat_CognicaoAparente AS alvo
USING (VALUES
    ('SE','Sensciente'      ,N'Possui nível de inteligência e cognição aferidos.'),
    ('SA','Sapiente'        ,N'Possui nível de sapiencia aferido, independente de manifestação cultural.'),
    ('IN','Inanimado'       ,N'Sem vontade própria aferida.'),
    ('AA','Autômato Anômalo',N'Entidade com aparente autonomia e comportamento autômato.')
) AS origem (Codigo, Nome, Descricao)
    ON alvo.Codigo = origem.Codigo
WHEN MATCHED THEN UPDATE SET alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao) VALUES (origem.Codigo, origem.Nome, origem.Descricao);
GO
