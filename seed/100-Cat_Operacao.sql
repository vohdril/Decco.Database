-- Seed convergente (run-always). Chave natural: Codigo.
-- Única fonte dos tipos de operação: a migração 0003 cria a tabela vazia, porque
-- nenhuma migração de dados depende destes valores.
MERGE Cat_Operacao AS alvo
USING (VALUES
    ('INVESTIGACAO', N'Investigação', N'Apuração de um fenômeno relatado e ainda não catalogado. Nasce tipicamente de uma notificação de campo.'      , 0, 1, '#2196F3'),
    ('PESQUISA'    , N'Pesquisa'    , N'Estudo controlado de uma anomalia já catalogada: testes, medições de IEIA-D e caracterização de perícias.', 1, 2, '#9C27B0'),
    ('SUPRESSAO'   , N'Supressão'   , N'Ação de contenção ativa ou neutralização de uma anomalia catalogada, sob protocolo.'                        , 1, 3, '#F44336')
) AS origem (Codigo, Nome, Descricao, RequerAnomalia, NivelAcessoMinimo, CorAlerta)
    ON alvo.Codigo = origem.Codigo
WHEN MATCHED THEN UPDATE SET
    alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao, alvo.RequerAnomalia = origem.RequerAnomalia,
    alvo.NivelAcessoMinimo = origem.NivelAcessoMinimo, alvo.CorAlerta = origem.CorAlerta
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao, RequerAnomalia, NivelAcessoMinimo, CorAlerta)
    VALUES (origem.Codigo, origem.Nome, origem.Descricao, origem.RequerAnomalia, origem.NivelAcessoMinimo, origem.CorAlerta);
GO
