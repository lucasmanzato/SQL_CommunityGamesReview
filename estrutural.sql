-- ESTRUTURA_E_DADOS.SQL

DROP TABLE IF EXISTS Comentarios;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Usuarios_Grupos;
DROP TABLE IF EXISTS Grupos;
DROP TABLE IF EXISTS Jogos_Plataformas;
DROP TABLE IF EXISTS Jogos;
DROP TABLE IF EXISTS Usuarios;
DROP TABLE IF EXISTS Plataformas;
 
-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS game_reviews_community;
USE game_reviews_community;

-- parte para cirar as tabelas --
-- 1. Tabela Plataformas
CREATE TABLE Plataformas (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Tabela Usuarios
CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_plataforma_preferida INT,
    FOREIGN KEY (id_plataforma_preferida) REFERENCES Plataformas(id_plataforma)
);

-- 3. Tabela Jogos
CREATE TABLE Jogos (
    id_jogo INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_lancamento DATE,
    desenvolvedora VARCHAR(100),
    media_notas DECIMAL(3,1) DEFAULT 0.0
);

-- 4. Tabela Jogos_Plataformas
CREATE TABLE Jogos_Plataformas (
    id_jogo INT,
    id_plataforma INT,
    PRIMARY KEY (id_jogo, id_plataforma),
    FOREIGN KEY (id_jogo) REFERENCES Jogos(id_jogo) ON DELETE CASCADE,
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma) ON DELETE CASCADE
);

-- 5. Tabela Reviews
CREATE TABLE Reviews (
    id_review INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_jogo INT,
    nota INT NOT NULL,
    comentario TEXT,
    data_review TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recomendacao BOOLEAN,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_jogo) REFERENCES Jogos(id_jogo) ON DELETE CASCADE,
    CONSTRAINT chk_nota CHECK (nota BETWEEN 0 AND 10)
);

-- 6. Tabela Comentarios
CREATE TABLE Comentarios (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_review INT,
    id_usuario INT,
    comentario TEXT NOT NULL,
    data_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_review) REFERENCES Reviews(id_review) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);

-- 7. Tabela Grupos
CREATE TABLE Grupos (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    id_plataforma INT,
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma)
);

-- 8. Tabela Usuarios_Grupos
CREATE TABLE Usuarios_Grupos (
    id_usuario INT,
    id_grupo INT,
    data_ingresso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_grupo),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES Grupos(id_grupo) ON DELETE CASCADE
);

-- Tabela de log para comentários excluídos
CREATE TABLE IF NOT EXISTS log_comentarios_excluidos (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_comentario INT,
    id_usuario INT,
    id_review INT,
    data_exclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(255)
);

-- parte para popular as tabelas  --
-- INSERTS PARA TABELA Plataformas (8 plataformas)
INSERT INTO Plataformas (nome) VALUES 
('PlayStation 5'), ('Xbox Series X'), ('Nintendo Switch'),
('PC'), ('PlayStation 4'), ('Xbox One'),
('Mobile'), ('Cloud Gaming');

-- INSERTS PARA TABELA Usuarios (23 usuários)
INSERT INTO Usuarios (id_usuario, nome, email, senha, id_plataforma_preferida) VALUES 
(1, 'Lucas Admin', 'lucas@equipe.com', 'senha123lucas', 1),
(2, 'Hanny Moderador', 'hanny@equipe.com', 'senha123hanny', 2),
(3, 'Augusto Usuario', 'augusto@equipe.com', 'senha123augusto', 3),
(4, 'João Silva', 'joao@email.com', 'senha123', 1),
(5, 'Maria Souza', 'maria@email.com', 'mariasenha', 3),
(6, 'Vanessa Oliveira', 'vanessa@email.com', 'vanessa123', 2),
(7, 'Ana Pereira', 'ana@email.com', 'anapereira', 4),
(8, 'Pedro Santos', 'pedro@email.com', 'pedro123', 1),
(9, 'Lucia Ferreira', 'lucia@email.com', 'luciasenha', 5),
(10, 'Marcos Ribeiro', 'marcos@email.com', 'marcos123', 6),
(11, 'Fernanda Alves', 'fernanda@email.com', 'fer123', 3),
(12, 'Ricardo Lima', 'ricardo@email.com', 'ricardo123', 7),
(13, 'Juliana Costa', 'juliana@email.com', 'juliana123', 2),
(14, 'Roberto Martins', 'roberto@email.com', 'roberto123', 4),
(15, 'Patricia Gomes', 'patricia@email.com', 'patricia123', 1),
(16, 'Lucas Barbosa', 'lucas@email.com', 'lucas123', 5),
(17, 'Amanda Rocha', 'amanda@email.com', 'amanda123', 3),
(18, 'Gustavo Dias', 'gustavo@email.com', 'gustavo123', 2),
(19, 'Tatiane Cunha', 'tatiane@email.com', 'tatiane123', 6),
(20, 'Diego Souza', 'diego@email.com', 'diego123', 4),
(21, 'Camila Lima', 'camila@email.com', 'camila123', 1),
(22, 'Rafael Santos', 'rafael@email.com', 'rafael123', 3);

-- INSERTS PARA TABELA Jogos (20 jogos)
INSERT INTO Jogos (titulo, descricao, data_lancamento, desenvolvedora) VALUES
('The Last of Us Part II', 'Jogo de ação e aventura pós-apocalíptico', '2020-06-19', 'Naughty Dog'),
('Cyberpunk 2077', 'RPG de mundo aberto futurista', '2020-12-10', 'CD Projekt Red'),
('Animal Crossing: New Horizons', 'Simulador de vida em uma ilha deserta', '2020-03-20', 'Nintendo'),
('God of War Ragnarök', 'Sequência da saga nórdica de Kratos', '2022-11-09', 'Santa Monica Studio'),
('Elden Ring', 'RPG de ação em mundo aberto', '2022-02-25', 'FromSoftware'),
('FIFA 23', 'Simulador de futebol', '2022-09-30', 'EA Sports'),
('The Legend of Zelda: Tears of the Kingdom', 'Aventura de Link em Hyrule', '2023-05-12', 'Nintendo'),
('Call of Duty: Modern Warfare II', 'FPS tático militar', '2022-10-28', 'Infinity Ward'),
('Horizon Forbidden West', 'Aventura em mundo aberto pós-apocalíptico', '2022-02-18', 'Guerrilla Games'),
('Starfield', 'RPG espacial em mundo aberto', '2023-09-06', 'Bethesda'),
('Minecraft', 'Jogo sandbox de construção', '2011-11-18', 'Mojang'),
('Grand Theft Auto V', 'Mundo aberto com diversas atividades', '2013-09-17', 'Rockstar'),
('Red Dead Redemption 2', 'Aventura no velho oeste', '2018-10-26', 'Rockstar'),
('Fortnite', 'Battle Royale gratuito', '2017-07-25', 'Epic Games'),
('Among Us', 'Jogo de dedução social', '2018-06-15', 'InnerSloth'),
('Valorant', 'FPS tático competitivo', '2020-06-02', 'Riot Games'),
('League of Legends', 'MOBA competitivo', '2009-10-27', 'Riot Games'),
('Apex Legends', 'Battle Royale com heróis', '2019-02-04', 'Respawn'),
('Overwatch 2', 'FPS com heróis e habilidades', '2022-10-04', 'Blizzard'),
('Genshin Impact', 'RPG de ação mundo aberto', '2020-09-28', 'miHoYo');

-- INSERTS PARA TABELA Jogos_Plataformas
INSERT INTO Jogos_Plataformas (id_jogo, id_plataforma) VALUES
(1,1), (1,5), (2,1), (2,2), (2,4), (2,5), (2,6), (3,3), (4,1), (4,5),
(5,1), (5,2), (5,4), (6,1), (6,2), (6,3), (6,4), (6,5), (6,6), (7,3),
(8,1), (8,2), (8,4), (8,5), (8,6), (9,1), (9,5), (10,2), (10,4), (11,1),
(11,2), (11,3), (11,4), (11,5), (11,6), (11,7), (12,1), (12,2), (12,4),
(12,5), (12,6), (13,1), (13,2), (13,4), (13,5), (13,6), (14,1), (14,2),
(14,3), (14,4), (14,5), (14,6), (14,7), (15,3), (15,4), (15,7), (16,4),
(17,4), (18,1), (18,2), (18,4), (18,5), (18,6), (18,7), (19,1), (19,2),
(19,3), (19,4), (19,5), (19,6), (20,1), (20,2), (20,3), (20,4), (20,7);

-- INSERTS PARA TABELA Grupos (8 grupos)
INSERT INTO Grupos (nome, descricao, id_plataforma) VALUES
('PS5 Fans', 'Comunidade de fãs do PlayStation 5', 1),
('Xbox Series X Community', 'Tudo sobre o Xbox Series X', 2),
('Nintendo Switch Brasil', 'Comunidade brasileira de Switch', 3),
('PC Master Race', 'Jogadores de PC', 4),
('PS4 Players', 'Comunidade do PlayStation 4', 5),
('Xbox One BR', 'Comunidade brasileira de Xbox One', 6),
('Mobile Gamers', 'Jogadores de celular', 7),
('Cloud Gaming', 'Jogadores de streaming', 8);

-- INSERTS PARA TABELA Usuarios_Grupos
INSERT INTO Usuarios_Grupos (id_usuario, id_grupo) VALUES
(1,1), (2,2), (3,3), (4,1), (4,5), (5,3), (6,2), (6,6), (7,4), (8,1),
(9,5), (10,6), (11,3), (12,7), (13,2), (14,4), (15,1), (16,5), (17,3),
(18,2), (19,6), (20,4), (21,1), (22,3);

-- INSERTS PARA TABELA Reviews (40 reviews)
INSERT INTO Reviews (id_usuario, id_jogo, nota, comentario, recomendacao) VALUES
(1,1,10,'Jogo incrível, história emocionante!',1),(12,1,8,'Bom jogo, mas a história divide opiniões',1),
(3,2,6,'Cheio de bugs no lançamento, melhorou depois',0),(10,2,9,'Depois dos patches ficou excelente',1),
(2,3,10,'Perfeito para relaxar!',1),(8,3,7,'Divertido, mas fica repetitivo',1),
(5,4,10,'Melhor jogo da geração!',1),(18,4,9,'Quase perfeito, só o final que podia ser melhor',1),
(4,5,10,'Obra prima dos jogos de mundo aberto',1),(11,5,8,'Difícil mas recompensador',1),
(6,6,7,'Melhor que o 22, mas ainda muito parecido',1),(13,6,5,'Só mais um FIFA com gráficos atualizados',0),
(14,7,10,'Nintendo mostrando como se faz!',1),(19,7,9,'Quase perfeito, só faltou mais dungeons',1),
(7,8,8,'Campanha ótima, multiplayer divertido',1),(16,8,6,'Mais do mesmo, mas bem polido',1),
(1,9,9,'Gráficos lindos e história interessante',1),(12,9,8,'Melhor que o primeiro em tudo',1),
(3,10,7,'Bom RPG, mas esperava mais',1),(15,10,9,'Melhor RPG espacial já feito',1),
(4,11,10,'Clássico que nunca envelhece',1),(17,11,10,'Liberdade criativa incrível',1),
(5,12,9,'Depois de tantos anos ainda é bom',1),(18,12,8,'Online continua divertido',1),
(6,13,10,'O melhor jogo que já joguei',1),(13,13,9,'História incrível, mas lento no começo',1),
(9,14,8,'Melhor battle royale gratuito',1),(20,14,7,'Divertido com amigos',1),
(2,15,8,'Muito bom para jogar em grupo',1),(8,15,6,'Engraçado mas enjoa rápido',1),
(11,16,9,'Melhor FPS tático atual',1),(17,16,8,'Competitivo e viciante',1),
(4,17,7,'Clássico mas comunidade tóxica',0),(11,17,8,'Melhor MOBA, mas exige muito tempo',1),
(7,18,9,'Battle royale mais dinâmico',1),(16,18,8,'Ótimo sistema de heróis',1),
(10,19,7,'Bom mas pior que o primeiro',1),(15,19,6,'Sistema de batalha passou melhor',0),
(9,20,9,'Gráficos lindos e jogabilidade viciante',1),(20,20,8,'Ótimo jogo gratuito',1);

-- INSERTS PARA TABELA Comentarios (40 comentários)
INSERT INTO Comentarios (id_review, id_usuario, comentario) VALUES
(1,2,'Concordo plenamente, jogo incrível mesmo!'),(1,5,'A cena do golfe me quebrou...'),
(2,1,'A história é pesada mas necessária'),(2,18,'Prefiro o primeiro'),
(3,4,'Joguei depois do patch 1.5 e estava bem melhor'),(3,10,'Comprei na promoção e valeu cada centavo'),
(4,3,'A DLC Phantom Liberty está excelente!'),(4,15,'Quero jogar mas meu PC não roda'),
(5,14,'Jogo perfeito para desestressar'),(5,19,'Minha ilha está linda depois de 300 horas'),
(6,2,'Concordo que fica repetitivo depois de um tempo'),(6,8,'Mas a atualização 2.0 ajudou bastante'),
(7,12,'Kratos está mais humano nesse jogo'),(7,18,'O combate está ainda melhor que no primeiro'),
(8,5,'O final foi perfeito na minha opinião'),(8,1,'Melhor jogo de PS5 até agora'),
(9,11,'Jogo difícil mas justo'),(9,17,'Melhor mundo aberto que já vi'),
(10,4,'Demorei 100 horas para zerar'),(10,6,'Mal consegui passar do primeiro chefe'),
(11,13,'Career mode continua o mesmo'),(11,16,'Pelo menos melhoraram o HyperMotion'),
(12,6,'Paguei caro por um roster update'),(12,18,'FIFA 24 já está na wishlist'),
(13,8,'Nintendo não erra'),(13,19,'Estou ansioso pelo próximo'),
(14,2,'As dungeons poderiam ser maiores'),(14,14,'Mas os shrines são ótimos'),
(15,16,'Campanha curta mas intensa'),(15,20,'Multiplayer está viciante'),
(16,7,'Warzone 2 está incluso e é ótimo'),(16,10,'Prefiro o Cold War'),
(17,12,'Aloy está ainda mais incrível'),(17,5,'Os gráficos no PS5 são de outro mundo'),
(18,1,'Melhorou em tudo em relação ao primeiro'),(18,12,'Ainda prefiro o Zero Dawn'),
(19,10,'Esperava mais conteúdo no lançamento'),(19,15,'Mas as DLCs devem melhorar'),
(20,3,'Melhor RPG da Bethesda desde Skyrim'),(20,17,'Precisa de mais patches ainda');

-- criação de usuários e permissões --
CREATE USER IF NOT EXISTS 'lucas_admin'@'localhost' IDENTIFIED BY 'senha_admin123';
GRANT ALL PRIVILEGES ON game_reviews_community.* TO 'lucas_admin'@'localhost';

CREATE USER IF NOT EXISTS 'hanny_mod'@'localhost' IDENTIFIED BY 'senha_mod123';
GRANT SELECT, INSERT, UPDATE, DELETE ON game_reviews_community.Reviews TO 'hanny_mod'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON game_reviews_community.Comentarios TO 'hanny_mod'@'localhost';
GRANT SELECT ON game_reviews_community.Usuarios TO 'hanny_mod'@'localhost';
GRANT SELECT ON game_reviews_community.Jogos TO 'hanny_mod'@'localhost';

CREATE USER IF NOT EXISTS 'augusto_user'@'localhost' IDENTIFIED BY 'senha_user123';
GRANT SELECT ON game_reviews_community.Jogos TO 'augusto_user'@'localhost';
GRANT SELECT ON game_reviews_community.Plataformas TO 'augusto_user'@'localhost';
GRANT SELECT ON game_reviews_community.Reviews TO 'augusto_user'@'localhost';
GRANT SELECT ON game_reviews_community.Comentarios TO 'augusto_user'@'localhost';
GRANT INSERT ON game_reviews_community.Reviews TO 'augusto_user'@'localhost';
GRANT INSERT ON game_reviews_community.Comentarios TO 'augusto_user'@'localhost';