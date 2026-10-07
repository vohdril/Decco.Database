-- Example data - Facilities (the former laboratories of decco.sql section 11A)
-- Run-always, but GUARDED: inserts only if it does not exist yet. Running it twice is harmless.
--
-- In an ADOPTED database these rows already exist: migration 0002 created them from
-- the former Laboratorio table and Anomaly.SitioContencao, and this script skips.
-- In an EMPTY database this script recreates EXACTLY the same state (same codes,
-- names and hierarchy) - which is what the rehearsal compares.
IF NOT EXISTS (SELECT 1 FROM Facility WHERE Code = 'SITIO-19')
BEGIN
    PRINT 'seed/examples: inserting facilities';

    DECLARE @SiteTypeId INT = (SELECT Id FROM Cat_FacilityType WHERE Code = 'SITIO');
    DECLARE @LabTypeId  INT = (SELECT Id FROM Cat_FacilityType WHERE Code = 'LABORATORIO');
    DECLARE @AreaTypeId INT = (SELECT Id FROM Cat_FacilityType WHERE Code = 'AREA_CONTENCAO');
    DECLARE @Site19 INT, @Site64 INT, @Site07 INT;
    DECLARE @NewRow TABLE (NewId INT);

    -- Sites (hierarchy root)
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='SITIO-19', @Name=N'Sítio-19', @FacilityTypeId=@SiteTypeId;
    SELECT @Site19 = NewId FROM @NewRow; DELETE FROM @NewRow;
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='SITIO-64', @Name=N'Sítio-64', @FacilityTypeId=@SiteTypeId;
    SELECT @Site64 = NewId FROM @NewRow; DELETE FROM @NewRow;
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='SITIO-07', @Name=N'Sítio-07', @FacilityTypeId=@SiteTypeId;
    SELECT @Site07 = NewId FROM @NewRow; DELETE FROM @NewRow;

    -- Laboratories (the 3 from section 11A, now children of their site)
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='LAB-BIO-19', @Name=N'Setor de Biologia Anômala', @FacilityTypeId=@LabTypeId, @ParentFacilityId=@Site19, @ResponsiblePerson=N'Dra. Elara Vance', @Specialty='Biologia Anômala';
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='LAB-SPIN-64', @Name=N'Laboratório de Spin Coerente', @FacilityTypeId=@LabTypeId, @ParentFacilityId=@Site64, @ResponsiblePerson=N'Dr. Aris Thoth', @Specialty='Física Quântica';
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='LAB-PSI-07', @Name=N'Câmara de Ressonância Psi', @FacilityTypeId=@LabTypeId, @ParentFacilityId=@Site07, @ResponsiblePerson=N'Dr. Marcus Bell', @Specialty='Narratologia';

    -- Containment area: the "Biblioteca Proibida" from the old SCP-1002 SitioContencao column
    INSERT INTO @NewRow EXEC usp_Facility_Insert @Code='AREA-001', @Name=N'Biblioteca Proibida', @FacilityTypeId=@AreaTypeId, @ParentFacilityId=@Site64;
END
ELSE
    PRINT 'seed/examples: facilities already exist - skipping.';
GO
