SELECT * FROM allstarfull;

SELECT * FROM appearances;

SELECT * FROM awardsmanagers;

SELECT * FROM awardsplayers;

SELECT * FROM awardssharemanagers;

SELECT * FROM batting;

SELECT * FROM battingpost;

SELECT * FROM collegeplaying;

SELECT * FROM fielding;

SELECT * FROM fieldingof;

SELECT * FROM fieldingofsplit;

SELECT * FROM fieldingpost;

SELECT * FROM halloffame;

SELECT * FROM homegames;

SELECT * FROM managers;

SELECT * FROM managershalf;

SELECT * FROM parks;

SELECT * FROM people;

SELECT * FROM pitching;

SELECT * FROM pitchingpost;

SELECT * FROM salaries;

SELECT * FROM schools;

SELECT * FROM seriespost;

SELECT * FROM teams;

SELECT * FROM teamsfranchises;

SELECT * FROM teamshalf;





--1. What range of years for baseball games played does the provided database cover?

SELECT
	MIN(yearid) AS min_year, 
	MAX(yearid) AS max_year
FROM teams AS t;





--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

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
				FROM people);





--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

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
				FROM people);





--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.






--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   





--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

--people table: playerid, namefirst, namelast
--batting table: stolen bases (sb), caught stealing (cs), yearid 
--conditions: **2016 only**, at least 20 stolen bases

SELECT p.playerid, p.namefirst, p.namelast,
     ROUND(((b.sb ::numeric / (b.sb + b.cs))*100),2) AS success_rate 
FROM people AS p
JOIN batting AS b ON p.playerid = b.playerid
WHERE b.yearid = 2016
  AND (b.sb + b.cs) >= 20
ORDER BY success_rate DESC
Limit 1;





--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--Teams Table: teamID, yearID, Wins (w), (Y or N) World Series Winner (wswin)

SELECT 
	lgid AS league, 
	yearID AS year, 
	teamID, 
	w AS max_no_world_series_winner
FROM Teams
WHERE yearID BETWEEN 1970 AND 2016
  AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;


SELECT 
	lgid AS league,
	yearID AS year, 
	teamID, 
	w AS min_yes_world_series_winner
FROM Teams
WHERE yearID BETWEEN 1970 AND 2016
  AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1;

--
SELECT yearID, lgid, teamID, w AS wins
FROM Teams
WHERE yearID BETWEEN 1970 AND 2016
  AND wswin = 'Y'
ORDER BY w ASC;
--

SELECT 
	lgid AS league,
	yearID AS year,
	teamID, 
	w AS min_yes_world_series_winner
FROM Teams
WHERE yearID BETWEEN 1970 AND 2016
  AND yearID != 1981
  AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1;


WITH max_wins AS (
    SELECT yearID, MAX(w) AS most_wins
    FROM Teams
    WHERE yearID BETWEEN 1970 AND 2016
    GROUP BY yearID
	ORDER BY yearID
),
ws_winners AS (
    SELECT t.yearID, t.teamID, t.w
    FROM Teams AS t
    JOIN max_wins AS m ON t.yearID = m.yearID 
                      AND t.w = m.most_wins
    WHERE t.wswin = 'Y'
)
SELECT COUNT(*) AS count_world_series_wins,
  ROUND((COUNT(*) * 100.0 / (2016 - 1970 + 1)),2) AS win_percentage
FROM ws_winners;



--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--attandance (Home attandce)

(SELECT parks.park_name
	, teams.name
	, ROUND((homegames.attendance)/(homegames.games::numeric),2) AS avg_attendance
FROM homegames
	INNER JOIN parks
		USING(park)
	INNER JOIN teams
		ON homegames.team = teams.teamid
WHERE homegames.games >= 10
	AND homegames.year = 2016
	AND teams.yearid = 2016
ORDER BY avg_attendance DESC
LIMIT 5)
UNION
(SELECT parks.park_name
	, teams.name
	, ROUND((homegames.attendance/homegames.games::numeric),2) AS avg_attendance
FROM homegames
	INNER JOIN parks
		USING(park)
	INNER JOIN teams
		ON homegames.team = teams.teamid
WHERE homegames.games >= 10
	AND homegames.year = 2016
	AND teams.yearid = 2016
ORDER BY avg_attendance
LIMIT 5)
ORDER BY avg_attendance DESC





--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

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





--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH top_hr AS (
	SELECT playerid
		, MAX(hr) AS top_hr
	FROM batting
	GROUP BY playerid
)
SELECT CONCAT(people.namefirst, ' ',people.namelast) AS full_name
	, batting.hr
FROM batting
	INNER JOIN top_hr
		USING (playerid)
	INNER JOIN people
		USING (playerid)
WHERE batting.hr = top_hr.top_hr
	AND batting.yearid = 2016
	AND batting.hr > 0
	AND (batting.yearid-LEFT(people.debut,4)::integer) >= 10
ORDER BY hr DESC;






--**Open-ended questions**

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.








--12. In this question, you will explore the connection between number of wins and attendance.
 -- *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
 -- *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.







--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
