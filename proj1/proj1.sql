-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching -- replace this line
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300 -- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst like '% %'
  ORDER BY namefirst, namelast -- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear -- replace this line
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear -- replace this line
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT people.namefirst, people.namelast, people.playerID, HallofFame.yearid
  FROM  people INNER JOIN HallofFame
  ON people.playerID = HallofFame.playerID
  WHERE HallofFame.inducted = 'Y'
  ORDER BY yearid desc, people.playerID
  -- replace this line
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT q2i.namefirst, q2i.namelast, q2i.playerid, schools.schoolid, q2i.yearid
  FROM (q2i INNER JOIN collegeplaying ON collegeplaying.playerid = q2i.playerid)
  INNER JOIN schools ON collegeplaying.schoolid = schools.schoolid
  WHERE schools.schoolstate = 'CA'
  ORDER BY q2i.yearid DESC, schools.schoolid, q2i.playerid-- replace this line
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, q2i.namefirst, q2i.namelast, collegeplaying.schoolid
  FROM q2i LEFT OUTER JOIN collegeplaying
  ON q2i.playerid = collegeplaying.playerid
  ORDER BY q2i.playerid DESC, collegeplaying.schoolid -- replace this line
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT people.playerid, namefirst, namelast, yearid, slg
  FROM (
    SELECT playerid AS playerid2, yearid, ((h - h2b - h3b - hr) + 2.0 * h2b + 3.0 * h3b + 4.0 * hr)/ab AS slg
    FROM batting
    WHERE ab > 50
    ORDER BY slg DESC, yearid, playerid
    LIMIT 10
  )
   INNER JOIN people
  ON playerid2 = people.playerid -- replace this line
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT  people.playerid, people.namefirst, people.namelast, lslg
  FROM (
    SELECT playerid as playerid2, ((sum(h) - sum(h2b) - sum(h3b) - sum(hr)) * 1.0 + sum(h2b) * 2.0 + sum(h3b) * 3.0 + sum(hr) * 4.0)/sum(ab) as lslg
    FROM batting
    GROUP BY playerid
    HAVING sum(ab) > 50
    ORDER BY lslg DESC, playerid
    LIMIT 10
  )
   INNER JOIN people
  ON playerid2 = people.playerid -- replace this line
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  FROM (
    SELECT playerid as playerid2, ((sum(h) - sum(h2b) - sum(h3b) - sum(hr)) * 1.0 + sum(h2b) * 2.0 + sum(h3b) * 3.0 + sum(hr) * 4.0)/sum(ab) as lslg
    FROM batting
    GROUP BY playerid
    HAVING sum(ab) > 50 AND lslg >
    (
      SELECT ((sum(h) - sum(h2b) - sum(h3b) - sum(hr)) * 1.0 + sum(h2b) * 2.0 + sum(h3b) * 3.0 + sum(hr) * 4.0)/sum(ab)
      FROM batting
      WHERE playerid = 'mayswi01'
    )
  )
  INNER JOIN people
  ON playerid2 = people.playerid -- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid -- replace this line
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW compute1
AS
  SELECT MIN(salary) as lowest, MAX(salary) as highest, (MAX(salary) - MIN(salary))/10 as step
  FROM salaries
  WHERE yearid = 2016
;

CREATE VIEW compute2
AS
  SELECT binid as id, lowest + binid * step as low_bound, lowest + binid * step + step as high_bound
  FROM binids, compute1
;

CREATE VIEW q4ii(binid, low, high, count)
AS
SELECT compute2.id, low_bound, high_bound, COUNT(*)
FROM compute2 LEFT OUTER JOIN salaries
ON ((salary >= low_bound AND salary < high_bound) OR (salary >= low_bound AND compute2.id = 9))
WHERE yearid = 2016
GROUP BY compute2.id
   -- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT t2.yearid, t2.min - t1.min, t2.max - t1.max, t2.avg - t1.avg
  FROM q4i as t1 INNER JOIN q4i as t2
  ON t2.yearid = t1.yearid + 1
  ORDER BY t2.yearid   -- replace this line
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT playerid2, namefirst, namelast, salary, yearid
  FROM (
    SELECT playerid AS playerid2, salary, yearid
    FROM salaries AS t1
    WHERE (t1.yearid = 2000 OR t1.yearid = 2001) AND t1.salary = (
      SELECT MAX(t2.salary) FROM salaries AS t2 WHERE t2.yearid = t1.yearid
    )
  ) INNER JOIN people
  ON playerid2 = people.playerid  -- replace this line
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT teamid2, MAX(salary) - MIN(salary)
  FROM (
    SELECT allstarfull.playerid as playerid2, allstarfull.teamid as teamid2
    FROM allstarfull
    WHERE allstarfull.yearid = 2016
  )
  INNER JOIN salaries
  ON playerid2 = salaries.playerid AND teamid2 = salaries.teamid
  WHERE salaries.yearid = 2016
  GROUP BY teamid2 -- replace this line
;
