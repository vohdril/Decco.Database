-- Seed convergente (run-always). Chave natural: Simbolo.
-- FK resolvida por Simbolo da força (não por Id fixo) — sobrevive a reseed.
MERGE Cat_CamadaOntologica AS alvo
USING (
    SELECT v.Simbolo, v.Nome, v.Descricao, f.Id AS ForcaFundamentalId, v.Prioridade
    FROM (VALUES
        ('THETA','THETA','Física Anômala. 95% dos casos. Acessa a "API" da realidade via spin coerente e deutério.','Kappa' ,1),
        ('PSI'  ,'PSI'  ,'Narrativo/Informacional. Opera através de símbolos, histórias e crenças.'                ,'Kappa' ,1),
        ('PHI'  ,'PHI'  ,'Consciência/Digital. A mente diretamente interagindo com a realidade.'                   ,'Kappa' ,1),
        ('OMEGA','OMEGA','Substrato Não-Bariônico. Acesso à "matéria escura" consciente.'                          ,'Lambda',2)
    ) AS v (Simbolo, Nome, Descricao, ForcaSimbolo, Prioridade)
    LEFT JOIN Cat_ForcaFundamental f ON f.Simbolo = v.ForcaSimbolo
) AS origem
    ON alvo.Simbolo = origem.Simbolo
WHEN MATCHED THEN UPDATE SET
    alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao,
    alvo.ForcaFundamentalId = origem.ForcaFundamentalId, alvo.Prioridade = origem.Prioridade
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Simbolo, Nome, Descricao, ForcaFundamentalId, Prioridade)
    VALUES (origem.Simbolo, origem.Nome, origem.Descricao, origem.ForcaFundamentalId, origem.Prioridade);
GO
