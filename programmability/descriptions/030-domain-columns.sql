-- =============================================================================
-- COLUMN descriptions — domain tables.
-- Includes the recovery of descriptions that existed in the original version of the
-- script (Fundacao_SCP database) and were lost in the consolidation — see DECCO-BACKLOG.
-- =============================================================================

-- ── Anomaly ────────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Anomaly','Id',
 N'Internal Id, IDENTITY starting at 1000. It is NOT the public identity — the contract exposes ScpCode (IdToCode pattern).';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','ScpCode',
 N'Public, stable identity of the anomaly (e.g. SCP-1001). External consumers reference the record by this code.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','CommonName',
 N'Common name, readable by operators (e.g. Proteu - O Metamorfo Complexo).';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','ObjectClassId',
 N'Containment class. Through Cat_ObjectClass.MinClearanceLevel, it determines the clearance needed to see this anomaly.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','OntologicalLayerId',
 N'Plane the anomaly operates on (THETA/PSI/PHI/OMEGA). Together with the matter type, it defines whether it falls into the Sigma slice.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','MatterTypeId',
 N'Material composition. Non-baryonic matter resists Theta suppressors and raises the Sigma flag.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','ApparentCognitionId',
 N'Brazilian cognition classification (SE/SA/IN/AA). Null until measured.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','DangerLevelId',
 N'Brazilian dangerousness classification (1..9). Null until measured.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','PrimaryMechanismId',
 N'Main VISIBLE mechanism — the observable HOW of the phenomenon (e.g. transformation = THETA-C).';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','SecondaryMechanismId',
 N'Underlying mechanism, optional. Only accepts mechanisms flagged as a sub-nature, and OMEGA cannot have a THETA sub-nature — both rules enforced by TR_Anomaly_ValidateMechanisms.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','IeiaDBaseline',
 N'Anomalous Isotopic Enrichment Index for Deuterium, measured on the object itself. The human baseline is below 0.015%; above 0.1% indicates active use of the Theta layer. It is the central quantitative marker of the system.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','SpinCoherenceFactor',
 N'Degree of anomalous spin coherence, on a textual scale: Nulo, Baixo, Médio, Alto, Crítico. Crítico indicates a Frozen Spin pattern coupled to a higher layer.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','Status',
 N'State of the RECORD: ATIVA, NEUTRALIZADA, DESTRUIDA. NOTE: the EM_PESQUISA value, used today, is a WORKFLOW state, not a catalog state — it moves to the classification pipeline once that exists (DECCO-BACKLOG, finding 6).';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','ContainmentFacilityId',
 N'Where the anomaly is physically contained: the most specific known facility (containment area or laboratory; otherwise, the site). Replaced the free-text SitioContencao (migrations 0002/0004). It is NOT a permission boundary: the anomaly is a global catalog, sliced by clearance; what is sliced by facility is Operation.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','ResearchLead',
 N'Responsible researcher, as free text. It is a PROCESS attribute, not a catalog one. The Operation entity exists since 0003; moving this data to Operation.ResponsiblePerson (PESQUISA type) is the next step, recorded in DECCO-BACKLOG.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','UpdatedAt',
 N'Maintained automatically by TR_Anomaly_SetUpdatedAt on every UPDATE. Facility and Operation follow the same pattern (TR_Facility_SetUpdatedAt, TR_Operation_SetUpdatedAt); the baseline tables do not.';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','CreatedBy',
 N'Filled with SYSTEM_USER by DEFAULT. In the baseline, Anomaly was the only table with user auditing; Facility and Operation are born with it. The other baseline tables only have dates (DECCO-BACKLOG, finding 5).';
EXEC dbo.usp_Decco_SetDescription 'Anomaly','UpdatedBy',
 N'Updated by TR_Anomaly_SetUpdatedAt with SYSTEM_USER on every UPDATE.';

-- ── LivingEntity ────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'LivingEntity','Identification',
 N'Designation of the individual instance (e.g. Individuo-Alpha). The anomaly is the type; the entity is the specimen.';
EXEC dbo.usp_Decco_SetDescription 'LivingEntity','Biology',
 N'Observed biological nature (e.g. Bariônica Modificada). Complements, at instance level, the matter type of the parent anomaly.';
EXEC dbo.usp_Decco_SetDescription 'LivingEntity','PowerOrigin',
 N'Hypothesis of how the entity accesses the anomaly force (e.g. Catalisador + Acesso PSI).';
EXEC dbo.usp_Decco_SetDescription 'LivingEntity','IsConscious',
 N'Quick operational consciousness flag. Not to be confused with Cat_ApparentCognition, which is the formal classification of the parent anomaly.';
EXEC dbo.usp_Decco_SetDescription 'LivingEntity','IntelligenceLevel',
 N'Numeric scale measured in tests. No CHECK in the database — the range is a domain convention.';

-- ── Artifact ────────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Artifact','SpinProperty',
 N'Description of the spin pattern fixed in the material (e.g. Spin Congelado com acoplamento OMEGA). It is the physical signature of the Theta-Passive mechanism.';
EXEC dbo.usp_Decco_SetDescription 'Artifact','UsageInstructions',
 N'Activation procedure of the artifact — ritual, gesture, catalyst. For conditional-mechanism artifacts, this is where the trigger is documented.';

-- ── Location ──────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Location','Coordinates',
 N'Geographic position (GEOGRAPHY type). One of the T-SQL features that require DeccoDB to run on SQL Server rather than SQLite.';
EXEC dbo.usp_Decco_SetDescription 'Location','EffectRadiusMeters',
 N'Reach of the anomalous effect from the coordinates. Basis for the evacuation perimeter calculation in the protocols.';
EXEC dbo.usp_Decco_SetDescription 'Location','IeiaDAmbient',
 N'IEIA-D reading of the ENVIRONMENT, not of the object. A fluctuation above baseline on the perimeter is the typical trigger of a field notification.';
EXEC dbo.usp_Decco_SetDescription 'Location','AnomalousClimate',
 N'Atypical weather pattern associated with the location, when there is one.';

-- ── AnomalyEvent ──────────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'AnomalyEvent','Periodicity',
 N'Recurrence pattern of the event, as free text (e.g. monthly, full moon). Feeds the forecast of observation windows.';
EXEC dbo.usp_Decco_SetDescription 'AnomalyEvent','Preconditions',
 N'Conditions that must hold for the event to fire. The event-level equivalent of a conditional mechanism trigger.';

-- ── Facility ──────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Facility','Code',
 N'Public, stable identity (e.g. SITIO-19, LAB-BIO-19, AREA-001). It CANNOT be updated by usp_Facility_Update: it is also the scoped cache key (decco:inst:{codigo}:*).';
EXEC dbo.usp_Decco_SetDescription 'Facility','FacilityTypeId',
 N'Facility type (Cat_FacilityType). Defines whether it is a root or needs a parent.';
EXEC dbo.usp_Decco_SetDescription 'Facility','ParentFacilityId',
 N'Facility that contains this one (e.g. the site of a laboratory). Null only for root types. Maximum depth 2, no cycles — enforced by TR_Facility_ValidateHierarchy.';
EXEC dbo.usp_Decco_SetDescription 'Facility','Specialty',
 N'Field of work, relevant for laboratories (Biologia Anômala, Física Quântica, Narratologia...). Inherited from the former Laboratorio table.';
EXEC dbo.usp_Decco_SetDescription 'Facility','MinClearanceLevel',
 N'Minimum clearance to operate in the facility. An axis parallel to Cat_ObjectClass: one slices anomalies, the other slices places.';
EXEC dbo.usp_Decco_SetDescription 'Facility','Status',
 N'ATIVA, INATIVA or DESATIVADA, with a CHECK. Only an ATIVA facility receives a new operation (TR_Operation_Validate).';

-- ── Operation ────────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Operation','Code',
 N'Public identity in the OP-{year}-{sequence} format (e.g. OP-2026-0001), generated by usp_Operation_Insert when not provided.';
EXEC dbo.usp_Decco_SetDescription 'Operation','Codename',
 N'Readable operational name (e.g. Jaguar Silente). Not unique — Code is the identity.';
EXEC dbo.usp_Decco_SetDescription 'Operation','OperationTypeId',
 N'Operation type (Cat_OperationType). If the type requires an anomaly, AnomalyId is mandatory (TR_Operation_Validate).';
EXEC dbo.usp_Decco_SetDescription 'Operation','FacilityId',
 N'Facility that owns the operation — mandatory from creation and CANNOT be updated. It is the key of the permission slicing and of the scoped cache.';
EXEC dbo.usp_Decco_SetDescription 'Operation','AnomalyId',
 N'Target anomaly, when already cataloged. Mandatory for types with RequiresAnomaly = 1.';
EXEC dbo.usp_Decco_SetDescription 'Operation','NotificationId',
 N'Field report that originated the operation, when there is one — the typical path of an investigation.';
EXEC dbo.usp_Decco_SetDescription 'Operation','Status',
 N'PLANEJADA, EM_ANDAMENTO, SUSPENSA, CONCLUIDA or ABORTADA, with a CHECK. When it enters CONCLUIDA/ABORTADA, ClosedAt is filled by usp_Operation_Update.';
EXEC dbo.usp_Decco_SetDescription 'Operation','Priority',
 N'Scale from 1 to 5, with a CHECK. Orders the operation list in usp_Operation_Search.';
EXEC dbo.usp_Decco_SetDescription 'Operation','MinClearanceLevel',
 N'Minimum clearance to SEE the operation. Combined with the facility slicing, it makes up resource-level authorization.';
EXEC dbo.usp_Decco_SetDescription 'Operation','ResponsiblePerson',
 N'Person in charge, as free text. Becomes an FK to the user once DeccoAuthDB exists.';
EXEC dbo.usp_Decco_SetDescription 'Operation','ResultSummary',
 N'Summary of the outcome, filled on closing.';

-- ── ContainmentProtocol ──────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'ContainmentProtocol','UrgencyLevel',
 N'Scale from 1 to 5, with a CHECK. Level 5 implies calling a specialized team and council authorization.';
EXEC dbo.usp_Decco_SetDescription 'ContainmentProtocol','ApplicableClasses',
 N'Comma-separated list of class codes (e.g. UKAR,ABAPORU). DENORMALIZED on purpose in the baseline — a natural candidate to become an N:N with Cat_ObjectClass.';
EXEC dbo.usp_Decco_SetDescription 'ContainmentProtocol','Steps',
 N'Numbered procedure, as text. Operational content read by the agent in the field.';

-- ── Protocol_AppliedTo ────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Protocol_AppliedTo','ValidFrom',
 N'Start of validity of this protocol on this anomaly. With ValidTo, it gives the history of which protocol applied in each period.';
EXEC dbo.usp_Decco_SetDescription 'Protocol_AppliedTo','Status',
 N'State of the link (ATIVO by default). Allows suspending a protocol without erasing the history.';

-- ── AnomalyNotification ─────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'AnomalyNotification','ReportedLocation',
 N'Where the phenomenon was reported. FREE TEXT because the notification may come from outside any known facility — not every occurrence starts inside the perimeter.';
EXEC dbo.usp_Decco_SetDescription 'AnomalyNotification','PriorityLevel',
 N'Scale from 1 to 5, with a CHECK. Orders the investigation queue.';
EXEC dbo.usp_Decco_SetDescription 'AnomalyNotification','Reporter',
 N'Who reported it. Can be a named operator or Sistema Automático, when the source is a sensor.';
EXEC dbo.usp_Decco_SetDescription 'AnomalyNotification','AnomalyId',
 N'Null until the investigation concludes. When filled, it links the field report to the catalog record it originated.';
EXEC dbo.usp_Decco_SetDescription 'AnomalyNotification','FacilityId',
 N'Known facility where the phenomenon was reported, when there is one. OPTIONAL: ReportedLocation remains the textual description, and a report from outside the perimeter keeps this column null.';

-- ── AnomalySkill ─────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'AnomalySkill','Name',
 N'Name of the capability. UNIQUE per anomaly (UQ_AnomalySkill_Anomaly_Name) — the same anomaly has no two skills with the same name.';
EXEC dbo.usp_Decco_SetDescription 'AnomalySkill','Level',
 N'Intensity/maturity of the skill. Domain scale, no CHECK in the database.';
EXEC dbo.usp_Decco_SetDescription 'AnomalySkill','Cost',
 N'What the anomaly consumes to exercise the skill (e.g. Nenhum; Deutério e ritual específico). It is what tells an Active mechanism from a Passive one in practice.';

-- ── Instance_DeviantSkill ──────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Instance_DeviantSkill','InstanceType',
 N'Polymorphic discriminator: ENTIDADE, ARTEFATO, LOCALIDADE or EVENTO, with a CHECK. Tells which table InstanceId must be looked up in.';
EXEC dbo.usp_Decco_SetDescription 'Instance_DeviantSkill','InstanceId',
 N'Id in the table indicated by InstanceType. NO real FK — it is a polymorphic reference, and integrity is the application''s responsibility.';
EXEC dbo.usp_Decco_SetDescription 'Instance_DeviantSkill','Intensity',
 N'How much the instance deviates from the parent anomaly pattern on this skill.';

-- ── AnomalySkill_Manifestation ────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'AnomalySkill_Manifestation','Intensity',
 N'Degree to which this skill produces this manifestation (Baixa, Média, Alta, Variável). Qualifies the N:N link.';

-- ── Incident ───────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Incident','IncidentType',
 N'Nature of the occurrence (Teste de Pesquisa, Falha de Contenção, Evento SIGMA...).';
EXEC dbo.usp_Decco_SetDescription 'Incident','SecurityLevel',
 N'Secrecy classification of the report, as free text. It is not the operator numeric clearance.';
EXEC dbo.usp_Decco_SetDescription 'Incident','IsSigmaEvent',
 N'Flags the incident as a Sigma Event — exceptional severity, typically involving the OMEGA layer or matter resistant to suppressors. Counted by vw_SigmaReport and by the @SigmaOnly filter of usp_Anomaly_Search.';
EXEC dbo.usp_Decco_SetDescription 'Incident','MaterialDamage',
 N'Description of the damage to facilities and equipment. Free text, used in consequence reports.';
GO
