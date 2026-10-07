-- Converging seed (run-always). Natural key: Code.
-- CORRECTION NOTE vs. baseline: the original decco.sql wrote OntologicalLayerId
-- as the literals 1..4, relying on the IDENTITY order. Here the FK is resolved
-- by the layer Symbol — the seed converges even if the Ids change.
MERGE Cat_InteractionMechanism AS target
USING (
    SELECT v.Code, v.Name, v.Description, c.Id AS OntologicalLayerId, v.IsSubNature
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
    ) AS v (Code, Name, Description, LayerSymbol, IsSubNature)
    LEFT JOIN Cat_OntologicalLayer c ON c.Symbol = v.LayerSymbol
) AS source
    ON target.Code = source.Code
WHEN MATCHED THEN UPDATE SET
    target.Name = source.Name, target.Description = source.Description,
    target.OntologicalLayerId = source.OntologicalLayerId, target.IsSubNature = source.IsSubNature
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Code, Name, Description, OntologicalLayerId, IsSubNature)
    VALUES (source.Code, source.Name, source.Description, source.OntologicalLayerId, source.IsSubNature);
GO
