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
















