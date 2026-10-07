-- =============================================================================
-- Descrições de TABELA — as 24 tabelas do DeccoDB (21 do baseline − Laboratorio + 4 da 0002/0003).
-- Vocabulário de lore ancorado em LORE-DECCO-BRUTO.md (raiz do workspace).
-- Run-always, idempotente via sp_Decco_SetDescription.
-- =============================================================================

-- ── Catálogos (read-only, alvo de IdToCode/CodeToId) ────────────────────────

EXEC dbo.sp_Decco_SetDescription 'Cat_ClasseObjeto', NULL,
 N'CATÁLOGO. Classe de contenção da anomalia no sistema brasileiro (PACATO, YAGUARA, ABAPORU, UKAR), com o equivalente do vocabulário ACS/SCP em ClasseACS. Define o clearance mínimo para ver a anomalia e a cor de severidade da UI.';

EXEC dbo.sp_Decco_SetDescription 'Cat_ForcaFundamental', NULL,
 N'CATÁLOGO. As forças fundamentais fictícias que originam os fenômenos anômalos: Kappa (campo de coerência informacional) e Lambda (substrato não-bariônico consciente). É a raiz da árvore ontológica — toda camada deriva de uma força.';

EXEC dbo.sp_Decco_SetDescription 'Cat_CamadaOntologica', NULL,
 N'CATÁLOGO. Em que plano a anomalia opera: THETA (física anômala, maioria dos casos), PSI (narrativo/informacional), PHI (consciência/digital), OMEGA (substrato não-bariônico). Cada camada pertence a uma força fundamental.';

EXEC dbo.sp_Decco_SetDescription 'Cat_TipoMateria', NULL,
 N'CATÁLOGO. Do que a anomalia é feita: Bariônica Anômala, Mista, Não-Bariônica ou Indefinido. O flag IsResistenteSupressores marca a matéria imune à tecnologia de supressão Theta.';

EXEC dbo.sp_Decco_SetDescription 'Cat_MecanismoInteracao', NULL,
 N'CATÁLOGO. COMO a anomalia age sobre a realidade, no formato CAMADA-LETRA (Ativo, Passivo, Condicional). Cada anomalia tem um mecanismo primário e, opcionalmente, um secundário — que só pode ser um mecanismo marcado como subnatureza.';

EXEC dbo.sp_Decco_SetDescription 'Cat_ManifestacaoEspecifica', NULL,
 N'CATÁLOGO. Efeitos observáveis e catalogados (metamorfose, telecinese, distorção espaço-temporal...). Ligam-se às perícias por Pericia_Manifestacao, com intensidade por vínculo.';

EXEC dbo.sp_Decco_SetDescription 'Cat_CognicaoAparente', NULL,
 N'CATÁLOGO do Sistema Brasileiro (Protocolo OA). Grau de cognição aferido na anomalia: SE (Sensciente), SA (Sapiente), IN (Inanimado), AA (Autômato Anômalo). Compõe o identificador OA, gerado na aplicação.';

EXEC dbo.sp_Decco_SetDescription 'Cat_Periculosidade', NULL,
 N'CATÁLOGO do Sistema Brasileiro (Protocolo OA). Escala de 9 níveis, do Mínimo ao Máximo. A partir do nível 8 há risco de romper o Véu/Esquadria e o protocolo de contenção passa a ser especial.';

EXEC dbo.sp_Decco_SetDescription 'Cat_TipoInstalacao', NULL,
 N'CATÁLOGO. Tipos de instalação: SITIO, LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO. O flag PermiteFilhos define a hierarquia — tipo que permite filhos é raiz, os demais vivem dentro dele.';

EXEC dbo.sp_Decco_SetDescription 'Cat_Operacao', NULL,
 N'CATÁLOGO. Tipos de operação: INVESTIGACAO, PESQUISA, SUPRESSAO. Define se o tipo exige uma anomalia catalogada como alvo (RequerAnomalia) e o clearance mínimo sugerido para a operação.';

-- ── Agregado principal ──────────────────────────────────────────────────────

EXEC dbo.sp_Decco_SetDescription 'Anomalia', NULL,
 N'ENTIDADE-RAIZ. Cada linha é um registro do catálogo de anomalias do DeCCO. Reúne a classificação ontológica (classe, camada, matéria, mecanismos), a classificação brasileira (cognição, periculosidade), os marcadores Theta mensuráveis e o estado operacional. Id começa em 1000; a identidade pública é o CodigoSCP.';

-- ── Instâncias 1:N — como a mesma anomalia se manifesta ─────────────────────

EXEC dbo.sp_Decco_SetDescription 'EntidadeViva', NULL,
 N'INSTÂNCIA 1:N de Anomalia. A manifestação da anomalia como ser vivo: espécie, biologia, origem do poder, nível de inteligência. Apagada em cascata com a anomalia-mãe.';

EXEC dbo.sp_Decco_SetDescription 'Artefato', NULL,
 N'INSTÂNCIA 1:N de Anomalia. A manifestação como objeto: material, origem, propriedade de spin e modo de uso (o ritual ou procedimento que ativa o efeito). Apagada em cascata.';

EXEC dbo.sp_Decco_SetDescription 'Localidade', NULL,
 N'INSTÂNCIA 1:N de Anomalia. ONDE a anomalia se manifesta no mundo — com coordenadas geográficas, raio de efeito e leitura ambiente de IEIA-D. NÃO confundir com o sítio de contenção: aqui é onde o fenômeno ocorre, não onde ele é guardado.';

EXEC dbo.sp_Decco_SetDescription 'Evento', NULL,
 N'INSTÂNCIA 1:N de Anomalia. A manifestação como ocorrência no tempo: janela, periodicidade, zona afetada e pré-condições de disparo.';

-- ── Configuração / backoffice ───────────────────────────────────────────────

EXEC dbo.sp_Decco_SetDescription 'Instalacao', NULL,
 N'CONFIGURAÇÃO / ESCOPO. Lugar físico do DeCCO: sítio, laboratório, área de contenção ou posto avançado (Cat_TipoInstalacao). Hierárquica em dois níveis — sítio na raiz, demais tipos como filhos (TR_Instalacao_Validar_Hierarquia). É a FRONTEIRA DE PERMISSÃO do sistema: o usuário recebe uma lista de instalações (relação que vive no DeccoAuthDB) e o trabalho escopado (Operacao) é filtrado por ela. Absorveu a antiga tabela Laboratorio (migração 0002/0004).';

EXEC dbo.sp_Decco_SetDescription 'Operacao', NULL,
 N'TRABALHO ESCOPADO. Investigação, pesquisa ou supressão (Cat_Operacao) conduzida DENTRO de uma instalação — InstalacaoId é obrigatório desde a criação. Diferente da Anomalia, que é catálogo global, a operação pertence a um lugar, e por isso é a primeira entidade cujo acesso e cache são recortados por instalação (chaves decco:inst:{codigo}:operacao:*).';

EXEC dbo.sp_Decco_SetDescription 'ProtocoloContencao', NULL,
 N'CONFIGURAÇÃO. Procedimento de contenção versionado: passos, recursos necessários, nível de urgência e as classes de objeto a que se aplica. Vincula-se às anomalias por Protocolo_AplicadoEm.';

EXEC dbo.sp_Decco_SetDescription 'Protocolo_AplicadoEm', NULL,
 N'RELACIONAMENTO N:N entre ProtocoloContencao e Anomalia, com vigência (início/fim) e status. Responde: que protocolos estão ativos nesta anomalia, e desde quando.';

EXEC dbo.sp_Decco_SetDescription 'NotificacaoAnomalia', NULL,
 N'ENTRADA DE CAMPO. Relato de fenômeno ainda não catalogado, com local, prioridade e relator. AnomaliaId é nulo enquanto a apuração não concluir — é o ponto de entrada do funil que termina num registro no catálogo.';

-- ── Perícias e desvios ──────────────────────────────────────────────────────

EXEC dbo.sp_Decco_SetDescription 'PericiaAnomalia', NULL,
 N'Capacidade nomeada de uma anomalia (o que ela sabe fazer), com mecanismos próprios, nível e custo de ativação. Uma anomalia pode ter várias perícias; o nome é único por anomalia.';

EXEC dbo.sp_Decco_SetDescription 'Instancia_PericiaDesviante', NULL,
 N'DESVIO. Registra que uma INSTÂNCIA específica (entidade, artefato, localidade ou evento) exerce uma perícia de forma diferente da anomalia-mãe. Referência POLIMÓRFICA: TipoInstancia + InstanciaId, sem FK real — a integridade é da aplicação.';

EXEC dbo.sp_Decco_SetDescription 'Pericia_Manifestacao', NULL,
 N'RELACIONAMENTO N:N entre PericiaAnomalia e Cat_ManifestacaoEspecifica, qualificado por intensidade. Traduz uma perícia abstrata nos efeitos observáveis que ela produz.';

EXEC dbo.sp_Decco_SetDescription 'Incidente', NULL,
 N'HISTÓRICO. Ocorrência registrada envolvendo uma anomalia: tipo, relatório, nível de segurança, vítimas e dano material. O flag IsEventoSigma marca os incidentes de gravidade excepcional, contabilizados em vw_Relatorio_Sigma.';
GO
