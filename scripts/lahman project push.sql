-- 1) What range of years for baseball games played does the provided database cover?

SELECT 
	MIN(yearid) AS min_year, 
	MAX(yearid) AS max_year
FROM teams AS t

-- A: 1871 to 2016; Teams and Appearances tables include the same range of dates and thus either can be included to find the answer.

-- 2) Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT height
FROM people

SELECT playerid, concat(namefirst, ' ', namelast) AS player_name, MIN(height) AS min_height
FROM people 
GROUP BY playerid
ORDER BY height ASC

SELECT playerid, g_all, teamid
FROM appearances
WHERE playerid = (SELECT playerid
				FROM people
				WHERE height = (SELECT MIN(height)
								FROM people))

SELECT DISTINCT CONCAT(people.namefirst,' ',people.namelast) AS full_name
	, people.height
	, appearances.g_all AS total_games
	, teams.name AS team_name
FROM people
INNER JOIN appearances
USING(playerid)
INNER JOIN teams
USING(teamid)
WHERE height = (SELECT MIN(height)
				FROM people)

-- A: Eddie Gaedel was the shortest player at 43 inches of height. He played 1 game with the St. Louis Browns.

-- 3) Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT *
FROM schools
WHERE schoolstate = 'TN'
ORDER BY schoolname desc

SELECT * 
FROM collegeplaying
WHERE schoolid = 'vandy'

SELECT DISTINCT collegeplaying.playerid, collegeplaying.schoolid, SUM(salaries.salary) AS total_salary, 
	CONCAT(people.namefirst,' ',people.namelast) AS full_name
FROM collegeplaying
INNER JOIN people
	USING(playerid)
INNER JOIN salaries
	USING(playerid)
	WHERE schoolid = 'vandy'
GROUP BY collegeplaying.playerid, collegeplaying.schoolid, full_name
ORDER BY total_salary DESC

SELECT playerid, SUM(salaries.salary) AS total_salary, CONCAT(people.namefirst,' ',people.namelast) AS full_name
FROM people
INNER JOIN salaries
	USING(playerid)
	WHERE playerid IN (SELECT playerid
						FROM collegeplaying 
						WHERE schoolid = 'vandy')
GROUP BY playerid, full_name
ORDER BY total_salary DESC

-- A: David Price

-- 4) Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT yearid, playerid, pos, PO
FROM fielding
where yearid = '2016'
GROUP BY  yearid, playerid,  PO, pos

SELECT playerid, pos, COUNT(PO) AS putout_total,
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield' 
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'null' END AS pos_class
FROM fielding
GROUP BY playerid, pos, pos_class
ORDER BY putout_total DESC

SELECT yearid, playerid, pos, COUNT(PO) AS putout_total,
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield' 
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'null' END AS pos_class
FROM fielding
WHERE yearid = '2016'
GROUP BY yearid, playerid, pos, PO
ORDER BY pos_class ASC

SELECT playerid, SUM(PO) AS putout_total,
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield' 
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'null' END AS pos_class
FROM fielding
WHERE yearid = '2016'
GROUP BY playerid,
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield' 
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'null' END
ORDER BY pos_class ASC

SELECT SUM(PO) AS putout_total,
	(
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield' 
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'null' END
	)	
	AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position

-- 5) Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

strikeouts per game by decade since 1920 
home runs per game

SELECT *
FROM batting

SELECT playerid, COUNT(SO) AS strikeouts, SUM(G) AS total_games, ROUND(AVG(SO/G),2) AS avg_strikeouts
FROM batting
WHERE yearID > 1920 
GROUP BY playerid

select playerid, COUNT(SHO) as shutouts, SUM(G) AS total_games, ROUND(AVG(SHO/G),2) AS avg_shutouts
from pitching
WHERE yearID > 1920 
group by playerid

SELECT (yearid/10)*10 AS decade
	, ROUND((SUM(SO::numeric))/SUM(G::numeric),2) AS so_per_g
	, ROUND((SUM(HR::numeric))/SUM(G::numeric),2) AS hr_per_g
	-- , ROUND((SUM(SHO::numeric))/SUM(G::numeric),2) AS sho_per_g
FROM teams
GROUP BY decade
HAVING (yearid/10)*10 > 1910
ORDER BY decade

SELECT CASE 
			WHEN yearid >=1920 AND yearid <1930 THEN '1920s'
			WHEN yearid >=1930 AND yearid <1940 THEN '1930s'
			WHEN yearid >=1940 AND yearid <1950 THEN '1940s'
			WHEN yearid >=1950 AND yearid <1960 THEN '1950s'
			WHEN yearid >=1960 AND yearid <1970 THEN '1960s'
			WHEN yearid >=1970 AND yearid <1980 THEN '1970s'
			WHEN yearid >=1980 AND yearid <1990 THEN '1980s'
			WHEN yearid >=1990 AND yearid <2000 THEN '1990s'
			WHEN yearid >=2000 AND yearid <2010 THEN '2000s'
			WHEN yearid >=2010 AND yearid <2020 THEN '2010s'
			END AS decade,
		ROUND(SUM(so*1.0)/SUM(g*1.0),2) AS avg_strikeouts,
		ROUND(SUM(hr*1.0)/SUM(g*1.0),2) AS avg_homeruns
FROM teams
GROUP BY decade
ORDER BY decade

-- 6) Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT teamid, SB
FROM Teams
WHERE yearid = 2016
ORDER BY SB DESC

SELECT SB
FROM BattingPost
ORDER BY SB DESC

SELECT playerID, CONCAT(people.namefirst,' ',people.namelast) AS full_name, SB, CS, (SB - CS) AS success_rate
FROM batting
JOIN people
USING(playerid)
WHERE batting.yearid = 2016 AND batting.SB >= 20
ORDER BY batting.SB DESC

SELECT playerID, CONCAT(p.namefirst,' ',p.namelast) AS full_name, b.SB, b.CS, ROUND((b.SB - b.CS)/b.SB::decimal,2) AS success_rate
FROM batting AS b
JOIN people AS p
USING(playerid)
WHERE b.yearid = 2016 AND b.SB >= 20
ORDER BY success_rate DESC

SELECT playerID, CONCAT(p.namefirst,' ',p.namelast) AS full_name, b.SB, b.CS, ROUND(b.SB/(b.SB + b.CS)::decimal,2) AS success_rate--, f.SB, f.CS
FROM batting AS b
JOIN people AS p
USING(playerid)
--JOIN fielding AS f
--USING(playerid)
WHERE b.yearid = 2016 AND b.SB >= 20 --AND f.SB IS NOT NULL AND f.CS IS NOT NULL
ORDER BY success_rate DESC

-- A: Chris Owings had the most success stealing bases in 2016 with a 90% success rate. 

-- 7) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

WITH CTE AS (

SELECT name, teamID, yearid, WSWin,
	(CASE
		WHEN WSWin = 'N' THEN SUM(W) ELSE NULL END) AS wins_WS_loser,
	(CASE
		WHEN WSWin = 'Y' THEN SUM(W) ELSE NULL END) AS wins_WS_winner
FROM teams
WHERE yearID BETWEEN 1970 AND 2016 AND WSWin IS NOT NULL 
GROUP BY name, teamID, yearID, WSWin
ORDER BY wins_WS_loser DESC, wins_WS_winner DESC
)
SELECT name
FROM CTE

WITH losers_cte AS
(
SELECT *
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
)
SELECT
	yearid,
	max(w) AS max_wins
FROM losers_cte
GROUP BY yearid
ORDER BY max_wins

-- A: Seattle Mariners did not win the world series and ended the season with 116 wins.

SELECT name, teamID, yearid, WSWin,
	(CASE
		WHEN WSWin = 'N' THEN SUM(W) ELSE NULL END) AS wins_WS_loser,
	(CASE
		WHEN WSWin = 'Y' THEN SUM(W) ELSE NULL END) AS wins_WS_winner
FROM teams
WHERE yearID BETWEEN 1970 AND 2016 AND WSWin IS NOT NULL 
GROUP BY name, teamID, yearID, WSWin
ORDER BY wins_WS_loser DESC, wins_WS_winner ASC

-- A: Los Angeles Dodgers did win the world series and ended the season with 63 wins. 

SELECT name, teamID, yearid, WSWin,
	(CASE
		WHEN WSWin = 'N' THEN SUM(W) ELSE NULL END) AS wins_WS_loser,
	(CASE
		WHEN WSWin = 'Y' THEN SUM(W) ELSE NULL END) AS wins_WS_winner
FROM teams
WHERE yearID BETWEEN 1970 AND 2016 AND WSWin IS NOT NULL AND yearID <> '1981'
GROUP BY name, teamID, yearID, WSWin
ORDER BY wins_WS_loser DESC, wins_WS_winner ASC 

-- A: Removing the problematic year of 1981, St. Louis Cardinals won the most games and won the world series at 83 games.

(SELECT teams.name
	, teams.yearid
	, teams.w
	, teams.wswin
FROM teams
WHERE (teams.yearid BETWEEN 1970 AND 1980
	OR teams.yearid BETWEEN 1982 AND 2016)
	AND teams.wswin = 'N'
ORDER BY teams.w DESC
LIMIT 1)
UNION
(SELECT teams.name
	, teams.yearid
	, teams.w
	, teams.wswin
FROM teams
WHERE (teams.yearid BETWEEN 1970 AND 1980
	OR teams.yearid BETWEEN 1982 AND 2016)
	AND teams.wswin = 'Y'
ORDER BY teams.w
LIMIT 1)

WITH top_wins AS 
(
	SELECT t1.yearid
		, t1.name
		, t1.w
		, t1.wswin
	FROM teams AS t1 
	WHERE (t1.w = (SELECT MAX(t2.w)
				FROM teams AS t2
				WHERE t1.yearid = t2.yearid))
		AND (t1.yearid BETWEEN 1970 AND 1980
			OR t1.yearid BETWEEN 1982 AND 2016)
)

SELECT ROUND((SELECT COUNT(top_wins.wswin)::numeric
		FROM top_wins
		WHERE top_wins.wswin = 'Y')/COUNT(top_wins.wswin)::numeric*100,2) AS ws_top_wins
FROM top_wins;

-- A: 25% of the time the team with the most wins also won the world series.

-- 8) Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

select *
from homegames
where year = '2016'

select p.park_name, t.name AS team_name, hg.games, SUM(hg.attendance)/COUNT(hg.games) AS total_attendance
from homegames as hg
join teams as t
ON hg.team = t.teamid
join parks as p
ON p.park = hg.park
where hg.year = '2016' and hg.games > 10
group by p.park_name, team_name, hg.games
order by total_attendance DESC
LIMIT 5;

select p.park_name, t.name AS team_name, hg.games, SUM(hg.attendance)/COUNT(hg.games) AS total_attendance
from homegames as hg
join teams as t
ON hg.team = t.teamid
join parks as p
ON p.park = hg.park
where hg.year = '2016' and hg.games > 10
group by p.park_name, team_name, hg.games
order by total_attendance ASC
LIMIT 5;

Numbers should be 47 something and 45 something

-- 9) Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

TSN Manager of the Year
In both NL and AL
Need full name and teams they were managing when they won the award

SELECT DISTINCT a.yearid, a.playerid, a.lgid, CONCAT(p.namefirst,' ',p.namelast) AS full_name,
	CASE
		WHEN a.lgid = 'AL' AND a.lgid = 'NL' THEN 'Y' ELSE NULL END AS leagues
FROM awardsmanagers AS a
JOIN people AS p
USING(playerid)
JOIN managershalf AS managers_table
USING(playerid)
WHERE a.awardid = 'TSN Manager of the Year' 

select playerid, 
	case when 
	awardid = 'TSN Manager of the Year' AND lgid = 'AL' AND lgid = 'NL' THEN COUNT(playerid) else null end AS managerwinner
from awardsmanagers 
group by awardid, lgid, playerid

select *
from awardsmanagers

select playerid, awardid, lgid
from awardsmanagers 
WHERE awardid = 'TSN Manager of the Year'-- AND lgid = 'AL' AND lgid = 'NL' 
--where managerwinner IS NOT NULL
group by awardid, lgid, playerid
