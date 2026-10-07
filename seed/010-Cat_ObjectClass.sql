-- Converging seed (run-always). Natural key: Code.
-- No DELETE clause: rows added by hand survive.
MERGE Cat_ObjectClass AS target
USING (VALUES
    ('PACATO' ,'Pacato' ,'Primária','SAFE'    ,'Anomalia contida de forma confiável com procedimentos padrão.',1,'#4CAF50'),
    ('YAGUARA','Yaguara','Primária','EUCLID'  ,'Anomalia imprevisível que requer atenção constante.'          ,2,'#FFC107'),
    ('ABAPORU','Abaporu','Primária','KETER'   ,'Extremamente difícil de conter, risco catastrófico.'          ,3,'#F44336'),
    ('UKAR'   ,'Ukar'   ,'Primária','THAUMIEL','Usada para conter outras anomalias. O segredo dos segredos.'  ,4,'#9C27B0')
) AS source (Code, Name, ClassType, AcsClass, Description, MinClearanceLevel, AlertColor)
    ON target.Code = source.Code
WHEN MATCHED THEN UPDATE SET
    target.Name = source.Name, target.ClassType = source.ClassType, target.AcsClass = source.AcsClass,
    target.Description = source.Description, target.MinClearanceLevel = source.MinClearanceLevel, target.AlertColor = source.AlertColor
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Code, Name, ClassType, AcsClass, Description, MinClearanceLevel, AlertColor)
    VALUES (source.Code, source.Name, source.ClassType, source.AcsClass, source.Description, source.MinClearanceLevel, source.AlertColor);
GO
