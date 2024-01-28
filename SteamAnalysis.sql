
-- Welche Entwickler haben ihre Spiele selbst gepublisht
SELECT appid, game, developers, publishers FROM steam_data
WHERE strpos( developers, publishers) > 0 
OR strpos( publishers , developers ) > 0

-- Dies zeigt welche Enwickler zusammen mit einen Publisher ihre Spiele gepublisht haben
SELECT * FROM (SELECT appid, game, developers, publishers FROM steam_data
WHERE strpos( developers, publishers) > 0 
OR strpos( publishers , developers ) > 0)
EXCEPT
SELECT appid, game, developers, publishers FROM steam_data
WHERE strpos( developers, publishers) > 0

-- Zeigt Preise von selbst-gepublishten Spiele 
SELECT game, developers, price FROM steam_data
WHERE developers = publishers

-- Zeigt  den Durchschnittspreis von ein selbst gepublishten Spiel
SELECT AVG(Price) FROM steam_data
WHERE developers = publishers

-- Zeigt  den Durchschnittspreis von einem Spiel, welches von einem Publisher vermarktet wurde
SELECT AVG(Price) FROM steam_data
WHERE developers <> publishers

-- Top 5 Preistags mit Publisher
SELECT price, COUNT(price) AS anzahl_price FROM steam_data
WHERE developers <> publishers 
GROUP BY price
HAVING COUNT(price) > 100
ORDER BY anzahl_price DESC
LIMIT 15

-- Top 5 Preistags ohne Publisher
SELECT price, COUNT(price) AS anzahl_price FROM steam_data
WHERE strpos( developers, publishers) > 0 
OR strpos( publishers , developers ) > 0
GROUP BY price
HAVING COUNT(price) > 100
ORDER BY anzahl_price DESC
LIMIT 15

SELECT COUNT(appid) FROM steam_data
WHERE strpos( developers, publishers) > 0 
OR strpos( publishers , developers ) > 0


SELECT appid, game, price, metacritic_score, user_score FROM steam_data
NATURAL JOIN metacritic_data 
WHERE user_score <> 0 OR metacritic_score >80
ORDER BY metacritic_score DESC


-- Sachen manuell ändern
UPDATE steam_data 
SET price = 19.99
WHERE appid = 7670

SELECT game FROM steam_data
WHERE appid = 271590

UPDATE steam_data 
SET price = 29.99
WHERE appid = 271590

-- Zeigt Spiele welche jeweils eine Bewertung von der Seite und von den Nutzern erhalten haben
SELECT game, price, metacritic_score, user_score FROM steam_data
NATURAL JOIN metacritic_data 
WHERE (metacritic_score <> 0 AND user_score <> 0) 

--Gibt an wie viele Spiele in welchen Preisbereichen verkauft werden
SELECT 
	CASE
		WHEN price = 0 THEN 'Gratis'
		WHEN price <= 5 THEN '5$'
		WHEN price <= 10 THEN '10$'
		WHEN price <= 20 THEN '20$'
		WHEN price <= 30 THEN '30$'
		WHEN price <= 60 THEN '60$'
		WHEN price <= 80 THEN '80$'
		WHEN price > 80 THEN 'Sehr teure Spiele'
	END AS price_range,
	COUNT(*) AS anzahl
FROM steam_data
GROUP BY price_range	

--Soll zeigen ob besser bewertete Spiele auch im Schnitt treurer sind
SELECT 
	CASE
		WHEN metacritic_score < 50 THEN 'Unter 50'
		WHEN metacritic_score < 70 THEN 'Unter 70'
		WHEN metacritic_score < 80 THEN 'Unter 80'
		WHEN metacritic_score < 90 THEN 'Unter 90'
		WHEN metacritic_score <= 100 THEN 'Unter 100'
	END AS scorebereich,
	AVG(price) AS preis
FROM metacritic_data
NATURAL JOIN steam_data
GROUP BY scorebereich

/*
Würde  gerne eine Empfehlung von Spielen bekommen, die ähnlich sind wie mein Lieblingsspiel.
1. Leider weiß ich nicht ob es Baldur's oder Balgur's Gate 3 heißt.
2. Hab bemerk, dass die Daten nicht vollständig sind und habe die manuell geupdatet.
3. Nun suche ich nach gute Spiele, welche die selben Tags haben.
*/
SELECT appid, game, price, metacritic_score, user_score, genres, tags FROM steam_data
NATURAL JOIN metacritic_data 
WHERE game LIKE '%''s Gate 3'

UPDATE metacritic_data 
SET metacritic_score = 96, user_score = 89
WHERE appid = 1086940

SELECT appid, game, price, metacritic_score, user_score, genres, tags FROM steam_data
NATURAL JOIN metacritic_data 
WHERE tags LIKE '%RPG%' AND tags LIKE '%Choices Matter%' AND tags LIKE '%Story Rich%' 
AND
metacritic_score >= 85
AND appid <> 1086940
ORDER BY 4 DESC, 3

-- Erstelle eine temporäre Tabelle für die Reviews
SELECT appid, game_name, (positive + negative) AS total_reviews, positive, negative FROM metacritic_data

DROP TABLE IF EXISTS game_reviews;
CREATE TEMPORARY TABLE game_reviews AS
SELECT appid, game_name, (positive + negative) AS total_reviews, positive, negative, metacritic_score, user_score FROM metacritic_data
SELECT * FROM game_reviews