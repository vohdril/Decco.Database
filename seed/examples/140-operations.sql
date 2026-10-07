-- Example data - Operations (new in 0003; they did not exist in decco.sql)
-- Run-always, but GUARDED: inserts only if it does not exist yet. Running it twice is harmless.
--
-- Built to exercise the SLICING BY FACILITY:
--   scope SITIO-19 (with children) -> OP-2026-0001, OP-2026-0002
--   scope SITIO-64 (with children) -> OP-2026-0003, OP-2026-0004
--   scope LAB-BIO-19               -> OP-2026-0002
-- and the slicing by CLEARANCE: levels 1, 2, 4 and 2.
-- Explicit (not generated) codes so the example is deterministic.
IF NOT EXISTS (SELECT 1 FROM Operation WHERE Code = 'OP-2026-0001')
BEGIN
    PRINT 'seed/examples: inserting operations';

    DECLARE @Investigacao INT = (SELECT Id FROM Cat_OperationType WHERE Code = 'INVESTIGACAO');
    DECLARE @Pesquisa     INT = (SELECT Id FROM Cat_OperationType WHERE Code = 'PESQUISA');
    DECLARE @Supressao    INT = (SELECT Id FROM Cat_OperationType WHERE Code = 'SUPRESSAO');

    DECLARE @Sitio19 INT = (SELECT Id FROM Facility WHERE Code = 'SITIO-19');
    DECLARE @Sitio64 INT = (SELECT Id FROM Facility WHERE Code = 'SITIO-64');
    DECLARE @LabBio  INT = (SELECT Id FROM Facility WHERE Code = 'LAB-BIO-19');
    DECLARE @Area001 INT = (SELECT Id FROM Facility WHERE Code = 'AREA-001');

    DECLARE @Scp1001 INT = (SELECT Id FROM Anomaly WHERE ScpCode = 'SCP-1001');
    DECLARE @Scp1002 INT = (SELECT Id FROM Anomaly WHERE ScpCode = 'SCP-1002');

    DECLARE @NotifTheta INT = (SELECT Id FROM AnomalyNotification WHERE Title = N'Flutuação Theta no Sítio-19');
    DECLARE @NotifPsi   INT = (SELECT Id FROM AnomalyNotification WHERE Title = N'Evento Psi não identificado');

    DECLARE @ProtOmega INT = (SELECT Id FROM ContainmentProtocol WHERE Code = 'PROT-OMEGA-CRIT');

    DECLARE @NewRow TABLE (NewId INT, FormattedCode VARCHAR(20));

    INSERT INTO @NewRow EXEC usp_Operation_Insert
        @Code = 'OP-2026-0001', @Codename = N'Jaguar Silente',
        @OperationTypeId = @Investigacao, @FacilityId = @Sitio19, @NotificationId = @NotifTheta,
        @Objective = N'Apurar a flutuação de IEIA-D acima de 0,3% no perímetro oeste e determinar se há anomalia não catalogada.',
        @Priority = 3, @MinClearanceLevel = 1, @ResponsiblePerson = N'Dra. Elara Vance';

    INSERT INTO @NewRow EXEC usp_Operation_Insert
        @Code = 'OP-2026-0002', @Codename = N'Espelho de Proteu',
        @OperationTypeId = @Pesquisa, @FacilityId = @LabBio, @AnomalyId = @Scp1001,
        @Objective = N'Mapear o limite de variação de massa entre formas do SCP-1001 e a latência de transformação.',
        @Priority = 3, @MinClearanceLevel = 2, @ResponsiblePerson = N'Dra. Elara Vance';

    INSERT INTO @NewRow EXEC usp_Operation_Insert
        @Code = 'OP-2026-0003', @Codename = N'Silêncio do Codex',
        @OperationTypeId = @Supressao, @FacilityId = @Area001, @AnomalyId = @Scp1002, @ProtocolId = @ProtOmega,
        @Objective = N'Estabilizar a zona de realidade instável deixada pela ativação não autorizada do Codex-Primus.',
        @Priority = 5, @MinClearanceLevel = 4, @ResponsiblePerson = N'Dr. Aris Thoth';

    INSERT INTO @NewRow EXEC usp_Operation_Insert
        @Code = 'OP-2026-0004', @Codename = N'Sono Partilhado',
        @OperationTypeId = @Investigacao, @FacilityId = @Sitio64, @NotificationId = @NotifPsi,
        @Objective = N'Investigar os sonhos compartilhados no alojamento e descartar entidade onírica em formação.',
        @Priority = 4, @MinClearanceLevel = 2, @ResponsiblePerson = N'Dr. Aris Thoth';

    -- Two already in progress: exercises the Status filter
    UPDATE Operation SET Status = 'EM_ANDAMENTO' WHERE Code IN ('OP-2026-0001', 'OP-2026-0002');
END
ELSE
    PRINT 'seed/examples: operations already exist - skipping.';
GO
