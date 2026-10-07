-- Seed convergente (run-always). Chave natural: Codigo.
MERGE Cat_ManifestacaoEspecifica AS alvo
USING (VALUES
    ('METAMORFOSE' ,N'Metamorfose'                ,N'Capacidade de alterar forma física'),
    ('REGENERACAO' ,N'Regeneração'                ,N'Capacidade de regenerar tecidos danificados'),
    ('TELEPATIA'   ,N'Telepatia'                  ,N'Comunicação direta mente-a-mente'),
    ('DISTORCAO_ST',N'Distorção Espaço-Temporal'  ,N'Manipulação do espaço e tempo local'),
    ('IGN-01'      ,N'Ignifagia'                  ,N'Criação e controle de chamas'),
    ('CRYO-05'     ,N'Criogênese'                 ,N'Redução drástica de temperatura'),
    ('TELE-03'     ,N'Telecinese'                 ,N'Movimento de objetos com a mente'),
    ('MEM-07'      ,N'Manipulação de Memória'     ,N'Alteração ou apagamento de memórias')
) AS origem (Codigo, Nome, Descricao)
    ON alvo.Codigo = origem.Codigo
WHEN MATCHED THEN UPDATE SET alvo.Nome = origem.Nome, alvo.Descricao = origem.Descricao
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Nome, Descricao) VALUES (origem.Codigo, origem.Nome, origem.Descricao);
GO
