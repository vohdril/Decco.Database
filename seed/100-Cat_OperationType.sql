-- Converging seed (run-always). Natural key: Code.
-- Single source of the operation types: migration 0003 creates the table empty, because
-- no data migration depends on these values.
MERGE Cat_OperationType AS target
USING (VALUES
    ('INVESTIGACAO', N'Investigação', N'Apuração de um fenômeno relatado e ainda não catalogado. Nasce tipicamente de uma notificação de campo.'      , 0, 1, '#2196F3'),
    ('PESQUISA'    , N'Pesquisa'    , N'Estudo controlado de uma anomalia já catalogada: testes, medições de IEIA-D e caracterização de perícias.', 1, 2, '#9C27B0'),
    ('SUPRESSAO'   , N'Supressão'   , N'Ação de contenção ativa ou neutralização de uma anomalia catalogada, sob protocolo.'                        , 1, 3, '#F44336')
) AS source (Code, Name, Description, RequiresAnomaly, MinClearanceLevel, AlertColor)
    ON target.Code = source.Code
WHEN MATCHED THEN UPDATE SET
    target.Name = source.Name, target.Description = source.Description, target.RequiresAnomaly = source.RequiresAnomaly,
    target.MinClearanceLevel = source.MinClearanceLevel, target.AlertColor = source.AlertColor
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Code, Name, Description, RequiresAnomaly, MinClearanceLevel, AlertColor)
    VALUES (source.Code, source.Name, source.Description, source.RequiresAnomaly, source.MinClearanceLevel, source.AlertColor);
GO
