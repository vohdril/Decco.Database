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
| [`decco-skills`](https://github.com/vohdril/decco-skills) | as skills didáticas que guiam o desenvolvimento (a migrar para `Decco.Skills`) |
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

programmability/       RUN-ALWAYS, CREATE OR ALTER — editável no lugar, diffável no git
  triggers/      (6)
  procedures/    (18)
  views/         (3)
  descriptions/  (4)   extended properties = documentação embutida

seed/                  RUN-ALWAYS, MERGE convergente
  010..100-Cat_*.sql   os 10 catálogos
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
  sobrescrever `DataAtualizacao`/`UsuarioAtualizacao`.
- **Ensaio em dois bancos** antes do real: uma cópia do banco populado (adoção) e um banco vazio. Os dois precisam
  terminar no **mesmo estado** — schema, programabilidade, descrições e dados.

### Armadilha: prefixo `sp_` + objetos perdidos no `master`

Para nomes que começam com `sp_`, o SQL Server procura **primeiro no `master`**. Se existir lá uma procedure com o
mesmo nome (ex.: alguém rodou o `decco.sql` sem `USE` e o schema caiu no `master`), o `CREATE OR ALTER` de um banco
novo enxerga a do `master`, tenta um `ALTER` local e falha com
`Msg 208 — Invalid object name 'sp_...'`. Qualificar com `dbo.` **não** resolve.

- Diagnóstico: `SELECT name FROM master.sys.objects WHERE is_ms_shipped = 0 AND name LIKE 'sp[_]%'`.
- Saída limpa: remover os objetos do `master` (decisão de quem administra a instância), ou ensaiar numa instância
  LocalDB nova — `sqllocaldb create DeccoEnsaio -s`, que já nasce com o `master` limpo.
- Correção de raiz: não usar o prefixo `sp_` em procedures de usuário. Renomear as 18 é uma mudança que quebra a
  `Decco.API`; está no `DECCO-BACKLOG.md`.

---

## Documentação embutida

As descrições de tabela e coluna vivem em `programmability/descriptions/` como *extended properties*
(`MS_Description`), aplicadas pelo helper idempotente `sp_Decco_SetDescription`.

Elas aparecem no SSMS e no Azure Data Studio, viram `<summary>` nas classes geradas por
`dotnet ef dbcontext scaffold`, e alimentam o dicionário:

```bash
sqlcmd -S "(localdb)\MSSQLLocalDB" -d DeccoDB -i docs/gerar-dicionario.sql -o docs/DICIONARIO-DE-DADOS.md -h -1 -W -f 65001
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
| `Cat_MecanismoInteracao.CamadaOntologicaId` resolvido por `Simbolo` | o original gravava os literais `1..4`, dependendo da ordem do IDENTITY |
| dados de exemplo envolvidos em `IF NOT EXISTS` | permitem rerodar sem violar as chaves únicas |

Inconsistências herdadas do baseline (`CHAR(10)` com padding, `TEXT` deprecado, `Eh*` vs `Is*`, auditoria parcial)
**não** foram corrigidas aqui — cada uma é uma migração própria. Lista completa no `DECCO-BACKLOG.md`.
