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