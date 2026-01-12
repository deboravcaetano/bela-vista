-- == ========================================================== == --
-- == ================== PROCEDURES/FUNCTIONS ================== == --
-- Operações de consulta e cálculo sobre viagens.
-- == ========================================================== == --

USE BelaVista;

-- S T O R E D  P R O C E D U R E S

-- Criação do procedimento "getTripByLoc".
-- Retorna viagens que passam por um determinado local (ponto de interesse).
-- DROP PROCEDURE IF EXISTS getTripByLoc;
DELIMITER $$
CREATE PROCEDURE getTripByLoc(IN current_user_id INT, IN p_loc VARCHAR(200))
BEGIN
	DECLARE isAdmin BOOLEAN;
    SELECT isAdmin(current_user_id) INTO isAdmin;

    IF isAdmin = 1 THEN
        SELECT DISTINCT vci.* FROM vwViagemComItinerario vci
            INNER JOIN PontoDeInteresse pi ON pi.Id_Viagem = vci.Id
			WHERE pi.Localizacao REGEXP p_loc;
    ELSE
        SELECT DISTINCT vci.* FROM vwViagemComItinerario vci
            INNER JOIN ViagemRealizadaUtilizador vu ON vci.Id = vu.Id_Viagem
            INNER JOIN PontoDeInteresse pi ON pi.Id_Viagem = vci.Id
			WHERE pi.Localizacao REGEXP p_loc AND vu.Id_Utilizador = current_user_id;
    END IF;

END $$
DELIMITER ;

-- Criação do procedimento "getUserTrips".
-- Retorna o histórico de viagens realizadas por um utilizador.
-- DROP PROCEDURE IF EXISTS getUserTrips;
DELIMITER $$
CREATE PROCEDURE getUserTrips(IN current_user_id INT, IN p_Id INT)
BEGIN
	DECLARE isAdmin BOOLEAN;
    SELECT isAdmin(current_user_id) INTO isAdmin;

    IF isAdmin = 1 THEN
		SELECT DISTINCT vci.* FROM vwViagemComItinerario vci
			INNER JOIN ViagemRealizadaUtilizador as vru ON vci.Id = vru.Id_Viagem
			WHERE Id_Utilizador = p_Id;
	ELSE
		SELECT DISTINCT vci.* FROM vwViagemComItinerario vci
			INNER JOIN ViagemRealizadaUtilizador ON vci.Id = Id_Viagem
			WHERE Id_Utilizador = p_Id AND Id_Utilizador = current_user_id;
    END IF;
END $$
DELIMITER ;

-- Criação do procedimento "getTripsByOrgId".
-- Retorna todas as viagens associadas a uma organização.
-- DROP PROCEDURE IF EXISTS getTripsByOrgId;
DELIMITER $$
CREATE PROCEDURE getTripsByOrgId(IN p_Org_Id INT)
BEGIN
	SELECT DISTINCT vci.* FROM vwViagemComItinerario vci
		INNER JOIN ViagemMencionaOrganizacao as vmo ON vci.Id = vmo.Id_Viagem
			WHERE Id_Organizacao = p_Org_Id;
END $$
DELIMITER ;

-- Criação do procedimento "getTripsByCost".
-- Retorna viagens num dado intervalo de custo.
-- DROP PROCEDURE IF EXISTS getTripsByCost;
DELIMITER $$
CREATE PROCEDURE getTripsByCost(IN p_bottom INT, IN p_top INT)
BEGIN
	SELECT DISTINCT vci.* FROM vwViagemComItinerario vci
		WHERE calculateTripCost(Id) BETWEEN p_bottom AND p_top;
END $$
DELIMITER ;

-- Criação do procedimento "getTripsByDates".
-- Retorna viagens num dado intervalo de datas.
-- DROP PROCEDURE IF EXISTS getTripsByDates;
DELIMITER $$
CREATE PROCEDURE getTripsByDates(IN p_bottom DATE, IN p_top DATE)
BEGIN
    SELECT DISTINCT vci.*
    FROM vwViagemComItinerario vci
    WHERE vci.Id IN (
        SELECT dv.Id_Viagem
        FROM DiaDeViagem dv
        GROUP BY dv.Id_Viagem
        HAVING MIN(dv.Data) >= p_bottom AND MAX(dv.Data) <= p_top
    );
END $$
DELIMITER ;


-- F U N C T I O N S

-- Criação da função "calculateTripRating".
-- Calcula a avaliação média associada a uma viagem.
-- DROP FUNCTION IF EXISTS calculateTripRating;
DELIMITER $$
CREATE FUNCTION calculateTripRating(p_Id INT)
RETURNS DECIMAL(3,2) DETERMINISTIC
READS SQL DATA
BEGIN
	RETURN (
		SELECT AVG(Avaliacao_Quantitativa)
		FROM ViagemRealizadaUtilizador
		WHERE Id_Viagem = p_Id
		);
END $$
DELIMITER ;

-- Criação da função "isAdmin".
-- Verifica se um utilizador é adiministrador.
-- DROP FUNCTION IF EXISTS isAdmin;
DELIMITER $$
CREATE FUNCTION isAdmin(user_id INT)
RETURNS BOOLEAN DETERMINISTIC
READS SQL DATA
BEGIN
	RETURN (
		SELECT Admin FROM Utilizador
			WHERE Id = user_id
        );
END $$
DELIMITER ;

-- Criação da função "calculateTripCost".
-- Calcula o custo total de uma viagem.
-- DROP FUNCTION IF EXISTS calculateTripCost;
DELIMITER $$
CREATE FUNCTION calculateTripCost(trip_id INT)
RETURNS DECIMAL(8,2) DETERMINISTIC
READS SQL DATA
BEGIN
	RETURN (
		SELECT SUM(Custo) FROM DiaDeViagem
			WHERE Id_Viagem = trip_id
        );
END $$
DELIMITER ;


-- E X E M P L O S  D E  U T I L I Z A Ç Ã O

-- CALL getTripsByOrgId(2);
-- CALL getTripByLoc(2 ,"Guim");
-- CALL getUserTrips(2,2);
-- CALL getTripsByCost(0, 85);
-- CALL getTripsByDates('2025-03-15', '2025-03-15');
-- SELECT calculateTripRating(2);
-- SELECT calculateTripCost(1);
-- SELECT isAdmin(2);
