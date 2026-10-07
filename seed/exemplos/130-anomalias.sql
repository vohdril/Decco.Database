-- Dados de exemplo - As 2 anomalias completas (decco.sql secao 11)
-- Run-always, mas GUARDADO: so insere se ainda nao existir. Rodar duas vezes e inofensivo.
IF NOT EXISTS (SELECT 1 FROM Anomalia WHERE CodigoSCP = 'SCP-1001')
BEGIN
    PRINT 'seed/exemplos: inserindo SCP-1001 e SCP-1002';

    -- Instalacoes de contencao (por codigo - seed/exemplos/100 ou migracao 0002).
    -- Equivalem ao antigo texto livre SitioContencao:
    --   'Sítio-19, Setor de Biologia Anômala' -> LAB-BIO-19
    --   'Sítio-64, Biblioteca Proibida'       -> AREA-001
    DECLARE @InstalacaoId_LAB_BIO_19 INT = (SELECT Id FROM Instalacao WHERE Codigo = 'LAB-BIO-19');
    DECLARE @InstalacaoId_AREA_001   INT = (SELECT Id FROM Instalacao WHERE Codigo = 'AREA-001');

    -- Exemplo 1: Metamorfo Complexo
    DECLARE @MetamorfoId INT;
    DECLARE @PericiaMetamorfoseId INT;
    DECLARE @ClasseObjetoId_EUCLID INT, @CamadaOntologicaId_THETA INT, @TipoMateriaId_BARIONICA INT;
    DECLARE @CognicaoAparenteId_SA INT, @PericulosidadeId_MEDIO INT;
    DECLARE @MecanismoPrimarioId_THETA_C INT, @MecanismoSecundarioId_PSI_C INT;
    DECLARE @ManifestacaoId_METAMORFOSE INT, @ManifestacaoId_REGENERACAO INT;

    -- Obter os IDs necessários
    SET @ClasseObjetoId_EUCLID = (SELECT Id FROM Cat_ClasseObjeto WHERE ClasseACS = 'EUCLID');
    SET @CamadaOntologicaId_THETA = (SELECT Id FROM Cat_CamadaOntologica WHERE Simbolo = 'THETA');
    SET @TipoMateriaId_BARIONICA = (SELECT Id FROM Cat_TipoMateria WHERE Nome = 'Bariônica Anômala');
    SET @CognicaoAparenteId_SA = (SELECT Id FROM Cat_CognicaoAparente WHERE Codigo = 'SA');
    SET @PericulosidadeId_MEDIO = (SELECT Id FROM Cat_Periculosidade WHERE Nivel = 5);
    SET @MecanismoPrimarioId_THETA_C = (SELECT Id FROM Cat_MecanismoInteracao WHERE Codigo = 'THETA-C');
    SET @MecanismoSecundarioId_PSI_C = (SELECT Id FROM Cat_MecanismoInteracao WHERE Codigo = 'PSI-C');
    SET @ManifestacaoId_METAMORFOSE = (SELECT Id FROM Cat_ManifestacaoEspecifica WHERE Codigo = 'METAMORFOSE');
    SET @ManifestacaoId_REGENERACAO = (SELECT Id FROM Cat_ManifestacaoEspecifica WHERE Codigo = 'REGENERACAO');

    -- Criar tabela temporária para capturar o resultado
    DECLARE @Resultado TABLE (NovoId INT, CodigoFormatado VARCHAR(50));

    -- Inserir a anomalia
    INSERT INTO @Resultado
    EXEC sp_Anomalia_Inserir 
        @CodigoSCP = 'SCP-1001',
        @NomeComum = 'Proteu - O Metamorfo Complexo',
        @Descricao = 'Entidade humanoide capaz de se transformar em múltiplas formas animais. Massa varia até +/- 60% da forma base. Formas são anatomicamente perfeitas.',
        @ClasseObjetoId = @ClasseObjetoId_EUCLID,
        @CamadaOntologicaId = @CamadaOntologicaId_THETA,
        @TipoMateriaId = @TipoMateriaId_BARIONICA,
        @CognicaoAparenteId = @CognicaoAparenteId_SA,
        @PericulosidadeId = @PericulosidadeId_MEDIO,
        @MecanismoPrimarioId = @MecanismoPrimarioId_THETA_C,
        @MecanismoSecundarioId = @MecanismoSecundarioId_PSI_C,
        @IEIA_D_Base = 0.5,
        @FatorCoerenciaSpin = 'Alto',
        @InstalacaoContencaoId = @InstalacaoId_LAB_BIO_19,
        @ResponsavelPesquisa = 'Dra. Elara Vance';

    -- Obter o ID da anomalia criada
    SELECT @MetamorfoId = NovoId FROM @Resultado;

    -- Limpar a tabela temporária
    DELETE FROM @Resultado;

    -- Adicionar como Entidade Viva
    EXEC sp_EntidadeViva_Inserir 
        @AnomaliaId = @MetamorfoId,
        @Identificacao = 'Indivíduo-Alpha',
        @Especie = 'Homo sapiens metamorfo',
        @Biologia = 'Bariônica Modificada',
        @OrigemPoder = 'Catalisador + Acesso PSI',
        @NivelInteligencia = 8;

    -- Adicionar perícia e manifestações
    INSERT INTO @Resultado
    EXEC sp_Anomalia_AdicionarPericia
        @AnomaliaId = @MetamorfoId,
        @Nome = 'Metamorfose Complexa',
        @Descricao = 'Capacidade de transformação em múltiplas formas animais',
        @MecanismoPrimarioId = @MecanismoPrimarioId_THETA_C,
        @MecanismoSecundarioId = @MecanismoSecundarioId_PSI_C,
        @Nivel = 3,
    	@Custo = 'Nenhum'

    -- Obter o ID da Pericia de Anomalia criada
    SELECT @PericiaMetamorfoseId = NovoId FROM @Resultado;

    -- Limpar a tabela temporária
    DELETE FROM @Resultado;

    EXEC sp_Pericia_AdicionarManifestacao
        @PericiaAnomaliaId = @PericiaMetamorfoseId,
        @ManifestacaoEspecificaId = @ManifestacaoId_METAMORFOSE,
        @Intensidade = 'Alta';

    EXEC sp_Pericia_AdicionarManifestacao
        @PericiaAnomaliaId = @PericiaMetamorfoseId,
        @ManifestacaoEspecificaId = @ManifestacaoId_REGENERACAO,
        @Intensidade = 'Média';

    -- Registrar um incidente
    EXEC sp_Incidente_Registrar
        @AnomaliaId = @MetamorfoId,
        @Tipo = 'Teste de Pesquisa',
        @Titulo = 'Teste de Limites de Transformação',
        @Relatorio = 'Sujeito transformou-se sequencialmente em lobo, urso e corvo dentro de 5 minutos.',
        @NivelSeguranca = 'Alto',
        @IsEventoSigma = 0,
        @Feridos = 0;



    -- Exemplo 2: Grimório de Spin Congelado
    DECLARE @GrimorioId INT;
    DECLARE @PericiaGrimorioId INT;
    DECLARE @ClasseObjetoId_KETER INT, @CamadaOntologicaId_OMEGA INT, @TipoMateriaId_MISTA INT;
    DECLARE @CognicaoAparenteId_IN INT, @PericulosidadeId_ALTO INT;
    DECLARE @MecanismoPrimarioId_OMEGA_A INT, @MecanismoSecundarioId_THETA_C INT;

    SET @ClasseObjetoId_KETER = (SELECT Id FROM Cat_ClasseObjeto WHERE ClasseACS = 'KETER');
    SET @CamadaOntologicaId_OMEGA = (SELECT Id FROM Cat_CamadaOntologica WHERE Simbolo = 'OMEGA');
    SET @TipoMateriaId_MISTA = (SELECT Id FROM Cat_TipoMateria WHERE Nome = 'Mista');
    SET @CognicaoAparenteId_IN = (SELECT Id FROM Cat_CognicaoAparente WHERE Codigo = 'IN');
    SET @PericulosidadeId_ALTO = (SELECT Id FROM Cat_Periculosidade WHERE Nivel = 6);
    SET @MecanismoPrimarioId_OMEGA_A = (SELECT Id FROM Cat_MecanismoInteracao WHERE Codigo = 'THETA-A');
    SET @MecanismoSecundarioId_THETA_C = (SELECT Id FROM Cat_MecanismoInteracao WHERE Codigo = 'OMEGA-C');


    -- Inserir a anomalia
    INSERT INTO @Resultado
    EXEC sp_Anomalia_Inserir 
        @CodigoSCP = 'SCP-1002',
        @NomeComum = 'Codex de Realidades - Grimório SIGMA',
        @Descricao = 'Tomo antigo com padrões de spin coerente "congelados" no pergaminho.',
        @ClasseObjetoId = @ClasseObjetoId_KETER,
        @CamadaOntologicaId = @CamadaOntologicaId_OMEGA,
        @TipoMateriaId = @TipoMateriaId_MISTA,
        @CognicaoAparenteId = @CognicaoAparenteId_IN,
        @PericulosidadeId = @PericulosidadeId_ALTO,
        @MecanismoPrimarioId = @MecanismoPrimarioId_OMEGA_A,
        @MecanismoSecundarioId = @MecanismoSecundarioId_THETA_C,
        @IEIA_D_Base = 0.05,
        @FatorCoerenciaSpin = 'Crítico',
        @InstalacaoContencaoId = @InstalacaoId_AREA_001,
        @ResponsavelPesquisa = 'Dr. Aris Thoth';

    -- Obter o ID da anomalia criada
    SELECT @GrimorioId = NovoId FROM @Resultado;


    -- Limpar a tabela temporária
    DELETE FROM @Resultado;

    -- Adicionar como Artefato
    EXEC sp_Artefato_Inserir
        @AnomaliaId = @GrimorioId,
        @Identificacao = 'Codex-Primus',
        @Material = 'Pergaminho/Pele Anômala',
        @PropriedadeSpin = 'Spin Congelado com acoplamento OMEGA',
        @Peso_Kg = 3.5,
        @ModoUsar = 'Ritual de ativação requer pronúncia precisa e gestos específicos.';

    -- Adicionar perícia para o artefato

    INSERT INTO @Resultado
    EXEC sp_Anomalia_AdicionarPericia
        @AnomaliaId = @GrimorioId,
        @Nome = 'Manipulação da Realidade',
        @Descricao = 'Capacidade de alterar regras locais da realidade através de padrões de spin',
        @MecanismoPrimarioId = @MecanismoPrimarioId_OMEGA_A,
        @MecanismoSecundarioId = @MecanismoSecundarioId_THETA_C,
        @Nivel = 5,
        @Custo = 'Deutério e ritual específico';

    -- Obter o ID da anomalia criada
    SELECT @PericiaGrimorioId = NovoId FROM @Resultado;


    -- Limpar a tabela temporária
    DELETE FROM @Resultado;

    -- Adicionar manifestações à perícia do grimório
    DECLARE @ManifestacaoId_DISTORCAO_ST INT, @ManifestacaoId_TELEPATIA INT;

    SET @ManifestacaoId_DISTORCAO_ST = (SELECT Id FROM Cat_ManifestacaoEspecifica WHERE Codigo = 'DISTORCAO_ST');
    SET @ManifestacaoId_TELEPATIA = (SELECT Id FROM Cat_ManifestacaoEspecifica WHERE Codigo = 'TELEPATIA');

    EXEC sp_Pericia_AdicionarManifestacao
        @PericiaAnomaliaId = @PericiaGrimorioId,
        @ManifestacaoEspecificaId = @ManifestacaoId_DISTORCAO_ST,
        @Intensidade = 'Variável';

    EXEC sp_Pericia_AdicionarManifestacao
        @PericiaAnomaliaId = @PericiaGrimorioId,
        @ManifestacaoEspecificaId = @ManifestacaoId_TELEPATIA,
        @Intensidade = 'Média';

    -- Registrar incidente Sigma
    EXEC sp_Incidente_Registrar
        @AnomaliaId = @GrimorioId,
        @Tipo = 'Evento SIGMA',
        @Titulo = 'Manifestação Não-Autorizada',
        @Relatorio = 'D-Class não-treinado tentou ler o Codex. Padrão de spin foi ativado, criando uma zona de realidade instável.',
        @NivelSeguranca = 'Nível 4',
        @IsEventoSigma = 1,
        @Mortes = 1,
        @DanoMaterial = 'Sala de teste completamente desestruturada';

    PRINT '✅ Sistema de catalogação completo instalado com sucesso!';
    PRINT 'Estrutura:';
    PRINT '- 7 tabelas de catálogo (ClasseObjeto, ForcaFundamental, CamadaOntologica, TipoMateria, MecanismoInteracao, ManifestacaoEspecifica, CognicaoAparente, Periculosidade)';
    PRINT '- 1 tabela principal (Anomalia)';
    PRINT '- 4 subtabelas 1:N (EntidadeViva, Artefato, Localidade, Evento)';
    PRINT '- 2 tabelas de perícias (PericiaAnomalia, Instancia_PericiaDesviante)';
    PRINT '- 2 tabelas de relacionamento N:N (Pericia_Manifestacao, Protocolo_AplicadoEm)';
    PRINT '- 1 tabela de histórico (Incidente)';
    PRINT '- Instalacao (absorveu Laboratorio), Operacao, ProtocoloContencao, NotificacaoAnomalia';
    PRINT '- 2 triggers de integridade';
    PRINT '- 12 stored procedures de CRUD';
    PRINT '- 3 views para dashboard';
    PRINT '- 2 exemplos de anomalias inseridas';
    PRINT '- 7 instalações (3 sítios, 3 laboratórios, 1 área), 3 protocolos, 2 notificações, 4 operações';
END
ELSE
    PRINT 'seed/exemplos: SCP-1001 e SCP-1002 ja existe - pulando.';
GO