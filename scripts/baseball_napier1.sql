
SELECT SUM(salary)
FROM salaries
WHERE playerid = 'priceda01'

SELECT *
FROM fielding




SELECT MIN(yearid),
	   MAX(yearid)
FROM teams

SELECT MIN(year),
	   MAX(year)
FROM homegames


--Question 2
SELECT DISTINCT CONCAT(people.namefirst,' ',people.namelast) AS full_name, 
				people.height, 
				appearances.g_all AS total_games, 
				teams.name AS team_name
FROM people
	INNER JOIN appearances
		USING(playerid)
	INNER JOIN teams
		USING(teamid)
WHERE height = (SELECT MIN(height)
				FROM people)


SELECT playerid, g_all, teamid
FROM appearances
WHERE playerid =(SELECT playerid 
				FROM people
				WHERE height = (SELECT MIN(height)
								FROM people))

--Question 3	
SELECT playerid, CONCAT(people.namefirst,' ',people.namelast) AS
		full_name, --s.salary
		SUM(s.salary) as salary
FROM people
	INNER JOIN salaries AS s
		USING(playerid)
WHERE playerid IN (SELECT DISTINCT playerid
				 FROM collegeplaying
				 WHERE schoolid='vandy')
GROUP BY playerid, full_name
ORDER BY salary DESC


--Question 4
SELECT SUM(po) AS putouts,
	   CASE WHEN pos ='OF' THEN 'Outfield'
			WHEN pos = 'P' OR pos ='C' THEN 'Battery'
			ELSE 'Infield'
			END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position