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

SELECT playerID, SB
FROM Batting
WHERE yearid = 2016
ORDER BY SB DESC

SELECT playerID, SB, CS
FROM Fielding
WHERE yearid = 2016
