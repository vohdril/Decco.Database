-- Converging seed (run-always). Natural key: Level (UNIQUE, CHECK 1..9).
MERGE Cat_DangerLevel AS target
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
) AS source (Level, Name, Description, AlertColor)
    ON target.Level = source.Level
WHEN MATCHED THEN UPDATE SET target.Name = source.Name, target.Description = source.Description, target.AlertColor = source.AlertColor
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Level, Name, Description, AlertColor) VALUES (source.Level, source.Name, source.Description, source.AlertColor);
GO
