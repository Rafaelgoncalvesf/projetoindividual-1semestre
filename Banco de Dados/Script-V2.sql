

CREATE DATABASE fortnite;
USE fortnite;

CREATE TABLE Questinario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pergunta VARCHAR(150) NOT NULL,
    alternativa CHAR(1) NOT NULL,
    resposta VARCHAR(100)
);

CREATE TABLE Usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45)  NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(45)  NOT NULL,
    fk_questionario INT,
    FOREIGN KEY (fk_questionario) REFERENCES Questinario (id)
);

CREATE TABLE partiida (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ranking INT NOT NULL,
    kills INT DEFAULT 0,
    modo_partida VARCHAR(100) NOT NULL,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES Usuario (id),
    CHECK (ranking BETWEEN 1 AND 100),
    CHECK (kills >= 0)
);

INSERT INTO Questinario (pergunta, alternativa, resposta) VALUES
    ('Qual é o seu modo de jogo favorito?', 'A', 'Battle Royale'),
    ('Qual é o seu modo de jogo favorito?', 'B', 'Zero Build'),
    ('Qual é o seu modo de jogo favorito?', 'C', 'Criativo');


INSERT INTO Usuario (nome, email, senha, Questinario_idQUIz) VALUES
    ('Ana Lima',     'ana@email.com',    'senha123', 1),
    ('Bruno Souza',  'bruno@email.com',  'senha123', 1),
    ('Carla Dias',   'carla@email.com',  'senha123', 2),
    ('Diego Rocha',  'diego@email.com',  'senha123', 1),
    ('Elisa Matos',  'elisa@email.com',  'senha123', 3),
    ('Felipe Costa', 'felipe@email.com', 'senha123', 2);

INSERT INTO partiida (ranking, kills, modo_partida, Usuario_idUsuario) VALUES
    (1,  5,  'Battle Royale', 1),
    (12, 3,  'Battle Royale', 1),
    (4,  7,  'Zero Build',    1),
    (1,  9,  'Battle Royale', 1),
    (8,  2,  'Battle Royale', 2),
    (1,  6,  'Zero Build',    2),
    (15, 1,  'Zero Build',    3),
    (3,  4,  'Battle Royale', 3),
    (7,  3,  'Zero Build',    4),
    (1,  11, 'Battle Royale', 4),
    (20, 0,  'Battle Royale', 5),
    (2,  8,  'Zero Build',    6);

-- Media 
SELECT
    COUNT(*)               AS partidas,
    ROUND(AVG(ranking), 1) AS mediaRanking,
    ROUND(AVG(kills), 1)   AS mediaKills
  FROM partiida;
  

-- gráfico de pizza: partidas por modo de jogo
SELECT modo_partida AS modo, COUNT(*) AS partidas
  FROM partiida
 GROUP BY modo_partida
 ORDER BY modo_partida;

-- gráfico de barras empilhadas: por modo, vitórias, Top 10 e outras colocações
SELECT
    modo_partida AS modo,
    SUM(ranking = 1) AS vitorias,
    SUM(ranking BETWEEN 2 AND 10)AS top10,
    SUM(ranking > 10) AS outras
  FROM partiida
 GROUP BY modo_partida
 ORDER BY modo_partida;

-- quiz: quantos jogadores escolheram cada modo favorito
SELECT 
q.resposta AS modoFavorito, 
COUNT(*) AS jogadores
  FROM Usuario u
  JOIN Questinario q ON q.id = u.fk_questionario
 GROUP BY q.id, q.resposta
 ORDER BY q.id;

-- histórico: últimas partidas do jogador
SELECT 
p.id, 
modo_partida,
ranking, 
 kills
  FROM partiida as p
 WHERE fk_usuario = 1
 ORDER BY p.id DESC
 LIMIT 10;

-- ranking geral: vitórias e kills de cada jogador
SELECT 
u.nome,
COUNT(*) AS partidas,
SUM(p.ranking = 1) AS vitorias,
SUM(p.kills)  AS kills
  FROM partiida p
  JOIN Usuario u ON u.id = p.fk_usuario
 GROUP BY u.id, u.nome
 ORDER BY vitorias DESC, kills DESC;


-- =====================================================================
--  5. COMANDOS QUE O SITE USA (troque os valores pelos que vêm do formulário)
-- =====================================================================

-- cadastro
INSERT INTO Usuario (nome, email, senha)
VALUES ('Novo Jogador', 'novo@email.com', 'minhasenha');

-- login: se voltar uma linha, o e-mail e a senha estão certos
SELECT idUsuario, nome, email
  FROM Usuario
 WHERE email = 'ana@email.com' AND senha = 'senha123';

-- o usuário já respondeu o quiz? (1 = sim, 0 = ainda não)
SELECT Questinario_idQUIz IS NOT NULL AS respondeu
  FROM Usuario
 WHERE idUsuario = 1;

-- salvar a resposta do quiz (aqui, o usuário 7 escolheu a alternativa B, id 2)
UPDATE Usuario SET Questinario_idQUIz = 2 WHERE idUsuario = 7;

-- o que um usuário respondeu no quiz
SELECT u.nome, q.pergunta, q.alternativa, q.resposta
  FROM Usuario u
  JOIN Questinario q ON q.idQUIz = u.Questinario_idQUIz
 WHERE u.idUsuario = 1;

-- trocar a senha
UPDATE Usuario SET senha = 'novasenha' WHERE idUsuario = 1;

-- registrar uma partida (ranking 1 = Victory Royale)
INSERT INTO partiida (ranking, kills, modo_partida, Usuario_idUsuario)
VALUES (1, 6, 'Battle Royale', 1);

-- apagar um usuário: primeiro as partidas dele (chave estrangeira), depois ele
DELETE FROM partiida WHERE Usuario_idUsuario = 7;
DELETE FROM Usuario  WHERE idUsuario = 7;