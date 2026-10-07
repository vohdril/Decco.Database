-- =============================================================================
-- Descrições de COLUNA — tabelas de domínio.
-- Inclui a recuperação das descrições que existiam na versão original do script
-- (banco Fundacao_SCP) e se perderam na consolidação — ver DECCO-BACKLOG.
-- =============================================================================

-- ── Anomalia ────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Anomalia','Id',
 N'Id interno, IDENTITY a partir de 1000. NÃO é a identidade pública — o contrato expõe CodigoSCP (padrão IdToCode).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','CodigoSCP',
 N'Identidade pública e estável da anomalia (ex.: SCP-1001). É por este código que consumidores externos referenciam o registro.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','NomeComum',
 N'Designação de uso corrente, legível por operadores (ex.: Proteu - O Metamorfo Complexo).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','ClasseObjetoId',
 N'Classe de contenção. Determina, via Cat_ClasseObjeto.NivelAcessoMinimo, o clearance necessário para ver esta anomalia.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','CamadaOntologicaId',
 N'Plano em que a anomalia opera (THETA/PSI/PHI/OMEGA). Junto com o tipo de matéria, define se ela entra no recorte Sigma.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','TipoMateriaId',
 N'Composição material. Matéria não-bariônica é resistente a supressores Theta e levanta bandeira Sigma.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','CognicaoAparenteId',
 N'Classificação brasileira de cognição (SE/SA/IN/AA). Nulo enquanto não aferida.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','PericulosidadeId',
 N'Classificação brasileira de periculosidade (1..9). Nulo enquanto não aferida.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','MecanismoPrimarioId',
 N'Mecanismo principal VISÍVEL — o COMO observável do fenômeno (ex.: transformação = THETA-C).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','MecanismoSecundarioId',
 N'Mecanismo subjacente, opcional. Só aceita mecanismos marcados como subnatureza, e OMEGA não pode ter subnatureza THETA — ambas as regras impostas por TR_Anomalia_Validar_Mecanismos.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','IEIA_D_Base',
 N'Índice de Enriquecimento Isotópico Anômalo para Deutério, medido no próprio objeto. Nível basal humano fica abaixo de 0,015%; acima de 0,1% indica uso ativo da camada Theta. É o marcador quantitativo central do sistema.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','FatorCoerenciaSpin',
 N'Grau de coerência do spin anômalo, em escala textual: Nulo, Baixo, Médio, Alto, Crítico. Crítico indica padrão de Spin Congelado com acoplamento a camada superior.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','Status',
 N'Estado do REGISTRO: ATIVA, NEUTRALIZADA, DESTRUIDA. NOTA: o valor EM_PESQUISA, em uso hoje, é estado de WORKFLOW e não de catálogo — migra para a esteira de classificação quando ela existir (DECCO-BACKLOG, achado 6).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','SitioContencao',
 N'Onde a anomalia está fisicamente contida. Hoje é TEXTO LIVRE e, por isso, serviu de fronteira de permissão improvisada. Vira FK para Instalacao — ver DECCO-BACKLOG, achado 7.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','ResponsavelPesquisa',
 N'Pesquisador responsável, em texto livre. É atributo de PROCESSO, não de catálogo — migra para a operação de pesquisa quando a entidade Operacao existir.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','DataAtualizacao',
 N'Mantida automaticamente por TR_Anomalia_Update_Date em todo UPDATE. É a única coluna de auditoria do schema realmente automática.';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','UsuarioCriacao',
 N'Preenchida com SYSTEM_USER por DEFAULT. Anomalia é a ÚNICA tabela do schema com auditoria de usuário — as demais só têm datas (DECCO-BACKLOG, achado 5).';
EXEC dbo.sp_Decco_SetDescription 'Anomalia','UsuarioAtualizacao',
 N'Atualizada por TR_Anomalia_Update_Date com SYSTEM_USER a cada UPDATE.';

-- ── EntidadeViva ────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','Identificacao',
 N'Designação da instância individual (ex.: Individuo-Alpha). A anomalia é o tipo; a entidade é o espécime.';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','Biologia',
 N'Natureza biológica observada (ex.: Bariônica Modificada). Complementa, no nível da instância, o tipo de matéria da anomalia-mãe.';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','OrigemPoder',
 N'Hipótese de como a entidade acessa a força de anomalia (ex.: Catalisador + Acesso PSI).';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','IsConsciente',
 N'Marcação operacional rápida de consciência. Não confundir com Cat_CognicaoAparente, que é a classificação formal da anomalia-mãe.';
EXEC dbo.sp_Decco_SetDescription 'EntidadeViva','NivelInteligencia',
 N'Escala numérica aferida em testes. Sem CHECK no banco — a faixa é convenção de domínio.';

-- ── Artefato ────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Artefato','PropriedadeSpin',
 N'Descrição do padrão de spin fixado no material (ex.: Spin Congelado com acoplamento OMEGA). É a assinatura física do mecanismo Theta-Passivo.';
EXEC dbo.sp_Decco_SetDescription 'Artefato','ModoUsar',
 N'Procedimento de ativação do artefato — ritual, gesto, catalisador. Para artefatos de mecanismo condicional, é onde o gatilho fica documentado.';

-- ── Localidade ──────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Localidade','Coordenadas',
 N'Posição geográfica (tipo GEOGRAPHY). Um dos recursos T-SQL que obrigam o DeccoDB a rodar em SQL Server e não em SQLite.';
EXEC dbo.sp_Decco_SetDescription 'Localidade','RaioEfeitoMetros',
 N'Alcance do efeito anômalo a partir das coordenadas. Base do cálculo de perímetro de evacuação nos protocolos.';
EXEC dbo.sp_Decco_SetDescription 'Localidade','IEIA_D_Ambiente',
 N'Leitura de IEIA-D do AMBIENTE, não do objeto. Flutuação acima do basal no perímetro é o gatilho típico de uma notificação de campo.';
EXEC dbo.sp_Decco_SetDescription 'Localidade','ClimaAnomalo',
 N'Padrão climático atípico associado à localidade, quando houver.';

-- ── Evento ──────────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Evento','Periodicidade',
 N'Padrão de recorrência do evento, em texto livre (ex.: mensal, lua cheia). Alimenta a previsão de janelas de observação.';
EXEC dbo.sp_Decco_SetDescription 'Evento','PreCondicoes',
 N'Condições que precisam estar satisfeitas para o evento disparar. É o equivalente, no nível do evento, do gatilho de um mecanismo condicional.';

-- ── Laboratorio ─────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Laboratorio','Sitio',
 N'Sítio de contenção a que o laboratório pertence. TEXTO LIVRE — o join com Anomalia.SitioContencao é por comparação de string. Vira FK para Instalacao (DECCO-BACKLOG, achado 7).';
EXEC dbo.sp_Decco_SetDescription 'Laboratorio','Especialidade',
 N'Área de atuação do laboratório (Biologia Anômala, Física Quântica, Narratologia...). É o único atributo que não é genérico de instalação.';
EXEC dbo.sp_Decco_SetDescription 'Laboratorio','NivelAcessoMinimo',
 N'Clearance mínimo para operar no laboratório. Eixo paralelo ao de Cat_ClasseObjeto: um recorta anomalias, o outro recorta lugares.';

-- ── ProtocoloContencao ──────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao','NivelUrgencia',
 N'Escala de 1 a 5, com CHECK. Nível 5 implica acionamento de equipe especializada e autorização de conselho.';
EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao','ClassesAplicaveis',
 N'Lista de códigos de classe separados por vírgula (ex.: UKAR,ABAPORU). DESNORMALIZADO de propósito no baseline — candidato natural a virar N:N com Cat_ClasseObjeto.';
EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao','Passos',
 N'Procedimento numerado, em texto. Conteúdo operacional lido pelo agente em campo.';

-- ── Protocolo_AplicadoEm ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Protocolo_AplicadoEm','DataInicio',
 N'Início da vigência deste protocolo nesta anomalia. Com DataFim, dá o histórico de qual protocolo valia em cada período.';
EXEC dbo.sp_Decco_SetDescription 'Protocolo_AplicadoEm','Status',
 N'Estado do vínculo (ATIVO por padrão). Permite suspender um protocolo sem apagar o histórico.';

-- ── NotificacaoAnomalia ─────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','LocalIdentificado',
 N'Onde o fenômeno foi relatado. TEXTO LIVRE porque a notificação pode vir de fora de qualquer instalação conhecida — nem toda ocorrência nasce dentro do perímetro.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','NivelPrioridade',
 N'Escala de 1 a 5, com CHECK. Ordena a fila de apuração.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','Relator',
 N'Quem reportou. Pode ser um operador nomeado ou Sistema Automático, quando a origem é sensor.';
EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia','AnomaliaId',
 N'Nulo até a apuração concluir. Quando preenchido, liga o relato de campo ao registro de catálogo que ele originou.';

-- ── PericiaAnomalia ─────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia','Nome',
 N'Designação da capacidade. UNIQUE por anomalia (UQ_Pericia_Anomalia_Nome) — a mesma anomalia não tem duas perícias homônimas.';
EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia','Nivel',
 N'Intensidade/maturidade da perícia. Escala de domínio, sem CHECK no banco.';
EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia','Custo',
 N'O que a anomalia consome para exercer a perícia (ex.: Nenhum; Deutério e ritual específico). É o que distingue mecanismo Ativo de Passivo na prática.';

-- ── Instancia_PericiaDesviante ──────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante','TipoInstancia',
 N'Discriminador polimórfico: ENTIDADE, ARTEFATO, LOCALIDADE ou EVENTO, com CHECK. Diz em qual tabela InstanciaId deve ser procurado.';
EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante','InstanciaId',
 N'Id na tabela indicada por TipoInstancia. SEM FK real — é referência polimórfica, e a integridade é responsabilidade da aplicação.';
EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante','Intensidade',
 N'Quanto a instância desvia do padrão da anomalia-mãe nesta perícia.';

-- ── Pericia_Manifestacao ────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Pericia_Manifestacao','Intensidade',
 N'Grau com que esta perícia produz esta manifestação (Baixa, Média, Alta, Variável). Qualifica o vínculo N:N.';

-- ── Incidente ───────────────────────────────────────────────────────────────
EXEC dbo.sp_Decco_SetDescription 'Incidente','Tipo',
 N'Natureza da ocorrência (Teste de Pesquisa, Falha de Contenção, Evento SIGMA...).';
EXEC dbo.sp_Decco_SetDescription 'Incidente','NivelSeguranca',
 N'Classificação de sigilo do relatório, em texto livre. Não é o clearance numérico do operador.';
EXEC dbo.sp_Decco_SetDescription 'Incidente','IsEventoSigma',
 N'Marca o incidente como Evento Sigma — gravidade excepcional, tipicamente envolvendo camada OMEGA ou matéria resistente a supressores. Contabilizado por vw_Relatorio_Sigma e pelo filtro @ApenasSigma de sp_Anomalia_Buscar.';
EXEC dbo.sp_Decco_SetDescription 'Incidente','DanoMaterial',
 N'Descrição do dano a instalações e equipamento. Texto livre, usado nos relatórios de consequência.';
GO
