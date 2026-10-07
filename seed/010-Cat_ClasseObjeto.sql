-- Converging seed (run-always). Natural key: Codigo.
-- No DELETE clause: rows added by hand survive.
MERGE Cat_ClasseObjeto AS target
USING (VALUES
    ('PACATO' ,'Pacato' ,'Primária','SAFE'    ,'Anomalia contida de forma confiável com procedimentos padrão.',1,'#4CAF50'),
    ('YAGUARA','Yaguara','Primária','EUCLID'  ,'Anomalia imprevisível que requer atenção constante.'          ,2,'#FFC107'),
    ('ABAPORU','Abaporu','Primária','KETER'   ,'Extremamente difícil de conter, risco catastrófico.'          ,3,'#F44336'),
    ('UKAR'   ,'Ukar'   ,'Primária','THAUMIEL','Usada para conter outras anomalias. O segredo dos segredos.'  ,4,'#9C27B0')
) AS source (Codigo, Nome, TipoClasse, ClasseACS, Descricao, NivelAcessoMinimo, CorAlerta)
    ON target.Codigo = source.Codigo
WHEN MATCHED THEN UPDATE SET
    target.Nome = source.Nome, target.TipoClasse = source.TipoClasse, target.ClasseACS = source.ClasseACS,
    target.Descricao = source.Descricao, target.NivelAcessoMinimo = source.NivelAcessoMinimo, target.CorAlerta = source.CorAlerta
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, TipoClasse, ClasseACS, Descricao, NivelAcessoMinimo, CorAlerta)
    VALUES (source.Codigo, source.Nome, source.TipoClasse, source.ClasseACS, source.Descricao, source.NivelAcessoMinimo, source.CorAlerta);
GO
