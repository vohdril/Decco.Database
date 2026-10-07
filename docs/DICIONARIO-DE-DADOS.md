# Dicionário de Dados — DeccoDB
 
> Gerado por `docs/gerar-dicionario.sql`. **Não editar à mão** — alterar as descrições em
> `programmability/descriptions/` e rodar o runner.
 
## Anomalia
 
ENTIDADE-RAIZ. Cada linha é um registro do catálogo de anomalias do DeCCO. Reúne a classificação ontológica (classe, camada, matéria, mecanismos), a classificação brasileira (cognição, periculosidade), os marcadores Theta mensuráveis e o estado operacional. Id começa em 1000; a identidade pública é o CodigoSCP.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não | Id interno, IDENTITY a partir de 1000. NÃO é a identidade pública — o contrato expõe CodigoSCP (padrão IdToCode). |
| `CodigoSCP` | varchar(50) | não | Identidade pública e estável da anomalia (ex.: SCP-1001). É por este código que consumidores externos referenciam o registro. |
| `NomeComum` | nvarchar(255) | não | Designação de uso corrente, legível por operadores (ex.: Proteu - O Metamorfo Complexo). |
| `Descricao` | nvarchar(MAX) | não |  |
| `ClasseObjetoId` | int | não | Classe de contenção. Determina, via Cat_ClasseObjeto.NivelAcessoMinimo, o clearance necessário para ver esta anomalia. |
| `CamadaOntologicaId` | int | não | Plano em que a anomalia opera (THETA/PSI/PHI/OMEGA). Junto com o tipo de matéria, define se ela entra no recorte Sigma. |
| `TipoMateriaId` | int | não | Composição material. Matéria não-bariônica é resistente a supressores Theta e levanta bandeira Sigma. |
| `CognicaoAparenteId` | int | sim | Classificação brasileira de cognição (SE/SA/IN/AA). Nulo enquanto não aferida. |
| `PericulosidadeId` | int | sim | Classificação brasileira de periculosidade (1..9). Nulo enquanto não aferida. |
| `MecanismoPrimarioId` | int | não | Mecanismo principal VISÍVEL — o COMO observável do fenômeno (ex.: transformação = THETA-C). |
| `MecanismoSecundarioId` | int | sim | Mecanismo subjacente, opcional. Só aceita mecanismos marcados como subnatureza, e OMEGA não pode ter subnatureza THETA — ambas as regras impostas por TR_Anomalia_Validar_Mecanismos. |
| `IEIA_D_Base` | decimal(8,4) | sim | Índice de Enriquecimento Isotópico Anômalo para Deutério, medido no próprio objeto. Nível basal humano fica abaixo de 0,015%; acima de 0,1% indica uso ativo da camada Theta. É o marcador quantitativo central do sistema. |
| `FatorCoerenciaSpin` | varchar(20) | sim | Grau de coerência do spin anômalo, em escala textual: Nulo, Baixo, Médio, Alto, Crítico. Crítico indica padrão de Spin Congelado com acoplamento a camada superior. |
| `Status` | varchar(20) | sim | Estado do REGISTRO: ATIVA, NEUTRALIZADA, DESTRUIDA. NOTA: o valor EM_PESQUISA, em uso hoje, é estado de WORKFLOW e não de catálogo — migra para a esteira de classificação quando ela existir (DECCO-BACKLOG, achado 6). |
| `ResponsavelPesquisa` | nvarchar(255) | sim | Pesquisador responsável, em texto livre. É atributo de PROCESSO, não de catálogo. A entidade Operacao existe desde a 0003; mover este dado para Operacao.Responsavel (tipo PESQUISA) é passo seguinte, registrado no DECCO-BACKLOG. |
| `DataCriacao` | datetime | sim |  |
| `DataAtualizacao` | datetime | sim | Mantida automaticamente por TR_Anomalia_Update_Date em todo UPDATE. Instalacao e Operacao seguem o mesmo padrão (TR_Instalacao_Update_Date, TR_Operacao_Update_Date); as tabelas do baseline não. |
| `UsuarioCriacao` | nvarchar(128) | sim | Preenchida com SYSTEM_USER por DEFAULT. No baseline, Anomalia era a única tabela com auditoria de usuário; Instalacao e Operacao já nascem com ela. As demais tabelas do baseline só têm datas (DECCO-BACKLOG, achado 5). |
| `UsuarioAtualizacao` | nvarchar(128) | sim | Atualizada por TR_Anomalia_Update_Date com SYSTEM_USER a cada UPDATE. |
| `InstalacaoContencaoId` | int | sim | Onde a anomalia está fisicamente contida: a instalação mais específica conhecida (área de contenção ou laboratório; senão, o sítio). Substituiu o texto livre SitioContencao (migrações 0002/0004). NÃO é fronteira de permissão: a anomalia é catálogo global, recortado por clearance; quem é recortado por instalação é a Operacao. |
 
## Artefato
 
INSTÂNCIA 1:N de Anomalia. A manifestação como objeto: material, origem, propriedade de spin e modo de uso (o ritual ou procedimento que ativa o efeito). Apagada em cascata.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `AnomaliaId` | int | não |  |
| `Identificacao` | nvarchar(100) | não |  |
| `Material` | nvarchar(255) | sim |  |
| `DataFabricacao` | date | sim |  |
| `LocalOrigem` | nvarchar(255) | sim |  |
| `PropriedadeSpin` | varchar(100) | sim | Descrição do padrão de spin fixado no material (ex.: Spin Congelado com acoplamento OMEGA). É a assinatura física do mecanismo Theta-Passivo. |
| `Peso_Kg` | decimal(10,2) | sim |  |
| `Dimensoes` | varchar(100) | sim |  |
| `ModoUsar` | nvarchar(MAX) | sim | Procedimento de ativação do artefato — ritual, gesto, catalisador. Para artefatos de mecanismo condicional, é onde o gatilho fica documentado. |
 
## Cat_CamadaOntologica
 
CATÁLOGO. Em que plano a anomalia opera: THETA (física anômala, maioria dos casos), PSI (narrativo/informacional), PHI (consciência/digital), OMEGA (substrato não-bariônico). Cada camada pertence a uma força fundamental.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Simbolo` | char(10) | não | Chave de negócio da camada: THETA, PSI, PHI, OMEGA. Mesma ressalva de CHAR(10) da força fundamental. |
| `Nome` | varchar(50) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `ForcaFundamentalId` | int | sim | A força fundamental de que esta camada deriva. THETA, PSI e PHI vêm de Kappa; OMEGA vem de Lambda. |
| `Prioridade` | int | não | Ordem de apresentação e de precedência analítica. OMEGA tem prioridade 2 por ser a camada de substrato; as demais, 1. |
 
## Cat_ClasseObjeto
 
CATÁLOGO. Classe de contenção da anomalia no sistema brasileiro (PACATO, YAGUARA, ABAPORU, UKAR), com o equivalente do vocabulário ACS/SCP em ClasseACS. Define o clearance mínimo para ver a anomalia e a cor de severidade da UI.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(10) | não | Chave de negócio da classe no vocabulário brasileiro: PACATO, YAGUARA, ABAPORU, UKAR. É o que o contrato público expõe — nunca o Id. |
| `Nome` | varchar(50) | não |  |
| `TipoClasse` | varchar(50) | não | Primária ou Secundária. Hoje só existem classes primárias semeadas; o eixo secundário está previsto e não usado. |
| `ClasseACS` | varchar(40) | sim | Equivalente da classe no vocabulário canônico SCP/ACS: SAFE, EUCLID, KETER, THAUMIEL. É, na prática, um ALIAS DE VOCABULÁRIO EXTERNO embutido na tabela — ver DECCO-BACKLOG (MapeamentoExterno). |
| `Descricao` | text | sim |  |
| `NivelAcessoMinimo` | int | não | Clearance mínimo (1..4) para que um operador possa VER anomalias desta classe. É o eixo hierárquico da autorização a nível de recurso. |
| `CorAlerta` | varchar(7) | sim | Cor hexadecimal de severidade. A UI apenas LÊ este valor — a paleta de severidade do design system é dirigida por aqui, não por constante no front. |
| `DataCriacao` | datetime | não |  |
| `Ativo` | bit | não |  |
 
## Cat_CognicaoAparente
 
CATÁLOGO do Sistema Brasileiro (Protocolo OA). Grau de cognição aferido na anomalia: SE (Sensciente), SA (Sapiente), IN (Inanimado), AA (Autômato Anômalo). Compõe o identificador OA, gerado na aplicação.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(5) | não | SE, SA, IN ou AA. É o terceiro bloco do identificador OA, no formato OA-[####][CF\|CN\|CI\|CMF]-[SE\|SA\|IN\|AA], montado na aplicação. |
| `Nome` | varchar(50) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
 
## Cat_ForcaFundamental
 
CATÁLOGO. As forças fundamentais fictícias que originam os fenômenos anômalos: Kappa (campo de coerência informacional) e Lambda (substrato não-bariônico consciente). É a raiz da árvore ontológica — toda camada deriva de uma força.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Simbolo` | char(10) | não | Chave de negócio da força (Kappa, Lambda). ATENÇÃO: o tipo é CHAR(10) — valores são preenchidos com espaços à direita na leitura, o que quebra o dicionário Simbolo->Id do IdToCode. Ver DECCO-BACKLOG, achado 1. |
| `Nome` | varchar(50) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `ParticulaPortadora` | varchar(50) | sim | Partícula fictícia que medeia a força (Áxion para Kappa; não-bariônica para Lambda). Elemento de lore, sem efeito funcional. |
 
## Cat_ManifestacaoEspecifica
 
CATÁLOGO. Efeitos observáveis e catalogados (metamorfose, telecinese, distorção espaço-temporal...). Ligam-se às perícias por Pericia_Manifestacao, com intensidade por vínculo.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(20) | não | Chave de negócio da manifestação. A nomenclatura é inconsistente por herança: convivem códigos descritivos (METAMORFOSE) e códigos sequenciais (IGN-01, CRYO-05). |
| `Nome` | nvarchar(100) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
 
## Cat_MecanismoInteracao
 
CATÁLOGO. COMO a anomalia age sobre a realidade, no formato CAMADA-LETRA (Ativo, Passivo, Condicional). Cada anomalia tem um mecanismo primário e, opcionalmente, um secundário — que só pode ser um mecanismo marcado como subnatureza.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(10) | não | Chave de negócio no formato CAMADA-LETRA: A = Ativo (consome recurso), B = Passivo (propriedade intrínseca), C = Condicional (depende de gatilho). |
| `Nome` | varchar(100) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `CamadaOntologicaId` | int | não | Camada a que o mecanismo pertence. O trigger TR_Anomalia_Validar_Mecanismos usa esta relação para impedir que uma anomalia OMEGA tenha subnatureza THETA. |
| `EhSubnatureza` | bit | não | Verdadeiro se o mecanismo pode ser usado como SECUNDÁRIO de uma anomalia. Imposto por TR_Anomalia_Validar_Mecanismos. NOTA DE NOMENCLATURA: é o único booleano com prefixo Eh; os outros 4 do schema usam Is. |
 
## Cat_Operacao
 
CATÁLOGO. Tipos de operação: INVESTIGACAO, PESQUISA, SUPRESSAO. Define se o tipo exige uma anomalia catalogada como alvo (RequerAnomalia) e o clearance mínimo sugerido para a operação.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(20) | não | Chave de negócio: INVESTIGACAO, PESQUISA, SUPRESSAO. Semeados apenas pelo seed/100 — nenhuma migração depende deles. |
| `Nome` | nvarchar(50) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `RequerAnomalia` | bit | não | 1 = a operação só pode existir com uma anomalia catalogada como alvo (pesquisa, supressão). 0 = pode nascer de um relato de campo (investigação). Imposto por TR_Operacao_Validar. |
| `NivelAcessoMinimo` | int | não | Clearance mínimo sugerido para operações deste tipo. Referência para a aplicação — cada Operacao guarda o seu próprio NivelAcessoMinimo. |
| `CorAlerta` | varchar(7) | sim | Cor hexadecimal do tipo, lida pela UI. |
| `Ativo` | bit | não |  |
 
## Cat_Periculosidade
 
CATÁLOGO do Sistema Brasileiro (Protocolo OA). Escala de 9 níveis, do Mínimo ao Máximo. A partir do nível 8 há risco de romper o Véu/Esquadria e o protocolo de contenção passa a ser especial.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Nivel` | int | não | Escala de 1 (Mínimo) a 9 (Máximo), com CHECK no banco. É a chave de negócio desta tabela — o Id é apenas técnico. |
| `Nome` | varchar(50) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `CorAlerta` | varchar(7) | sim | Cor hexadecimal do nível, em gradiente verde->vermelho. Lida pela UI; não duplicar a paleta no front. |
 
## Cat_TipoInstalacao
 
CATÁLOGO. Tipos de instalação: SITIO, LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO. O flag PermiteFilhos define a hierarquia — tipo que permite filhos é raiz, os demais vivem dentro dele.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(20) | não | Chave de negócio: SITIO, LABORATORIO, AREA_CONTENCAO, POSTO_AVANCADO. Os quatro são inseridos pela migração 0002 (que depende deles para migrar dados) e convergidos pelo seed/090. |
| `Nome` | nvarchar(50) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `PermiteFilhos` | bit | não | 1 = tipo raiz, que contém outras instalações (SITIO). 0 = tipo que vive dentro de um raiz. Base das regras de TR_Instalacao_Validar_Hierarquia. |
| `Ativo` | bit | não |  |
 
## Cat_TipoMateria
 
CATÁLOGO. Do que a anomalia é feita: Bariônica Anômala, Mista, Não-Bariônica ou Indefinido. O flag IsResistenteSupressores marca a matéria imune à tecnologia de supressão Theta.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Nome` | varchar(50) | não | Chave de negócio do tipo de matéria (é UNIQUE): Bariônica Anômala, Mista, Não-Bariônica, Indefinido. |
| `Descricao` | nvarchar(MAX) | não |  |
| `IsResistenteSupressores` | bit | não | Verdadeiro quando a matéria é imune à tecnologia de supressão Theta. Usado por sp_Anomalia_Buscar como um dos critérios do filtro @ApenasSigma. |
 
## EntidadeViva
 
INSTÂNCIA 1:N de Anomalia. A manifestação da anomalia como ser vivo: espécie, biologia, origem do poder, nível de inteligência. Apagada em cascata com a anomalia-mãe.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `AnomaliaId` | int | não |  |
| `Identificacao` | nvarchar(100) | não | Designação da instância individual (ex.: Individuo-Alpha). A anomalia é o tipo; a entidade é o espécime. |
| `Especie` | nvarchar(150) | não |  |
| `Biologia` | nvarchar(255) | sim | Natureza biológica observada (ex.: Bariônica Modificada). Complementa, no nível da instância, o tipo de matéria da anomalia-mãe. |
| `OrigemPoder` | nvarchar(100) | sim | Hipótese de como a entidade acessa a força de anomalia (ex.: Catalisador + Acesso PSI). |
| `DataNascimento` | date | sim |  |
| `IsConsciente` | bit | sim | Marcação operacional rápida de consciência. Não confundir com Cat_CognicaoAparente, que é a classificação formal da anomalia-mãe. |
| `NivelInteligencia` | int | sim | Escala numérica aferida em testes. Sem CHECK no banco — a faixa é convenção de domínio. |
| `Dieta` | nvarchar(100) | sim |  |
| `Observacoes` | nvarchar(MAX) | sim |  |
 
## Evento
 
INSTÂNCIA 1:N de Anomalia. A manifestação como ocorrência no tempo: janela, periodicidade, zona afetada e pré-condições de disparo.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `AnomaliaId` | int | não |  |
| `Nome` | nvarchar(255) | não |  |
| `DataHoraInicio` | datetime | não |  |
| `DataHoraFim` | datetime | sim |  |
| `Periodicidade` | nvarchar(100) | sim | Padrão de recorrência do evento, em texto livre (ex.: mensal, lua cheia). Alimenta a previsão de janelas de observação. |
| `ZonaAfetada` | nvarchar(255) | sim |  |
| `DuracaoMedia` | time | sim |  |
| `PreCondicoes` | nvarchar(MAX) | sim | Condições que precisam estar satisfeitas para o evento disparar. É o equivalente, no nível do evento, do gatilho de um mecanismo condicional. |
 
## Incidente
 
HISTÓRICO. Ocorrência registrada envolvendo uma anomalia: tipo, relatório, nível de segurança, vítimas e dano material. O flag IsEventoSigma marca os incidentes de gravidade excepcional, contabilizados em vw_Relatorio_Sigma.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `AnomaliaId` | int | não |  |
| `DataHora` | datetime | sim |  |
| `Tipo` | varchar(50) | não | Natureza da ocorrência (Teste de Pesquisa, Falha de Contenção, Evento SIGMA...). |
| `Titulo` | nvarchar(255) | não |  |
| `Relatorio` | nvarchar(MAX) | não |  |
| `NivelSeguranca` | varchar(20) | não | Classificação de sigilo do relatório, em texto livre. Não é o clearance numérico do operador. |
| `IsEventoSigma` | bit | sim | Marca o incidente como Evento Sigma — gravidade excepcional, tipicamente envolvendo camada OMEGA ou matéria resistente a supressores. Contabilizado por vw_Relatorio_Sigma e pelo filtro @ApenasSigma de sp_Anomalia_Buscar. |
| `Mortes` | int | sim |  |
| `Feridos` | int | sim |  |
| `DanoMaterial` | nvarchar(255) | sim | Descrição do dano a instalações e equipamento. Texto livre, usado nos relatórios de consequência. |
 
## Instalacao
 
CONFIGURAÇÃO / ESCOPO. Lugar físico do DeCCO: sítio, laboratório, área de contenção ou posto avançado (Cat_TipoInstalacao). Hierárquica em dois níveis — sítio na raiz, demais tipos como filhos (TR_Instalacao_Validar_Hierarquia). É a FRONTEIRA DE PERMISSÃO do sistema: o usuário recebe uma lista de instalações (relação que vive no DeccoAuthDB) e o trabalho escopado (Operacao) é filtrado por ela. Absorveu a antiga tabela Laboratorio (migração 0002/0004).
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(20) | não | Identidade pública e estável (ex.: SITIO-19, LAB-BIO-19, AREA-001). NÃO é atualizável por sp_Instalacao_Atualizar: é também a chave do cache escopado (decco:inst:{codigo}:*). |
| `Nome` | nvarchar(255) | não |  |
| `Descricao` | nvarchar(MAX) | sim |  |
| `TipoInstalacaoId` | int | não | Tipo da instalação (Cat_TipoInstalacao). Define se ela é raiz ou precisa de pai. |
| `InstalacaoPaiId` | int | sim | Instalação que contém esta (ex.: o sítio de um laboratório). Nulo apenas para tipos raiz. Profundidade máxima 2, sem ciclos — imposto por TR_Instalacao_Validar_Hierarquia. |
| `Responsavel` | nvarchar(255) | sim |  |
| `Especialidade` | varchar(50) | sim | Área de atuação, relevante para laboratórios (Biologia Anômala, Física Quântica, Narratologia...). Herdada da antiga tabela Laboratorio. |
| `NivelAcessoMinimo` | int | não | Clearance mínimo para operar na instalação. Eixo paralelo ao de Cat_ClasseObjeto: um recorta anomalias, o outro recorta lugares. |
| `Status` | varchar(20) | não | ATIVA, INATIVA ou DESATIVADA, com CHECK. Só instalação ATIVA recebe operação nova (TR_Operacao_Validar). |
| `DataCriacao` | datetime | não |  |
| `DataAtualizacao` | datetime | não |  |
| `UsuarioCriacao` | nvarchar(128) | não |  |
| `UsuarioAtualizacao` | nvarchar(128) | não |  |
 
## Instancia_PericiaDesviante
 
DESVIO. Registra que uma INSTÂNCIA específica (entidade, artefato, localidade ou evento) exerce uma perícia de forma diferente da anomalia-mãe. Referência POLIMÓRFICA: TipoInstancia + InstanciaId, sem FK real — a integridade é da aplicação.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `TipoInstancia` | varchar(20) | não | Discriminador polimórfico: ENTIDADE, ARTEFATO, LOCALIDADE ou EVENTO, com CHECK. Diz em qual tabela InstanciaId deve ser procurado. |
| `InstanciaId` | int | não | Id na tabela indicada por TipoInstancia. SEM FK real — é referência polimórfica, e a integridade é responsabilidade da aplicação. |
| `PericiaDesvianteId` | int | não |  |
| `DataDescoberta` | date | sim |  |
| `Intensidade` | varchar(20) | sim | Quanto a instância desvia do padrão da anomalia-mãe nesta perícia. |
| `Observacoes` | nvarchar(MAX) | sim |  |
 
## Localidade
 
INSTÂNCIA 1:N de Anomalia. ONDE a anomalia se manifesta no mundo — com coordenadas geográficas, raio de efeito e leitura ambiente de IEIA-D. NÃO confundir com o sítio de contenção: aqui é onde o fenômeno ocorre, não onde ele é guardado.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `AnomaliaId` | int | não |  |
| `Nome` | nvarchar(255) | não |  |
| `Coordenadas` | geography | sim | Posição geográfica (tipo GEOGRAPHY). Um dos recursos T-SQL que obrigam o DeccoDB a rodar em SQL Server e não em SQLite. |
| `RaioEfeitoMetros` | int | sim | Alcance do efeito anômalo a partir das coordenadas. Base do cálculo de perímetro de evacuação nos protocolos. |
| `IEIA_D_Ambiente` | decimal(8,4) | sim | Leitura de IEIA-D do AMBIENTE, não do objeto. Flutuação acima do basal no perímetro é o gatilho típico de uma notificação de campo. |
| `IsGeograficamenteLimitada` | bit | sim |  |
| `TipoTerreno` | varchar(100) | sim |  |
| `ClimaAnomalo` | varchar(100) | sim | Padrão climático atípico associado à localidade, quando houver. |
 
## NotificacaoAnomalia
 
ENTRADA DE CAMPO. Relato de fenômeno ainda não catalogado, com local, prioridade e relator. AnomaliaId é nulo enquanto a apuração não concluir — é o ponto de entrada do funil que termina num registro no catálogo.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Titulo` | nvarchar(255) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `LocalIdentificado` | nvarchar(255) | não | Onde o fenômeno foi relatado. TEXTO LIVRE porque a notificação pode vir de fora de qualquer instalação conhecida — nem toda ocorrência nasce dentro do perímetro. |
| `DataHora` | datetime | sim |  |
| `Status` | varchar(20) | sim |  |
| `NivelPrioridade` | int | não | Escala de 1 a 5, com CHECK. Ordena a fila de apuração. |
| `Relator` | nvarchar(255) | sim | Quem reportou. Pode ser um operador nomeado ou Sistema Automático, quando a origem é sensor. |
| `AnomaliaId` | int | sim | Nulo até a apuração concluir. Quando preenchido, liga o relato de campo ao registro de catálogo que ele originou. |
| `DataResolucao` | datetime | sim |  |
| `InstalacaoId` | int | sim | Instalação conhecida onde o fenômeno foi relatado, quando houver. OPCIONAL: LocalIdentificado continua sendo a descrição textual, e um relato de fora do perímetro fica com esta coluna nula. |
 
## Operacao
 
TRABALHO ESCOPADO. Investigação, pesquisa ou supressão (Cat_Operacao) conduzida DENTRO de uma instalação — InstalacaoId é obrigatório desde a criação. Diferente da Anomalia, que é catálogo global, a operação pertence a um lugar, e por isso é a primeira entidade cujo acesso e cache são recortados por instalação (chaves decco:inst:{codigo}:operacao:*).
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(20) | não | Identidade pública no formato OP-{ano}-{sequencial} (ex.: OP-2026-0001), gerada por sp_Operacao_Inserir quando não informada. |
| `Codinome` | nvarchar(100) | não | Nome operacional legível (ex.: Jaguar Silente). Não é único — o Codigo é a identidade. |
| `TipoOperacaoId` | int | não | Tipo da operação (Cat_Operacao). Se o tipo exige anomalia, AnomaliaId é obrigatório (TR_Operacao_Validar). |
| `InstalacaoId` | int | não | Instalação dona da operação — obrigatória desde a criação e NÃO atualizável. É a chave do recorte de permissão e do cache escopado. |
| `AnomaliaId` | int | sim | Anomalia alvo, quando já catalogada. Obrigatória para tipos com RequerAnomalia = 1. |
| `NotificacaoId` | int | sim | Relato de campo que originou a operação, quando houver — o caminho típico de uma investigação. |
| `ProtocoloId` | int | sim |  |
| `Objetivo` | nvarchar(500) | não |  |
| `Descricao` | nvarchar(MAX) | sim |  |
| `Status` | varchar(20) | não | PLANEJADA, EM_ANDAMENTO, SUSPENSA, CONCLUIDA ou ABORTADA, com CHECK. Ao entrar em CONCLUIDA/ABORTADA, DataEncerramento é preenchida por sp_Operacao_Atualizar. |
| `Prioridade` | int | não | Escala de 1 a 5, com CHECK. Ordena a lista de operações em sp_Operacao_Buscar. |
| `NivelAcessoMinimo` | int | não | Clearance mínimo para VER a operação. Somado ao recorte por instalação, compõe a autorização a nível de recurso. |
| `Responsavel` | nvarchar(255) | sim | Responsável, em texto livre. Vira FK para o usuário quando o DeccoAuthDB existir. |
| `DataAbertura` | datetime | não |  |
| `DataPrevisaoTermino` | datetime | sim |  |
| `DataEncerramento` | datetime | sim |  |
| `ResultadoResumo` | nvarchar(MAX) | sim | Síntese do resultado, preenchida no encerramento. |
| `DataCriacao` | datetime | não |  |
| `DataAtualizacao` | datetime | não |  |
| `UsuarioCriacao` | nvarchar(128) | não |  |
| `UsuarioAtualizacao` | nvarchar(128) | não |  |
 
## Pericia_Manifestacao
 
RELACIONAMENTO N:N entre PericiaAnomalia e Cat_ManifestacaoEspecifica, qualificado por intensidade. Traduz uma perícia abstrata nos efeitos observáveis que ela produz.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `PericiaAnomaliaId` | int | não |  |
| `ManifestacaoEspecificaId` | int | não |  |
| `Intensidade` | varchar(20) | sim | Grau com que esta perícia produz esta manifestação (Baixa, Média, Alta, Variável). Qualifica o vínculo N:N. |
| `Observacoes` | nvarchar(MAX) | sim |  |
 
## PericiaAnomalia
 
Capacidade nomeada de uma anomalia (o que ela sabe fazer), com mecanismos próprios, nível e custo de ativação. Uma anomalia pode ter várias perícias; o nome é único por anomalia.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `AnomaliaId` | int | não |  |
| `Nome` | nvarchar(100) | não | Designação da capacidade. UNIQUE por anomalia (UQ_Pericia_Anomalia_Nome) — a mesma anomalia não tem duas perícias homônimas. |
| `Descricao` | nvarchar(MAX) | sim |  |
| `MecanismoPrimarioId` | int | não |  |
| `MecanismoSecundarioId` | int | sim |  |
| `Nivel` | int | sim | Intensidade/maturidade da perícia. Escala de domínio, sem CHECK no banco. |
| `Custo` | nvarchar(100) | sim | O que a anomalia consome para exercer a perícia (ex.: Nenhum; Deutério e ritual específico). É o que distingue mecanismo Ativo de Passivo na prática. |
 
## Protocolo_AplicadoEm
 
RELACIONAMENTO N:N entre ProtocoloContencao e Anomalia, com vigência (início/fim) e status. Responde: que protocolos estão ativos nesta anomalia, e desde quando.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `ProtocoloId` | int | não |  |
| `AnomaliaId` | int | não |  |
| `DataInicio` | datetime | sim | Início da vigência deste protocolo nesta anomalia. Com DataFim, dá o histórico de qual protocolo valia em cada período. |
| `DataFim` | datetime | sim |  |
| `Status` | varchar(20) | sim | Estado do vínculo (ATIVO por padrão). Permite suspender um protocolo sem apagar o histórico. |
| `Observacoes` | nvarchar(MAX) | sim |  |
 
## ProtocoloContencao
 
CONFIGURAÇÃO. Procedimento de contenção versionado: passos, recursos necessários, nível de urgência e as classes de objeto a que se aplica. Vincula-se às anomalias por Protocolo_AplicadoEm.
 
| Coluna | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | não |  |
| `Codigo` | varchar(20) | não |  |
| `Titulo` | nvarchar(255) | não |  |
| `Descricao` | nvarchar(MAX) | não |  |
| `NivelUrgencia` | int | não | Escala de 1 a 5, com CHECK. Nível 5 implica acionamento de equipe especializada e autorização de conselho. |
| `ClassesAplicaveis` | varchar(100) | sim | Lista de códigos de classe separados por vírgula (ex.: UKAR,ABAPORU). DESNORMALIZADO de propósito no baseline — candidato natural a virar N:N com Cat_ClasseObjeto. |
| `Passos` | nvarchar(MAX) | não | Procedimento numerado, em texto. Conteúdo operacional lido pelo agente em campo. |
| `RecursosNecessarios` | nvarchar(MAX) | sim |  |
| `DataCriacao` | datetime | sim |  |
| `DataAtualizacao` | datetime | sim |  |
 
