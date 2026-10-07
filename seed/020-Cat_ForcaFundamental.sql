-- Seed convergente (run-always). Chave natural: Simbolo.
MERGE Cat_ForcaFundamental AS alvo
USING (VALUES
    ('Kappa' ,'Kappa' ,'Campo de Coerência Informacional. Força que permite a manifestação de narrativas e conceitos abstratos na realidade física.','Áxion'),
    ('Lambda','Lambda','Substrato Não-Bariônico Consciente. A "matéria escura" consciente que fundamenta as outras forças.'                        ,'Não-bariônico')
) AS origem (Simbolo, Nome, Descricao, ParticulaPortadora)
    ON alvo.Simbolo = origem.Simbolo
WHEN MATCHED THEN UPDATE SET
    alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao, alvo.ParticulaPortadora = origem.ParticulaPortadora
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Simbolo, Nome, Descricao, ParticulaPortadora)
    VALUES (origem.Simbolo, origem.Nome, origem.Descricao, origem.ParticulaPortadora);
GO
