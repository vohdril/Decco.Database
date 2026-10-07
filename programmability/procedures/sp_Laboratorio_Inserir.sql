-- Procedure para criar laboratório
CREATE OR ALTER PROCEDURE sp_Laboratorio_Inserir
    @Codigo VARCHAR(20),
    @Nome NVARCHAR(255),
    @Descricao NVARCHAR(MAX) = NULL,
    @Sitio NVARCHAR(100),
    @Responsavel NVARCHAR(255) = NULL,
    @Especialidade VARCHAR(50) = NULL,
    @NivelAcessoMinimo INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Laboratorio (Codigo, Nome, Descricao, Sitio, Responsavel, Especialidade, NivelAcessoMinimo)
    VALUES (@Codigo, @Nome, @Descricao, @Sitio, @Responsavel, @Especialidade, @NivelAcessoMinimo);
    SELECT SCOPE_IDENTITY() as NovoId;
END;
GO
