# Decco.Database

Versionamento de schema do **DeccoDB** — o banco de domínio do sandbox de estudos **Decco**, um catálogo fictício de
anomalias no estilo Fundação SCP / MIB, usado para praticar arquitetura .NET corporativa.

Estratégia: **migração** (não estado), com [DbUp](https://dbup.readthedocs.io/). O deploy é um console .NET 8 neste
mesmo repositório — nada de CLI externo.

> **Dados 100% fictícios.** Nenhum segredo, credencial real ou dado pessoal. Senhas de container vêm sempre de
> variável de ambiente.

> **Idioma:** o schema é **inglês** desde a `0005` — tabelas, colunas, procedures (`usp_*`), views, triggers,
> constraints, comentários, mensagens e descrições (`MS_Description`). Ficam em português: as **migrações
> 0001–0004** (já aplicadas, nunca editadas), os **dados** (lore, nomes exibidos, códigos como `ATIVA` e `SITIO`) e,
> **temporariamente**, a camada de compatibilidade da `0005`/`0006` — views e procedures com os nomes antigos, que
> mantêm a Decco.API funcionando até ela migrar. Glossário PT→EN: `decco-compass/reference/29` (Decco.Skills).

## Repositórios do ecossistema

| Repo | Papel |
|---|---|
| [`Decco.API`](https://github.com/vohdril/Decco.API) | core .NET 8 (EF Core + Dapper) que **possui** este banco |
| [`Decco.Dashboard`](https://github.com/vohdril/Decco.Dashboard) | front React/Vite + Module Federation |
| [`Decco.Skills`](https://github.com/vohdril/Decco.Skills) | o hub de skills didáticas que guiam o desenvolvimento (substitui o `decco-skills`, arquivado) |
| **`Decco.Database`** | **este repo** — o schema, versionado |

Por que um repositório separado para o banco: o schema tem ciclo de vida próprio (muda por migração, não por
compilação), é consumido por mais de um projeto, e precisa de histórico auditável independente do código da API.
É o mesmo motivo pelo qual ecossistemas corporativos mantêm um `*-db` ao lado do `*-api`.

---

## Estrutura

```
migrations/            APPEND-ONLY, journaled em dbo.SchemaVersions
  0001_baseline_schema.sql             21 tabelas + 12 índices — DDL do decco.sql, inalterado
  0002_instalacao.sql                  EXPAND: Instalacao + Cat_TipoInstalacao; migra Laboratorio e SitioContencao
  0003_operacao.sql                    Operacao + Cat_Operacao (trabalho escopado por instalação)
  0004_contrai_laboratorio_e_sitio.sql CONTRACT: verifica, depois remove Laboratorio e SitioContencao
  0005_expand_english_names.sql        EXPAND: schema inteiro em inglês + 24 views de compatibilidade (nomes antigos)
  0006_compat_portuguese_programmability.sql  as 18 procedures sp_* e as 3 views antigas, congeladas (temporárias)
  0007_explicit_constraint_names.sql   nomes determinísticos para as 120 constraints de nome gerado + IX/CK/FK/UQ

programmability/       RUN-ALWAYS, CREATE OR ALTER — editável no lugar, diffável no git
  triggers/      (6)   TR_{Table}_{Action}
  procedures/    (18)  usp_{Entity}_{Verb}
  views/         (3)   vw_{Subject}
  descriptions/  (4)   extended properties = documentação embutida

seed/                  RUN-ALWAYS, MERGE convergente
  010..100-Cat_*.sql   os 10 catálogos
  examples/            dados de exemplo, guardados por IF NOT EXISTS (chamam as procedures usp_*)

docs/                  generate-data-dictionary.sql → DATA-DICTIONARY.md
docker/                SQL Server para o alvo `docker`
Decco.Database.Runner/ console .NET 8 que faz o deploy
```

**Ordem de execução:** `migrations` → `programmability` (triggers → procedures → views → descriptions) → `seed` → `seed/examples`.

Por que nesta ordem: `seed/examples/` chama stored procedures, então a programabilidade precisa existir antes;
e uma migração pode alterar uma tabela de que uma procedure depende, então as migrações vêm primeiro.

---

## Os dois regimes

| | `migrations/` | `programmability/` e `seed/` |
|---|---|---|
| Executa | **uma vez**, registrada no journal | **sempre** |
| Pode editar depois? | **nunca** — reescrever o passado quebra a reprodutibilidade | **sim** — é o estado desejado |
| O que o git mostra | o `ALTER` que você escreveu | **o diff real do objeto** |

É essa separação que permite editar uma stored procedure como se fosse código normal, sem perder o histórico do schema.

---

## Rodar

### Primeira vez num banco que JÁ EXISTE (adoção)

O `DeccoDB` atual já tem o schema e os dados. O baseline **não pode ser re-executado** — ele é marcado como aplicado:

```bash
dotnet run --project Decco.Database.Runner -- --target localdb --baseline
# confirme digitando ADOPT
dotnet run --project Decco.Database.Runner -- --target localdb
```

A primeira chamada insere `migrations/0001_baseline_schema.sql` em `dbo.SchemaVersions` **sem rodar**.
A segunda aplica programabilidade, seed e exemplos — todos idempotentes.

> ⚠️ **Ensaie antes.** Restaure um backup como `DeccoDB_Adocao`, rode os dois comandos apontando para ele
> (`--connection "...Database=DeccoDB_Adocao..."`), confira, e só então rode contra o banco real.
>
> ✅ Verificação: `SELECT COUNT(*) FROM Anomaly` continua ≥ 2 e `SELECT * FROM dbo.SchemaVersions` mostra o baseline.

### Banco vazio (máquina nova, Docker, CI)

```bash
dotnet run --project Decco.Database.Runner -- --target localdb
```

O runner cria o database (`EnsureDatabase`), roda o baseline de verdade e aplica o resto.

### Docker

```bash
# PowerShell
$env:DECCO_SA_PASSWORD = "<senha forte>"
docker compose -f docker/docker-compose.yml up -d
dotnet run --project Decco.Database.Runner -- --target docker
```

### Outros modos

```bash
dotnet run --project Decco.Database.Runner -- --target localdb --dry-run      # lista o que rodaria
dotnet run --project Decco.Database.Runner -- --connection "Server=...;..."   # alvo arbitrário
dotnet run --project Decco.Database.Runner -- --target localdb --single-transaction   # deploy inteiro numa transação
```

`--single-transaction` existe para deploys em que a migração e os scripts run-always dependem uns dos outros. A `0005`
remove os triggers antigos e conta com `20-triggers` para criar os novos: por script, as tabelas ficariam sem trigger
entre um passo e outro; em transação única, tudo entra ou sai junto.

A connection string é **um único ponto trocável**: `--connection` > `DECCO_DB_CONNECTION` > default do alvo.
Senha de Docker **sempre** por variável de ambiente — nunca em arquivo versionado.

---

## Adicionar uma tabela nova

1. `migrations/000N_<tema>.sql` — o `CREATE TABLE` + índices + o `UPDATE` de migração de dados, se houver.
2. Se tiver SP/view/trigger: um arquivo por objeto em `programmability/`, com `CREATE OR ALTER`.
3. Se for catálogo: um `MERGE` em `seed/`.
4. Descrições em `programmability/descriptions/`.
5. `dotnet run --project Decco.Database.Runner -- --target localdb`

**Nunca** editar um arquivo de `migrations/` já aplicado.

---

## Expand / contract — como uma migração destrutiva é feita aqui

As migrações 0002–0004 trocaram texto livre por entidade (`Laboratorio` + `Anomalia.SitioContencao` →
`Instalacao`) **sem perder dados**, em duas fases:

| Fase | Script | O que faz |
|---|---|---|
| **Expand** | `0002` | cria o modelo novo **ao lado** do antigo e copia os dados (set-based, genérico — roda igual num banco populado e num vazio) |
| | `0003` | acrescenta o que depende do modelo novo (`Operacao`) |
| **Contract** | `0004` | **prova** que todo dado antigo tem correspondente novo (3 verificações com `THROW`) e só então remove o antigo |

Regras que valem para qualquer migração destrutiva futura:

- A verificação vem **antes** do `DROP`, e falha com `THROW` — que no DbUp derruba a transação do script inteiro.
- O script de contract é **um lote só** (sem `GO`). `THROW` aborta o lote corrente; se o arquivo for rodado à mão no
  SSMS, cada `GO` iniciaria um lote novo que roda mesmo depois do erro — e os `DROP` aconteceriam. Em lote único, não.
- Migração estrutural **desliga o trigger de auditoria** enquanto mexe nas linhas: não é edição de negócio e não deve
  sobrescrever `UpdatedAt`/`UpdatedBy`.
- **Ensaio em dois bancos** antes do real: uma cópia do banco populado (adoção) e um banco vazio. Os dois precisam
  terminar no **mesmo estado** — schema, programabilidade, descrições e dados.

### A tradução do schema (0005–0007) — expand sem contract, ainda

| Fase | Script | O que faz |
|---|---|---|
| **Expand** | `0005` | `sp_rename` de 24 tabelas e das colunas; recria os 7 CHECKs que bloqueiam o rename; cria **views com os nomes antigos** sobre as tabelas novas |
| | `0006` | congela as procedures e views antigas, que leem e escrevem pelas views da `0005` |
| | `0007` | dá nome explícito a todas as constraints (o nome gerado mudava a cada banco criado) |
| **Contract** | *próxima migração* | remove a camada de compatibilidade — **depois** que a Decco.API usar os nomes em inglês |

Verificado antes de aplicar: o *fingerprint* de formato e de dados (por `object_id`, que o `sp_rename` preserva) ficou
idêntico; a suíte **atual** da Decco.API, sem uma linha alterada, passou contra o banco expandido; e a cópia populada,
o banco vazio e um banco criado do zero terminaram no mesmo estado. Lições que valem para qualquer rename:

- **Todo CHECK que cita a coluna bloqueia o `sp_rename`** (Msg 15336) — remover, renomear, recriar.
- **`SET XACT_ABORT ON`** em migração com `sp_rename`: sem ele, um rename que falha não aborta a transação.
- **O banco novo passa pela migração antes de qualquer run-always** — por isso a `0005` usa `DROP … IF EXISTS` nos
  triggers antigos, que ainda não existem nesse caminho.
- **Run-always é aditivo:** renomear o arquivo cria o objeto novo e deixa o antigo no banco. Quem remove é uma migração.
- **Não reservar números de migração.** Um número reservado e aplicado *depois* de números maiores roda em ordens
  diferentes num banco existente (por último) e num banco novo (na ordem do nome). A correção do `Simbolo CHAR(10)`,
  que estava reservada como `0005`, pega o próximo número livre quando for escrita.

### Armadilha: prefixo `sp_` + objetos perdidos no `master`

Para nomes que começam com `sp_`, o SQL Server procura **primeiro no `master`**. Se existir lá uma procedure com o
mesmo nome (ex.: alguém rodou o `decco.sql` sem `USE` e o schema caiu no `master`), o `CREATE OR ALTER` de um banco
novo enxerga a do `master`, tenta um `ALTER` local e falha com
`Msg 208 — Invalid object name 'sp_...'`. Qualificar com `dbo.` **não** resolve.

- Diagnóstico: `SELECT name FROM master.sys.objects WHERE is_ms_shipped = 0 AND name LIKE 'sp[_]%'`.
- Saída limpa: remover os objetos do `master` (decisão de quem administra a instância), ou ensaiar numa instância
  LocalDB nova — `sqllocaldb create DeccoEnsaio -s`, que já nasce com o `master` limpo.
- Correção de raiz: não usar o prefixo `sp_` em procedures de usuário. **Feito na `0005`**: as procedures são
  `usp_*`; as 18 `sp_*` sobrevivem só como camada de compatibilidade (`0006`) até o contract.

---

## Documentação embutida

As descrições de tabela e coluna vivem em `programmability/descriptions/` como *extended properties*
(`MS_Description`), aplicadas pelo helper idempotente `usp_Decco_SetDescription`.

Elas aparecem no SSMS e no Azure Data Studio, viram `<summary>` nas classes geradas por
`dotnet ef dbcontext scaffold`, e alimentam o dicionário:

```bash
sqlcmd -S "(localdb)\MSSQLLocalDB" -d DeccoDB -i docs/generate-data-dictionary.sql -o docs/DATA-DICTIONARY.md -h -1 -W -f 65001
```

Cobertura atual: **24/24 tabelas** e **94 colunas** de domínio documentadas.

---

## Divergências conhecidas em relação ao `decco.sql` original

Nada do DDL foi alterado. As transformações aplicadas na quebra em arquivos foram:

| O quê | Por quê |
|---|---|
| `CREATE DATABASE` / `USE` removidos | o runner cria o database via `EnsureDatabase`; scripts não escolhem em que banco rodam |
| `CREATE` → `CREATE OR ALTER` em SPs, views e triggers | é o que torna o regime run-always possível |
| `INSERT` dos catálogos → `MERGE` | idempotência; sem cláusula `DELETE`, linhas acrescentadas à mão sobrevivem |
| `Cat_MecanismoInteracao.CamadaOntologicaId` (hoje `Cat_InteractionMechanism.OntologicalLayerId`) resolvido por `Simbolo` | o original gravava os literais `1..4`, dependendo da ordem do IDENTITY |
| dados de exemplo envolvidos em `IF NOT EXISTS` | permitem rerodar sem violar as chaves únicas |

Inconsistências herdadas do baseline (`CHAR(10)` com padding, `TEXT` deprecado, `Eh*` vs `Is*`, auditoria parcial)
**não** foram corrigidas aqui — cada uma é uma migração própria. Lista completa no `DECCO-BACKLOG.md`.
