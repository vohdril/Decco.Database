-- =============================================================================
-- Descrições de COLUNA — tabelas de catálogo (Cat_*).
-- Documentadas as colunas com semântica de domínio; Id/Ativo/DataCriacao
-- autoevidentes ficam de fora de propósito (documentar o óbvio é ruído).
-- =============================================================================

-- ── Cat_ClasseObjeto ────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','Codigo',
 N'Chave de negócio da classe no vocabulário brasileiro: PACATO, YAGUARA, ABAPORU, UKAR. É o que o contrato público expõe — nunca o Id.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','TipoClasse',
 N'Primária ou Secundária. Hoje só existem classes primárias semeadas; o eixo secundário está previsto e não usado.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','ClasseACS',
 N'Equivalente da classe no vocabulário canônico SCP/ACS: SAFE, EUCLID, KETER, THAUMIEL. É, na prática, um ALIAS DE VOCABULÁRIO EXTERNO embutido na tabela — ver DECCO-BACKLOG (MapeamentoExterno).';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','NivelAcessoMinimo',
 N'Clearance mínimo (1..4) para que um operador possa VER anomalias desta classe. É o eixo hierárquico da autorização a nível de recurso.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto','CorAlerta',
 N'Cor hexadecimal de severidade. A UI apenas LÊ este valor — a paleta de severidade do design system é dirigida por aqui, não por constante no front.';

-- ── Cat_ForcaFundamental ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_ForcaFundamental','Simbolo',
 N'Chave de negócio da força (Kappa, Lambda). ATENÇÃO: o tipo é CHAR(10) — valores são preenchidos com espaços à direita na leitura, o que quebra o dicionário Simbolo->Id do IdToCode. Ver DECCO-BACKLOG, achado 1.';
EXEC dbo.sp_Decco_SetDescription 'Cat_ForcaFundamental','ParticulaPortadora',
 N'Partícula fictícia que medeia a força (Áxion para Kappa; não-bariônica para Lambda). Elemento de lore, sem efeito funcional.';

-- ── Cat_CamadaOntologica ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica','Simbolo',
 N'Chave de negócio da camada: THETA, PSI, PHI, OMEGA. Mesma ressalva de CHAR(10) da força fundamental.';
EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica','ForcaFundamentalId',
 N'A força fundamental de que esta camada deriva. THETA, PSI e PHI vêm de Kappa; OMEGA vem de Lambda.';
EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica','Prioridade',
 N'Ordem de apresentação e de precedência analítica. OMEGA tem prioridade 2 por ser a camada de substrato; as demais, 1.';

-- ── Cat_TipoMateria ─────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoMateria','Nome',
 N'Chave de negócio do tipo de matéria (é UNIQUE): Bariônica Anômala, Mista, Não-Bariônica, Indefinido.';
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoMateria','IsResistenteSupressores',
 N'Verdadeiro quando a matéria é imune à tecnologia de supressão Theta. Usado por sp_Anomalia_Buscar como um dos critérios do filtro @ApenasSigma.';

-- ── Cat_MecanismoInteracao ──────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao','Codigo',
 N'Chave de negócio no formato CAMADA-LETRA: A = Ativo (consome recurso), B = Passivo (propriedade intrínseca), C = Condicional (depende de gatilho).';
EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao','CamadaOntologicaId',
 N'Camada a que o mecanismo pertence. O trigger TR_Anomalia_Validar_Mecanismos usa esta relação para impedir que uma anomalia OMEGA tenha subnatureza THETA.';
EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao','EhSubnatureza',
 N'Verdadeiro se o mecanismo pode ser usado como SECUNDÁRIO de uma anomalia. Imposto por TR_Anomalia_Validar_Mecanismos. NOTA DE NOMENCLATURA: é o único booleano com prefixo Eh; os outros 4 do schema usam Is.';

-- ── Cat_ManifestacaoEspecifica ──────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_ManifestacaoEspecifica','Codigo',
 N'Chave de negócio da manifestação. A nomenclatura é inconsistente por herança: convivem códigos descritivos (METAMORFOSE) e códigos sequenciais (IGN-01, CRYO-05).';

-- ── Cat_CognicaoAparente ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_CognicaoAparente','Codigo',
 N'SE, SA, IN ou AA. É o terceiro bloco do identificador OA, no formato OA-[####][CF|CN|CI|CMF]-[SE|SA|IN|AA], montado na aplicação.';

-- ── Cat_Periculosidade ──────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_Periculosidade','Nivel',
 N'Escala de 1 (Mínimo) a 9 (Máximo), com CHECK no banco. É a chave de negócio desta tabela — o Id é apenas técnico.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Periculosidade','CorAlerta',
 N'Cor hexadecimal do nível, em gradiente verde->vermelho. Lida pela UI; não duplicar a paleta no front.';

-- ── Cat_TipoInstalacao ──────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoInstalacao','Codigo',
 N'Chave de negócio: SITIO, LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO. Os quatro são inseridos pela migração 0002 (que depende deles para migrar dados) e convergidos pelo seed/090.';
EXEC dbo.sp_Decco_SetDescription 'Cat_TipoInstalacao','PermiteFilhos',
 N'1 = tipo raiz, que contém outras instalações (SITIO). 0 = tipo que vive dentro de um raiz. Base das regras de TR_Instalacao_Validar_Hierarquia.';

-- ── Cat_Operacao ────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','Codigo',
 N'Chave de negócio: INVESTIGACAO, PESQUISA, SUPRESSAO. Semeados apenas pelo seed/100 — nenhuma migração depende deles.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','RequerAnomalia',
 N'1 = a operação só pode existir com uma anomalia catalogada como alvo (pesquisa, supressão). 0 = pode nascer de um relato de campo (investigação). Imposto por TR_Operacao_Validar.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','NivelAcessoMinimo',
 N'Clearance mínimo sugerido para operações deste tipo. Referência para a aplicação — cada Operacao guarda o seu próprio NivelAcessoMinimo.';
EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao','CorAlerta',
 N'Cor hexadecimal do tipo, lida pela UI.';
GO
