-- Seed convergente (run-always). Chave natural: Codigo.
-- Sem cláusula DELETE: linhas acrescentadas manualmente sobrevivem.
MERGE Cat_ClasseObjeto AS alvo
USING (VALUES
    ('PACATO' ,'Pacato' ,'Primária','SAFE'    ,'Anomalia contida de forma confiável com procedimentos padrão.',1,'#4CAF50'),
    ('YAGUARA','Yaguara','Primária','EUCLID'  ,'Anomalia imprevisível que requer atenção constante.'          ,2,'#FFC107'),
    ('ABAPORU','Abaporu','Primária','KETER'   ,'Extremamente difícil de conter, risco catastrófico.'          ,3,'#F44336'),
    ('UKAR'   ,'Ukar'   ,'Primária','THAUMIEL','Usada para conter outras anomalias. O segredo dos segredos.'  ,4,'#9C27B0')
) AS origem (Codigo, Nome, TipoClasse, ClasseACS, Descricao, NivelAcessoMinimo, CorAlerta)
    ON alvo.Codigo = origem.Codigo
WHEN MATCHED THEN UPDATE SET
    alvo.Nome = origem.Nome, alvo.TipoClasse = origem.TipoClasse, alvo.ClasseACS = origem.ClasseACS,
    alvo.Descricao = origem.Descricao, alvo.NivelAcessoMinimo = origem.NivelAcessoMinimo, alvo.CorAlerta = origem.CorAlerta
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, TipoClasse, ClasseACS, Descricao, NivelAcessoMinimo, CorAlerta)
    VALUES (origem.Codigo, origem.Nome, origem.TipoClasse, origem.ClasseACS, origem.Descricao, origem.NivelAcessoMinimo, origem.CorAlerta);
GO
