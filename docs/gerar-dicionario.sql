-- =============================================================================
-- Gera o docs/DICIONARIO-DE-DADOS.md a partir do PRÓPRIO BANCO.
--
-- Porquê gerado e não escrito à mão: um dicionário mantido manualmente
-- desatualiza na primeira migração que ninguém lembrou de refletir. Aqui a
-- fonte da verdade são as extended properties, aplicadas por
-- programmability/descriptions/ — o markdown é só uma projeção.
--
-- Uso:
--   sqlcmd -S "(localdb)\MSSQLLocalDB" -d DeccoDB -i docs/gerar-dicionario.sql ^
--          -o docs/DICIONARIO-DE-DADOS.md -h -1 -W -f 65001
-- =============================================================================
SET NOCOUNT ON;

PRINT '# Dicionário de Dados — DeccoDB';
PRINT '';
PRINT '> Gerado por `docs/gerar-dicionario.sql`. **Não editar à mão** — alterar as descrições em';
PRINT '> `programmability/descriptions/` e rodar o runner.';
PRINT '';

DECLARE @tab SYSNAME, @desc NVARCHAR(MAX);
DECLARE cur CURSOR FAST_FORWARD FOR
    SELECT t.name,
           CAST(ep.value AS NVARCHAR(MAX))
      FROM sys.tables t
      LEFT JOIN sys.extended_properties ep
             ON ep.class = 1 AND ep.major_id = t.object_id
            AND ep.minor_id = 0 AND ep.name = N'MS_Description'
     WHERE t.name <> 'SchemaVersions'
     ORDER BY t.name;

OPEN cur;
FETCH NEXT FROM cur INTO @tab, @desc;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '## ' + @tab;
    PRINT '';
    IF @desc IS NOT NULL BEGIN PRINT @desc; PRINT ''; END
    PRINT '| Coluna | Tipo | Nulo | Descrição |';
    PRINT '|---|---|---|---|';

    DECLARE @linha NVARCHAR(MAX);
    DECLARE c2 CURSOR FAST_FORWARD FOR
        SELECT '| `' + c.name + '` | '
             + ty.name
             + CASE WHEN ty.name IN ('varchar','nvarchar','char','nchar')
                    THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX'
                                    ELSE CAST(c.max_length / CASE WHEN ty.name LIKE 'n%' THEN 2 ELSE 1 END AS VARCHAR(10)) END + ')'
                    WHEN ty.name = 'decimal'
                    THEN '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                    ELSE '' END
             + ' | ' + CASE WHEN c.is_nullable = 1 THEN 'sim' ELSE 'não' END
             + ' | ' + ISNULL(REPLACE(CAST(ep.value AS NVARCHAR(MAX)), '|', '\|'), '') + ' |'
          FROM sys.columns c
          JOIN sys.types ty ON ty.user_type_id = c.user_type_id
          LEFT JOIN sys.extended_properties ep
                 ON ep.class = 1 AND ep.major_id = c.object_id
                AND ep.minor_id = c.column_id AND ep.name = N'MS_Description'
         WHERE c.object_id = OBJECT_ID(@tab)
         ORDER BY c.column_id;

    OPEN c2;
    FETCH NEXT FROM c2 INTO @linha;
    WHILE @@FETCH_STATUS = 0 BEGIN PRINT @linha; FETCH NEXT FROM c2 INTO @linha; END
    CLOSE c2; DEALLOCATE c2;

    PRINT '';
    FETCH NEXT FROM cur INTO @tab, @desc;
END
CLOSE cur; DEALLOCATE cur;
