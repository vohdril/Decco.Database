-- Procedure para obter o perfil completo de uma anomalia
CREATE OR ALTER PROCEDURE sp_Anomalia_ObterPerfilCompleto
    @AnomaliaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Informações básicas da anomalia
    SELECT 
        a.Id,
        a.CodigoSCP,
        a.NomeComum,
        a.Descricao,
        co.Nome as ClasseObjeto,
        co.CorAlerta,
        ca.Nome as CamadaOntologica,
        ff.Nome as ForcaFundamental,
        tm.Nome as TipoMateria,
        mp.Nome as MecanismoPrimario,
        ms.Nome as MecanismoSecundario,
        a.IEIA_D_Base,
        a.FatorCoerenciaSpin,
        a.Status,
        a.SitioContencao,
        a.ResponsavelPesquisa,
        a.DataCriacao,
        a.DataAtualizacao
    FROM Anomalia a
    INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
    INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
    INNER JOIN Cat_ForcaFundamental ff ON ca.ForcaFundamentalId = ff.Id
    INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
    INNER JOIN Cat_MecanismoInteracao mp ON a.MecanismoPrimarioId = mp.Id
    LEFT JOIN Cat_MecanismoInteracao ms ON a.MecanismoSecundarioId = ms.Id
    WHERE a.Id = @AnomaliaId;
    
    -- Entidades vivas associadas
    SELECT * FROM EntidadeViva WHERE AnomaliaId = @AnomaliaId;
    
    -- Artefatos associados
    SELECT * FROM Artefato WHERE AnomaliaId = @AnomaliaId;
    
    -- Localidades associadas
    SELECT * FROM Localidade WHERE AnomaliaId = @AnomaliaId;
    
    -- Eventos associados
    SELECT * FROM Evento WHERE AnomaliaId = @AnomaliaId;
    
    -- Perícias da anomalia
    SELECT 
        pa.*,
        mp.Nome as MecanismoPrimarioNome,
        ms.Nome as MecanismoSecundarioNome
    FROM PericiaAnomalia pa
    INNER JOIN Cat_MecanismoInteracao mp ON pa.MecanismoPrimarioId = mp.Id
    LEFT JOIN Cat_MecanismoInteracao ms ON pa.MecanismoSecundarioId = ms.Id
    WHERE pa.AnomaliaId = @AnomaliaId;
    
    -- Manifestações (via perícias)
    SELECT DISTINCT
        cm.Codigo,
        cm.Nome,
        cm.Descricao
    FROM PericiaAnomalia pa
    INNER JOIN Pericia_Manifestacao pm ON pa.Id = pm.PericiaAnomaliaId
    INNER JOIN Cat_ManifestacaoEspecifica cm ON pm.ManifestacaoEspecificaId = cm.Id
    WHERE pa.AnomaliaId = @AnomaliaId;
    
    -- Incidentes registrados
    SELECT * FROM Incidente 
    WHERE AnomaliaId = @AnomaliaId 
    ORDER BY DataHora DESC;
END;
GO
