-- Converging seed (run-always). Natural key: Nivel (UNIQUE, CHECK 1..9).
MERGE Cat_Periculosidade AS target
USING (VALUES
    (1,'Mínimo'              ,N'Nenhum perigo em quase todas as manifestações.'                    ,'#4CAF50'),
    (2,'Muito Baixo'         ,N'Leve perigo se não conduzido corretamente.'                        ,'#8BC34A'),
    (3,'Baixo I (Atividade)' ,N'Perigo leve ou moderado por definição ontológica.'                 ,'#CDDC39'),
    (4,'Baixo II (Recursos)' ,N'Perigo leve ou moderado em condições geográficas específicas.'     ,'#FFEB3B'),
    (5,'Médio'               ,N'Perigo moderado. Requer treinamento mínimo.'                       ,'#FFC107'),
    (6,'Alto I (Atividade)'  ,N'Alto perigo pela existência ou comportamento da anomalia.'         ,'#FF9800'),
    (7,'Alto II (Recursos)'  ,N'Alto risco mediante condições materiais/geográficas.'              ,'#FF5722'),
    (8,'Muito Alto'          ,N'Risco de romper o Véu/Esquadria. Requer protocolo especial.'       ,'#F44336'),
    (9,'Máximo'              ,N'Nenhum protocolo convencional é esperado funcionar.'               ,'#D32F2F')
) AS source (Nivel, Nome, Descricao, CorAlerta)
    ON target.Nivel = source.Nivel
WHEN MATCHED THEN UPDATE SET target.Nome = source.Nome, target.Descricao = source.Descricao, target.CorAlerta = source.CorAlerta
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Nivel, Nome, Descricao, CorAlerta) VALUES (source.Nivel, source.Nome, source.Descricao, source.CorAlerta);
GO
