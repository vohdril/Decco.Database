-- =============================================================================
-- COLUMN descriptions — domain tables.
-- Includes the recovery of descriptions that existed in the original version of the
-- script (Fundacao_SCP database) and were lost in the consolidation — see DECCO-BACKLOG.
-- =============================================================================

-- ── Anomalia ────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Anomalia','Id',
 N'Internal Id, IDENTITY starting at 1000. It is NOT the public identity — the contract exposes CodigoSCP (IdToCode pattern).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','CodigoSCP',
 N'Public, stable identity of the anomaly (e.g. SCP-1001). External consumers reference the record by this code.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','NomeComum',
 N'Common name, readable by operators (e.g. Proteu - O Metamorfo Complexo).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','ClasseObjetoId',
 N'Containment class. Through Cat_ClasseObjeto.NivelAcessoMinimo, it determines the clearance needed to see this anomaly.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','CamadaOntologicaId',
 N'Plane the anomaly operates on (THETA/PSI/PHI/OMEGA). Together with the matter type, it defines whether it falls into the Sigma slice.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','TipoMateriaId',
 N'Material composition. Non-baryonic matter resists Theta suppressors and raises the Sigma flag.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','CognicaoAparenteId',
 N'Brazilian cognition classification (SE/SA/IN/AA). Null until measured.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','PericulosidadeId',
 N'Brazilian dangerousness classification (1..9). Null until measured.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','MecanismoPrimarioId',
 N'Main VISIBLE mechanism — the observable HOW of the phenomenon (e.g. transformation = THETA-C).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','MecanismoSecundarioId',
 N'Underlying mechanism, optional. Only accepts mechanisms flagged as a sub-nature, and OMEGA cannot have a THETA sub-nature — both rules enforced by TR_Anomalia_Validar_Mecanismos.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','IEIA_D_Base',
 N'Anomalous Isotopic Enrichment Index for Deuterium, measured on the object itself. The human baseline is below 0.015%; above 0.1% indicates active use of the Theta layer. It is the central quantitative marker of the system.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','FatorCoerenciaSpin',
 N'Degree of anomalous spin coherence, on a textual scale: Nulo, Baixo, Médio, Alto, Crítico. Crítico indicates a Frozen Spin pattern coupled to a higher layer.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','Status',
 N'State of the RECORD: ATIVA, NEUTRALIZADA, DESTRUIDA. NOTE: the EM_PESQUISA value, used today, is a WORKFLOW state, not a catalog state — it moves to the classification pipeline once that exists (DECCO-BACKLOG, finding 6).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','InstalacaoContencaoId',
 N'Where the anomaly is physically contained: the most specific known facility (containment area or laboratory; otherwise, the site). Replaced the free-text SitioContencao (migrations 0002/0004). It is NOT a permission boundary: the anomaly is a global catalog, sliced by clearance; what is sliced by facility is Operacao.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','ResponsavelPesquisa',
 N'Responsible researcher, as free text. It is a PROCESS attribute, not a catalog one. The Operacao entity exists since 0003; moving this data to Operacao.Responsavel (PESQUISA type) is the next step, recorded in DECCO-BACKLOG.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','DataAtualizacao',
 N'Maintained automatically by TR_Anomalia_Update_Date on every UPDATE. Instalacao and Operacao follow the same pattern (TR_Instalacao_Update_Date, TR_Operacao_Update_Date); the baseline tables do not.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','UsuarioCriacao',
 N'Filled with SYSTEM_USER by DEFAULT. In the baseline, Anomalia was the only table with user auditing; Instalacao and Operacao are born with it. The other baseline tables only have dates (DECCO-BACKLOG, finding 5).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','UsuarioAtualizacao',
 N'Updated by TR_Anomalia_Update_Date with SYSTEM_USER on every UPDATE.';

-- ── EntidadeViva ────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','Identificacao',
 N'Designation of the individual instance (e.g. Individuo-Alpha). The anomaly is the type; the entity is the specimen.';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','Biologia',
 N'Observed biological nature (e.g. Bariônica Modificada). Complements, at instance level, the matter type of the parent anomaly.';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','OrigemPoder',
 N'Hypothesis of how the entity accesses the anomaly force (e.g. Catalisador + Acesso PSI).';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','IsConsciente',
 N'Quick operational consciousness flag. Not to be confused with Cat_CognicaoAparente, which is the formal classification of the parent anomaly.';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','NivelInteligencia',
 N'Numeric scale measured in tests. No CHECK in the database — the range is a domain convention.';

-- ── Artefato ────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Artefato','PropriedadeSpin',
 N'Description of the spin pattern fixed in the material (e.g. Spin Congelado com acoplamento OMEGA). It is the physical signature of the Theta-Passive mechanism.';
EXEC dbo.sp_Decco_SetDescription 'Artefato','ModoUsar',
 N'Activation procedure of the artifact — ritual, gesture, catalyst. For conditional-mechanism artifacts, this is where the trigger is documented.';

-- ── Localidade ──────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Localidade','Coordenadas',
 N'Geographic position (GEOGRAPHY type). One of the T-SQL features that require DeccoDB to run on SQL Server rather than SQLite.';
EXEC dbo.sp_Decco_SetDescription 'Localidade','RaioEfeitoMetros',
 N'Reach of the anomalous effect from the coordinates. Basis for the evacuation perimeter calculation in the protocols.';
EXEC dbo.sp_Decco_SetDescription 'Localidade','IEIA_D_Ambiente',
 N'IEIA-D reading of the ENVIRONMENT, not of the object. A fluctuation above baseline on the perimeter is the typical trigger of a field notification.';
EXEC dbo.sp_Decco_SetDescription 'Localidade','ClimaAnomalo',
 N'Atypical weather pattern associated with the location, when there is one.';

-- ── Evento ──────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Evento','Periodicidade',
 N'Recurrence pattern of the event, as free text (e.g. monthly, full moon). Feeds the forecast of observation windows.';
EXEC dbo.sp_Decco_SetDescription 'Evento','PreCondicoes',
 N'Conditions that must hold for the event to fire. The event-level equivalent of a conditional mechanism trigger.';

-- ── Instalacao ──────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Instalacao','Codigo',
 N'Public, stable identity (e.g. SITIO-19, LAB-BIO-19, AREA-001). It CANNOT be updated by sp_Instalacao_Atualizar: it is also the scoped cache key (decco:inst:{codigo}:*).';
EXEC dbo.sp_Decco_SetDescription 'Instalacao','TipoInstalacaoId',
 N'Facility type (Cat_TipoInstalacao). Defines whether it is a root or needs a parent.';
EXEC dbo.sp_Decco_SetDescription 'Instalacao','InstalacaoPaiId',
 N'Facility that contains this one (e.g. the site of a laboratory). Null only for root types. Maximum depth 2, no cycles — enforced by TR_Instalacao_Validar_Hierarquia.';
EXEC dbo.sp_Decco_SetDescription 'Instalacao','Especialidade',
 N'Field of work, relevant for laboratories (Biologia Anômala, Física Quântica, Narratologia...). Inherited from the former Laboratorio table.';
EXEC dbo.sp_Decco_SetDescription 'Instalacao','NivelAcessoMinimo',
 N'Minimum clearance to operate in the facility. An axis parallel to Cat_ClasseObjeto: one slices anomalies, the other slices places.';
EXEC dbo.sp_Decco_SetDescription 'Instalacao','Status',
 N'ATIVA, INATIVA or DESATIVADA, with a CHECK. Only an ATIVA facility receives a new operation (TR_Operacao_Validar).';

-- ── Operacao ────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Operacao','Codigo',
 N'Public identity in the OP-{year}-{sequence} format (e.g. OP-2026-0001), generated by sp_Operacao_Inserir when not provided.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','Codinome',
 N'Readable operational name (e.g. Jaguar Silente). Not unique — Codigo is the identity.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','TipoOperacaoId',
 N'Operation type (Cat_Operacao). If the type requires an anomaly, AnomaliaId is mandatory (TR_Operacao_Validar).';
EXEC dbo.sp_Decco_SetDescription 'Operacao','InstalacaoId',
 N'Facility that owns the operation — mandatory from creation and CANNOT be updated. It is the key of the permission slicing and of the scoped cache.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','AnomaliaId',
 N'Target anomaly, when already cataloged. Mandatory for types with RequerAnomalia = 1.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','NotificacaoId',
 N'Field report that originated the operation, when there is one — the typical path of an investigation.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','Status',
 N'PLANEJADA, EM_ANDAMENTO, SUSPENSA, CONCLUIDA or ABORTADA, with a CHECK. When it enters CONCLUIDA/ABORTADA, DataEncerramento is filled by sp_Operacao_Atualizar.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','Prioridade',
 N'Scale from 1 to 5, with a CHECK. Orders the operation list in sp_Operacao_Buscar.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','NivelAcessoMinimo',
 N'Minimum clearance to SEE the operation. Combined with the facility slicing, it makes up resource-level authorization.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','Responsavel',
 N'Person in charge, as free text. Becomes an FK to the user once DeccoAuthDB exists.';
EXEC dbo.sp_Decco_SetDescription 'Operacao','ResultadoResumo',
 N'Summary of the outcome, filled on closing.';

-- ── ProtocoloContencao ──────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao','NivelUrgencia',
 N'Scale from 1 to 5, with a CHECK. Level 5 implies calling a specialized team and council authorization.';
EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao','ClassesAplicaveis',
 N'Comma-separated list of class codes (e.g. UKAR,ABAPORU). DENORMALIZED on purpose in the baseline — a natural candidate to become an N:N with Cat_ClasseObjeto.';
EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao','Passos',
 N'Numbered procedure, as text. Operational content read by the agent in the field.';

-- ── Protocolo_AplicadoEm ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Protocolo_AplicadoEm','DataInicio',
 N'Start of validity of this protocol on this anomaly. With DataFim, it gives the history of which protocol applied in each period.';
EXEC dbo.sp_Decco_SetDescription 'Protocolo_AplicadoEm','Status',
 N'State of the link (ATIVO by default). Allows suspending a protocol without erasing the history.';

-- ── NotificacaoAnomalia ─────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','LocalIdentificado',
 N'Where the phenomenon was reported. FREE TEXT because the notification may come from outside any known facility — not every occurrence starts inside the perimeter.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','NivelPrioridade',
 N'Scale from 1 to 5, with a CHECK. Orders the investigation queue.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','Relator',
 N'Who reported it. Can be a named operator or Sistema Automático, when the source is a sensor.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','AnomaliaId',
 N'Null until the investigation concludes. When filled, it links the field report to the catalog record it originated.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','InstalacaoId',
 N'Known facility where the phenomenon was reported, when there is one. OPTIONAL: LocalIdentificado remains the textual description, and a report from outside the perimeter keeps this column null.';

-- ── PericiaAnomalia ─────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia','Nome',
 N'Name of the capability. UNIQUE per anomaly (UQ_Pericia_Anomalia_Nome) — the same anomaly has no two skills with the same name.';
EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia','Nivel',
 N'Intensity/maturity of the skill. Domain scale, no CHECK in the database.';
EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia','Custo',
 N'What the anomaly consumes to exercise the skill (e.g. Nenhum; Deutério e ritual específico). It is what tells an Active mechanism from a Passive one in practice.';

-- ── Instancia_PericiaDesviante ──────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante','TipoInstancia',
 N'Polymorphic discriminator: ENTIDADE, ARTEFATO, LOCALIDADE or EVENTO, with a CHECK. Tells which table InstanciaId must be looked up in.';
EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante','InstanciaId',
 N'Id in the table indicated by TipoInstancia. NO real FK — it is a polymorphic reference, and integrity is the application''s responsibility.';
EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante','Intensidade',
 N'How much the instance deviates from the parent anomaly pattern on this skill.';

-- ── Pericia_Manifestacao ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Pericia_Manifestacao','Intensidade',
 N'Degree to which this skill produces this manifestation (Baixa, Média, Alta, Variável). Qualifies the N:N link.';

-- ── Incidente ───────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Incidente','Tipo',
 N'Nature of the occurrence (Teste de Pesquisa, Falha de Contenção, Evento SIGMA...).';
EXEC dbo.sp_Decco_SetDescription 'Incidente','NivelSeguranca',
 N'Secrecy classification of the report, as free text. It is not the operator numeric clearance.';
EXEC dbo.sp_Decco_SetDescription 'Incidente','IsEventoSigma',
 N'Flags the incident as a Sigma Event — exceptional severity, typically involving the OMEGA layer or matter resistant to suppressors. Counted by vw_Relatorio_Sigma and by the @ApenasSigma filter of sp_Anomalia_Buscar.';
EXEC dbo.sp_Decco_SetDescription 'Incidente','DanoMaterial',
 N'Description of the damage to facilities and equipment. Free text, used in consequence reports.';
GO
