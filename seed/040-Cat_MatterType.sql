-- Converging seed (run-always). Natural key: Name (UNIQUE).
MERGE Cat_MatterType AS target
USING (VALUES
    ('Bariônica Anômala','Átomos normais com propriedades anômalas. Pode ser suprimida com tecnologia Theta.',CAST(0 AS BIT)),
    ('Mista'            ,'Parte bariônica, parte não-bariônica. Comportamento imprevisível.'                 ,CAST(0 AS BIT)),
    ('Não-Bariônica'    ,'Não é feita de átomos. Sua forma é um "avatar" do substrato Σ.'                    ,CAST(1 AS BIT)),
    ('Indefinido'       ,'Não sabemos ainda. Geralmente em pesquisa ativa.'                                  ,CAST(0 AS BIT))
) AS source (Name, Description, IsSuppressorResistant)
    ON target.Name = source.Name
WHEN MATCHED THEN UPDATE SET
    target.Description = source.Description, target.IsSuppressorResistant = source.IsSuppressorResistant
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Name, Description, IsSuppressorResistant)
    VALUES (source.Name, source.Description, source.IsSuppressorResistant);
GO
