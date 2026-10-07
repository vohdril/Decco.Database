-- Seed convergente (run-always). Chave natural: Codigo.
-- NOTA DE CORREÇÃO vs. baseline: o decco.sql original gravava CamadaOntologicaId
-- com os literais 1..4, dependendo da ordem do IDENTITY. Aqui a FK é resolvida
-- pelo Simbolo da camada — o seed converge mesmo se os Ids mudarem.
MERGE Cat_MecanismoInteracao AS alvo
USING (
    SELECT v.Codigo, v.Nome, v.Descricao, c.Id AS CamadaOntologicaId, v.EhSubnatureza
    FROM (VALUES
        ('THETA-A','Theta-Ativo'       ,'Usa ativamente a Força de Anomalia, alterando fisicamente a realidade (Consome deutério). Pirocinese, Crioscinese, fortificação exótica, telecinese são casos comuns','THETA',CAST(0 AS BIT)),
        ('THETA-B','Theta-Passivo'     ,'Propriedade intrínseca. "Spin Congelado" na matéria. Materiais inorganicos, ligas anomalas ou fatores de coerencia concetrados em codificação genética são alguns casos','THETA',CAST(0 AS BIT)),
        ('THETA-C','Theta-Condicional' ,'Ativa sob condições específicas.'                                      ,'THETA',CAST(0 AS BIT)),
        ('PSI-A'  ,'Psi-Ativo'         ,'Força uma narrativa ou conceito sobre a realidade.'                    ,'PSI'  ,CAST(0 AS BIT)),
        ('PSI-B'  ,'Psi-Passivo'       ,'Propriedade intrínseca de um conceito ou informação.'                  ,'PSI'  ,CAST(0 AS BIT)),
        ('PSI-C'  ,'Psi-Condicional'   ,'Ativa-se sob condições narrativas/informacionais.'                     ,'PSI'  ,CAST(1 AS BIT)),
        ('PHI-A'  ,'Phi-Ativo'         ,'Uso ativo da consciência para interagir com a realidade.'              ,'PHI'  ,CAST(0 AS BIT)),
        ('PHI-B'  ,'Phi-Passivo'       ,'Estado consciente que produz efeitos constantes.'                      ,'PHI'  ,CAST(0 AS BIT)),
        ('PHI-C'  ,'Phi-Condicional'   ,'Protocolo consciente ativado por gatilho informacional.'               ,'PHI'  ,CAST(1 AS BIT)),
        ('OMEGA-A','Omega-Ativo'       ,'Acesso direto ao substrato Σ para reescrever regras.'                  ,'OMEGA',CAST(0 AS BIT)),
        ('OMEGA-B','Omega-Passivo'     ,'Emana o substrato Σ passivamente.'                                     ,'OMEGA',CAST(1 AS BIT)),
        ('OMEGA-C','Omega-Condicional' ,'Acesso limitado a Σ através de gatilho.'                               ,'OMEGA',CAST(1 AS BIT))
    ) AS v (Codigo, Nome, Descricao, CamadaSimbolo, EhSubnatureza)
    LEFT JOIN Cat_CamadaOntologica c ON c.Simbolo = v.CamadaSimbolo
) AS origem
    ON alvo.Codigo = origem.Codigo
WHEN MATCHED THEN UPDATE SET
    alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao,
    alvo.CamadaOntologicaId = origem.CamadaOntologicaId, alvo.EhSubnatureza = origem.EhSubnatureza
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao, CamadaOntologicaId, EhSubnatureza)
    VALUES (origem.Codigo, origem.Nome, origem.Descricao, origem.CamadaOntologicaId, origem.EhSubnatureza);
GO
