# Decco.Database

Versionamento de schema do **DeccoDB** — o banco de domínio do sandbox de estudos **Decco**, um catálogo fictício de
anomalias no estilo Fundação SCP / MIB, usado para praticar arquitetura .NET corporativa.

Estratégia: **migração** (não estado), com [DbUp](https://dbup.readthedocs.io/). O deploy é um console .NET 8 neste
mesmo repositório — nada de CLI externo.

> **Dados 100% fictícios.** Nenhum segredo, credencial real ou dado pessoal. Senhas de container vêm sempre de
> variável de ambiente.

## Repositórios do ecossistema

| Repo | Papel |
|---|---|
| [`Decco.API`](https://github.com/vohdril/Decco.API) | core .NET 8 (EF Core + Dapper) que **possui** este banco |
| [`Decco.Dashboard`](https://github.com/vohdril/Decco.Dashboard) | front React/Vite + Module Federation |
| [`decco-skill`](https://github.com/vohdril/decco-skill) | a skill didática que guia o desenvolvimento |
| **`Decco.Database`** | **este repo** — o schema, versionado |

Por que um repositório separado para o banco: o schema tem ciclo de vida próprio (muda por migração, não por
compilação), é consumido por mais de um projeto, e precisa de histórico auditável independente do código da API.
É o mesmo motivo pelo qual ecossistemas corporativos mantêm um `*-db` ao lado do `*-api`.

---

## Estrutura

```
migrations/            APPEND-ONLY, journaled em dbo.SchemaVersions
  0001_baseline_schema.sql     21 tabelas + 12 índices — DDL do decco.sql, inalterado

programmability/       RUN-ALWAYS, CREATE OR ALTER — editável no lugar, diffável no git
  triggers/      (2)
  procedures/    (13)
  views/         (3)
  descriptions/  (4)   extended properties = documentação embutida

seed/                  RUN-ALWAYS, MERGE convergente
  010..080-Cat_*.sql   os 8 catálogos
  exemplos/            dados de exemplo, guardados por IF NOT EXISTS

docs/                  gerar-dicionario.sql → DICIONARIO-DE-DADOS.md
docker/                SQL Server para o alvo `docker`
Decco.Database.Runner/ console .NET 8 que faz o deploy
```

**Ordem de execução:** `migrations` → `programmability` (triggers → procedures → views → descriptions) → `seed` → `seed/exemplos`.

Por que nesta ordem: `seed/exemplos/` chama stored procedures, então a programabilidade precisa existir antes;
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
# confirme digitando ADOTAR
dotnet run --project Decco.Database.Runner -- --target localdb
```

A primeira chamada insere `migrations/0001_baseline_schema.sql` em `dbo.SchemaVersions` **sem rodar**.
A segunda aplica programabilidade, seed e exemplos — todos idempotentes.

> ⚠️ **Ensaie antes.** Restaure um backup como `DeccoDB_Adocao`, rode os dois comandos apontando para ele
> (`--connection "...Database=DeccoDB_Adocao..."`), confira, e só então rode contra o banco real.
>
> ✅ Verificação: `SELECT COUNT(*) FROM Anomalia` continua ≥ 2 e `SELECT * FROM dbo.SchemaVersions` mostra o baseline.

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
```

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

## Documentação embutida

As descrições de tabela e coluna vivem em `programmability/descriptions/` como *extended properties*
(`MS_Description`), aplicadas pelo helper idempotente `sp_Decco_SetDescription`.

Elas aparecem no SSMS e no Azure Data Studio, viram `<summary>` nas classes geradas por
`dotnet ef dbcontext scaffold`, e alimentam o dicionário:

```bash
sqlcmd -S "(localdb)\MSSQLLocalDB" -d DeccoDB -i docs/gerar-dicionario.sql -o docs/DICIONARIO-DE-DADOS.md -h -1 -W -f 65001
```

Cobertura atual: **21/21 tabelas** e **73 colunas** de domínio documentadas.

---

## Divergências conhecidas em relação ao `decco.sql` original

Nada do DDL foi alterado. As transformações aplicadas na quebra em arquivos foram:

| O quê | Por quê |
|---|---|
| `CREATE DATABASE` / `USE` removidos | o runner cria o database via `EnsureDatabase`; scripts não escolhem em que banco rodam |
| `CREATE` → `CREATE OR ALTER` em SPs, views e triggers | é o que torna o regime run-always possível |
| `INSERT` dos catálogos → `MERGE` | idempotência; sem cláusula `DELETE`, linhas acrescentadas à mão sobrevivem |
| `Cat_MecanismoInteracao.CamadaOntologicaId` resolvido por `Simbolo` | o original gravava os literais `1..4`, dependendo da ordem do IDENTITY |
| dados de exemplo envolvidos em `IF NOT EXISTS` | permitem rerodar sem violar as chaves únicas |

Inconsistências herdadas do baseline (`CHAR(10)` com padding, `TEXT` deprecado, `Eh*` vs `Is*`, auditoria parcial)
**não** foram corrigidas aqui — cada uma é uma migração própria. Lista completa no `DECCO-BACKLOG.md`.
