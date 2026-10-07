-- =============================================================================
-- 0007 — Explicit names for every constraint and index
--
-- 120 of the 128 constraints had SYSTEM-GENERATED names (PK__Anomalia__3214EC07…).
-- The suffix changes every time a database is created, so the same constraint had a
-- different name in DeccoDB, in the rehearsal copies and in Docker — and the EF
-- configurations of Decco.API already carried names that no longer exist anywhere.
-- From here on every name is deterministic:
--
--   PK_{Table}   UQ_{Table}_{Column}   FK_{Table}_{Role}   DF_{Table}_{Column}
--   (Role = the FK column without its trailing "Id")
--
-- The generated names are looked up in the catalog, never written as literals.
-- Renaming a PK or UQ constraint also renames the index behind it.
-- The named Portuguese constraints and indexes are renamed explicitly.
-- The 4 generated CHECKs were already recreated with explicit names by 0005.
--
-- ⚠️ ONE SINGLE BATCH (no GO) — see 0004/0005.
--
-- Depends on: 0005_expand_english_names.sql
-- =============================================================================
SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @sql NVARCHAR(MAX) = N'';

-- ── Primary keys → PK_{Table} ───────────────────────────────────────────────
SELECT @sql += N'EXEC sp_rename N''dbo.' + QUOTENAME(k.name) + N''', N''PK_' + t.name + N''', N''OBJECT'';' + NCHAR(10)
  FROM sys.key_constraints k
  JOIN sys.tables t ON t.object_id = k.parent_object_id
 WHERE k.type = 'PK' AND k.is_system_named = 1;

-- ── Unique constraints → UQ_{Table}_{Column} (all generated ones are single-column)
SELECT @sql += N'EXEC sp_rename N''dbo.' + QUOTENAME(k.name) + N''', N''UQ_' + t.name + N'_' + c.name + N''', N''OBJECT'';' + NCHAR(10)
  FROM sys.key_constraints k
  JOIN sys.tables t         ON t.object_id = k.parent_object_id
  JOIN sys.index_columns ic ON ic.object_id = k.parent_object_id AND ic.index_id = k.unique_index_id
  JOIN sys.columns c        ON c.object_id = ic.object_id AND c.column_id = ic.column_id
 WHERE k.type = 'UQ' AND k.is_system_named = 1;

-- ── Foreign keys → FK_{Table}_{Role} ─────────────────────────────────────────
SELECT @sql += N'EXEC sp_rename N''dbo.' + QUOTENAME(fk.name) + N''', N''FK_' + t.name + N'_' + LEFT(c.name, LEN(c.name) - 2) + N''', N''OBJECT'';' + NCHAR(10)
  FROM sys.foreign_keys fk
  JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
  JOIN sys.tables t  ON t.object_id = fk.parent_object_id
  JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
 WHERE fk.is_system_named = 1;

-- ── Defaults → DF_{Table}_{Column} ──────────────────────────────────────────
SELECT @sql += N'EXEC sp_rename N''dbo.' + QUOTENAME(d.name) + N''', N''DF_' + t.name + N'_' + c.name + N''', N''OBJECT'';' + NCHAR(10)
  FROM sys.default_constraints d
  JOIN sys.tables t  ON t.object_id = d.parent_object_id
  JOIN sys.columns c ON c.object_id = d.parent_object_id AND c.column_id = d.parent_column_id
 WHERE d.is_system_named = 1;

EXEC sys.sp_executesql @sql;

-- ── Named constraints and indexes ───────────────────────────────────────────
EXEC sp_rename N'dbo.CK_Instalacao_Status',                                                  N'CK_Facility_Status',                      N'OBJECT';
EXEC sp_rename N'dbo.CK_Operacao_Status',                                                    N'CK_Operation_Status',                     N'OBJECT';
EXEC sp_rename N'dbo.FK_Anomalia_InstalacaoContencao',                                       N'FK_Anomaly_ContainmentFacility',          N'OBJECT';
EXEC sp_rename N'dbo.FK_NotificacaoAnomalia_Instalacao',                                     N'FK_AnomalyNotification_Facility',         N'OBJECT';
EXEC sp_rename N'dbo.UQ_Pericia_Anomalia_Nome',                                              N'UQ_AnomalySkill_Anomaly_Name',            N'OBJECT';
EXEC sp_rename N'dbo.Anomaly.IX_Anomalia_CodigoSCP',                                         N'IX_Anomaly_ScpCode',                      N'INDEX';
EXEC sp_rename N'dbo.Anomaly.IX_Anomalia_InstalacaoContencao',                               N'IX_Anomaly_ContainmentFacility',          N'INDEX';
EXEC sp_rename N'dbo.Anomaly.IX_Anomalia_Status',                                            N'IX_Anomaly_Status',                       N'INDEX';
EXEC sp_rename N'dbo.Artifact.IX_Artefato_AnomaliaId',                                       N'IX_Artifact_AnomalyId',                   N'INDEX';
EXEC sp_rename N'dbo.LivingEntity.IX_EntidadeViva_AnomaliaId',                               N'IX_LivingEntity_AnomalyId',               N'INDEX';
EXEC sp_rename N'dbo.AnomalyEvent.IX_Evento_AnomaliaId',                                     N'IX_AnomalyEvent_AnomalyId',               N'INDEX';
EXEC sp_rename N'dbo.Incident.IX_Incidente_Anomalia',                                        N'IX_Incident_Anomaly',                     N'INDEX';
EXEC sp_rename N'dbo.Facility.IX_Instalacao_Pai',                                            N'IX_Facility_Parent',                      N'INDEX';
EXEC sp_rename N'dbo.Facility.IX_Instalacao_Tipo',                                           N'IX_Facility_Type',                        N'INDEX';
EXEC sp_rename N'dbo.Instance_DeviantSkill.IX_Instancia_PericiaDesviante_Instancia',         N'IX_Instance_DeviantSkill_Instance',       N'INDEX';
EXEC sp_rename N'dbo.Instance_DeviantSkill.IX_Instancia_PericiaDesviante_Pericia',           N'IX_Instance_DeviantSkill_DeviantSkill',   N'INDEX';
EXEC sp_rename N'dbo.Location.IX_Localidade_AnomaliaId',                                     N'IX_Location_AnomalyId',                   N'INDEX';
EXEC sp_rename N'dbo.AnomalyNotification.IX_NotificacaoAnomalia_Data',                       N'IX_AnomalyNotification_ReportedAt',       N'INDEX';
EXEC sp_rename N'dbo.AnomalyNotification.IX_NotificacaoAnomalia_Instalacao',                 N'IX_AnomalyNotification_Facility',         N'INDEX';
EXEC sp_rename N'dbo.AnomalyNotification.IX_NotificacaoAnomalia_Status',                     N'IX_AnomalyNotification_Status',           N'INDEX';
EXEC sp_rename N'dbo.Operation.IX_Operacao_Anomalia',                                        N'IX_Operation_Anomaly',                    N'INDEX';
EXEC sp_rename N'dbo.Operation.IX_Operacao_Instalacao',                                      N'IX_Operation_Facility',                   N'INDEX';
EXEC sp_rename N'dbo.Operation.IX_Operacao_Status',                                          N'IX_Operation_Status',                     N'INDEX';
EXEC sp_rename N'dbo.Operation.IX_Operacao_Tipo',                                            N'IX_Operation_Type',                       N'INDEX';
EXEC sp_rename N'dbo.Protocol_AppliedTo.IX_Protocolo_AplicadoEm_Anomalia',                   N'IX_Protocol_AppliedTo_Anomaly',           N'INDEX';

-- ── Verification: no generated name survives ────────────────────────────────
IF EXISTS (SELECT 1 FROM sys.key_constraints     WHERE is_system_named = 1)
OR EXISTS (SELECT 1 FROM sys.foreign_keys        WHERE is_system_named = 1)
OR EXISTS (SELECT 1 FROM sys.default_constraints WHERE is_system_named = 1)
OR EXISTS (SELECT 1 FROM sys.check_constraints   WHERE is_system_named = 1)
    THROW 50701, '0007 aborted: a system-named constraint survived.', 1;
