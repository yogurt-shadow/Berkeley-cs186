## Lecture 2. SQL, Part I 

+ Two sublanguages:
    + DDL : Data Definition Language
        + Define and modify schema
    + DML : Data Manipulation Language
        + Queries can be written intuitively

***
### DDL

**Sailors**

| sid | sname | rating | age|
|-|-|-|-|
|1|Fred|7|22|
|2|Jim|2|39|
|3|Nancy|8|27|

**DDL Language**

```SQL
CREATE TABLE Sailors (
    sid INTEGER,
    sname CHAR(20),
    rating INTEGER,
    age FLOAT,
    PRIMARY KEY (sid));
```

**Primary Key column(s)**

+ Provides a **unique** "lookup key" for the relation
+ Cannot have any duplicate values
+ Can be made up of > 1 column
    + E.g. (firstname, lastname)

|bid|bname|color|
|-|-|-|
|101|Nina|red|
|102|Pinta|blue|
|103|Santa Maria| red|

```SQL
CREATE TABLE Boats (
    bid INTEGER,
    bname CHAR(20),
    color CHAR(10), 
    PRIMARY KEY (bid));
```

|sid|bid|day|
|-|-|-|
|1|102|9/12|
|2|102|9/13|

```SQL
CREATE TABLE Reserves (
    sid INTEGER,
    bid INTEGER,
    day DATE,
    PRIMARY KEY (sid, bid, day),
    FOREIGN KEY (sid)
    	REFERENCES Sailors
    FOREIGN KEY (bid)
    	REFERENCES Boats);
```
***
### DML

**SELECT DISTINCT**

```SQL
SELECT DISTINCT S.name, S.gpa
  FROM students S
WHERE S.dept = 'CS';
```
+ **DISTINCT** specifies removal of duplicate rows before output
+ Can refer to the students table as "S", which is called an alias

**ORDER BY, Pt.1**

```SQL
SELECT S.name, S.gpa, S.age*2 AS a2
FROM Students S
WHERE S.dept = 'CS'
ORDER BY S.gpa, S.name, a2;
```
**ORDER BY, Pt.2**
```SQL
SELECT S.name, S.gpa, S.age*2 AS a2
FROM Students S
WHERE S.dept = 'CS'
ORDER BY S.gpa DESC, S.name ASC, a2;
```
+ Ascending order by default, but can be overridden
    + **DESC** flag for descending, **ASC** for ascending
    + Can mix and match, lexicographically

**LIMIT**

```SQL
SELECT S.name, S.gpa, S.age*2 AS a2
FROM Students S
WHERE S.dept = 'CS'
ORDER BY S.gpa DESC, S.name ASC, a2;
LIMIT 3;
```
+ Only produces the first &lt;integer&gt; output rows
+ Typically used with **ORDER BY**
    + Otherwise the output is non-deterministic
    + Output set depends on algorithm for query processing

**AGGREGATES**

```SQL
SELECT [DISTINCT] AVG(S.gpa)
FROM Students S
WHERE S.dept = 'CS';
```
+ Before producing output, compute a summary of some arithmetic expression
+ Other aggregates: **SUM, COUNT, MAX, MIN**

**GROUP BY**
```SQL
SELECT [DISTINCT] AVG(S.gpa), S.dept
FROM Students S
GROUP BY S.dept;
```
+ Partition table into groups with same **GROUP BY** column values
+ Produce an aggregate result per group

**HAVING**

```SQL
SELECT [DISTINCT] AVG(S.gpa), S.dept
FROM Students S
GROUP BY S.dept
HAVING COUNT(*) > 2;
```
+ **HAVING** filters groups
+ **HAVING** is applied after grouping and aggregation

**PUTTING IT ALL TOGETHER**

```SQL
SELECT S.dept, AVG(S.gpa), COUNT(*)
FROM Students S
WHERE S.gender = 'F'
GROUP BY S.dept
HAVING COUNT(*) >= 2
ORDER BY S.dept;
```
**AN ILLEGAL EXAMPLE**

```SQL
SELECT S.name, AVG(S.gpa)
FROM Students S
GROUP BY S.dept
```
+ name is not distinct group by department

**GENERAL BASIC SINGLE-TABLE QUERIES (DML)**

```SQL
SELECT [DISTINCT] <column expression list>
FROM <single table>
[WHERE <predicate>]
[GROUP BY <column list>
[HAVING <predicate>] ]
[ORDER BY <colunm list>]
[LIMIT <integer>];
```
