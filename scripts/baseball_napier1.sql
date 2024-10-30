--Question 1
SELECT MIN(year),
	   MAX(year)
FROM homegames;


--Question 2
SELECT DISTINCT CONCAT(people.namefirst,' ',people.namelast) AS 
				full_name, 
				people.height, 
				appearances.g_all AS total_games, 
				teams.name AS team_name
FROM people
	INNER JOIN appearances
		USING(playerid)
	INNER JOIN teams
		USING(teamid)
WHERE height = (SELECT MIN(height)
				FROM people);


--Question 3:  Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?	
SELECT playerid, CONCAT(people.namefirst,' ',people.namelast) AS
		full_name, 
		SUM(s.salary) as salary
FROM people
	INNER JOIN salaries AS s
		USING(playerid)
WHERE playerid IN (SELECT playerid
				 FROM collegeplaying
				 WHERE schoolid='vandy')
GROUP BY playerid, full_name
ORDER BY salary DESC;

SELECT * 
FROM collegeplaying


--Question 4:  Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016
SELECT SUM(po) AS putouts,
	   CASE WHEN pos ='OF' THEN 'Outfield'
			WHEN pos = 'P' OR pos ='C' THEN 'Battery'
			ELSE 'Infield'
			END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position;


--Question 5:  Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT CASE WHEN yearid >=1920 AND yearid <1930 THEN '1920s'
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

--Question 6:  Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases

SELECT  playerid,
		CONCAT(p.namefirst,' ',p.namelast) AS
		full_name,
		(b.sb+b.cs) AS steal_attempts,
		b.sb::numeric/(b.sb+b.cs) AS steal_success
FROM batting AS b
INNER JOIN people AS p
USING(playerid)
WHERE (b.sb+b.cs)>=20 AND b.yearid=2016
ORDER BY steal_success DESC;

--Question 7: From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT name,
	   yearid,
	   w
FROM teams
WHERE (wswin = 'N' OR wswin IS NULL)
  AND (yearid>=1970 AND yearid<=2016)
  AND w=(SELECT MAX(w)
  		 FROM teams
		 WHERE (yearid>=1970 AND yearid<=2016)
		 AND (wswin = 'N' OR wswin IS NULL))


SELECT name,
	   yearid,
	   w
FROM teams
WHERE (wswin = 'Y')
  AND (yearid>=1970 AND yearid<=2016)
  AND yearid <> 1981
  AND w=(SELECT MIN(w)
  		 FROM teams
		 WHERE (yearid>=1970 AND yearid<=2016)
		 AND (wswin = 'Y')
		 AND yearid <> 1981)


SELECT name,
	   yearid,
	   w
FROM teams
WHERE (wswin = 'Y')

-------
WITH max_by_year AS (SELECT yearid, 
							MAX(w) AS max_wins
				   FROM teams
				   WHERE yearid>=1970 AND yearid<=2016
				   AND yearid<>1981
				   GROUP BY yearid
				   ORDER BY yearid)
				   
SELECT SUM(CASE WHEN wswin='Y' AND w=(max_wins) THEN 1.0
           ELSE 0.0
		   END)/46.0 AS percentage   
FROM teams
INNER JOIN max_by_year
USING(yearid)
WHERE yearid>=1970 AND yearid<=2016
	 AND wswin IS NOT NULL


--Question 8:  Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Top 5
SELECT h.team,
       t.name,
	   h.park,
	   p.park_name,
	   ROUND(h.attendance/h.games::numeric,2) AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
	USING(park)
INNER JOIN teams AS t
	ON h.team=t.teamid
WHERE (h.year=2016 AND t.yearid = 2016)
  AND h.games>10 
ORDER BY avg_attendance DESC
LIMIT 5;


--Lowest 5
SELECT h.team,
       t.name,
	   h.park,
	   p.park_name,
	   ROUND(h.attendance/h.games::numeric,2) AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
	USING(park)
INNER JOIN teams AS t
	ON h.team=t.teamid
WHERE (h.year=2016 AND t.yearid = 2016)
  AND h.games>10 
ORDER BY avg_attendance 
LIMIT 5;


--Question 9:  Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--Find the playerids of the managers how have this award in both leagues, along with the respective years.  Use this table as a CTE to pull the team names for each year.
WITH dual_awards AS (
				SELECT playerid, yearid
				FROM awardsmanagers
				WHERE playerid IN (
									SELECT playerid 
									FROM awardsmanagers
									WHERE awardid='TSN Manager of the Year'
									  AND lgid = 'AL'
									
									INTERSECT
									
									SELECT playerid
									FROM awardsmanagers
									WHERE awardid='TSN Manager of the Year'
									  AND lgid = 'NL'
								  )
				AND awardid='TSN Manager of the Year'
					 )
SELECT CONCAT(p.namefirst,' ',p.namelast),
	   m.yearid,
	   m.teamid,
	   t.name
FROM dual_awards AS d
INNER JOIN people AS p
USING(playerid)
INNER JOIN managers AS m
	ON m.playerid = d.playerid
	AND m.yearid = d.yearid
INNER JOIN teams AS t
	ON m.teamid = t.teamid
	AND m.yearid = t.yearid


--Question 10:  Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


--Use 2 CTEs here, one that returns the career spans of each player, and one that produces the maximum homeruns for each player's career (greater than 1)

WITH careers AS (
					SELECT CONCAT(namefirst,' ',namelast) AS fullname,
						   playerid,
						   CAST(LEFT(debut,4) AS integer) AS debut_year,
						   CAST(LEFT(finalgame,4) AS integer) AS final_year,
						   (CAST(LEFT(finalgame,4) AS integer) - 									        CAST(LEFT(debut,4) AS integer)) AS career_span
					FROM people
				 ),
    homeruns AS (
					SELECT playerid,
						   MAX(hr) AS max_homers
					FROM batting
					GROUP BY playerid
					   HAVING MAX(hr)>0
					ORDER BY playerid
			     )
SELECT c.fullname,
       h.playerid, 
	   b.yearid,
	   h.max_homers
FROM homeruns AS h
INNER JOIN careers AS c
USING(playerid)
INNER JOIN batting AS b
ON   h.max_homers=b.hr
 AND h.playerid=b.playerid
WHERE  c.career_span>=10
AND b.yearid=2016
ORDER BY h.playerid




SELECT playerid, hr, yearid
FROM batting
WHERE playerid IN('canoro01','davisra01','encared01','napolmi01','paganan01',
'wainwad01','uptonju01') 
ORDER BY playerid