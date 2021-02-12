## Lecture 3. SQL, Part II

### Queries
**Join Queries**
```SQL
SELECT [DISTINCT] <column expression list>
FROM <table1 [AS t1], ... , tableN [AS tn]>
[WHERE <predicate>]
[GROUP BY <column list> [HAVING <predicate>]]
[ORDER BY <column list>];
```

**Sailors**
|sid|sname|rating|age|
|-|-|-|-|
|1|Popeye|10|22|
|2|OliveOyl|11|39|
|3|Garfield|1|27|
|4|Bob|5|19|

**Reserves**
|sid|bid|day|
|-|-|-|
|1|102|9/12|
|2|102|9/13|
|1|101|10/01|
**Cross (Cartesian) Product**
|sid|sname|rating|age|sid|bid|day|
|-|-|-|-|-|-|-|
|1|Popeye|10|22|1|102|9/12|
|1|Popeye|10|22|2|102|9/13|
|1|Popeye|10|22|1|101|10/01|
|2|OliveOyl|11|39|1|102|9/12|
|...|...|...|...|...|...|...|

+ All pairs of tuples, concatenated

```SQL
SELECT Sailors.sid, Sailors.sname, Reserves.bid
FROM Sailors, Reserves
WHERE Sailors.sid = Reserves.sid

SELECT S.sid, sname, bid
FROM Sailors AS S, Reserves AS R
WHERE S.sid = R.sid
```
|sid|sname|bid|
|-|-|-|
|1|Popeye|102|
|1|Popeye|101|
|2|OliveOyl|102|

*More Aliases*
```SQL
SELECT x.sname, x.age, y.sname AS sname2, y.age AS age2
FROM Sailors AS x, Sailors AS y
WHERE x.age > y.age
```
+ Table aliases in the **FROM** clause
    + needed when the same table used multiple times (self-join)
+ Column aliases in the **SELECT** clause

***
**Arithmetic Expressions**
```SQL
SELECT S.age, S.age-5 AS age1, 2*S.age AS age2
FROM Sailors AS S
WHERE S.name = 'Popeye'

SELECT S1.sname AS name1, S2.sname AS name2
FROM Sailors AS S1, Sailors AS S2
WHERE 2*S1.rating = S2.rating - 1
```

**SQL Calculator**
```SQL
SELECT
      log(1000) as three,
      exp(ln(2)) as two,
      cos(0) as one,
      ln(2*3) = ln(2) + ln(3) as sanity;
```

**String Comparisons**
```SQL
SELECT S.sname
FROM Sailors S
WHERE S.sname ~ 'B.*'
```

***
**Combining Predicates**
+ Boolean logic: **AND, OR**
+ Set operations: **INTERSECT, UNION**

```SQL
SELECT R.sid
FROM Boats B, Reserves R
WHERE R.bid = B.bid AND
	  (B.color = 'red' OR B.color = 'green')
```
*Another expression*
```SQL
SELECT R.sid
FROM Boats B, Reserves R
WHERE R.bid = B.bid AND B.color = 'red'

UNION ALL

SELECT R.sid
FROM Boats B, Reserves R
WHERE R.bid = B.bid AND B.color = 'green'
```

***
#### Set Semantics
no copy
**UNION, INTERSECT, EXCEPY**

#### Multiset Semantics
have duplicates
R = {A(4), B(2), C(1), D(1)}
S = {A(2), B(3), C(1), E(1)}
+ **UNION ALL**: sum of cardinalities
    + {A(6), B(5), C(2), D(1), E(1)}
+ **INTERSECT ALL**: min of cardinalities
    + {A(2), B(2), C(1)}
+ **EXCEPT ALL**: difference of cardinalities
    + {A(2), D(1)}

***
#### Nested Queries: IN
+ Names of sailors who've reserved boat #102:

```SQL
SELECT S.sname
FROM Sailors S
WHERE S.sid IN
    (SELECT R.sid
    FROM Reserves R
    WHERE R.bid = 102)
```

#### Nested Queries: EXISTS
```SQL
SELECT S.sname
FROM Sailors S
WHERE EXISTS
    (SELECT R.sid
    FROM Reserves R
    WHERE R.bid = 103)
```
+ if there is a reserve's bid is 103, this query will return **all sailors' names**.

#### Nested Queries with Correlation
+ Names of sailors who've reserved boat #102:
+ Correlated subquery is recomputed for each Sailors tuple

```SQL
SELECT S.sname
FROM Sailors S
WHERE EXISTS
    (SELECT *
    FROM Reserves R
    WHERE R.bid = 102 AND S.sid = R.sid)
```

+ Other forms: **ANY, ALL**

```SQL
SELECT * 
FROM Sailors S
WHERE S.rating > ANY
    (SELECT S2.rating
    FROM Sailors S2
    WHERE S2.sname = 'Popeye')
```

#### A Tough One: "Division"
+ Relational Division: "Find sailors who've reserved all boats."
+ Said differently: "sailors with no counterexample missing boats"

```SQL
SELECT S.sname
FROM Sailors S
WHERE NOT EXISTS
    (SELECT B.bid
    FROM Boats B
    WHERE NOT EXISTS (SELECT R.bid
                     FROM Reserves R
                     WHERE R.bid = B.bid
                     AND R.sid = s.sid ))
```

#### Find sailor with the highest rating (ARGMAX)
```SQL
SELECT *
FROM Sailors S
WHERE S.rating >= ALL
    (SELECT S2.rating
    FROM Sailors S2)
  
SELECT *
FROM Sailors S
WHERE S.rating = 
    (SELECT MAX(S2.rating)
    FROM Sailors S2)
```
***
#### Inner Joins
```SQL
SELECT s.*, r.bid
FROM Sailors S, Reserves r
WHERE s.sid = r.sid
AND ...

SELECT s.*, r.bid
FROM Sailors s INNER JOIN Reserves r
ON s.sid = r.sid
WHERE ... 
```

#### Join Variants
```SQL
SELECT <column expression list>
FROM table_name
[INNER | NATURAL
  | {LEFT | RIGHT | FULL } {OUTER}] JOIN
  table_name
  ON <qualification_list>
WHERE ...
```
+ **NATURAL** means equi-join for pairs of attributes with the same name
+ **LEFT OUTER JOIN**: return s all matched rows and preserves all unmatched rows from the table on the left of the join
    + use nulls in fields of non-matching tuples
    + ```SQL
      SELECT s.sid, s.sname, r.bid
      FROM Sailors2 s LEFT OUTER JOIN Reserves2 r
      ON s.sid = r.sid;
      ```
+ **RIGHT OUTER JOIN**: return s all matched rows and preserves all unmatched rows from the table on the right of the join
    + ```SQL
      SELECT r.sid, b.bid, b.bname
      FROM Reserves2 r RIGHT OUTER JOIN Boats2 b
      ON r.bid = b.bid
      ```
+ **FULL OUTER JOIN**: returns all (matched or unmatched) rows from the tables on both sides of the join
    + ```SQL
      SELECT r.sid, b.bid, b.bname
      FROM Reserves2 r FULL OUTER JOIN Boats2 b
      ON r.bid = b.bid
      ```
    + returns all boats and all information on reservations

***
#### Views: Names Queries
```SQL
CREATE VIEW view_name
AS select_statement
```
+ makes development simpler
+ often used for security
+ not "materialized"

```SQL
CREATE VIEW Redcount
AS SELECT B.bid, COUNT(*) AS scount
    FROM Boats2 B, Reserves2 R
    WHERE R.bid = B.bid AND B.color = 'red'
    GROUP BY B.bid
    
SELECT * FROM Redcount;

SELECT bname, scount
FROM Redcount R, Boats2 B
WHERE R.bid = B.bid
AND scout < 10;
```
---
#### WITH a.k.a. common table expression (CTE)
```SQL
WITH Reds(bid, scount) AS
(SELECT B.bid, COUNT(*)
FROM Boats2 B, Reserves2 R
WHERE R.bid = B.bid AND B.color = 'red'
GROUP BY B.bid)

SELECT bname, scount
FROM Boats2 B, Reds
WHERE Reds.bid = B.bid
AND scount < 10
```

**Can have many queries in WITH**
```SQL
WITH Reds(bid, scount) AS
(SELECT B.bid, COUNT(*)
FROM Boats2 B, Reserves2 R
WHERE R.bid = B.bid AND B.color = 'red'
GROUP BY B.bid),

UnpopularReds AS
SELECT bname, scount
FROM Boats2 B, Reds
WHERE Reds.bid = B.bid
AND scount < 10

SELECT * FROM UnpopularReds;
```

*Example: ARGMAX GROUP BY*
```SQL
WITH maxratings(age, maxrating) AS
(SELECT age, max(rating)
FROM Sailors
Group BY age)

SELECT S.*
FROM Sailors S, maxratings m
WHERE S.age = m.age
AND S.rating = m.maxrating;
```

***
#### Null Values
+ Field values are sometimes unknown
    + SQL provides a special value NULL
    + Every data type can be NULL
+ The presence of null complicates many issues
    + Selection predicates (WHERE)
    + Aggregation
+ NULLs comes naturally from Outer joins
+ Rule: (x op NULL) evaluates to ... NULL!
    + ```SQL
      SELECT rating = NULL FROM sailors;
      SELECT rating < NULL FROM sailors;
      SELECT rating >= NULL FROM sailors;
      ```
+ Explicit NULL Checks
    + ```SQL
      SELECT * FROM Sailors WHERE rating IS NULL;
      SELECT * FROM Sailors WHERE rating IS NOT NULL;
      ```
+ Do not output a tuple WHERE NULL
    + ```SQL
      SELECT * FROM sailors;
      SELECT * FROM sailors WHERE rating > 8;
      SELECT * FROM sailors WHERE rating <= 8;
      ```

**NULL in Boolean logic**
|NOT|T|F|N|
|-|-|-|-|
| |F|T| N|

|AND|T|F|N|
|-|-|-|-|
|T|T|F|N|
|F|F|F|F|
|N|N|F|N|

|OR|T|F|N|
|-|-|-|-|
|T|T|T|T|
|F|T|F|N|
|N|T|N|N|

**General rule: NULL can take on either T or F, so answer needs to accommodate either value.**

**NULL and Aggregation**
```SQL
SELECT count(*) FROM sailors;
SELECT sum(rating) FROM sailors;
```

**General rule: NULL column values are ignored by aggregate functions**

***
#### Summary
A declarative language
+ somebody has to translate to algorithms 
+ The RDBMS implementer