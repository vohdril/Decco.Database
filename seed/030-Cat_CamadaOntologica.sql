-- Converging seed (run-always). Natural key: Simbolo.
-- FK resolved by the force Simbolo (not by a fixed Id) — survives a reseed.
MERGE Cat_CamadaOntologica AS target
USING (
    SELECT v.Simbolo, v.Nome, v.Descricao, f.Id AS ForcaFundamentalId, v.Prioridade
    FROM (VALUES
        ('THETA','THETA','Física Anômala. 95% dos casos. Acessa a "API" da realidade via spin coerente e deutério.','Kappa' ,1),
        ('PSI'  ,'PSI'  ,'Narrativo/Informacional. Opera através de símbolos, histórias e crenças.'                ,'Kappa' ,1),
        ('PHI'  ,'PHI'  ,'Consciência/Digital. A mente diretamente interagindo com a realidade.'                   ,'Kappa' ,1),
        ('OMEGA','OMEGA','Substrato Não-Bariônico. Acesso à "matéria escura" consciente.'                          ,'Lambda',2)
    ) AS v (Simbolo, Nome, Descricao, ForcaSimbolo, Prioridade)
    LEFT JOIN Cat_ForcaFundamental f ON f.Simbolo = v.ForcaSimbolo
) AS source
    ON target.Simbolo = source.Simbolo
WHEN MATCHED THEN UPDATE SET
    target.Nome = source.Nome, target.Descricao = source.Descricao,
    target.ForcaFundamentalId = source.ForcaFundamentalId, target.Prioridade = source.Prioridade
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Simbolo, Nome, Descricao, ForcaFundamentalId, Prioridade)
    VALUES (source.Simbolo, source.Nome, source.Descricao, source.ForcaFundamentalId, source.Prioridade);
GO
