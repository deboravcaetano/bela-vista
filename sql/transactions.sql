-- == ========================================================== == --
-- == ====================== TRANSACTIONS ===================== == --
-- Procedures com transactions para manipulação segura de dados.
-- == ========================================================== == --

USE BelaVista;

DELIMITER $$

-- O procedimento createTrip permite que qualquer utilizador crie uma viagem, ficando automaticamente como organizador
-- DROP PROCEDURE IF EXISTS createTrip$$
CREATE PROCEDURE createTrip(
    IN p_Id_Utilizador INT,
    IN p_Titulo VARCHAR(150),
    IN p_Descricao TEXT
)
BEGIN
    DECLARE v_Id_Viagem INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao criar viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    INSERT INTO Viagem (Titulo, Descricao)
      VALUES (p_Titulo, p_Descricao);
    
    SET v_Id_Viagem = LAST_INSERT_ID();
    
    INSERT INTO ViagemRealizadaUtilizador (Id_Viagem, Id_Utilizador, Cargo)
      VALUES (v_Id_Viagem, p_Id_Utilizador, 'organizador');
    
    COMMIT;
    SELECT v_Id_Viagem AS Id_Viagem, 'Viagem criada com sucesso!' AS Mensagem;
END$$


-- O prodecimento editTrip permite que um organizador ou admin edite uma viagem
-- DROP PROCEDURE IF EXISTS editTrip$$
CREATE PROCEDURE editTrip(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Titulo VARCHAR(150),
    IN p_Descricao TEXT
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao editar viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'O Utilizador não partipa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem editar viagens.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    UPDATE Viagem
      SET Titulo = p_Titulo,
          Descricao = p_Descricao
      WHERE Id = p_Id_Viagem;
    
    COMMIT;
    SELECT 'Viagem editada com sucesso!' AS Mensagem;
END$$


-- O prodecimento deleteTrip permite que um organizador ou admin elimine uma viagem
-- DROP PROCEDURE IF EXISTS deleteTrip$$
CREATE PROCEDURE deleteTrip(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao eliminar viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'O Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem eliminar viagens.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    DELETE FROM Viagem WHERE Id = p_Id_Viagem;
    
    COMMIT;
    SELECT 'Viagem eliminada com sucesso!' AS Mensagem;
END$$


-- O prodecimento createTripDay permite que um utilizador organizador ou admin crie um dia de viagem
-- DROP PROCEDURE IF EXISTS createTripDay$$
CREATE PROCEDURE createTripDay(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Data DATE,
    IN p_Custo DECIMAL(8,2),
    IN p_Alojamento VARCHAR(150),
    IN p_Transporte VARCHAR(100)
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao criar dia de viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'O Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem criar dias de viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    IF p_Custo < 0 THEN
        SET v_Erro = 'O custo não pode ser negativo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    INSERT INTO DiaDeViagem (Data, Id_Viagem, Custo, Alojamento, Transporte)
      VALUES (p_Data, p_Id_Viagem, p_Custo, p_Alojamento, p_Transporte);
    
    COMMIT;
    SELECT 'Dia de viagem criado com sucesso!' AS Mensagem;
END$$


-- O prodecimento editTripDay permite que um utilizador organizador ou admin edite um dia de viagem
-- DROP PROCEDURE IF EXISTS editTripDay$$
CREATE PROCEDURE editTripDay(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Data DATE,
    IN p_Custo DECIMAL(8,2),
    IN p_Alojamento VARCHAR(150),
    IN p_Transporte VARCHAR(100)
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao editar dia de viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'O Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem editar dias de viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    IF p_Custo < 0 THEN
        SET v_Erro = 'O custo não pode ser negativo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    UPDATE DiaDeViagem
      SET Custo = p_Custo,
          Alojamento = p_Alojamento,
          Transporte = p_Transporte
     WHERE Data = p_Data AND Id_Viagem = p_Id_Viagem;
    
    COMMIT;
    SELECT 'Dia de viagem editado com sucesso!' AS Mensagem;
END$$


-- O prodecimento deleteTripDay permite que um utilizador organizador ou admin elimine um dia de viagem
-- DROP PROCEDURE IF EXISTS deleteTripDay$$
CREATE PROCEDURE deleteTripDay(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Data DATE
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao eliminar dia de viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'O Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem eliminar dias de viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    DELETE FROM DiaDeViagem
      WHERE Data = p_Data AND Id_Viagem = p_Id_Viagem;
    
    COMMIT;
    SELECT 'Dia de viagem eliminado com sucesso!' AS Mensagem;
END$$


-- O prodecimento createInterestPoint permite que um utilizador organizador ou admin crie um ponto de interesse.
-- DROP PROCEDURE IF EXISTS createInterestPoint$$
CREATE PROCEDURE createInterestPoint(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Data DATE,
    IN p_Nome VARCHAR(150),
    IN p_Localizacao VARCHAR(200),
    IN p_Descricao TEXT,
    IN p_Horario TIME
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Dia_Existe INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao criar ponto de interesse. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo
        FROM ViagemRealizadaUtilizador
        WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem criar pontos de interesse.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    SELECT COUNT(*) INTO v_Dia_Existe
    FROM DiaDeViagem
    WHERE Data = p_Data AND Id_Viagem = p_Id_Viagem;
    
    IF v_Dia_Existe = 0 THEN
        SET v_Erro = 'Dia de viagem não existe. Crie o dia primeiro.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    INSERT INTO PontoDeInteresse (Nome, Localizacao, Descricao, Horario, Data, Id_Viagem)
    VALUES (p_Nome, p_Localizacao, p_Descricao, p_Horario, p_Data, p_Id_Viagem);
    
    COMMIT;
    SELECT LAST_INSERT_ID() AS Id_PontoInteresse, 'Ponto de interesse criado com sucesso!' AS Mensagem;
END$$


-- O prodecimento editInterestPoint permite que um utilizador organizador ou admin edite um ponto de interesse.
-- DROP PROCEDURE IF EXISTS editInterestPoint$$
CREATE PROCEDURE editInterestPoint(
    IN p_Id_Utilizador INT,
    IN p_Id INT,
    IN p_Nome VARCHAR(150),
    IN p_Localizacao VARCHAR(200),
    IN p_Descricao TEXT,
    IN p_Horario TIME
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Id_Viagem INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao editar ponto de interesse. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT Id_Viagem INTO v_Id_Viagem FROM PontoDeInteresse
     WHERE Id = p_Id;
    
    IF v_Id_Viagem IS NULL THEN
        SET v_Erro = 'Ponto de interesse não encontrado.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = v_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'O Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem editar pontos de interesse.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    UPDATE PontoDeInteresse
      SET Nome = p_Nome,
          Localizacao = p_Localizacao,
          Descricao = p_Descricao,
          Horario = p_Horario
      WHERE Id = p_Id;
    
    COMMIT;
    SELECT 'Ponto de interesse editado com sucesso!' AS Mensagem;
END$$


-- O prodecimento deleteInterestPoint permite que um utilizador organizador ou admin elimine um ponto de interesse.
-- DROP PROCEDURE IF EXISTS deleteInterestPoint$$
CREATE PROCEDURE deleteInterestPoint(
    IN p_Id_Utilizador INT,
    IN p_Id INT
)
BEGIN
    DECLARE v_Cargo VARCHAR(20);
    DECLARE v_IsAdmin BOOLEAN;
    DECLARE v_Id_Viagem INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao eliminar ponto de interesse. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT Id_Viagem INTO v_Id_Viagem FROM PontoDeInteresse
      WHERE Id = p_Id;
    
    IF v_Id_Viagem IS NULL THEN
        SET v_Erro = 'Ponto de interesse não encontrado.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    SELECT isAdmin(p_Id_Utilizador) INTO v_IsAdmin;
    
    IF v_IsAdmin = 0 THEN
        SELECT Cargo INTO v_Cargo FROM ViagemRealizadaUtilizador
          WHERE Id_Viagem = v_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
        
        IF v_Cargo IS NULL THEN
            SET v_Erro = 'Utilizador não participa nesta viagem.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
        
        IF v_Cargo != 'organizador' THEN
            SET v_Erro = 'Apenas organizadores podem eliminar pontos de interesse.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
        END IF;
    END IF;
    
    DELETE FROM PontoDeInteresse WHERE Id = p_Id;
    
    COMMIT;
    SELECT 'Ponto de interesse eliminado com sucesso!' AS Mensagem;
END$$


-- O prodecimento reviewTrip permite que um utilizador avalie uma viagem em que tenha participado.
-- DROP PROCEDURE IF EXISTS reviewTrip $$
CREATE PROCEDURE reviewTrip(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Avaliacao_Descritiva TEXT,
    IN p_Avaliacao_Quantitativa INT
)
BEGIN
    DECLARE v_Participa INT;
    DECLARE v_Avaliacao_Existe INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao avaliar viagem. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_Participa FROM ViagemRealizadaUtilizador
      WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
    
    IF v_Participa = 0 THEN
        SET v_Erro = 'Apenas participantes da viagem podem avaliá-la.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    IF p_Avaliacao_Quantitativa < 0 OR p_Avaliacao_Quantitativa > 5 THEN
        SET v_Erro = 'A avaliação quantitativa deve estar entre 0 e 5.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    SELECT COUNT(*) INTO v_Avaliacao_Existe FROM ViagemRealizadaUtilizador
      WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador
        AND (Avaliacao_Descritiva IS NOT NULL OR Avaliacao_Quantitativa IS NOT NULL);
    
    IF v_Avaliacao_Existe > 0 THEN
        SET v_Erro = 'Já existe uma avaliação para esta viagem.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    UPDATE ViagemRealizadaUtilizador
      SET Avaliacao_Descritiva = p_Avaliacao_Descritiva,
          Avaliacao_Quantitativa = p_Avaliacao_Quantitativa
      WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
    
    COMMIT;
    SELECT 'Avaliação criada com sucesso!' AS Mensagem;
END$$


-- O prodecimento editTripReview permite que um utilizador edite uma avaliação sua numa dada viagem em que tenha participado.
-- DROP PROCEDURE IF EXISTS editTripReview $$
CREATE PROCEDURE editTripReview(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT,
    IN p_Avaliacao_Descritiva TEXT,
    IN p_Avaliacao_Quantitativa INT
)
BEGIN
    DECLARE v_Participa INT;
    DECLARE v_Avaliacao_Existe INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao editar avaliação. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_Participa FROM ViagemRealizadaUtilizador
      WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
    
    IF v_Participa = 0 THEN
        SET v_Erro = 'A avaliação não existe ou não pertence ao utilizador.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    SELECT COUNT(*) INTO v_Avaliacao_Existe FROM ViagemRealizadaUtilizador
      WHERE Id_Viagem = p_Id_Viagem 
        AND Id_Utilizador = p_Id_Utilizador
        AND (Avaliacao_Descritiva IS NOT NULL OR Avaliacao_Quantitativa IS NOT NULL);
    
    IF v_Avaliacao_Existe = 0 THEN
        SET v_Erro = 'A avaliação não existe';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    IF p_Avaliacao_Quantitativa < 0 OR p_Avaliacao_Quantitativa > 5 THEN
        SET v_Erro = 'A avaliação quantitativa deve estar entre 0 e 5.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    UPDATE ViagemRealizadaUtilizador
      SET Avaliacao_Descritiva = p_Avaliacao_Descritiva,
          Avaliacao_Quantitativa = p_Avaliacao_Quantitativa
      WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
    
    COMMIT;
    SELECT 'Avaliação editada com sucesso!' AS Mensagem;
END$$


-- O prodecimento deleteTripReview permite que um utilizador elimine uma avaliação sua, numa dada viagem em que tenha participado.
-- DROP PROCEDURE IF EXISTS deleteTripReview $$
CREATE PROCEDURE deleteTripReview(
    IN p_Id_Utilizador INT,
    IN p_Id_Viagem INT
)
BEGIN
    DECLARE v_Participa INT;
    DECLARE v_Avaliacao_Existe INT;
    DECLARE v_Erro VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_Erro = 'Erro ao eliminar avaliação. Transação revertida.';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_Participa FROM ViagemRealizadaUtilizador
     WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
    
    IF v_Participa = 0 THEN
        SET v_Erro = 'A avaliação não existe ou não pertence ao utilizador.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    SELECT COUNT(*) INTO v_Avaliacao_Existe FROM ViagemRealizadaUtilizador
      WHERE Id_Viagem = p_Id_Viagem 
        AND Id_Utilizador = p_Id_Utilizador
        AND (Avaliacao_Descritiva IS NOT NULL OR Avaliacao_Quantitativa IS NOT NULL);
    
    IF v_Avaliacao_Existe = 0 THEN
        SET v_Erro = 'A avaliação não existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_Erro;
    END IF;
    
    UPDATE ViagemRealizadaUtilizador
      SET Avaliacao_Descritiva = NULL,
          Avaliacao_Quantitativa = NULL
      WHERE Id_Viagem = p_Id_Viagem AND Id_Utilizador = p_Id_Utilizador;
    
    COMMIT;
    SELECT 'Avaliação eliminada com sucesso!' AS Mensagem;
END$$

DELIMITER ;

-- EXEMPLOS:

-- CALL createTrip(3, 'Viagem a Paris', 'Uma viagem incrível pela cidade do amor');

-- CALL editTrip(2, 1, 'Novo Título', 'Nova Descrição');

-- CALL deleteTrip(2, 1);

-- CALL createTripDay(2, 1, '2024-06-15', 150.50, 'Hotel XYZ', 'Autocarro');

-- CALL editTripDay(2, 1, '2024-06-15', 180.00, 'Hotel ABC', 'Comboio');

-- CALL deleteTripDay(2, 1, '2024-06-15');

-- CALL createInterestPoint(2, 1, '2024-06-15', 'Torre Eiffel', 'Paris, França', 'Monumento histórico', '14:30:00');

-- CALL editInterestPoint(2, 1, 'Torre Eiffel', 'Paris, França', 'Descrição atualizada', '15:00:00');

-- CALL deleteInterestPoint(2, 1);

-- CALL reviewTrip(3, 1, 'Viagem excelente!', 5);

-- CALL editTripReview(3, 1, 'Viagem muito boa.', 4);

-- CALL deleteTripReview(3, 1);
