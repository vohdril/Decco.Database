-- Example data - The 2 complete anomalies (decco.sql section 11)
-- Run-always, but GUARDED: inserts only if it does not exist yet. Running it twice is harmless.
IF NOT EXISTS (SELECT 1 FROM Anomaly WHERE ScpCode = 'SCP-1001')
BEGIN
    PRINT 'seed/examples: inserting SCP-1001 and SCP-1002';

    -- Containment facilities (by code - seed/examples/100 or migration 0002).
    -- They are equivalent to the former free-text SitioContencao:
    --   'Sítio-19, Setor de Biology Anômala' -> LAB-BIO-19
    --   'Sítio-64, Biblioteca Proibida'       -> AREA-001
    DECLARE @FacilityId_LAB_BIO_19 INT = (SELECT Id FROM Facility WHERE Code = 'LAB-BIO-19');
    DECLARE @FacilityId_AREA_001   INT = (SELECT Id FROM Facility WHERE Code = 'AREA-001');

    -- Example 1: Complex Shapeshifter
    DECLARE @MetamorfoId INT;
    DECLARE @MetamorphosisSkillId INT;
    DECLARE @ObjectClassId_EUCLID INT, @OntologicalLayerId_THETA INT, @MatterTypeId_BARYONIC INT;
    DECLARE @ApparentCognitionId_SA INT, @DangerLevelId_MEDIUM INT;
    DECLARE @PrimaryMechanismId_THETA_C INT, @SecondaryMechanismId_PSI_C INT;
    DECLARE @ManifestacaoId_METAMORFOSE INT, @ManifestacaoId_REGENERACAO INT;

    -- Get the required IDs
    SET @ObjectClassId_EUCLID = (SELECT Id FROM Cat_ObjectClass WHERE AcsClass = 'EUCLID');
    SET @OntologicalLayerId_THETA = (SELECT Id FROM Cat_OntologicalLayer WHERE Symbol = 'THETA');
    SET @MatterTypeId_BARYONIC = (SELECT Id FROM Cat_MatterType WHERE Name = 'Bariônica Anômala');
    SET @ApparentCognitionId_SA = (SELECT Id FROM Cat_ApparentCognition WHERE Code = 'SA');
    SET @DangerLevelId_MEDIUM = (SELECT Id FROM Cat_DangerLevel WHERE Level = 5);
    SET @PrimaryMechanismId_THETA_C = (SELECT Id FROM Cat_InteractionMechanism WHERE Code = 'THETA-C');
    SET @SecondaryMechanismId_PSI_C = (SELECT Id FROM Cat_InteractionMechanism WHERE Code = 'PSI-C');
    SET @ManifestacaoId_METAMORFOSE = (SELECT Id FROM Cat_SpecificManifestation WHERE Code = 'METAMORFOSE');
    SET @ManifestacaoId_REGENERACAO = (SELECT Id FROM Cat_SpecificManifestation WHERE Code = 'REGENERACAO');

    -- Create a temporary table to capture the result
    DECLARE @Result TABLE (NewId INT, FormattedCode VARCHAR(50));

    -- Insert the anomaly
    INSERT INTO @Result
    EXEC usp_Anomaly_Insert 
        @ScpCode = 'SCP-1001',
        @CommonName = 'Proteu - O Metamorfo Complexo',
        @Description = 'Entidade humanoide capaz de se transformar em múltiplas formas animais. Massa varia até +/- 60% da forma base. Formas são anatomicamente perfeitas.',
        @ObjectClassId = @ObjectClassId_EUCLID,
        @OntologicalLayerId = @OntologicalLayerId_THETA,
        @MatterTypeId = @MatterTypeId_BARYONIC,
        @ApparentCognitionId = @ApparentCognitionId_SA,
        @DangerLevelId = @DangerLevelId_MEDIUM,
        @PrimaryMechanismId = @PrimaryMechanismId_THETA_C,
        @SecondaryMechanismId = @SecondaryMechanismId_PSI_C,
        @IeiaDBaseline = 0.5,
        @SpinCoherenceFactor = 'Alto',
        @ContainmentFacilityId = @FacilityId_LAB_BIO_19,
        @ResearchLead = 'Dra. Elara Vance';

    -- Get the ID of the created anomaly
    SELECT @MetamorfoId = NewId FROM @Result;

    -- Clear the temporary table
    DELETE FROM @Result;

    -- Add as a living entity
    EXEC usp_LivingEntity_Insert 
        @AnomalyId = @MetamorfoId,
        @Identification = 'Indivíduo-Alpha',
        @Species = 'Homo sapiens metamorfo',
        @Biology = 'Bariônica Modificada',
        @PowerOrigin = 'Catalisador + Acesso PSI',
        @IntelligenceLevel = 8;

    -- Add skill and manifestations
    INSERT INTO @Result
    EXEC usp_Anomaly_AddSkill
        @AnomalyId = @MetamorfoId,
        @Name = 'Metamorfose Complexa',
        @Description = 'Capacidade de transformação em múltiplas formas animais',
        @PrimaryMechanismId = @PrimaryMechanismId_THETA_C,
        @SecondaryMechanismId = @SecondaryMechanismId_PSI_C,
        @Level = 3,
    	@Cost = 'Nenhum'

    -- Get the ID of the created anomaly skill
    SELECT @MetamorphosisSkillId = NewId FROM @Result;

    -- Clear the temporary table
    DELETE FROM @Result;

    EXEC usp_AnomalySkill_AddManifestation
        @AnomalySkillId = @MetamorphosisSkillId,
        @SpecificManifestationId = @ManifestacaoId_METAMORFOSE,
        @Intensity = 'Alta';

    EXEC usp_AnomalySkill_AddManifestation
        @AnomalySkillId = @MetamorphosisSkillId,
        @SpecificManifestationId = @ManifestacaoId_REGENERACAO,
        @Intensity = 'Média';

    -- Record an incident
    EXEC usp_Incident_Register
        @AnomalyId = @MetamorfoId,
        @IncidentType = 'Teste de Pesquisa',
        @Title = 'Teste de Limites de Transformação',
        @Report = 'Sujeito transformou-se sequencialmente em lobo, urso e corvo dentro de 5 minutos.',
        @SecurityLevel = 'Alto',
        @IsSigmaEvent = 0,
        @Injuries = 0;



    -- Example 2: Frozen Spin Grimoire
    DECLARE @GrimorioId INT;
    DECLARE @GrimoireSkillId INT;
    DECLARE @ObjectClassId_KETER INT, @OntologicalLayerId_OMEGA INT, @MatterTypeId_MIXED INT;
    DECLARE @ApparentCognitionId_IN INT, @DangerLevelId_HIGH INT;
    DECLARE @PrimaryMechanismId_OMEGA_A INT, @SecondaryMechanismId_THETA_C INT;

    SET @ObjectClassId_KETER = (SELECT Id FROM Cat_ObjectClass WHERE AcsClass = 'KETER');
    SET @OntologicalLayerId_OMEGA = (SELECT Id FROM Cat_OntologicalLayer WHERE Symbol = 'OMEGA');
    SET @MatterTypeId_MIXED = (SELECT Id FROM Cat_MatterType WHERE Name = 'Mista');
    SET @ApparentCognitionId_IN = (SELECT Id FROM Cat_ApparentCognition WHERE Code = 'IN');
    SET @DangerLevelId_HIGH = (SELECT Id FROM Cat_DangerLevel WHERE Level = 6);
    SET @PrimaryMechanismId_OMEGA_A = (SELECT Id FROM Cat_InteractionMechanism WHERE Code = 'THETA-A');
    SET @SecondaryMechanismId_THETA_C = (SELECT Id FROM Cat_InteractionMechanism WHERE Code = 'OMEGA-C');


    -- Insert the anomaly
    INSERT INTO @Result
    EXEC usp_Anomaly_Insert 
        @ScpCode = 'SCP-1002',
        @CommonName = 'Codex de Realidades - Grimório SIGMA',
        @Description = 'Tomo antigo com padrões de spin coerente "congelados" no pergaminho.',
        @ObjectClassId = @ObjectClassId_KETER,
        @OntologicalLayerId = @OntologicalLayerId_OMEGA,
        @MatterTypeId = @MatterTypeId_MIXED,
        @ApparentCognitionId = @ApparentCognitionId_IN,
        @DangerLevelId = @DangerLevelId_HIGH,
        @PrimaryMechanismId = @PrimaryMechanismId_OMEGA_A,
        @SecondaryMechanismId = @SecondaryMechanismId_THETA_C,
        @IeiaDBaseline = 0.05,
        @SpinCoherenceFactor = 'Crítico',
        @ContainmentFacilityId = @FacilityId_AREA_001,
        @ResearchLead = 'Dr. Aris Thoth';

    -- Get the ID of the created anomaly
    SELECT @GrimorioId = NewId FROM @Result;


    -- Clear the temporary table
    DELETE FROM @Result;

    -- Add as an artifact
    EXEC usp_Artifact_Insert
        @AnomalyId = @GrimorioId,
        @Identification = 'Codex-Primus',
        @Material = 'Pergaminho/Pele Anômala',
        @SpinProperty = 'Spin Congelado com acoplamento OMEGA',
        @WeightKg = 3.5,
        @UsageInstructions = 'Ritual de ativação requer pronúncia precisa e gestos específicos.';

    -- Add a skill for the artifact

    INSERT INTO @Result
    EXEC usp_Anomaly_AddSkill
        @AnomalyId = @GrimorioId,
        @Name = 'Manipulação da Realidade',
        @Description = 'Capacidade de alterar regras locais da realidade através de padrões de spin',
        @PrimaryMechanismId = @PrimaryMechanismId_OMEGA_A,
        @SecondaryMechanismId = @SecondaryMechanismId_THETA_C,
        @Level = 5,
        @Cost = 'Deutério e ritual específico';

    -- Get the ID of the created anomaly
    SELECT @GrimoireSkillId = NewId FROM @Result;


    -- Clear the temporary table
    DELETE FROM @Result;

    -- Add manifestations to the grimoire skill
    DECLARE @ManifestacaoId_DISTORCAO_ST INT, @ManifestacaoId_TELEPATIA INT;

    SET @ManifestacaoId_DISTORCAO_ST = (SELECT Id FROM Cat_SpecificManifestation WHERE Code = 'DISTORCAO_ST');
    SET @ManifestacaoId_TELEPATIA = (SELECT Id FROM Cat_SpecificManifestation WHERE Code = 'TELEPATIA');

    EXEC usp_AnomalySkill_AddManifestation
        @AnomalySkillId = @GrimoireSkillId,
        @SpecificManifestationId = @ManifestacaoId_DISTORCAO_ST,
        @Intensity = 'Variável';

    EXEC usp_AnomalySkill_AddManifestation
        @AnomalySkillId = @GrimoireSkillId,
        @SpecificManifestationId = @ManifestacaoId_TELEPATIA,
        @Intensity = 'Média';

    -- Record a Sigma incident
    EXEC usp_Incident_Register
        @AnomalyId = @GrimorioId,
        @IncidentType = 'Evento SIGMA',
        @Title = 'Manifestação Não-Autorizada',
        @Report = 'D-Class não-treinado tentou ler o Codex. Padrão de spin foi ativado, criando uma zona de realidade instável.',
        @SecurityLevel = 'Nível 4',
        @IsSigmaEvent = 1,
        @Fatalities = 1,
        @MaterialDamage = 'Sala de teste completamente desestruturada';

    PRINT '✅ Full cataloging system installed successfully!';
    PRINT 'Structure:';
    PRINT '- 10 catalog tables (ObjectClass, FundamentalForce, OntologicalLayer, MatterType, InteractionMechanism, SpecificManifestation, ApparentCognition, DangerLevel, FacilityType, OperationType)';
    PRINT '- 1 main table (Anomaly)';
    PRINT '- 4 1:N subtables (LivingEntity, Artifact, Location, AnomalyEvent)';
    PRINT '- 2 skill tables (AnomalySkill, Instance_DeviantSkill)';
    PRINT '- 2 N:N relationship tables (AnomalySkill_Manifestation, Protocol_AppliedTo)';
    PRINT '- 1 history table (Incident)';
    PRINT '- Facility (absorbed Laboratorio), Operation, ContainmentProtocol, AnomalyNotification';
    PRINT '- 6 triggers (audit and integrity)';
    PRINT '- 18 CRUD stored procedures';
    PRINT '- 3 dashboard views';
    PRINT '- 2 example anomalies inserted';
    PRINT '- 7 facilities (3 sites, 3 laboratories, 1 area), 3 protocols, 2 notifications, 4 operations';
END
ELSE
    PRINT 'seed/examples: SCP-1001 and SCP-1002 already exist - skipping.';
GO