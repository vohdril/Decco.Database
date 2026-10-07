CREATE OR ALTER VIEW vw_Relatorio_Sigma AS
SELECT 
    a.CodigoSCP,
    a.NomeComum,
    co.Nome as Classe,
    ca.Nome as Camada,
    tm.IsResistenteSupressores,
    COUNT(i.Id) as TotalIncidentes,
    SUM(CASE WHEN i.IsEventoSigma = 1 THEN 1 ELSE 0 END) as IncidentesSigma,
    MAX(i.DataHora) as UltimoIncidente,
    ic.Codigo AS InstalacaoContencaoCodigo,
    ic.Nome AS InstalacaoContencao,
    a.ResponsavelPesquisa
FROM Anomalia a
INNER JOIN Cat_ClasseObjeto co ON a.ClasseObjetoId = co.Id
INNER JOIN Cat_CamadaOntologica ca ON a.CamadaOntologicaId = ca.Id
INNER JOIN Cat_TipoMateria tm ON a.TipoMateriaId = tm.Id
LEFT JOIN Instalacao ic ON ic.Id = a.InstalacaoContencaoId
LEFT JOIN Incidente i ON a.Id = i.AnomaliaId
WHERE ca.Simbolo = 'OMEGA' 
   OR tm.IsResistenteSupressores = 1
   OR co.Codigo = 'APOT'
GROUP BY a.Id, a.CodigoSCP, a.NomeComum, co.Nome, ca.Nome, 
         tm.IsResistenteSupressores, ic.Codigo, ic.Nome, a.ResponsavelPesquisa;
GO
