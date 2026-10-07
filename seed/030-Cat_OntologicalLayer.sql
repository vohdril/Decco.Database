-- Converging seed (run-always). Natural key: Symbol.
-- FK resolved by the force Symbol (not by a fixed Id) — survives a reseed.
MERGE Cat_OntologicalLayer AS target
USING (
    SELECT v.Symbol, v.Name, v.Description, f.Id AS FundamentalForceId, v.Priority
    FROM (VALUES
        ('THETA','THETA','Física Anômala. 95% dos casos. Acessa a "API" da realidade via spin coerente e deutério.','Kappa' ,1),
        ('PSI'  ,'PSI'  ,'Narrativo/Informacional. Opera através de símbolos, histórias e crenças.'                ,'Kappa' ,1),
        ('PHI'  ,'PHI'  ,'Consciência/Digital. A mente diretamente interagindo com a realidade.'                   ,'Kappa' ,1),
        ('OMEGA','OMEGA','Substrato Não-Bariônico. Acesso à "matéria escura" consciente.'                          ,'Lambda',2)
    ) AS v (Symbol, Name, Description, ForceSymbol, Priority)
    LEFT JOIN Cat_FundamentalForce f ON f.Symbol = v.ForceSymbol
) AS source
    ON target.Symbol = source.Symbol
WHEN MATCHED THEN UPDATE SET
    target.Name = source.Name, target.Description = source.Description,
    target.FundamentalForceId = source.FundamentalForceId, target.Priority = source.Priority
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Symbol, Name, Description, FundamentalForceId, Priority)
    VALUES (source.Symbol, source.Name, source.Description, source.FundamentalForceId, source.Priority);
GO
