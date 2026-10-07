-- Example data - Field notifications (decco.sql section 11C)
-- Run-always, but GUARDED: inserts only if it does not exist yet. Running it twice is harmless.
-- @FacilityId points to the SITE (not to the area): the same link that
-- migration 0002 creates in an adopted database - ReportedLocation keeps the detail.
IF NOT EXISTS (SELECT 1 FROM AnomalyNotification WHERE Title = N'Flutuação Theta no Sítio-19')
BEGIN
    PRINT 'seed/examples: inserting notifications';

    DECLARE @Sitio19 INT = (SELECT Id FROM Facility WHERE Code = 'SITIO-19');
    DECLARE @Sitio64 INT = (SELECT Id FROM Facility WHERE Code = 'SITIO-64');

    -- =============================================
    -- SECTION 11C: EXAMPLE DATA — NOTIFICATIONS
    -- =============================================
    EXEC usp_AnomalyNotification_Insert @Title='Flutuação Theta no Sítio-19', @Description='Sensor IEIA-D detectou flutuação acima de 0.3% no perímetro oeste. Possível nova anomalia não catalogada.', @ReportedLocation='Sítio-19, Perímetro Oeste', @PriorityLevel=3, @Reporter='Sistema Automático', @FacilityId=@Sitio19;
    EXEC usp_AnomalyNotification_Insert @Title='Evento Psi não identificado', @Description='Relato de sonhos compartilhados entre 12 funcionários do Sítio-64. Possível entidade onírica em formação.', @ReportedLocation='Sítio-64, Alojamento Funcionários', @PriorityLevel=4, @Reporter='Dr. Aris Thoth', @FacilityId=@Sitio64;
END
ELSE
    PRINT 'seed/examples: notifications already exist - skipping.';
GO
