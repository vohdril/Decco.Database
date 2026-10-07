using System.Text;
using DbUp;
using DbUp.Engine;
using DbUp.Engine.Output;
using DbUp.Helpers;
using DbUp.Support;

Console.OutputEncoding = Encoding.UTF8;

// ─────────────────────────────────────────────────────────────────────────────
// Decco.Database.Runner — deploy de schema do DeccoDB
//
//   dotnet run -- --target localdb
//   dotnet run -- --target docker
//   dotnet run -- --target localdb --baseline   (adoção: marca sem executar)
//   dotnet run -- --target localdb --dry-run    (lista o que rodaria)
//
// Ordem de execução:
//   1. migrations/        RunOnce  — journaled em dbo.SchemaVersions (append-only)
//   2. programmability/   RunAlways — CREATE OR ALTER (triggers → procedures → views → descriptions)
//   3. seed/              RunAlways — MERGE convergente dos catálogos
//   4. seed/exemplos/     RunAlways — dados de exemplo, guardados por IF NOT EXISTS
//
// Porquê a ordem: `seed/exemplos/` chama stored procedures (sp_Anomalia_Inserir…),
// então a programabilidade precisa existir antes. E uma migração pode alterar uma
// tabela de que uma procedure depende, então migrations vem primeiro.
// ─────────────────────────────────────────────────────────────────────────────

var argv = args.ToList();
bool Flag(string name) => argv.Remove(name);
string? Opt(string name)
{
    var i = argv.IndexOf(name);
    if (i < 0 || i + 1 >= argv.Count) return null;
    var v = argv[i + 1];
    argv.RemoveRange(i, 2);
    return v;
}

var baseline = Flag("--baseline");
var dryRun   = Flag("--dry-run");
var target   = Opt("--target") ?? "localdb";
var explicitConnection = Opt("--connection");

// A connection string é UM ÚNICO PONTO TROCÁVEL (reference/02 da decco-maker).
// Precedência: --connection > variável de ambiente > default do alvo.
var connectionString = explicitConnection
    ?? Environment.GetEnvironmentVariable("DECCO_DB_CONNECTION")
    ?? target switch
    {
        "localdb" => @"Server=(localdb)\MSSQLLocalDB;Database=DeccoDB;Trusted_Connection=True;MultipleActiveResultSets=True;TrustServerCertificate=True;",
        // >>> senha do Docker SEMPRE por variável de ambiente — nunca neste arquivo
        "docker"  => $"Server=localhost,1433;Database=DeccoDB;User Id=sa;Password={Environment.GetEnvironmentVariable("DECCO_SA_PASSWORD")};TrustServerCertificate=True;MultipleActiveResultSets=True;",
        _ => throw new ArgumentException($"Alvo desconhecido: '{target}'. Use localdb | docker, ou passe --connection.")
    };

var raiz = LocalizarRaizDoProjeto();
var log  = new ConsoleUpgradeLog();

Console.WriteLine($"╔═ Decco.Database.Runner");
Console.WriteLine($"║  alvo .......... {(explicitConnection is not null ? "(--connection)" : target)}");
Console.WriteLine($"║  raiz .......... {raiz}");
Console.WriteLine($"║  modo .......... {(baseline ? "BASELINE (marcar sem executar)" : dryRun ? "DRY-RUN" : "deploy")}");
Console.WriteLine($"╚═");

// ── Etapa 0: criar o banco se não existir ───────────────────────────────────
// Database-first: o schema é do banco, mas o CONTINENTE (o database) o runner cria.
// É por isso que `CREATE DATABASE` não vive em nenhum script.
if (!baseline && !dryRun)
    EnsureDatabase.For.SqlDatabase(connectionString);

// ── Modo BASELINE: adoção de um banco que já existe ─────────────────────────
if (baseline)
{
    var pendentes = Carregar(Path.Combine(raiz, "migrations"), "10-migrations", ScriptType.RunOnce);

    Console.WriteLine("\nO modo --baseline MARCA os scripts abaixo como executados, SEM rodá-los.");
    Console.WriteLine("Use apenas ao adotar um banco que JÁ tem o schema aplicado.\n");
    foreach (var s in pendentes) Console.WriteLine($"   • {s.Name}");

    Console.Write("\nDigite ADOTAR para confirmar: ");
    if (Console.ReadLine()?.Trim() != "ADOTAR")
    {
        Console.WriteLine("Cancelado. Nada foi alterado.");
        return 2;
    }

    var engineBaseline = DeployChanges.To
        .SqlDatabase(connectionString)
        .WithScripts(pendentes)
        .WithVariablesDisabled()
        .JournalToSqlTable("dbo", "SchemaVersions")
        .LogTo(log)
        .Build();

    engineBaseline.MarkAsExecuted();
    Console.WriteLine("\n✅ Baseline marcado. Rode novamente sem --baseline para aplicar programabilidade e seed.");
    return 0;
}

// ── Deploy normal ───────────────────────────────────────────────────────────
var scripts = CarregarTudo(raiz);

var engine = DeployChanges.To
    .SqlDatabase(connectionString)
    .WithScripts(scripts)
    // `WithVariablesDisabled` desliga a substituição de $variavel$ do DbUp.
    // Sem isto, qualquer `$` literal num script vira erro de variável não definida.
    .WithVariablesDisabled()
    .WithTransactionPerScript()
    .JournalToSqlTable("dbo", "SchemaVersions")
    .LogTo(log)
    .Build();

if (dryRun)
{
    // GetScriptsToExecute() consulta o journal, logo precisa do banco de pé.
    // Se ele ainda não existe, nada foi aplicado — então tudo rodaria.
    if (!engine.TryConnect(out var erroConexao))
    {
        Console.WriteLine($"\n⚠️  Sem conexão com o banco ({erroConexao}).");
        Console.WriteLine("    Assumindo banco inexistente: TODOS os scripts rodariam.\n");
        foreach (var s in scripts) Console.WriteLine($"   • {s.Name}");
        return 0;
    }

    Console.WriteLine("\nScripts que seriam executados:\n");
    foreach (var s in engine.GetScriptsToExecute()) Console.WriteLine($"   • {s.Name}");
    return 0;
}

var resultado = engine.PerformUpgrade();

if (!resultado.Successful)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine($"\n❌ Falhou em: {resultado.ErrorScript?.Name}");
    Console.WriteLine(resultado.Error);
    Console.ResetColor();
    return 1;
}

Console.ForegroundColor = ConsoleColor.Green;
Console.WriteLine("\n✅ Deploy concluído.");
Console.ResetColor();
return 0;

// ─────────────────────────────────────────────────────────────────────────────

// ⚠️ O DbUp ORDENA OS SCRIPTS ALFABETICAMENTE PELO NOME — inclusive uma lista
// explícita passada a WithScripts(). A ordem em que adicionamos à List<> é
// descartada. Portanto a ordem de execução precisa estar codificada NO NOME.
//
// Daí o prefixo numérico de grupo. Sem ele, a ordem alfabética das pastas seria
//   descriptions < exemplos < migrations < procedures < seed < triggers < views
// — e num banco vazio `descriptions` rodaria antes de as tabelas existirem, e
// `exemplos` antes das stored procedures que ele chama. Os dois falhariam.
//
static List<SqlScript> CarregarTudo(string raiz)
{
    // Os grupos, na ordem em que PRECISAM rodar. O prefixo numérico é o que
    // GARANTE essa ordem depois da reordenação alfabética do DbUp.
    (string Pasta, string Prefixo, ScriptType Tipo)[] grupos =
    {
        ("migrations",                                    "10-migrations",   ScriptType.RunOnce),
        (Path.Combine("programmability", "triggers"),     "20-triggers",     ScriptType.RunAlways),
        (Path.Combine("programmability", "procedures"),   "30-procedures",   ScriptType.RunAlways),
        (Path.Combine("programmability", "views"),        "40-views",        ScriptType.RunAlways),
        (Path.Combine("programmability", "descriptions"), "50-descriptions", ScriptType.RunAlways),
        ("seed",                                          "60-seed",         ScriptType.RunAlways),
        (Path.Combine("seed", "exemplos"),                "70-exemplos",     ScriptType.RunAlways),
    };

    var todos = new List<SqlScript>();
    foreach (var (pasta, prefixo, tipo) in grupos)
        todos.AddRange(Carregar(Path.Combine(raiz, pasta), prefixo, tipo));
    return todos;
}

// Carrega os .sql de uma pasta como SqlScript explícitos — à mão, em vez de
// WithScriptsFromFileSystem, para o runner dizer exatamente o que faz.
static List<SqlScript> Carregar(string pasta, string prefixo, ScriptType tipo)
{
    if (!Directory.Exists(pasta)) return new List<SqlScript>();

    var opcoes = new SqlScriptOptions { ScriptType = tipo };

    return Directory
        .GetFiles(pasta, "*.sql", SearchOption.TopDirectoryOnly)
        .OrderBy(f => f, StringComparer.Ordinal)
        .Select(f => new SqlScript(
            // O nome é a chave do journal E o critério de ordenação.
            name: $"{prefixo}/{Path.GetFileName(f)}",
            contents: File.ReadAllText(f),
            sqlScriptOptions: opcoes))
        .ToList();
}

// Sobe a árvore procurando a pasta que contém `migrations/` — permite rodar
// tanto de bin/Debug quanto da raiz do projeto.
static string LocalizarRaizDoProjeto()
{
    var dir = new DirectoryInfo(AppContext.BaseDirectory);
    while (dir is not null)
    {
        if (Directory.Exists(Path.Combine(dir.FullName, "migrations"))) return dir.FullName;
        dir = dir.Parent;
    }
    throw new DirectoryNotFoundException(
        "Não encontrei a pasta 'migrations/'. Rode a partir de Decco.Database/.");
}
