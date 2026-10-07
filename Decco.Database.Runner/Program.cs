using System.Text;
using DbUp;
using DbUp.Engine;
using DbUp.Engine.Output;
using DbUp.Helpers;
using DbUp.Support;

Console.OutputEncoding = Encoding.UTF8;

// ─────────────────────────────────────────────────────────────────────────────
// Decco.Database.Runner — DeccoDB schema deployment
//
//   dotnet run -- --target localdb
//   dotnet run -- --target docker
//   dotnet run -- --target localdb --baseline   (adoption: mark without running)
//   dotnet run -- --target localdb --dry-run    (list what would run)
//
// Execution order:
//   1. migrations/        RunOnce  — journaled in dbo.SchemaVersions (append-only)
//   2. programmability/   RunAlways — CREATE OR ALTER (triggers → procedures → views → descriptions)
//   3. seed/              RunAlways — converging MERGE of the catalogs
//   4. seed/examples/     RunAlways — example data, guarded by IF NOT EXISTS
//
// Why this order: `seed/examples/` calls stored procedures (sp_Anomalia_Inserir…),
// so programmability must exist first. And a migration may change a table a
// procedure depends on, so migrations come first.
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

// The connection string is ONE SWAPPABLE POINT (decco-maker reference/02).
// Precedence: --connection > environment variable > target default.
var connectionString = explicitConnection
    ?? Environment.GetEnvironmentVariable("DECCO_DB_CONNECTION")
    ?? target switch
    {
        "localdb" => @"Server=(localdb)\MSSQLLocalDB;Database=DeccoDB;Trusted_Connection=True;MultipleActiveResultSets=True;TrustServerCertificate=True;",
        // >>> the Docker password ALWAYS comes from an environment variable — never from this file
        "docker"  => $"Server=localhost,1433;Database=DeccoDB;User Id=sa;Password={Environment.GetEnvironmentVariable("DECCO_SA_PASSWORD")};TrustServerCertificate=True;MultipleActiveResultSets=True;",
        _ => throw new ArgumentException($"Unknown target: '{target}'. Use localdb | docker, or pass --connection.")
    };

var root = FindProjectRoot();
var log  = new ConsoleUpgradeLog();

Console.WriteLine($"╔═ Decco.Database.Runner");
Console.WriteLine($"║  target ........ {(explicitConnection is not null ? "(--connection)" : target)}");
Console.WriteLine($"║  root .......... {root}");
Console.WriteLine($"║  mode .......... {(baseline ? "BASELINE (mark without running)" : dryRun ? "DRY-RUN" : "deploy")}");
Console.WriteLine($"╚═");

// ── Step 0: create the database if it does not exist ────────────────────────
// Database-first: the schema belongs to the database, but the runner creates the
// CONTAINER (the database itself). That is why `CREATE DATABASE` lives in no script.
if (!baseline && !dryRun)
    EnsureDatabase.For.SqlDatabase(connectionString);

// ── BASELINE mode: adopting a database that already exists ──────────────────
if (baseline)
{
    var pending = Load(Path.Combine(root, "migrations"), "10-migrations", ScriptType.RunOnce);

    Console.WriteLine("\n--baseline MARKS the scripts below as executed, WITHOUT running them.");
    Console.WriteLine("Use it only when adopting a database that ALREADY has the schema applied.\n");
    foreach (var s in pending) Console.WriteLine($"   • {s.Name}");

    Console.Write("\nType ADOPT to confirm: ");
    if (Console.ReadLine()?.Trim() != "ADOPT")
    {
        Console.WriteLine("Cancelled. Nothing was changed.");
        return 2;
    }

    var baselineEngine = DeployChanges.To
        .SqlDatabase(connectionString)
        .WithScripts(pending)
        .WithVariablesDisabled()
        .JournalToSqlTable("dbo", "SchemaVersions")
        .LogTo(log)
        .Build();

    baselineEngine.MarkAsExecuted();
    Console.WriteLine("\n✅ Baseline marked. Run again without --baseline to apply programmability and seed.");
    return 0;
}

// ── Normal deployment ───────────────────────────────────────────────────────
var scripts = LoadAll(root);

var engine = DeployChanges.To
    .SqlDatabase(connectionString)
    .WithScripts(scripts)
    // `WithVariablesDisabled` turns off DbUp's $variable$ substitution.
    // Without it, any literal `$` in a script becomes an undefined-variable error.
    .WithVariablesDisabled()
    .WithTransactionPerScript()
    .JournalToSqlTable("dbo", "SchemaVersions")
    .LogTo(log)
    .Build();

if (dryRun)
{
    // GetScriptsToExecute() reads the journal, so it needs the database to be up.
    // If it does not exist yet, nothing was applied — so everything would run.
    if (!engine.TryConnect(out var connectionError))
    {
        Console.WriteLine($"\n⚠️  No connection to the database ({connectionError}).");
        Console.WriteLine("    Assuming a missing database: ALL scripts would run.\n");
        foreach (var s in scripts) Console.WriteLine($"   • {s.Name}");
        return 0;
    }

    Console.WriteLine("\nScripts that would run:\n");
    foreach (var s in engine.GetScriptsToExecute()) Console.WriteLine($"   • {s.Name}");
    return 0;
}

var result = engine.PerformUpgrade();

if (!result.Successful)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine($"\n❌ Failed at: {result.ErrorScript?.Name}");
    Console.WriteLine(result.Error);
    Console.ResetColor();
    return 1;
}

Console.ForegroundColor = ConsoleColor.Green;
Console.WriteLine("\n✅ Deployment completed.");
Console.ResetColor();
return 0;

// ─────────────────────────────────────────────────────────────────────────────

// ⚠️ DbUp SORTS SCRIPTS ALPHABETICALLY BY NAME — even an explicit list passed to
// WithScripts(). The order in which we add them to the List<> is discarded.
// Therefore the execution order must be encoded IN THE NAME.
//
// Hence the numeric group prefix. Without it, the alphabetical folder order would be
//   descriptions < examples < migrations < procedures < seed < triggers < views
// — and on an empty database `descriptions` would run before the tables exist, and
// `examples` before the stored procedures it calls. Both would fail.
//
static List<SqlScript> LoadAll(string root)
{
    // The groups, in the order they MUST run. The numeric prefix is what GUARANTEES
    // that order after DbUp's alphabetical sort.
    (string Folder, string Prefix, ScriptType Type)[] groups =
    {
        ("migrations",                                    "10-migrations",   ScriptType.RunOnce),
        (Path.Combine("programmability", "triggers"),     "20-triggers",     ScriptType.RunAlways),
        (Path.Combine("programmability", "procedures"),   "30-procedures",   ScriptType.RunAlways),
        (Path.Combine("programmability", "views"),        "40-views",        ScriptType.RunAlways),
        (Path.Combine("programmability", "descriptions"), "50-descriptions", ScriptType.RunAlways),
        ("seed",                                          "60-seed",         ScriptType.RunAlways),
        (Path.Combine("seed", "examples"),                "70-examples",     ScriptType.RunAlways),
    };

    var all = new List<SqlScript>();
    foreach (var (folder, prefix, type) in groups)
        all.AddRange(Load(Path.Combine(root, folder), prefix, type));
    return all;
}

// Loads the .sql files of a folder as explicit SqlScripts — by hand, instead of
// WithScriptsFromFileSystem, so the runner says exactly what it does.
static List<SqlScript> Load(string folder, string prefix, ScriptType type)
{
    if (!Directory.Exists(folder)) return new List<SqlScript>();

    var options = new SqlScriptOptions { ScriptType = type };

    return Directory
        .GetFiles(folder, "*.sql", SearchOption.TopDirectoryOnly)
        .OrderBy(f => f, StringComparer.Ordinal)
        .Select(f => new SqlScript(
            // The name is the journal key AND the sorting criterion.
            name: $"{prefix}/{Path.GetFileName(f)}",
            contents: File.ReadAllText(f),
            sqlScriptOptions: options))
        .ToList();
}

// Walks up the tree looking for the folder that contains `migrations/` — allows
// running both from bin/Debug and from the project root.
static string FindProjectRoot()
{
    var dir = new DirectoryInfo(AppContext.BaseDirectory);
    while (dir is not null)
    {
        if (Directory.Exists(Path.Combine(dir.FullName, "migrations"))) return dir.FullName;
        dir = dir.Parent;
    }
    throw new DirectoryNotFoundException(
        "Could not find the 'migrations/' folder. Run from Decco.Database/.");
}
