USE BelaVista;

DELIMITER $$

CREATE PROCEDURE gerar_resumo_viagem(IN p_id_viagem INT)
BEGIN
    DECLARE v_titulo VARCHAR(150);
    DECLARE v_custo_total DECIMAL(10,2);
    DECLARE v_data_dia DATE;
    DECLARE v_custo_dia DECIMAL(8,2);
    DECLARE done INTEGER DEFAULT 0;
    DECLARE v_resumo TEXT DEFAULT '';
    DECLARE v_linha TEXT;
    
    -- Cursor para percorrer os dias da viagem
    DECLARE cursor_dias CURSOR FOR
        SELECT Data, Custo
			FROM DiadeViagem
        WHERE Id_Viagem = p_id_viagem
        ORDER BY Data;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Obter título da viagem
    SELECT Titulo INTO v_titulo
		FROM Viagem
    WHERE Id = p_id_viagem;
    
    -- Verificar se a viagem existe
    IF v_titulo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Viagem não encontrada';
    END IF;
    
    -- Calcular custo total
    SELECT COALESCE(SUM(Custo), 0) INTO v_custo_total
    FROM DiadeViagem
    WHERE Id_Viagem = p_id_viagem;
    
    -- Construir cabeçalho da fatura
    SET v_resumo = CONCAT(
        '========================================\n',
        '          Resumo de uma viagem\n',
        '========================================\n',
        'Viagem: ', v_titulo, '\n',
        '========================================\n\n',
        'DETALHES DOS DIAS:\n',
        '----------------------------------------\n'
    );
    
    OPEN cursor_dias;
    
    loop_dias: LOOP
        FETCH cursor_dias INTO v_data_dia, v_custo_dia;
        
        IF done = 1 THEN
            LEAVE loop_dias;
        END IF;
        
        SET v_linha = CONCAT(
            DATE_FORMAT(v_data_dia, '%d/%m/%Y'), REPEAT(' ', 5), v_custo_dia, ' €\n'
        );
        
        SET v_resumo = CONCAT(v_resumo, v_linha);
    END LOOP;
    
    CLOSE cursor_dias;
    
    -- Adicionar rodapé com total
    SET v_resumo = CONCAT(
        v_resumo,
        '----------------------------------------\n',
        'TOTAL:', REPEAT(' ', 21),
		v_custo_total, ' €\n',
        '========================================\n'
    );

    SET @caminho = CONCAT('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/resumo_viagem_', p_id_viagem, '.txt');
    SET @sql = CONCAT('SELECT ? INTO OUTFILE ''', @caminho, '''');
    PREPARE stmt FROM @sql;
    SET @conteudo = v_resumo;
    EXECUTE stmt USING @conteudo;
    DEALLOCATE PREPARE stmt;
    
    
END$$

DELIMITER ;

CALL gerar_resumo_viagem(2);

-- DROP PROCEDURE gerar_resumo_viagem;
-- SHOW VARIABLES LIKE 'secure_file_priv';


