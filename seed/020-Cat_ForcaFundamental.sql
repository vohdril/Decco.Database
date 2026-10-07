-- Converging seed (run-always). Natural key: Simbolo.
MERGE Cat_ForcaFundamental AS target
USING (VALUES
    ('Kappa' ,'Kappa' ,'Campo de Coerência Informacional. Força que permite a manifestação de narrativas e conceitos abstratos na realidade física.','Áxion'),
    ('Lambda','Lambda','Substrato Não-Bariônico Consciente. A "matéria escura" consciente que fundamenta as outras forças.'                        ,'Não-bariônico')
) AS source (Simbolo, Nome, Descricao, ParticulaPortadora)
    ON target.Simbolo = source.Simbolo
WHEN MATCHED THEN UPDATE SET
    target.Nome = source.Nome, target.Descricao = source.Descricao, target.ParticulaPortadora = source.ParticulaPortadora
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Simbolo, Nome, Descricao, ParticulaPortadora)
    VALUES (source.Simbolo, source.Nome, source.Descricao, source.ParticulaPortadora);
GO
