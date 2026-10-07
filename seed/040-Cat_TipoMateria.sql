-- Seed convergente (run-always). Chave natural: Nome (é UNIQUE).
MERGE Cat_TipoMateria AS alvo
USING (VALUES
    ('Bariônica Anômala','Átomos normais com propriedades anômalas. Pode ser suprimida com tecnologia Theta.',CAST(0 AS BIT)),
    ('Mista'            ,'Parte bariônica, parte não-bariônica. Comportamento imprevisível.'                 ,CAST(0 AS BIT)),
    ('Não-Bariônica'    ,'Não é feita de átomos. Sua forma é um "avatar" do substrato Σ.'                    ,CAST(1 AS BIT)),
    ('Indefinido'       ,'Não sabemos ainda. Geralmente em pesquisa ativa.'                                  ,CAST(0 AS BIT))
) AS origem (Nome, Descricao, IsResistenteSupressores)
    ON alvo.Nome = origem.Nome
WHEN MATCHED THEN UPDATE SET
    alvo.Descricao = origem.Descricao, alvo.IsResistenteSupressores = origem.IsResistenteSupressores
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Nome, Descricao, IsResistenteSupressores)
    VALUES (origem.Nome, origem.Descricao, origem.IsResistenteSupressores);
GO
