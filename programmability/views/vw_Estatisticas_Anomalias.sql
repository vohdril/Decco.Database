CREATE OR ALTER VIEW vw_Estatisticas_Anomalias AS
SELECT 
    -- Totais
    COUNT(*) as TotalAnomalias,
    SUM(CASE WHEN Status = 'ATIVA' THEN 1 ELSE 0 END) as Ativas,
    SUM(CASE WHEN Status = 'NEUTRALIZADA' THEN 1 ELSE 0 END) as Neutralizadas,
    
    -- Por Classe
    SUM(CASE WHEN co.Codigo = 'SAFE' THEN 1 ELSE 0 END) as Classe_Safe,
    SUM(CASE WHEN co.Codigo = 'EUCLID' THEN 1 ELSE 0 END) as Classe_Euclid,
    SUM(CASE WHEN co.Codigo = 'KETER' THEN 1 ELSE 0 END) as Classe_Keter,
    SUM(CASE WHEN co.Codigo = 'THAUMIEL' THEN 1 ELSE 0 END) as Classe_Thaumiel,
    SUM(CASE WHEN co.Codigo = 'APOT' THEN 1 ELSE 0 END) as Classe_Apotheosis,
    
    -- Por Camada
    SUM(CASE WHEN ca.Simbolo = 'THETA' THEN 1 ELSE 0 END) as Camada_Theta,
    SUM(CASE WHEN ca.Simbolo = 'PSI' THEN 1 ELSE 0 END) as Camada_Psi,
    SUM(CASE WHEN ca.Simbolo = 'PHI' THEN 1 ELSE 0 END) as Camada_Phi,
    SUM(CASE WHEN ca.Simbolo = 'OMEGA' THEN 1 ELSE 0 END) as Camada_Omega,
    
    -- Por Tipo de Matéria
    SUM(CASE WHEN tm.Nome = 'Bariônica Anômala' THEN 1 ELSE 0 END) as Materia_Barionica,
    SUM(CASE WHEN tm.Nome = 'Não-Bariônica' THEN 1 ELSE 0 END) as Materia_NaoBarionica,
    SUM(CASE WHEN tm.Nome = 'Mista' THEN 1 ELSE 0 END) as Materia_Mista,
    
    -- Estatísticas Theta
    AVG(ISNULL(a.IEIA_D_Base, 0)) as IEIA_D_Medio,
    SUM(CASE WHEN tm.IsResistenteSupressores = 1 THEN 1 ELSE 0 END) as ResistenteSupressao
    
FROM Anomalia a
INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id;
GO
