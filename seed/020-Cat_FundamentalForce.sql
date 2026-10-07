-- Converging seed (run-always). Natural key: Symbol.
MERGE Cat_FundamentalForce AS target
USING (VALUES
    ('Kappa' ,'Kappa' ,'Campo de Coerência Informacional. Força que permite a manifestação de narrativas e conceitos abstratos na realidade física.','Áxion'),
    ('Lambda','Lambda','Substrato Não-Bariônico Consciente. A "matéria escura" consciente que fundamenta as outras forças.'                        ,'Não-bariônico')
) AS source (Symbol, Name, Description, CarrierParticle)
    ON target.Symbol = source.Symbol
WHEN MATCHED THEN UPDATE SET
    target.Name = source.Name, target.Description = source.Description, target.CarrierParticle = source.CarrierParticle
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Symbol, Name, Description, CarrierParticle)
    VALUES (source.Symbol, source.Name, source.Description, source.CarrierParticle);
GO
