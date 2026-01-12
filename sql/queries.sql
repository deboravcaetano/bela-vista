-- == ========================================================== == --
-- == ======================== QUERIES ========================= == --
-- Interrogações utilizadas pelos utilizadores do sistema de base de dados.
-- == ========================================================== == --

USE BelaVista;

-- Calcular as datas de ida e regresso das viagens com base nos seus dias
SELECT
    v.Id AS IdViagem,
    v.Titulo AS NomeViagem,
    MIN(dv.Data) AS DataIda,
    MAX(dv.Data) AS DataRegresso
FROM
    Viagem AS v
        JOIN
    DiaDeViagem AS dv ON v.Id = dv.Id_Viagem
GROUP BY v.Id , v.Titulo;


-- Identificar o utilizador com maior número de viagens realizadas
SELECT
    u.Id AS UserId,
    u.Nome AS Nome_Utilizador,
    COUNT(vru.Id_Viagem) AS Total_Viagens
FROM
    Utilizador AS u
        JOIN
    ViagemRealizadaUtilizador AS vru ON u.Id = vru.Id_Utilizador
GROUP BY u.Id
ORDER BY Total_Viagens DESC
LIMIT 1;


-- Listar as avaliações (média de avaliação quantitativa) por viagem
SELECT
    v.Id AS IdViagem,
    v.Titulo AS NomeViagem,
    AVG(vru.Avaliacao_Quantitativa) AS MediaAvaliacao
FROM
    Viagem AS v
        JOIN
    ViagemRealizadaUtilizador AS vru ON v.Id = vru.Id_Viagem
GROUP BY v.Id , v.Titulo
ORDER BY MediaAvaliacao DESC;


-- Listar o custo total das viagens com base nos seus dias
SELECT
    V.Id, V.Titulo, SUM(DV.Custo) AS Custo_Viagem
FROM
    Viagem AS V
        INNER JOIN
    DiaDeViagem AS DV ON V.Id = DV.Id_Viagem
GROUP BY V.Id
ORDER BY V.Id;


-- Listar todos os utilizadores que pertencem a uma organização
PREPARE participantes_organização FROM
	'SELECT UPO.Id_Utilizador, U.Nome
		FROM UtilizadorPertenceOrganizacao AS UPO INNER JOIN Utilizador AS U
			ON UPO.Id_Utilizador = U.Id
        WHERE Id_Organizacao = ? ;';

SET @id_org = 2;
EXECUTE participantes_organização USING @id_org;
DEALLOCATE PREPARE participantes_organização;


-- Listar todos os participantes de uma viagem
PREPARE participantes_viagem FROM
	'SELECT VRU.Id_Utilizador, U.Nome
		FROM Viagem AS V INNER JOIN ViagemRealizadaUtilizador AS VRU
			ON V.Id = VRU.Id_Viagem INNER JOIN Utilizador AS U
				ON VRU.Id_Utilizador = U.Id
		WHERE (V.Id = ? ) AND (VRU.Cargo = ''participante''); ';

SET @id_viagem = 1;
EXECUTE participantes_viagem USING @id_viagem;
DEALLOCATE PREPARE participantes_viagem;

-- Listar quais as organizações com os membros mais ativos (que realizam mais viagens) e melhor avaliam
SELECT
    o.Id,
    o.Nome AS Nome_Organizacao,
    COUNT(DISTINCT vru.Id_Viagem) AS Total_Viagens_Feitas,
    COUNT(DISTINCT vru.Id_Utilizador) AS Membros_Ativos,
    ROUND(AVG(vru.Avaliacao_Quantitativa), 2) AS Avaliacao_Media_Membros
FROM Organizacao o
LEFT JOIN UtilizadorPertenceOrganizacao upo ON o.Id = upo.Id_Organizacao
LEFT JOIN ViagemRealizadaUtilizador vru ON upo.Id_Utilizador = vru.Id_Utilizador
GROUP BY o.Id, o.Nome
ORDER BY Total_Viagens_Feitas DESC, Avaliacao_Media_Membros DESC;
