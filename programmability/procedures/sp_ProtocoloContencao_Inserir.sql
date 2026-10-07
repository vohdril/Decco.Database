-- Procedure that creates a containment protocol
CREATE OR ALTER PROCEDURE sp_ProtocoloContencao_Inserir
    @Codigo VARCHAR(20),
    @Titulo NVARCHAR(255),
    @Descricao NVARCHAR(MAX),
    @NivelUrgencia INT,
    @ClassesAplicaveis VARCHAR(100) = NULL,
    @Passos NVARCHAR(MAX),
    @RecursosNecessarios NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProtocoloContencao (Codigo, Titulo, Descricao, NivelUrgencia, ClassesAplicaveis, Passos, RecursosNecessarios)
    VALUES (@Codigo, @Titulo, @Descricao, @NivelUrgencia, @ClassesAplicaveis, @Passos, @RecursosNecessarios);
    SELECT SCOPE_IDENTITY() as NovoId;
END;
GO
