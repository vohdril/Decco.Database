-- Converging seed (run-always). Natural key: Nome (UNIQUE).
MERGE Cat_TipoMateria AS target
USING (VALUES
    ('Bariônica Anômala','Átomos normais com propriedades anômalas. Pode ser suprimida com tecnologia Theta.',CAST(0 AS BIT)),
    ('Mista'            ,'Parte bariônica, parte não-bariônica. Comportamento imprevisível.'                 ,CAST(0 AS BIT)),
    ('Não-Bariônica'    ,'Não é feita de átomos. Sua forma é um "avatar" do substrato Σ.'                    ,CAST(1 AS BIT)),
    ('Indefinido'       ,'Não sabemos ainda. Geralmente em pesquisa ativa.'                                  ,CAST(0 AS BIT))
) AS source (Nome, Descricao, IsResistenteSupressores)
    ON target.Nome = source.Nome
WHEN MATCHED THEN UPDATE SET
    target.Descricao = source.Descricao, target.IsResistenteSupressores = source.IsResistenteSupressores
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Nome, Descricao, IsResistenteSupressores)
    VALUES (source.Nome, source.Descricao, source.IsResistenteSupressores);
GO
