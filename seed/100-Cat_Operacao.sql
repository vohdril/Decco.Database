-- Converging seed (run-always). Natural key: Codigo.
-- Single source of the operation types: migration 0003 creates the table empty, because
-- no data migration depends on these values.
MERGE Cat_Operacao AS target
USING (VALUES
    ('INVESTIGACAO', N'Investigação', N'Apuração de um fenômeno relatado e ainda não catalogado. Nasce tipicamente de uma notificação de campo.'      , 0, 1, '#2196F3'),
    ('PESQUISA'    , N'Pesquisa'    , N'Estudo controlado de uma anomalia já catalogada: testes, medições de IEIA-D e caracterização de perícias.', 1, 2, '#9C27B0'),
    ('SUPRESSAO'   , N'Supressão'   , N'Ação de contenção ativa ou neutralização de uma anomalia catalogada, sob protocolo.'                        , 1, 3, '#F44336')
) AS source (Codigo, Nome, Descricao, RequerAnomalia, NivelAcessoMinimo, CorAlerta)
    ON target.Codigo = source.Codigo
WHEN MATCHED THEN UPDATE SET
    target.Nome = source.Nome, target.Descricao = source.Descricao, target.RequerAnomalia = source.RequerAnomalia,
    target.NivelAcessoMinimo = source.NivelAcessoMinimo, target.CorAlerta = source.CorAlerta
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao, RequerAnomalia, NivelAcessoMinimo, CorAlerta)
    VALUES (source.Codigo, source.Nome, source.Descricao, source.RequerAnomalia, source.NivelAcessoMinimo, source.CorAlerta);
GO
