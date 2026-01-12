-- == ========================================================== == --
-- == ========================== VIEWS ========================= == --
-- Vistas de utilização do sistema de bases de dados.
-- == ========================================================== == --

USE BelaVista;

-- Custo das Viagens (ordem decrescente)
CREATE OR REPLACE VIEW vwCustoViagens AS
    SELECT
        v.Id,
        v.Titulo,
        SUM(dv.Custo) AS Custo_Total
    FROM
        Viagem AS v
        JOIN DiaDeViagem AS dv ON v.Id = dv.Id_Viagem
    GROUP BY
        v.Id, v.Titulo
    ORDER BY
        Custo_Total DESC;

--
-- DROP VIEW vwCustoViagens;
--


-- Pontos de Interesse das Viagems
CREATE OR REPLACE VIEW vwPontosInteresseViagem AS
    SELECT
        v.Id AS Id_Viagem,
        v.Titulo,
        pi.Id AS Id_PontoInteresse,
        pi.Nome,
        dv.Data
    FROM
        Viagem AS v
    JOIN
        DiaDeViagem AS dv
            ON dv.Id_Viagem = v.Id
    JOIN
        PontoDeInteresse AS pi
            ON pi.Id_Viagem = dv.Id_Viagem
        AND pi.Data = dv.Data;

--
-- DROP VIEW vwPontosInteresseViagem;
--


-- Pontos de Interesse e a sua quantidade de Fotografias
CREATE OR REPLACE VIEW vwPontosdeInteresseFotografias AS
    SELECT
        pi.Id,
        pi.Nome,
        pi.Localizacao,
        COUNT(f.Id_Fotografia) AS Total_Fotografias
    FROM
        PontodeInteresse pi
            LEFT JOIN
        Fotografias AS f ON f.Id_PontoInteresse = pi.Id
    GROUP BY pi.Id , pi.Nome , pi.Localizacao;


--
-- DROP VIEW vwPontosdeInteresseFotografias;
--


-- Custos e Logística por dia de viagem
CREATE OR REPLACE VIEW vwLogisticaDiaDeViagem AS
    SELECT
        d.Data,
        d.Id_Viagem,
        d.Custo,
        d.Alojamento,
        d.Transporte,
        v.Titulo AS Viagem
    FROM
        DiaDeViagem AS d
    JOIN
        Viagem AS v ON v.Id = d.Id_Viagem;

--
-- DROP VIEW vwLogisticaDiaDeViagem;
--


-- Utilizadores e as suas viagens
CREATE OR REPLACE VIEW vwUtilizadoresViagens AS
    SELECT
        u.Nome,
        u.Email,
        vru.Cargo,
        v.Titulo AS Viagem,
        vru.Avaliacao_Quantitativa,
        vru.Avaliacao_Descritiva
    FROM
        Utilizador AS u
            JOIN
        ViagemRealizadaUtilizador AS vru ON vru.Id_Utilizador = u.Id
            JOIN
        Viagem v ON v.Id = vru.Id_Viagem;

--
-- DROP VIEW vwUtilizadoresViagens;
--


-- Organizadores e as suas viagens
CREATE OR REPLACE VIEW vwOrganizadoresViagem AS
    SELECT
        u.Nome AS Organizador, u.Email, v.Titulo AS Viagem
    FROM
        Viagem v
            JOIN
        ViagemRealizadaUtilizador vru ON vru.Id_Viagem = v.Id
            AND vru.Cargo = 'organizador'
            JOIN
        Utilizador u ON u.Id = vru.Id_Utilizador;

--
-- DROP VIEW vwOrganizadoresViagem;
--


-- Organizações associadas às Viagens
CREATE OR REPLACE VIEW vwViagensOrganizacoes AS
    SELECT
        o.Nome AS Organizacao, v.Titulo AS Viagem
    FROM
        Viagem AS v
            JOIN
        ViagemMencionaOrganizacao vmo ON vmo.Id_Viagem = v.Id
            JOIN
        Organizacao AS o ON o.Id = vmo.Id_Organizacao;

--
-- DROP VIEW vwViagensOrganizacoes;
--


-- Utilizadores e suas Organizações
CREATE OR REPLACE VIEW vwUtilizadoresOrganizacoes AS
    SELECT
        u.Nome AS Utilizador, u.Email, o.Nome AS Organizacao
    FROM
        Organizacao AS o
            JOIN
        UtilizadorPertenceOrganizacao AS upo ON upo.Id_Organizacao = o.Id
            JOIN
        Utilizador AS u ON u.Id = upo.Id_Utilizador
	ORDER BY u.Nome ASC;

--
-- DROP VIEW vwUtilizadoresOrganizacoes;
--


-- Viagens e as suas Avaliações
CREATE OR REPLACE VIEW vwAvaliacoesViagem AS
    SELECT
        v.Titulo,
        vru.Avaliacao_Quantitativa,
        vru.Avaliacao_Descritiva,
        u.Nome AS Utilizador
    FROM
        ViagemRealizadaUtilizador AS vru
            JOIN
        Viagem AS v ON v.Id = vru.Id_Viagem
            JOIN
        Utilizador AS u ON u.Id = vru.Id_Utilizador
	ORDER BY v.Titulo;

--
-- DROP VIEW vwAvaliacoesViagem;
--


-- Participantes por Viagem
CREATE OR REPLACE VIEW vwParticipantesViagem AS
    SELECT
        v.Titulo AS Viagem, COUNT(*) AS Total_Participantes
    FROM
        Viagem AS v
            JOIN
        ViagemRealizadaUtilizador AS vru ON vru.Id_Viagem = v.Id
    WHERE
        vru.Cargo = 'participante'
    GROUP BY v.Titulo;

--
-- DROP VIEW vwParticipantesViagem;
--


CREATE OR REPLACE VIEW vwViagemComItinerario AS
    SELECT
        v.Id,
        v.Titulo,
        v.Descricao,
        GROUP_CONCAT(DISTINCT CONCAT(DATE_FORMAT(dv.Data, '%d/%m/%Y'),
                    ' (',
                    dv.Custo,
                    ' EUR)',
                    IF(dv.Alojamento IS NOT NULL,
                        CONCAT(' - ', dv.Alojamento),
                        ''),
                    IF(dv.Transporte IS NOT NULL,
                        CONCAT(' - ', dv.Transporte),
                        ''),
                    '
                    ',
                    '   Pontos: ',
                    (SELECT
                            GROUP_CONCAT(CONCAT(TIME_FORMAT(pi2.Horario, '%H:%i'),
                                            ' - ',
                                            pi2.Nome,
                                            ' (',
                                            pi2.Localizacao,
                                            ')')
                                    ORDER BY pi2.Horario
                                    SEPARATOR '
                                               ')
                        FROM
                            PontoDeInteresse pi2
                        WHERE
                            pi2.Data = dv.Data
                                AND pi2.Id_Viagem = v.Id))
            ORDER BY dv.Data
            SEPARATOR '

            ') AS itinerario_completo
    FROM
        Viagem AS v
            INNER JOIN
        DiaDeViagem AS dv ON v.Id = dv.Id_Viagem
            LEFT JOIN
        PontoDeInteresse AS pi ON dv.Data = pi.Data
            AND pi.Id_Viagem = v.Id
    GROUP BY v.Id , v.Titulo , v.Descricao;

--
-- DROP VIEW vwViagemComItinerario;
--
