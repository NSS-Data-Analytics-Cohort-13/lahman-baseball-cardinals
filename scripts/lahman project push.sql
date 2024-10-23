


-- 1) What range of years for baseball games played does the provided database cover?

SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM teams AS t

-- A: 1871 to 2016; Teams and Appearances tables include the same range of dates and thus either can be included to find the asnwer.

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

One of the joins is grabbing some dupes.

-- A: 