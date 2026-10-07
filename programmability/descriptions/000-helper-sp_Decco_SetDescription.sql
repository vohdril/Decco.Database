-- =============================================================================
-- Helper de documentação embutida (extended properties).
--
-- Porquê existe: `sp_addextendedproperty` FALHA se a propriedade já existe, e
-- `sp_updateextendedproperty` falha se NÃO existe. Num script run-always isso
-- obrigaria a um IF EXISTS/ELSE de 6 linhas por coluna documentada (~130 colunas).
-- Este helper faz o upsert e deixa as chamadas com uma linha cada.
--
-- A documentação em MS_Description aparece no SSMS, no Azure Data Studio, vira
-- <summary> nas classes geradas por `dotnet ef dbcontext scaffold`, e alimenta a
-- geração do docs/DICIONARIO-DE-DADOS.md.
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.sp_Decco_SetDescription
    @Tabela    SYSNAME,
    @Coluna    SYSNAME        = NULL,   -- NULL = descrição da TABELA
    -- ⚠️ NÃO usar NVARCHAR(MAX) aqui. O parâmetro @value de sp_addextendedproperty
    -- é SQL_VARIANT, e sql_variant NÃO suporta os tipos MAX — passar nvarchar(max)
    -- resulta em "Operand type clash: nvarchar(max) is incompatible with sql_variant"
    -- (erro 206). O limite prático seguro para nvarchar dentro de sql_variant é 3750.
    @Descricao NVARCHAR(3750)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(@Tabela) IS NULL
    BEGIN
        RAISERROR('sp_Decco_SetDescription: objeto %s não existe.', 16, 1, @Tabela);
        RETURN;
    END

    DECLARE @existe BIT = 0;

    IF @Coluna IS NULL
        SELECT @existe = 1
          FROM sys.extended_properties
         WHERE class = 1 AND major_id = OBJECT_ID(@Tabela) AND minor_id = 0
           AND name = N'MS_Description';
    ELSE
        SELECT @existe = 1
          FROM sys.extended_properties ep
          JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
         WHERE ep.class = 1 AND ep.major_id = OBJECT_ID(@Tabela)
           AND c.name = @Coluna AND ep.name = N'MS_Description';

    IF @existe = 1
    BEGIN
        IF @Coluna IS NULL
            EXEC sp_updateextendedproperty N'MS_Description', @Descricao,
                 N'SCHEMA', N'dbo', N'TABLE', @Tabela;
        ELSE
            EXEC sp_updateextendedproperty N'MS_Description', @Descricao,
                 N'SCHEMA', N'dbo', N'TABLE', @Tabela, N'COLUMN', @Coluna;
    END
    ELSE
    BEGIN
        IF @Coluna IS NULL
            EXEC sp_addextendedproperty N'MS_Description', @Descricao,
                 N'SCHEMA', N'dbo', N'TABLE', @Tabela;
        ELSE
            EXEC sp_addextendedproperty N'MS_Description', @Descricao,
                 N'SCHEMA', N'dbo', N'TABLE', @Tabela, N'COLUMN', @Coluna;
    END
END
GO
