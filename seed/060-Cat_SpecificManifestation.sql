-- Converging seed (run-always). Natural key: Code.
MERGE Cat_SpecificManifestation AS target
USING (VALUES
    ('METAMORFOSE' ,N'Metamorfose'                ,N'Capacidade de alterar forma física'),
    ('REGENERACAO' ,N'Regeneração'                ,N'Capacidade de regenerar tecidos danificados'),
    ('TELEPATIA'   ,N'Telepatia'                  ,N'Comunicação direta mente-a-mente'),
    ('DISTORCAO_ST',N'Distorção Espaço-Temporal'  ,N'Manipulação do espaço e tempo local'),
    ('IGN-01'      ,N'Ignifagia'                  ,N'Criação e controle de chamas'),
    ('CRYO-05'     ,N'Criogênese'                 ,N'Redução drástica de temperatura'),
    ('TELE-03'     ,N'Telecinese'                 ,N'Movimento de objetos com a mente'),
    ('MEM-07'      ,N'Manipulação de Memória'     ,N'Alteração ou apagamento de memórias')
) AS source (Code, Name, Description)
    ON target.Code = source.Code
WHEN MATCHED THEN UPDATE SET target.Name = source.Name, target.Description = source.Description
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Code, Name, Description) VALUES (source.Code, source.Name, source.Description);
GO
