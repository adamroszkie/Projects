-- Number of matches where a player ranked within the top 10 lost to a player ranked outside the top 100
-- Percentage of these matches out of a total of 25,362 matches

SELECT 
COUNT(*) AS NumMatches,
COUNT(*) / 25362 * 100 AS percent_matches
FROM atp_tennis_data
WHERE 
    (
        (Rank_1 <= 10 AND Rank_2 > 100 AND Winner = Player_2) OR
        (Rank_2 <= 10 AND Rank_1 > 100 AND Winner = Player_1)
    );

-- Player with the longest winning streak

WITH RankedMatches AS (
SELECT
Date,
Player_1,
Player_2,
Winner,
ROW_NUMBER() OVER (PARTITION BY Player_1 ORDER BY Date) AS P1_Rank,
ROW_NUMBER() OVER (PARTITION BY Player_2 ORDER BY Date) AS P2_Rank
	FROM atp_tennis_data),
	
Streaks AS (
SELECT
Player_1 AS Player,
Date,
Winner,
P1_Rank - ROW_NUMBER() OVER (PARTITION BY Player_1 ORDER BY Date) AS StreakGroup
FROM RankedMatches
WHERE Winner = Player_1
UNION ALL

SELECT
Player_2 AS Player,
Date,
Winner,
P2_Rank - ROW_NUMBER() OVER (PARTITION BY Player_2 ORDER BY Date) AS StreakGroup
FROM RankedMatches
WHERE Winner = Player_2),
CountedStreaks AS (
SELECT
Player,
COUNT(*) AS StreakLength,
MIN(Date) AS StreakStart,
MAX(Date) AS StreakEnd
FROM Streaks
GROUP BY Player, StreakGroup)

SELECT
Player,
MAX(StreakLength) AS LongestWinningStreak
FROM CountedStreaks
GROUP BY Player
ORDER BY LongestWinningStreak DESC;


-- Matches lost by Federer

WITH matches_lost AS (
    SELECT
        Player_1 AS Player,
        Winner,
        Date
    FROM atp_tennis_data
    WHERE Player_1 != Winner AND Player_1 LIKE '%Federer%'
    UNION ALL
    SELECT
        Player_2 AS Player,
        Winner,
        Date
    FROM atp_tennis_data
    WHERE Player_2 != Winner AND Player_2 LIKE '%Federer%'
)
SELECT
    Winner,
    COUNT(Winner) AS num_lost
FROM matches_lost
GROUP BY Winner
ORDER BY num_lost DESC



-- Matches won by Federer
WITH matches_won AS (
    SELECT
        Player_2 AS Player,
        Winner,
        Date
    FROM atp_tennis_data
    WHERE Player_1 = Winner AND Player_1 LIKE '%Federer%'
    UNION ALL
    SELECT
        Player_1 AS Player,
        Winner,
        Date
    FROM atp_tennis_data
    WHERE Player_2 = Winner AND Player_2 LIKE '%Federer%')
	
	
SELECT
Player,
COUNT(Player) AS num_won
FROM matches_won
GROUP BY Player
ORDER BY num_won DESC



-- Number of matches each player played in the tournament?

WITH Matches2015 AS (
    SELECT
        Tournament,
        Player_1 AS Player,
        Date
    FROM atp_tennis_data
    WHERE YEAR(Date) = 2015
    UNION ALL
    SELECT
        Tournament,
        Player_2 AS Player,
        Date
    FROM atp_tennis_data
    WHERE YEAR(Date) = 2015
)
SELECT
        Tournament,
        Player,
        COUNT(*) AS NumMatches
    FROM Matches2015
    GROUP BY Tournament, Player
