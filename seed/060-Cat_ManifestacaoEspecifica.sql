-- Converging seed (run-always). Natural key: Codigo.
MERGE Cat_ManifestacaoEspecifica AS target
USING (VALUES
    ('METAMORFOSE' ,N'Metamorfose'                ,N'Capacidade de alterar forma física'),
    ('REGENERACAO' ,N'Regeneração'                ,N'Capacidade de regenerar tecidos danificados'),
    ('TELEPATIA'   ,N'Telepatia'                  ,N'Comunicação direta mente-a-mente'),
    ('DISTORCAO_ST',N'Distorção Espaço-Temporal'  ,N'Manipulação do espaço e tempo local'),
    ('IGN-01'      ,N'Ignifagia'                  ,N'Criação e controle de chamas'),
    ('CRYO-05'     ,N'Criogênese'                 ,N'Redução drástica de temperatura'),
    ('TELE-03'     ,N'Telecinese'                 ,N'Movimento de objetos com a mente'),
    ('MEM-07'      ,N'Manipulação de Memória'     ,N'Alteração ou apagamento de memórias')
) AS source (Codigo, Nome, Descricao)
    ON target.Codigo = source.Codigo
WHEN MATCHED THEN UPDATE SET target.Nome = source.Nome, target.Descricao = source.Descricao
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao) VALUES (source.Codigo, source.Nome, source.Descricao);
GO
