-- =============================================================================
-- COLUMN descriptions — catalog tables (Cat_*).
-- Only columns with domain semantics are documented; self-evident Id/Ativo/DataCriacao
-- are left out on purpose (documenting the obvious is noise).
-- =============================================================================

-- ── Cat_ClasseObjeto ────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','Codigo',
 N'Business key of the class in the Brazilian vocabulary: PACATO, YAGUARA, ABAPORU, UKAR. It is what the public contract exposes — never the Id.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','TipoClasse',
 N'Primary or Secondary. Only primary classes are seeded today; the secondary axis is planned and unused.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','ClasseACS',
 N'Equivalent of the class in the canonical SCP/ACS vocabulary: SAFE, EUCLID, KETER, THAUMIEL. In practice it is an EXTERNAL VOCABULARY ALIAS embedded in the table — see DECCO-BACKLOG (ExternalMapping).';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','NivelAcessoMinimo',
 N'Minimum clearance (1..4) for an operator to SEE anomalies of this class. It is the hierarchical axis of resource-level authorization.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','CorAlerta',
 N'Hex severity color. The UI only READS this value — the design system severity palette is driven from here, not by a front-end constant.';

-- ── Cat_ForcaFundamental ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_ForcaFundamental','Simbolo',
 N'Business key of the force (Kappa, Lambda). WARNING: the type is CHAR(10) — values come back right-padded with spaces, which breaks the IdToCode Simbolo->Id dictionary. See DECCO-BACKLOG, finding 1.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ForcaFundamental','ParticulaPortadora',
 N'Fictional particle that mediates the force (Axion for Kappa; non-baryonic for Lambda). Lore element, no functional effect.';

-- ── Cat_CamadaOntologica ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica','Simbolo',
 N'Business key of the layer: THETA, PSI, PHI, OMEGA. Same CHAR(10) caveat as the fundamental force.';
EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica','ForcaFundamentalId',
 N'The fundamental force this layer derives from. THETA, PSI and PHI come from Kappa; OMEGA comes from Lambda.';
EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica','Prioridade',
 N'Display order and analytical precedence. OMEGA has priority 2 because it is the substrate layer; the others, 1.';

-- ── Cat_TipoMateria ─────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoMateria','Nome',
 N'Business key of the matter type (UNIQUE): Bariônica Anômala, Mista, Não-Bariônica, Indefinido.';
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoMateria','IsResistenteSupressores',
 N'True when the matter is immune to Theta suppression technology. Used by sp_Anomalia_Buscar as one of the criteria of the @ApenasSigma filter.';

-- ── Cat_MecanismoInteracao ──────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao','Codigo',
 N'Business key in the LAYER-LETTER format: A = Active (consumes a resource), B = Passive (intrinsic property), C = Conditional (depends on a trigger).';
EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao','CamadaOntologicaId',
 N'Layer the mechanism belongs to. The TR_Anomalia_Validar_Mecanismos trigger uses this relation to prevent an OMEGA anomaly from having a THETA sub-nature.';
EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao','EhSubnatureza',
 N'True if the mechanism can be used as the SECONDARY mechanism of an anomaly. Enforced by TR_Anomalia_Validar_Mecanismos. NAMING NOTE: it is the only boolean with the Eh prefix; the other 4 in the schema use Is.';

-- ── Cat_ManifestacaoEspecifica ──────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_ManifestacaoEspecifica','Codigo',
 N'Business key of the manifestation. The naming is inconsistent by inheritance: descriptive codes (METAMORFOSE) coexist with sequential codes (IGN-01, CRYO-05).';

-- ── Cat_CognicaoAparente ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_CognicaoAparente','Codigo',
 N'SE, SA, IN or AA. It is the third block of the OA identifier, in the OA-[####][CF|CN|CI|CMF]-[SE|SA|IN|AA] format, built by the application.';

-- ── Cat_Periculosidade ──────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_Periculosidade','Nivel',
 N'Scale from 1 (Minimum) to 9 (Maximum), with a CHECK in the database. It is the business key of this table — the Id is technical only.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Periculosidade','CorAlerta',
 N'Hex color of the level, in a green->red gradient. Read by the UI; do not duplicate the palette in the front end.';

-- ── Cat_TipoInstalacao ──────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoInstalacao','Codigo',
 N'Business key: SITIO, LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO. All four are inserted by migration 0002 (which needs them to migrate data) and converged by seed/090.';
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoInstalacao','PermiteFilhos',
 N'1 = root type, which contains other facilities (SITIO). 0 = a type that lives inside a root. Basis of the TR_Instalacao_Validar_Hierarquia rules.';

-- ── Cat_Operacao ────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','Codigo',
 N'Business key: INVESTIGACAO, PESQUISA, SUPRESSAO. Seeded only by seed/100 — no migration depends on them.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','RequerAnomalia',
 N'1 = the operation can only exist with a cataloged anomaly as its target (research, suppression). 0 = it can start from a field report (investigation). Enforced by TR_Operacao_Validar.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','NivelAcessoMinimo',
 N'Suggested minimum clearance for operations of this type. A reference for the application — each Operacao keeps its own NivelAcessoMinimo.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','CorAlerta',
 N'Hex color of the type, read by the UI.';
GO
