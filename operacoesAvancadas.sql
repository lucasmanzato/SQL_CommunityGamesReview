-- OPERACOES_AVANCADAS.SQL

USE game_reviews_community;

-- -------------------------------------------------------------------------------------------------------- CRUD -----------------------------------------------------------
-- 1. Deletar Usuário e seus Dados Relacionados (CASCADE remove reviews e comentários)
DELETE FROM Usuarios WHERE id_usuario = 1;

-- Verifica se foi removido
SELECT * FROM Usuarios WHERE id_usuario = 1;

-- 2. Deletar Jogo e suas Relações (CASCADE remove reviews, comentários e plataformas)
DELETE FROM Jogos WHERE id_jogo = 3;

-- Verifica
SELECT * FROM Jogos WHERE id_jogo = 3;

-- 3. Deletar Review Específica (CASCADE remove comentários)
DELETE FROM Reviews WHERE id_review = 5;

-- Verifica
SELECT * FROM Reviews WHERE id_review = 5;

-- 4. Deletar Comentário (assumindo que o trigger de log já existe)
DELETE FROM Comentarios WHERE id_comentario = 8;

-- Verifica o log (se o trigger estiver configurado)
SELECT * FROM log_comentarios_excluidos WHERE id_comentario = 8;

-- -------------------------------------------------------------------------------------------------------------- Procedure  --------------------------------------------------------------------
-- 1. PROCEDURE para cadastrar novo usuário
DELIMITER //
CREATE PROCEDURE cadastrar_usuario(
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_senha VARCHAR(255),
    IN p_id_plataforma INT
)
BEGIN
    INSERT INTO Usuarios (nome, email, senha, id_plataforma_preferida)
    VALUES (p_nome, p_email, p_senha, p_id_plataforma);
    SELECT 'Usuário cadastrado com sucesso!' AS Resultado;
END //
DELIMITER ;

-- 2. PROCEDURE para adicionar jogo
DELIMITER //
CREATE PROCEDURE adicionar_jogo(
    IN p_titulo VARCHAR(100),
    IN p_descricao TEXT,
    IN p_data_lancamento DATE,
    IN p_desenvolvedora VARCHAR(100)
)
BEGIN
    INSERT INTO Jogos (titulo, descricao, data_lancamento, desenvolvedora)
    VALUES (p_titulo, p_descricao, p_data_lancamento, p_desenvolvedora);
    SELECT CONCAT('Jogo "', p_titulo, '" cadastrado com sucesso!') AS Resultado;
END //
DELIMITER ;

-- 3. PROCEDURE para registrar review
DELIMITER //
CREATE PROCEDURE registrar_review(
    IN p_id_usuario INT,
    IN p_id_jogo INT,
    IN p_nota INT,
    IN p_comentario TEXT)
BEGIN
    IF p_nota BETWEEN 0 AND 10 THEN
        INSERT INTO Reviews (id_usuario, id_jogo, nota, comentario)
        VALUES (p_id_usuario, p_id_jogo, p_nota, p_comentario);
        SELECT 'Review registrada com sucesso!' AS Resultado;
    ELSE
        SELECT 'Erro: A nota deve estar entre 0 e 10' AS Resultado;
    END IF;
END //
DELIMITER ;

-- 4. PROCEDURE para listar reviews
DELIMITER //
CREATE PROCEDURE listar_reviews_jogo(
    IN p_id_jogo INT)
BEGIN
    SELECT 
        u.nome AS Usuario,
        r.nota AS Nota,
        r.comentario AS Comentario,
        DATE_FORMAT(r.data_review, '%d/%m/%Y') AS Data
    FROM Reviews r
    JOIN Usuarios u ON r.id_usuario = u.id_usuario
    WHERE r.id_jogo = p_id_jogo
    ORDER BY r.data_review DESC;
END //
DELIMITER ;

-- ------------------------------------------------------------------- Functions -------------------------------------------------------------------------------------------
-- 1. Function para Calcular a Média de Notas de um Jogo
DELIMITER //
CREATE FUNCTION calcular_media_jogo(p_id_jogo INT) 
RETURNS DECIMAL(3,1)
DETERMINISTIC
BEGIN
    DECLARE v_media DECIMAL(3,1);
    
    SELECT AVG(nota) INTO v_media
    FROM Reviews
    WHERE id_jogo = p_id_jogo;
    
    RETURN IFNULL(v_media, 0.0);
END //
DELIMITER ;

-- 2. Function para Verificar se um Jogo Existe em uma Plataforma
DELIMITER //
CREATE FUNCTION jogo_na_plataforma(p_id_jogo INT, p_id_plataforma INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_resultado BOOLEAN DEFAULT FALSE;
    
    SELECT EXISTS (
        SELECT 1 FROM Jogos_Plataformas 
        WHERE id_jogo = p_id_jogo 
        AND id_plataforma = p_id_plataforma
    ) INTO v_resultado;
    
    RETURN v_resultado;
END //
DELIMITER ;

-- --------------------------------------------------------------------------Triggers---------------------------------------------------------------------------
-- 1. Trigger para Atualizar Média de Notas ao Adicionar Review
DELIMITER //
CREATE TRIGGER after_review_insert
AFTER INSERT ON Reviews
FOR EACH ROW
BEGIN
    UPDATE Jogos 
    SET media_notas = (
        SELECT AVG(nota) FROM Reviews 
        WHERE id_jogo = NEW.id_jogo
    )
    WHERE id_jogo = NEW.id_jogo;
END //
DELIMITER ;

-- 2. Trigger para Validar Plataforma do Jogo ao Registrar Review
DELIMITER //
CREATE TRIGGER before_review_insert
BEFORE INSERT ON Reviews
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Jogos_Plataformas jp
        JOIN Usuarios u ON jp.id_plataforma = u.id_plataforma_preferida
        WHERE jp.id_jogo = NEW.id_jogo
        AND u.id_usuario = NEW.id_usuario
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Game not available on user preferred platform';
    END IF;
END //
DELIMITER ;

-- 3. Trigger para Limitar Reviews por Usuário por Jogo
DELIMITER //
CREATE TRIGGER prevent_duplicate_review
BEFORE INSERT ON Reviews
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reviews 
        WHERE id_usuario = NEW.id_usuario 
        AND id_jogo = NEW.id_jogo
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already reviewed this game';
    END IF;
END //
DELIMITER ;

-- 4. Trigger para Registrar Log ao Excluir Comentário
DELIMITER //
CREATE TRIGGER before_comentario_delete
BEFORE DELETE ON Comentarios
FOR EACH ROW
BEGIN
    INSERT INTO log_comentarios_excluidos 
    (id_comentario, id_usuario, id_review)
    VALUES (OLD.id_comentario, OLD.id_usuario, OLD.id_review);
END //
DELIMITER ;

-- 5. Trigger para Atualizar Contagem de Reviews ao Deletar
DELIMITER //
CREATE TRIGGER after_review_delete
AFTER DELETE ON Reviews
FOR EACH ROW
BEGIN
    UPDATE Jogos 
    SET media_notas = (
        SELECT AVG(nota) FROM Reviews 
        WHERE id_jogo = OLD.id_jogo
    )
    WHERE id_jogo = OLD.id_jogo;
END //
DELIMITER ;

-- --------------------------------------------------------------------------------------------------View--------------------------------------------------
-- 1. View: vw_jogos_melhores_avaliados
CREATE VIEW vw_jogos_melhores_avaliados AS
SELECT 
    j.id_jogo,
    j.titulo,
    ROUND(j.media_notas, 1) AS media_notas,
    GROUP_CONCAT(DISTINCT p.nome ORDER BY p.nome SEPARATOR ', ') AS plataformas,
    COUNT(r.id_review) AS total_reviews
FROM Jogos j
JOIN Jogos_Plataformas jp ON j.id_jogo = jp.id_jogo
JOIN Plataformas p ON jp.id_plataforma = p.id_plataforma
LEFT JOIN Reviews r ON j.id_jogo = r.id_jogo
GROUP BY j.id_jogo
HAVING total_reviews > 0
ORDER BY media_notas DESC, total_reviews DESC
LIMIT 10;

-- 2. View: vw_reviews_completas
CREATE VIEW vw_reviews_completas AS
SELECT 
    r.id_review,
    j.titulo AS jogo,
    u.nome AS usuario,
    r.nota,
    SUBSTRING(r.comentario, 1, 100) AS comentario_resumido,
    DATE_FORMAT(r.data_review, '%d/%m/%Y') AS data,
    IF(r.recomendacao = 1, '👍', '👎') AS recomendacao,
    p.nome AS plataforma_usuario
FROM Reviews r
JOIN Jogos j ON r.id_jogo = j.id_jogo
JOIN Usuarios u ON r.id_usuario = u.id_usuario
JOIN Plataformas p ON u.id_plataforma_preferida = p.id_plataforma
ORDER BY r.data_review DESC;

-- 3. View: vw_usuarios_ativos
CREATE VIEW vw_usuarios_ativos AS
SELECT 
    u.id_usuario,
    u.nome,
    p.nome AS plataforma_preferida,
    COUNT(r.id_review) AS total_reviews,
    ROUND(AVG(r.nota), 1) AS media_notas_dadas,
    DATE_FORMAT(MAX(r.data_review), '%d/%m/%Y') AS ultima_atividade,
    DATEDIFF(NOW(), MAX(r.data_review)) AS dias_desde_ultima_review
FROM Usuarios u
JOIN Plataformas p ON u.id_plataforma_preferida = p.id_plataforma
JOIN Reviews r ON u.id_usuario = r.id_usuario
GROUP BY u.id_usuario
HAVING total_reviews > 0
ORDER BY total_reviews DESC;


-- ------------------------------------------------------------------------------------
-- TESTES DAS PROCEDURES
-- ------------------------------------------------------------------------------------

-- 1. Teste da PROCEDURE cadastrar_usuario
CALL cadastrar_usuario('Novo Usuário', 'novo@email.com', 'senha123', 1);
SELECT * FROM Usuarios WHERE email = 'novo@email.com';

-- 2. Teste da PROCEDURE adicionar_jogo
CALL adicionar_jogo('Novo Jogo', 'Descrição do novo jogo', '2023-01-01', 'Nova Dev');
SELECT * FROM Jogos WHERE titulo = 'Novo Jogo';

-- 3. Teste da PROCEDURE registrar_review
-- Teste com nota válida
CALL registrar_review(2, 1, 5, 'Jogo excelente!');
-- Teste com nota inválida (deve falhar)
CALL registrar_review(2, 1, 11, 'Nota inválida');

-- 4. Teste da PROCEDURE listar_reviews_jogo
CALL listar_reviews_jogo(1);

-- ------------------------------------------------------------------------------------
-- TESTES DAS FUNCTIONS
-- ------------------------------------------------------------------------------------

-- 1. Teste da FUNCTION calcular_media_jogo
SELECT 
    titulo,
    media_notas AS media_atual,
    calcular_media_jogo(id_jogo) AS media_calculada
FROM Jogos 
WHERE id_jogo = 1;

-- 2. Teste da FUNCTION jogo_na_plataforma
SELECT 
    j.titulo,
    p.nome AS plataforma,
    jogo_na_plataforma(j.id_jogo, p.id_plataforma) AS disponivel
FROM Jogos j
CROSS JOIN Plataformas p
WHERE j.id_jogo = 1;

-- ------------------------------------------------------------------------------------
-- TESTES DOS TRIGGERS
-- ------------------------------------------------------------------------------------

-- 1. Teste do TRIGGER after_review_insert (atualiza média automaticamente)
-- Ver média antes
SELECT media_notas FROM Jogos WHERE id_jogo = 1;
-- Insere nova review
INSERT INTO Reviews (id_usuario, id_jogo, nota, comentario) VALUES (3, 1, 8, 'Teste trigger insert');
-- Ver média depois
SELECT media_notas FROM Jogos WHERE id_jogo = 1;

-- 2. Teste do TRIGGER before_review_insert (valida plataforma)
-- Deve falhar pois o usuário 3 tem plataforma preferida 3 (Switch) e o jogo 1 não está disponível nela
INSERT INTO Reviews (id_usuario, id_jogo, nota, comentario) VALUES (3, 1, 8, 'Teste plataforma inválida');

-- 3. Teste do TRIGGER prevent_duplicate_review
-- Deve falhar pois o usuário 2 já avaliou o jogo 1
INSERT INTO Reviews (id_usuario, id_jogo, nota, comentario) VALUES (2, 1, 7, 'Segunda review');

-- 4. Teste do TRIGGER before_comentario_delete
-- Ver log antes
SELECT * FROM log_comentarios_excluidos;
-- Deleta um comentário
DELETE FROM Comentarios WHERE id_comentario = 1;
-- Ver log depois
SELECT * FROM log_comentarios_excluidos;

-- 5. Teste do TRIGGER after_review_delete
-- Ver média antes
SELECT media_notas FROM Jogos WHERE id_jogo = 1;
-- Deleta uma review
DELETE FROM Reviews WHERE id_review = LAST_INSERT_ID();
-- Ver média depois
SELECT media_notas FROM Jogos WHERE id_jogo = 1;

-- ------------------------------------------------------------------------------------
-- TESTES DAS VIEWS
-- ------------------------------------------------------------------------------------

-- 1. Teste da VIEW vw_jogos_melhores_avaliados
SELECT * FROM vw_jogos_melhores_avaliados;

-- 2. Teste da VIEW vw_reviews_completas
-- Todas as reviews
SELECT * FROM vw_reviews_completas;
-- Filtrado por jogo
SELECT * FROM vw_reviews_completas WHERE jogo = 'Elden Ring';

-- 3. Teste da VIEW vw_usuarios_ativos
-- Todos os usuários ativos
SELECT * FROM vw_usuarios_ativos;
-- Top 5 usuários mais ativos
SELECT * FROM vw_usuarios_ativos ORDER BY total_reviews DESC LIMIT 5;
-- Usuários inativos (última review há mais de 30 dias)
SELECT * FROM vw_usuarios_ativos WHERE dias_desde_ultima_review > 30;