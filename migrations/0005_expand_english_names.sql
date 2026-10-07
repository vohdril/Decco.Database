-- =============================================================================
-- 0005 — EXPAND: English names for the whole schema, Portuguese compatibility views
--
--   sp_rename  24 tables and their columns          (decco-compass/reference/29)
--   DROP + ADD the 7 CHECKs that block a column rename (Msg 15336)
--   DROP       the 6 old triggers (their bodies cite the old names; run-always
--              recreates them in English in this same deploy)
--   DROP       sp_Decco_SetDescription (replaced by usp_Decco_SetDescription)
--   CREATE     24 compatibility VIEWS with the OLD table and column names
--
-- RENAME-ONLY: no type, nullability, key or data change. The shape fingerprint
-- (object_id, column_id, type, length, nullability) must be identical before and
-- after — sp_rename keeps object_id and column_id.
--
-- Why compatibility views: Decco.API still maps its EF entities and Dapper SQL to
-- the Portuguese names. Each view exposes a table under its old name with the old
-- column names, and is updatable (single table, no aggregates), so EF reads,
-- inserts (OUTPUT ... INTO, because the entities declare HasTrigger) and updates
-- keep working. The 0006 compatibility procedures run on top of them.
-- They are TEMPORARY: a later contract migration drops them once every consumer
-- uses the English names. They live in a RunOnce migration on purpose — as
-- run-always scripts, the next deploy would recreate them after the contract.
--
-- ⚠️ ONE SINGLE BATCH (no GO), like 0004: a manual run that hits an error must not
-- go on to the next batch. CREATE VIEW must start a batch, so the views are
-- created through sp_executesql. XACT_ABORT makes a failing sp_rename abort the
-- whole transaction — without it, the rest of the script would still commit
-- (verified in the reference/28 proof of concept).
--
-- Depends on: 0004_contrai_laboratorio_e_sitio.sql
-- =============================================================================
SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @sql NVARCHAR(MAX);

-- ── 1. Drop the CHECKs that block the rename ────────────────────────────────
-- System-named inline CHECKs: the name differs per database, so it is looked up.
SET @sql = N'';
SELECT @sql += N'ALTER TABLE dbo.' + QUOTENAME(OBJECT_NAME(cc.parent_object_id))
             + N' DROP CONSTRAINT ' + QUOTENAME(cc.name) + N';' + NCHAR(10)
  FROM sys.check_constraints cc
 WHERE cc.is_system_named = 1
   AND (   (cc.parent_object_id = OBJECT_ID('dbo.Cat_Periculosidade')         AND COL_NAME(cc.parent_object_id, cc.parent_column_id) = 'Nivel')
        OR (cc.parent_object_id = OBJECT_ID('dbo.Instancia_PericiaDesviante') AND COL_NAME(cc.parent_object_id, cc.parent_column_id) = 'TipoInstancia')
        OR (cc.parent_object_id = OBJECT_ID('dbo.NotificacaoAnomalia')        AND COL_NAME(cc.parent_object_id, cc.parent_column_id) = 'NivelPrioridade')
        OR (cc.parent_object_id = OBJECT_ID('dbo.ProtocoloContencao')         AND COL_NAME(cc.parent_object_id, cc.parent_column_id) = 'NivelUrgencia'));
IF @@ROWCOUNT <> 4
    THROW 50501, '0005 aborted: expected 4 system-named CHECKs on Nivel/TipoInstancia/NivelPrioridade/NivelUrgencia. Nothing was changed.', 1;
EXEC sys.sp_executesql @sql;

ALTER TABLE dbo.Instalacao DROP CONSTRAINT CK_Instalacao_NaoEhPaiDeSiMesma;
ALTER TABLE dbo.Operacao   DROP CONSTRAINT CK_Operacao_Encerramento;
ALTER TABLE dbo.Operacao   DROP CONSTRAINT CK_Operacao_Prioridade;

-- ── 2. Drop the old triggers and the old description helper ─────────────────
-- IF EXISTS: on a database created from scratch, 0005 runs BEFORE the run-always
-- scripts, so none of these objects exists yet.
DROP TRIGGER IF EXISTS dbo.TR_Anomalia_Update_Date;
DROP TRIGGER IF EXISTS dbo.TR_Anomalia_Validar_Mecanismos;
DROP TRIGGER IF EXISTS dbo.TR_Instalacao_Update_Date;
DROP TRIGGER IF EXISTS dbo.TR_Instalacao_Validar_Hierarquia;
DROP TRIGGER IF EXISTS dbo.TR_Operacao_Update_Date;
DROP TRIGGER IF EXISTS dbo.TR_Operacao_Validar;
DROP PROCEDURE IF EXISTS dbo.sp_Decco_SetDescription;

-- ── 3. Rename tables and columns ────────────────────────────────────────────

-- Anomalia → Anomaly
EXEC sp_rename N'dbo.Anomalia', N'Anomaly';
EXEC sp_rename N'dbo.Anomaly.CodigoSCP',                                     N'ScpCode',                 N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.NomeComum',                                     N'CommonName',              N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.Descricao',                                     N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.ClasseObjetoId',                                N'ObjectClassId',           N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.CamadaOntologicaId',                            N'OntologicalLayerId',      N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.TipoMateriaId',                                 N'MatterTypeId',            N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.CognicaoAparenteId',                            N'ApparentCognitionId',     N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.PericulosidadeId',                              N'DangerLevelId',           N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.MecanismoPrimarioId',                           N'PrimaryMechanismId',      N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.MecanismoSecundarioId',                         N'SecondaryMechanismId',    N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.IEIA_D_Base',                                   N'IeiaDBaseline',           N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.FatorCoerenciaSpin',                            N'SpinCoherenceFactor',     N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.ResponsavelPesquisa',                           N'ResearchLead',            N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.DataCriacao',                                   N'CreatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.DataAtualizacao',                               N'UpdatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.UsuarioCriacao',                                N'CreatedBy',               N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.UsuarioAtualizacao',                            N'UpdatedBy',               N'COLUMN';
EXEC sp_rename N'dbo.Anomaly.InstalacaoContencaoId',                         N'ContainmentFacilityId',   N'COLUMN';

-- Artefato → Artifact
EXEC sp_rename N'dbo.Artefato', N'Artifact';
EXEC sp_rename N'dbo.Artifact.AnomaliaId',                                   N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.Artifact.Identificacao',                                N'Identification',          N'COLUMN';
EXEC sp_rename N'dbo.Artifact.DataFabricacao',                               N'ManufactureDate',         N'COLUMN';
EXEC sp_rename N'dbo.Artifact.LocalOrigem',                                  N'OriginPlace',             N'COLUMN';
EXEC sp_rename N'dbo.Artifact.PropriedadeSpin',                              N'SpinProperty',            N'COLUMN';
EXEC sp_rename N'dbo.Artifact.Peso_Kg',                                      N'WeightKg',                N'COLUMN';
EXEC sp_rename N'dbo.Artifact.Dimensoes',                                    N'Dimensions',              N'COLUMN';
EXEC sp_rename N'dbo.Artifact.ModoUsar',                                     N'UsageInstructions',       N'COLUMN';

-- EntidadeViva → LivingEntity
EXEC sp_rename N'dbo.EntidadeViva', N'LivingEntity';
EXEC sp_rename N'dbo.LivingEntity.AnomaliaId',                               N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.Identificacao',                            N'Identification',          N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.Especie',                                  N'Species',                 N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.Biologia',                                 N'Biology',                 N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.OrigemPoder',                              N'PowerOrigin',             N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.DataNascimento',                           N'BirthDate',               N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.IsConsciente',                             N'IsConscious',             N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.NivelInteligencia',                        N'IntelligenceLevel',       N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.Dieta',                                    N'Diet',                    N'COLUMN';
EXEC sp_rename N'dbo.LivingEntity.Observacoes',                              N'Notes',                   N'COLUMN';

-- Evento → AnomalyEvent
EXEC sp_rename N'dbo.Evento', N'AnomalyEvent';
EXEC sp_rename N'dbo.AnomalyEvent.AnomaliaId',                               N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.Nome',                                     N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.DataHoraInicio',                           N'StartsAt',                N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.DataHoraFim',                              N'EndsAt',                  N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.Periodicidade',                            N'Periodicity',             N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.ZonaAfetada',                              N'AffectedZone',            N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.DuracaoMedia',                             N'AverageDuration',         N'COLUMN';
EXEC sp_rename N'dbo.AnomalyEvent.PreCondicoes',                             N'Preconditions',           N'COLUMN';

-- Localidade → Location
EXEC sp_rename N'dbo.Localidade', N'Location';
EXEC sp_rename N'dbo.Location.AnomaliaId',                                   N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.Location.Nome',                                         N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Location.Coordenadas',                                  N'Coordinates',             N'COLUMN';
EXEC sp_rename N'dbo.Location.RaioEfeitoMetros',                             N'EffectRadiusMeters',      N'COLUMN';
EXEC sp_rename N'dbo.Location.IEIA_D_Ambiente',                              N'IeiaDAmbient',            N'COLUMN';
EXEC sp_rename N'dbo.Location.IsGeograficamenteLimitada',                    N'IsGeographicallyBounded', N'COLUMN';
EXEC sp_rename N'dbo.Location.TipoTerreno',                                  N'TerrainType',             N'COLUMN';
EXEC sp_rename N'dbo.Location.ClimaAnomalo',                                 N'AnomalousClimate',        N'COLUMN';

-- Cat_ClasseObjeto → Cat_ObjectClass
EXEC sp_rename N'dbo.Cat_ClasseObjeto', N'Cat_ObjectClass';
EXEC sp_rename N'dbo.Cat_ObjectClass.Codigo',                                N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.Nome',                                  N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.TipoClasse',                            N'ClassType',               N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.ClasseACS',                             N'AcsClass',                N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.Descricao',                             N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.NivelAcessoMinimo',                     N'MinClearanceLevel',       N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.CorAlerta',                             N'AlertColor',              N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.DataCriacao',                           N'CreatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Cat_ObjectClass.Ativo',                                 N'IsActive',                N'COLUMN';

-- Cat_ForcaFundamental → Cat_FundamentalForce
EXEC sp_rename N'dbo.Cat_ForcaFundamental', N'Cat_FundamentalForce';
EXEC sp_rename N'dbo.Cat_FundamentalForce.Simbolo',                          N'Symbol',                  N'COLUMN';
EXEC sp_rename N'dbo.Cat_FundamentalForce.Nome',                             N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_FundamentalForce.Descricao',                        N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_FundamentalForce.ParticulaPortadora',               N'CarrierParticle',         N'COLUMN';

-- Cat_CamadaOntologica → Cat_OntologicalLayer
EXEC sp_rename N'dbo.Cat_CamadaOntologica', N'Cat_OntologicalLayer';
EXEC sp_rename N'dbo.Cat_OntologicalLayer.Simbolo',                          N'Symbol',                  N'COLUMN';
EXEC sp_rename N'dbo.Cat_OntologicalLayer.Nome',                             N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_OntologicalLayer.Descricao',                        N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_OntologicalLayer.ForcaFundamentalId',               N'FundamentalForceId',      N'COLUMN';
EXEC sp_rename N'dbo.Cat_OntologicalLayer.Prioridade',                       N'Priority',                N'COLUMN';

-- Cat_TipoMateria → Cat_MatterType
EXEC sp_rename N'dbo.Cat_TipoMateria', N'Cat_MatterType';
EXEC sp_rename N'dbo.Cat_MatterType.Nome',                                   N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_MatterType.Descricao',                              N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_MatterType.IsResistenteSupressores',                N'IsSuppressorResistant',   N'COLUMN';

-- Cat_MecanismoInteracao → Cat_InteractionMechanism
EXEC sp_rename N'dbo.Cat_MecanismoInteracao', N'Cat_InteractionMechanism';
EXEC sp_rename N'dbo.Cat_InteractionMechanism.Codigo',                       N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_InteractionMechanism.Nome',                         N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_InteractionMechanism.Descricao',                    N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_InteractionMechanism.CamadaOntologicaId',           N'OntologicalLayerId',      N'COLUMN';
EXEC sp_rename N'dbo.Cat_InteractionMechanism.EhSubnatureza',                N'IsSubNature',             N'COLUMN';

-- Cat_ManifestacaoEspecifica → Cat_SpecificManifestation
EXEC sp_rename N'dbo.Cat_ManifestacaoEspecifica', N'Cat_SpecificManifestation';
EXEC sp_rename N'dbo.Cat_SpecificManifestation.Codigo',                      N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_SpecificManifestation.Nome',                        N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_SpecificManifestation.Descricao',                   N'Description',             N'COLUMN';

-- Cat_CognicaoAparente → Cat_ApparentCognition
EXEC sp_rename N'dbo.Cat_CognicaoAparente', N'Cat_ApparentCognition';
EXEC sp_rename N'dbo.Cat_ApparentCognition.Codigo',                          N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_ApparentCognition.Nome',                            N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_ApparentCognition.Descricao',                       N'Description',             N'COLUMN';

-- Cat_Periculosidade → Cat_DangerLevel
EXEC sp_rename N'dbo.Cat_Periculosidade', N'Cat_DangerLevel';
EXEC sp_rename N'dbo.Cat_DangerLevel.Nivel',                                 N'Level',                   N'COLUMN';
EXEC sp_rename N'dbo.Cat_DangerLevel.Nome',                                  N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_DangerLevel.Descricao',                             N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_DangerLevel.CorAlerta',                             N'AlertColor',              N'COLUMN';

-- Cat_TipoInstalacao → Cat_FacilityType
EXEC sp_rename N'dbo.Cat_TipoInstalacao', N'Cat_FacilityType';
EXEC sp_rename N'dbo.Cat_FacilityType.Codigo',                               N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_FacilityType.Nome',                                 N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_FacilityType.Descricao',                            N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_FacilityType.PermiteFilhos',                        N'AllowsChildren',          N'COLUMN';
EXEC sp_rename N'dbo.Cat_FacilityType.Ativo',                                N'IsActive',                N'COLUMN';

-- Cat_Operacao → Cat_OperationType
EXEC sp_rename N'dbo.Cat_Operacao', N'Cat_OperationType';
EXEC sp_rename N'dbo.Cat_OperationType.Codigo',                              N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_OperationType.Nome',                                N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Cat_OperationType.Descricao',                           N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Cat_OperationType.RequerAnomalia',                      N'RequiresAnomaly',         N'COLUMN';
EXEC sp_rename N'dbo.Cat_OperationType.NivelAcessoMinimo',                   N'MinClearanceLevel',       N'COLUMN';
EXEC sp_rename N'dbo.Cat_OperationType.CorAlerta',                           N'AlertColor',              N'COLUMN';
EXEC sp_rename N'dbo.Cat_OperationType.Ativo',                               N'IsActive',                N'COLUMN';

-- Instalacao → Facility
EXEC sp_rename N'dbo.Instalacao', N'Facility';
EXEC sp_rename N'dbo.Facility.Codigo',                                       N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Facility.Nome',                                         N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.Facility.Descricao',                                    N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Facility.TipoInstalacaoId',                             N'FacilityTypeId',          N'COLUMN';
EXEC sp_rename N'dbo.Facility.InstalacaoPaiId',                              N'ParentFacilityId',        N'COLUMN';
EXEC sp_rename N'dbo.Facility.Responsavel',                                  N'ResponsiblePerson',       N'COLUMN';
EXEC sp_rename N'dbo.Facility.Especialidade',                                N'Specialty',               N'COLUMN';
EXEC sp_rename N'dbo.Facility.NivelAcessoMinimo',                            N'MinClearanceLevel',       N'COLUMN';
EXEC sp_rename N'dbo.Facility.DataCriacao',                                  N'CreatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Facility.DataAtualizacao',                              N'UpdatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Facility.UsuarioCriacao',                               N'CreatedBy',               N'COLUMN';
EXEC sp_rename N'dbo.Facility.UsuarioAtualizacao',                           N'UpdatedBy',               N'COLUMN';

-- Operacao → Operation
EXEC sp_rename N'dbo.Operacao', N'Operation';
EXEC sp_rename N'dbo.Operation.Codigo',                                      N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.Operation.Codinome',                                    N'Codename',                N'COLUMN';
EXEC sp_rename N'dbo.Operation.TipoOperacaoId',                              N'OperationTypeId',         N'COLUMN';
EXEC sp_rename N'dbo.Operation.InstalacaoId',                                N'FacilityId',              N'COLUMN';
EXEC sp_rename N'dbo.Operation.AnomaliaId',                                  N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.Operation.NotificacaoId',                               N'NotificationId',          N'COLUMN';
EXEC sp_rename N'dbo.Operation.ProtocoloId',                                 N'ProtocolId',              N'COLUMN';
EXEC sp_rename N'dbo.Operation.Objetivo',                                    N'Objective',               N'COLUMN';
EXEC sp_rename N'dbo.Operation.Descricao',                                   N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.Operation.Prioridade',                                  N'Priority',                N'COLUMN';
EXEC sp_rename N'dbo.Operation.NivelAcessoMinimo',                           N'MinClearanceLevel',       N'COLUMN';
EXEC sp_rename N'dbo.Operation.Responsavel',                                 N'ResponsiblePerson',       N'COLUMN';
EXEC sp_rename N'dbo.Operation.DataAbertura',                                N'OpenedAt',                N'COLUMN';
EXEC sp_rename N'dbo.Operation.DataPrevisaoTermino',                         N'ExpectedEndAt',           N'COLUMN';
EXEC sp_rename N'dbo.Operation.DataEncerramento',                            N'ClosedAt',                N'COLUMN';
EXEC sp_rename N'dbo.Operation.ResultadoResumo',                             N'ResultSummary',           N'COLUMN';
EXEC sp_rename N'dbo.Operation.DataCriacao',                                 N'CreatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Operation.DataAtualizacao',                             N'UpdatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.Operation.UsuarioCriacao',                              N'CreatedBy',               N'COLUMN';
EXEC sp_rename N'dbo.Operation.UsuarioAtualizacao',                          N'UpdatedBy',               N'COLUMN';

-- ProtocoloContencao → ContainmentProtocol
EXEC sp_rename N'dbo.ProtocoloContencao', N'ContainmentProtocol';
EXEC sp_rename N'dbo.ContainmentProtocol.Codigo',                            N'Code',                    N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.Titulo',                            N'Title',                   N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.Descricao',                         N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.NivelUrgencia',                     N'UrgencyLevel',            N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.ClassesAplicaveis',                 N'ApplicableClasses',       N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.Passos',                            N'Steps',                   N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.RecursosNecessarios',               N'RequiredResources',       N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.DataCriacao',                       N'CreatedAt',               N'COLUMN';
EXEC sp_rename N'dbo.ContainmentProtocol.DataAtualizacao',                   N'UpdatedAt',               N'COLUMN';

-- Protocolo_AplicadoEm → Protocol_AppliedTo
EXEC sp_rename N'dbo.Protocolo_AplicadoEm', N'Protocol_AppliedTo';
EXEC sp_rename N'dbo.Protocol_AppliedTo.ProtocoloId',                        N'ProtocolId',              N'COLUMN';
EXEC sp_rename N'dbo.Protocol_AppliedTo.AnomaliaId',                         N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.Protocol_AppliedTo.DataInicio',                         N'ValidFrom',               N'COLUMN';
EXEC sp_rename N'dbo.Protocol_AppliedTo.DataFim',                            N'ValidTo',                 N'COLUMN';
EXEC sp_rename N'dbo.Protocol_AppliedTo.Observacoes',                        N'Notes',                   N'COLUMN';

-- NotificacaoAnomalia → AnomalyNotification
EXEC sp_rename N'dbo.NotificacaoAnomalia', N'AnomalyNotification';
EXEC sp_rename N'dbo.AnomalyNotification.Titulo',                            N'Title',                   N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.Descricao',                         N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.LocalIdentificado',                 N'ReportedLocation',        N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.DataHora',                          N'ReportedAt',              N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.NivelPrioridade',                   N'PriorityLevel',           N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.Relator',                           N'Reporter',                N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.AnomaliaId',                        N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.DataResolucao',                     N'ResolvedAt',              N'COLUMN';
EXEC sp_rename N'dbo.AnomalyNotification.InstalacaoId',                      N'FacilityId',              N'COLUMN';

-- PericiaAnomalia → AnomalySkill
EXEC sp_rename N'dbo.PericiaAnomalia', N'AnomalySkill';
EXEC sp_rename N'dbo.AnomalySkill.AnomaliaId',                               N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill.Nome',                                     N'Name',                    N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill.Descricao',                                N'Description',             N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill.MecanismoPrimarioId',                      N'PrimaryMechanismId',      N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill.MecanismoSecundarioId',                    N'SecondaryMechanismId',    N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill.Nivel',                                    N'Level',                   N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill.Custo',                                    N'Cost',                    N'COLUMN';

-- Instancia_PericiaDesviante → Instance_DeviantSkill
EXEC sp_rename N'dbo.Instancia_PericiaDesviante', N'Instance_DeviantSkill';
EXEC sp_rename N'dbo.Instance_DeviantSkill.TipoInstancia',                   N'InstanceType',            N'COLUMN';
EXEC sp_rename N'dbo.Instance_DeviantSkill.InstanciaId',                     N'InstanceId',              N'COLUMN';
EXEC sp_rename N'dbo.Instance_DeviantSkill.PericiaDesvianteId',              N'DeviantSkillId',          N'COLUMN';
EXEC sp_rename N'dbo.Instance_DeviantSkill.DataDescoberta',                  N'DiscoveryDate',           N'COLUMN';
EXEC sp_rename N'dbo.Instance_DeviantSkill.Intensidade',                     N'Intensity',               N'COLUMN';
EXEC sp_rename N'dbo.Instance_DeviantSkill.Observacoes',                     N'Notes',                   N'COLUMN';

-- Pericia_Manifestacao → AnomalySkill_Manifestation
EXEC sp_rename N'dbo.Pericia_Manifestacao', N'AnomalySkill_Manifestation';
EXEC sp_rename N'dbo.AnomalySkill_Manifestation.PericiaAnomaliaId',          N'AnomalySkillId',          N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill_Manifestation.ManifestacaoEspecificaId',   N'SpecificManifestationId', N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill_Manifestation.Intensidade',                N'Intensity',               N'COLUMN';
EXEC sp_rename N'dbo.AnomalySkill_Manifestation.Observacoes',                N'Notes',                   N'COLUMN';

-- Incidente → Incident
EXEC sp_rename N'dbo.Incidente', N'Incident';
EXEC sp_rename N'dbo.Incident.AnomaliaId',                                   N'AnomalyId',               N'COLUMN';
EXEC sp_rename N'dbo.Incident.DataHora',                                     N'OccurredAt',              N'COLUMN';
EXEC sp_rename N'dbo.Incident.Tipo',                                         N'IncidentType',            N'COLUMN';
EXEC sp_rename N'dbo.Incident.Titulo',                                       N'Title',                   N'COLUMN';
EXEC sp_rename N'dbo.Incident.Relatorio',                                    N'Report',                  N'COLUMN';
EXEC sp_rename N'dbo.Incident.NivelSeguranca',                               N'SecurityLevel',           N'COLUMN';
EXEC sp_rename N'dbo.Incident.IsEventoSigma',                                N'IsSigmaEvent',            N'COLUMN';
EXEC sp_rename N'dbo.Incident.Mortes',                                       N'Fatalities',              N'COLUMN';
EXEC sp_rename N'dbo.Incident.Feridos',                                      N'Injuries',                N'COLUMN';
EXEC sp_rename N'dbo.Incident.DanoMaterial',                                 N'MaterialDamage',          N'COLUMN';

-- ── 4. Recreate the CHECKs, with explicit English names ─────────────────────
ALTER TABLE dbo.Cat_DangerLevel ADD CONSTRAINT CK_Cat_DangerLevel_Level CHECK (Level >= 1 AND Level <= 9);
ALTER TABLE dbo.Instance_DeviantSkill ADD CONSTRAINT CK_Instance_DeviantSkill_InstanceType CHECK (InstanceType IN ('ENTIDADE', 'ARTEFATO', 'LOCALIDADE', 'EVENTO'));
ALTER TABLE dbo.AnomalyNotification ADD CONSTRAINT CK_AnomalyNotification_PriorityLevel CHECK (PriorityLevel >= 1 AND PriorityLevel <= 5);
ALTER TABLE dbo.ContainmentProtocol ADD CONSTRAINT CK_ContainmentProtocol_UrgencyLevel CHECK (UrgencyLevel >= 1 AND UrgencyLevel <= 5);
ALTER TABLE dbo.Facility ADD CONSTRAINT CK_Facility_NotOwnParent CHECK (ParentFacilityId IS NULL OR ParentFacilityId <> Id);
ALTER TABLE dbo.Operation ADD CONSTRAINT CK_Operation_ClosedAfterOpened CHECK (ClosedAt IS NULL OR ClosedAt >= OpenedAt);
ALTER TABLE dbo.Operation ADD CONSTRAINT CK_Operation_Priority CHECK (Priority >= 1 AND Priority <= 5);

-- ── 5. Compatibility views: the OLD names over the English tables ───────────
EXEC sys.sp_executesql N'CREATE VIEW dbo.Anomalia AS SELECT Id, ScpCode AS CodigoSCP, CommonName AS NomeComum, Description AS Descricao, ObjectClassId AS ClasseObjetoId, OntologicalLayerId AS CamadaOntologicaId, MatterTypeId AS TipoMateriaId, ApparentCognitionId AS CognicaoAparenteId, DangerLevelId AS PericulosidadeId, PrimaryMechanismId AS MecanismoPrimarioId, SecondaryMechanismId AS MecanismoSecundarioId, IeiaDBaseline AS IEIA_D_Base, SpinCoherenceFactor AS FatorCoerenciaSpin, Status, ResearchLead AS ResponsavelPesquisa, CreatedAt AS DataCriacao, UpdatedAt AS DataAtualizacao, CreatedBy AS UsuarioCriacao, UpdatedBy AS UsuarioAtualizacao, ContainmentFacilityId AS InstalacaoContencaoId FROM dbo.Anomaly;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Artefato AS SELECT Id, AnomalyId AS AnomaliaId, Identification AS Identificacao, Material, ManufactureDate AS DataFabricacao, OriginPlace AS LocalOrigem, SpinProperty AS PropriedadeSpin, WeightKg AS Peso_Kg, Dimensions AS Dimensoes, UsageInstructions AS ModoUsar FROM dbo.Artifact;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.EntidadeViva AS SELECT Id, AnomalyId AS AnomaliaId, Identification AS Identificacao, Species AS Especie, Biology AS Biologia, PowerOrigin AS OrigemPoder, BirthDate AS DataNascimento, IsConscious AS IsConsciente, IntelligenceLevel AS NivelInteligencia, Diet AS Dieta, Notes AS Observacoes FROM dbo.LivingEntity;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Evento AS SELECT Id, AnomalyId AS AnomaliaId, Name AS Nome, StartsAt AS DataHoraInicio, EndsAt AS DataHoraFim, Periodicity AS Periodicidade, AffectedZone AS ZonaAfetada, AverageDuration AS DuracaoMedia, Preconditions AS PreCondicoes FROM dbo.AnomalyEvent;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Localidade AS SELECT Id, AnomalyId AS AnomaliaId, Name AS Nome, Coordinates AS Coordenadas, EffectRadiusMeters AS RaioEfeitoMetros, IeiaDAmbient AS IEIA_D_Ambiente, IsGeographicallyBounded AS IsGeograficamenteLimitada, TerrainType AS TipoTerreno, AnomalousClimate AS ClimaAnomalo FROM dbo.Location;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_ClasseObjeto AS SELECT Id, Code AS Codigo, Name AS Nome, ClassType AS TipoClasse, AcsClass AS ClasseACS, Description AS Descricao, MinClearanceLevel AS NivelAcessoMinimo, AlertColor AS CorAlerta, CreatedAt AS DataCriacao, IsActive AS Ativo FROM dbo.Cat_ObjectClass;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_ForcaFundamental AS SELECT Id, Symbol AS Simbolo, Name AS Nome, Description AS Descricao, CarrierParticle AS ParticulaPortadora FROM dbo.Cat_FundamentalForce;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_CamadaOntologica AS SELECT Id, Symbol AS Simbolo, Name AS Nome, Description AS Descricao, FundamentalForceId AS ForcaFundamentalId, Priority AS Prioridade FROM dbo.Cat_OntologicalLayer;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_TipoMateria AS SELECT Id, Name AS Nome, Description AS Descricao, IsSuppressorResistant AS IsResistenteSupressores FROM dbo.Cat_MatterType;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_MecanismoInteracao AS SELECT Id, Code AS Codigo, Name AS Nome, Description AS Descricao, OntologicalLayerId AS CamadaOntologicaId, IsSubNature AS EhSubnatureza FROM dbo.Cat_InteractionMechanism;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_ManifestacaoEspecifica AS SELECT Id, Code AS Codigo, Name AS Nome, Description AS Descricao FROM dbo.Cat_SpecificManifestation;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_CognicaoAparente AS SELECT Id, Code AS Codigo, Name AS Nome, Description AS Descricao FROM dbo.Cat_ApparentCognition;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_Periculosidade AS SELECT Id, Level AS Nivel, Name AS Nome, Description AS Descricao, AlertColor AS CorAlerta FROM dbo.Cat_DangerLevel;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_TipoInstalacao AS SELECT Id, Code AS Codigo, Name AS Nome, Description AS Descricao, AllowsChildren AS PermiteFilhos, IsActive AS Ativo FROM dbo.Cat_FacilityType;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Cat_Operacao AS SELECT Id, Code AS Codigo, Name AS Nome, Description AS Descricao, RequiresAnomaly AS RequerAnomalia, MinClearanceLevel AS NivelAcessoMinimo, AlertColor AS CorAlerta, IsActive AS Ativo FROM dbo.Cat_OperationType;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Instalacao AS SELECT Id, Code AS Codigo, Name AS Nome, Description AS Descricao, FacilityTypeId AS TipoInstalacaoId, ParentFacilityId AS InstalacaoPaiId, ResponsiblePerson AS Responsavel, Specialty AS Especialidade, MinClearanceLevel AS NivelAcessoMinimo, Status, CreatedAt AS DataCriacao, UpdatedAt AS DataAtualizacao, CreatedBy AS UsuarioCriacao, UpdatedBy AS UsuarioAtualizacao FROM dbo.Facility;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Operacao AS SELECT Id, Code AS Codigo, Codename AS Codinome, OperationTypeId AS TipoOperacaoId, FacilityId AS InstalacaoId, AnomalyId AS AnomaliaId, NotificationId AS NotificacaoId, ProtocolId AS ProtocoloId, Objective AS Objetivo, Description AS Descricao, Status, Priority AS Prioridade, MinClearanceLevel AS NivelAcessoMinimo, ResponsiblePerson AS Responsavel, OpenedAt AS DataAbertura, ExpectedEndAt AS DataPrevisaoTermino, ClosedAt AS DataEncerramento, ResultSummary AS ResultadoResumo, CreatedAt AS DataCriacao, UpdatedAt AS DataAtualizacao, CreatedBy AS UsuarioCriacao, UpdatedBy AS UsuarioAtualizacao FROM dbo.Operation;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.ProtocoloContencao AS SELECT Id, Code AS Codigo, Title AS Titulo, Description AS Descricao, UrgencyLevel AS NivelUrgencia, ApplicableClasses AS ClassesAplicaveis, Steps AS Passos, RequiredResources AS RecursosNecessarios, CreatedAt AS DataCriacao, UpdatedAt AS DataAtualizacao FROM dbo.ContainmentProtocol;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Protocolo_AplicadoEm AS SELECT ProtocolId AS ProtocoloId, AnomalyId AS AnomaliaId, ValidFrom AS DataInicio, ValidTo AS DataFim, Status, Notes AS Observacoes FROM dbo.Protocol_AppliedTo;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.NotificacaoAnomalia AS SELECT Id, Title AS Titulo, Description AS Descricao, ReportedLocation AS LocalIdentificado, ReportedAt AS DataHora, Status, PriorityLevel AS NivelPrioridade, Reporter AS Relator, AnomalyId AS AnomaliaId, ResolvedAt AS DataResolucao, FacilityId AS InstalacaoId FROM dbo.AnomalyNotification;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.PericiaAnomalia AS SELECT Id, AnomalyId AS AnomaliaId, Name AS Nome, Description AS Descricao, PrimaryMechanismId AS MecanismoPrimarioId, SecondaryMechanismId AS MecanismoSecundarioId, Level AS Nivel, Cost AS Custo FROM dbo.AnomalySkill;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Instancia_PericiaDesviante AS SELECT Id, InstanceType AS TipoInstancia, InstanceId AS InstanciaId, DeviantSkillId AS PericiaDesvianteId, DiscoveryDate AS DataDescoberta, Intensity AS Intensidade, Notes AS Observacoes FROM dbo.Instance_DeviantSkill;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Pericia_Manifestacao AS SELECT AnomalySkillId AS PericiaAnomaliaId, SpecificManifestationId AS ManifestacaoEspecificaId, Intensity AS Intensidade, Notes AS Observacoes FROM dbo.AnomalySkill_Manifestation;';
EXEC sys.sp_executesql N'CREATE VIEW dbo.Incidente AS SELECT Id, AnomalyId AS AnomaliaId, OccurredAt AS DataHora, IncidentType AS Tipo, Title AS Titulo, Report AS Relatorio, SecurityLevel AS NivelSeguranca, IsSigmaEvent AS IsEventoSigma, Fatalities AS Mortes, Injuries AS Feridos, MaterialDamage AS DanoMaterial FROM dbo.Incident;';

-- ── 6. Verification: the English tables and the compatibility views exist ───
IF (SELECT COUNT(*) FROM sys.tables WHERE name IN ('Anomaly', 'Artifact', 'LivingEntity', 'AnomalyEvent', 'Location', 'Cat_ObjectClass', 'Cat_FundamentalForce', 'Cat_OntologicalLayer', 'Cat_MatterType', 'Cat_InteractionMechanism', 'Cat_SpecificManifestation', 'Cat_ApparentCognition', 'Cat_DangerLevel', 'Cat_FacilityType', 'Cat_OperationType', 'Facility', 'Operation', 'ContainmentProtocol', 'Protocol_AppliedTo', 'AnomalyNotification', 'AnomalySkill', 'Instance_DeviantSkill', 'AnomalySkill_Manifestation', 'Incident')) <> 24
    THROW 50502, '0005 aborted: not every English table exists after the rename.', 1;
IF (SELECT COUNT(*) FROM sys.views WHERE name IN ('Anomalia', 'Artefato', 'EntidadeViva', 'Evento', 'Localidade', 'Cat_ClasseObjeto', 'Cat_ForcaFundamental', 'Cat_CamadaOntologica', 'Cat_TipoMateria', 'Cat_MecanismoInteracao', 'Cat_ManifestacaoEspecifica', 'Cat_CognicaoAparente', 'Cat_Periculosidade', 'Cat_TipoInstalacao', 'Cat_Operacao', 'Instalacao', 'Operacao', 'ProtocoloContencao', 'Protocolo_AplicadoEm', 'NotificacaoAnomalia', 'PericiaAnomalia', 'Instancia_PericiaDesviante', 'Pericia_Manifestacao', 'Incidente')) <> 24
    THROW 50503, '0005 aborted: not every compatibility view was created.', 1;
IF EXISTS (SELECT 1 FROM sys.triggers WHERE parent_class = 1 AND name IN ('TR_Anomalia_Update_Date', 'TR_Anomalia_Validar_Mecanismos', 'TR_Instalacao_Update_Date', 'TR_Instalacao_Validar_Hierarquia', 'TR_Operacao_Update_Date', 'TR_Operacao_Validar'))
    THROW 50504, '0005 aborted: an old trigger survived.', 1;
