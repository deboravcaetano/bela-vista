-- == ========================================================== == --
-- == ========================= USERS ========================== == --
-- Criação de utilizadores da Base de Dados Bela Vista.
-- == ========================================================== == --

USE BelaVista;

CREATE ROLE IF NOT EXISTS role_administrador;

GRANT INSERT, DELETE, SELECT, UPDATE ON BelaVista.* TO role_administrador;

GRANT SELECT ON BelaVista.vwCustoViagens TO role_administrador;
GRANT SELECT ON BelaVista.vwPontosInteresseViagem TO role_administrador;
GRANT SELECT ON BelaVista.vwPontosdeInteresseFotografias TO role_administrador;
GRANT SELECT ON BelaVista.vwLogisticaDiaDeViagem TO role_administrador;
GRANT SELECT ON BelaVista.vwUtilizadoresViagens TO role_administrador;
GRANT SELECT ON BelaVista.vwOrganizadoresViagem TO role_administrador;
GRANT SELECT ON BelaVista.vwViagensOrganizacoes TO role_administrador;
GRANT SELECT ON BelaVista.vwUtilizadoresOrganizacoes TO role_administrador;
GRANT SELECT ON BelaVista.vwAvaliacoesViagem TO role_administrador;
GRANT SELECT ON BelaVista.vwParticipantesViagem TO role_administrador;
GRANT SELECT ON BelaVista.vwViagemComItinerario TO role_administrador;

CREATE USER IF NOT EXISTS 'milena_salome'@'localhost'
IDENTIFIED BY 'msalome123';

CREATE USER IF NOT EXISTS 'julio_cesar'@'localhost'
IDENTIFIED BY 'julioc1234';


GRANT role_administrador TO 'milena_salome'@'localhost';
GRANT role_administrador TO 'julio_cesar'@'localhost';

SET DEFAULT ROLE role_administrador TO
    'milena_salome'@'localhost',
    'julio_cesar'@'localhost';

FLUSH PRIVILEGES;

--
-- REVOKE role_administrador FROM 'milena_salome'@'localhost';
-- REVOKE role_administrador FROM 'julio_cesar'@'localhost';
-- DROP USER IF EXISTS 'milena_salome'@'localhost';
-- DROP USER IF EXISTS 'julio_cesar'@'localhost';
-- DROP ROLE IF EXISTS role_administrador;
--



-- Criação de um utilizador
CREATE USER IF NOT EXISTS 'utilizador'@'localhost'
	IDENTIFIED BY 'password_utilizador';

CREATE VIEW vw_geral_org AS
	SELECT O.Id AS Id_Organizacao, O.Nome AS Nome_Organização, U.Nome AS Nome_Pessoa
		FROM Organizacao AS O INNER JOIN UtilizadorPertenceOrganizacao AS UPO
			ON O.Id = UPO.Id_Organizacao
				INNER JOIN Utilizador AS U
					ON UPO.Id_Utilizador = U.Id;


GRANT SELECT ON BelaVista.vw_geral_org TO 'utilizador'@'localhost';
GRANT SELECT ON BelaVista.vw_geral_org TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.Utilizador TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.Viagem TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.PontoDeInteresse TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.Fotografias TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.DiaDeViagem TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.UtilizadorPertenceOrganizacao TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.ViagemRealizadaUtilizador TO 'utilizador'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON BelaVista.ViagemMencionaOrganizacao TO 'utilizador'@'localhost';

FLUSH PRIVILEGES;

--
-- REVOKE SELECT ON BelaVista.vw_geral_org FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.Utilizador FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.Viagem FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.PontoDeInteresse FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.Fotografias FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.DiaDeViagem FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.UtilizadorPertenceOrganizacao FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.ViagemRealizadaUtilizador FROM 'utilizador'@'localhost';
-- REVOKE SELECT, INSERT, DELETE, UPDATE ON BelaVista.ViagemMencionaOrganizacao FROM 'utilizador'@'localhost';
-- DROP USER IF EXISTS 'utilizador'@'localhost';
-- DROP VIEW IF EXISTS vw_geral_org;
-- FLUSH PRIVILEGES;
--


