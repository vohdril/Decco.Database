-- =============================================================================
-- COLUMN descriptions — catalog tables (Cat_*).
-- Only columns with domain semantics are documented; self-evident Id/IsActive/CreatedAt
-- are left out on purpose (documenting the obvious is noise).
-- =============================================================================

-- ── Cat_ObjectClass ────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_ObjectClass','Code',
 N'Business key of the class in the Brazilian vocabulary: PACATO, YAGUARA, ABAPORU, UKAR. It is what the public contract exposes — never the Id.';
EXEC dbo.usp_Decco_SetDescription 'Cat_ObjectClass','ClassType',
 N'Primary or Secondary. Only primary classes are seeded today; the secondary axis is planned and unused.';
EXEC dbo.usp_Decco_SetDescription 'Cat_ObjectClass','AcsClass',
 N'Equivalent of the class in the canonical SCP/ACS vocabulary: SAFE, EUCLID, KETER, THAUMIEL. In practice it is an EXTERNAL VOCABULARY ALIAS embedded in the table — see DECCO-BACKLOG (ExternalMapping).';
EXEC dbo.usp_Decco_SetDescription 'Cat_ObjectClass','MinClearanceLevel',
 N'Minimum clearance (1..4) for an operator to SEE anomalies of this class. It is the hierarchical axis of resource-level authorization.';
EXEC dbo.usp_Decco_SetDescription 'Cat_ObjectClass','AlertColor',
 N'Hex severity color. The UI only READS this value — the design system severity palette is driven from here, not by a front-end constant.';

-- ── Cat_FundamentalForce ────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_FundamentalForce','Symbol',
 N'Business key of the force (Kappa, Lambda). WARNING: the type is CHAR(10) — values come back right-padded with spaces, which breaks the IdToCode Symbol->Id dictionary. See DECCO-BACKLOG, finding 1.';
EXEC dbo.usp_Decco_SetDescription 'Cat_FundamentalForce','CarrierParticle',
 N'Fictional particle that mediates the force (Axion for Kappa; non-baryonic for Lambda). Lore element, no functional effect.';

-- ── Cat_OntologicalLayer ────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_OntologicalLayer','Symbol',
 N'Business key of the layer: THETA, PSI, PHI, OMEGA. Same CHAR(10) caveat as the fundamental force.';
EXEC dbo.usp_Decco_SetDescription 'Cat_OntologicalLayer','FundamentalForceId',
 N'The fundamental force this layer derives from. THETA, PSI and PHI come from Kappa; OMEGA comes from Lambda.';
EXEC dbo.usp_Decco_SetDescription 'Cat_OntologicalLayer','Priority',
 N'Display order and analytical precedence. OMEGA has priority 2 because it is the substrate layer; the others, 1.';

-- ── Cat_MatterType ─────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_MatterType','Name',
 N'Business key of the matter type (UNIQUE): Bariônica Anômala, Mista, Não-Bariônica, Indefinido.';
EXEC dbo.usp_Decco_SetDescription 'Cat_MatterType','IsSuppressorResistant',
 N'True when the matter is immune to Theta suppression technology. Used by usp_Anomaly_Search as one of the criteria of the @SigmaOnly filter.';

-- ── Cat_InteractionMechanism ──────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_InteractionMechanism','Code',
 N'Business key in the LAYER-LETTER format: A = Active (consumes a resource), B = Passive (intrinsic property), C = Conditional (depends on a trigger).';
EXEC dbo.usp_Decco_SetDescription 'Cat_InteractionMechanism','OntologicalLayerId',
 N'Layer the mechanism belongs to. The TR_Anomaly_ValidateMechanisms trigger uses this relation to prevent an OMEGA anomaly from having a THETA sub-nature.';
EXEC dbo.usp_Decco_SetDescription 'Cat_InteractionMechanism','IsSubNature',
 N'True if the mechanism can be used as the SECONDARY mechanism of an anomaly. Enforced by TR_Anomaly_ValidateMechanisms. NAMING NOTE: it is the only boolean with the Eh prefix; the other 4 in the schema use Is.';

-- ── Cat_SpecificManifestation ──────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_SpecificManifestation','Code',
 N'Business key of the manifestation. The naming is inconsistent by inheritance: descriptive codes (METAMORFOSE) coexist with sequential codes (IGN-01, CRYO-05).';

-- ── Cat_ApparentCognition ────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_ApparentCognition','Code',
 N'SE, SA, IN or AA. It is the third block of the OA identifier, in the OA-[####][CF|CN|CI|CMF]-[SE|SA|IN|AA] format, built by the application.';

-- ── Cat_DangerLevel ──────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_DangerLevel','Level',
 N'Scale from 1 (Minimum) to 9 (Maximum), with a CHECK in the database. It is the business key of this table — the Id is technical only.';
EXEC dbo.usp_Decco_SetDescription 'Cat_DangerLevel','AlertColor',
 N'Hex color of the level, in a green->red gradient. Read by the UI; do not duplicate the palette in the front end.';

-- ── Cat_FacilityType ──────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_FacilityType','Code',
 N'Business key: SITIO, LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO. All four are inserted by migration 0002 (which needs them to migrate data) and converged by seed/090.';
EXEC dbo.usp_Decco_SetDescription 'Cat_FacilityType','AllowsChildren',
 N'1 = root type, which contains other facilities (SITIO). 0 = a type that lives inside a root. Basis of the TR_Facility_ValidateHierarchy rules.';

-- ── Cat_OperationType ────────────────────────────────────────────────────────────
EXEC dbo.usp_Decco_SetDescription 'Cat_OperationType','Code',
 N'Business key: INVESTIGACAO, PESQUISA, SUPRESSAO. Seeded only by seed/100 — no migration depends on them.';
EXEC dbo.usp_Decco_SetDescription 'Cat_OperationType','RequiresAnomaly',
 N'1 = the operation can only exist with a cataloged anomaly as its target (research, suppression). 0 = it can start from a field report (investigation). Enforced by TR_Operation_Validate.';
EXEC dbo.usp_Decco_SetDescription 'Cat_OperationType','MinClearanceLevel',
 N'Suggested minimum clearance for operations of this type. A reference for the application — each Operation keeps its own MinClearanceLevel.';
EXEC dbo.usp_Decco_SetDescription 'Cat_OperationType','AlertColor',
 N'Hex color of the type, read by the UI.';
GO
