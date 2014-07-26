```
      ___           ___           ___
     /\  \         /\  \         /\__\
    /::\  \       /::\  \       /:/  /
   /:/\ \  \     /:/\:\  \     /:/  /
  _\:\~\ \  \    \:\~\:\  \   /:/  /
 /\ \:\ \ \__\    \:\ \:\__\ /:/__/
 \:\ \:\ \/__/     \:\/:/  / \:\  \
  \:\ \:\__\        \::/  /   \:\  \
   \:\/:/  /        /:/  /     \:\  \
    \::/  /        /:/  /       \:\__\
     \/__/         \/__/         \/__/

*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
--- SQL101 ---- Summer of Tech ---- 2014 ---
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
```
:sparkles: Welcome to the practical exercise segment of
the bootcamp! :sparkles:

We're going to be working in SQLite 3, and
we're going to implement a database that can
store your course grades.

To get started, open a terminal instance,
`cd` your way into a directory where we can
create a new database file, then type the
command

```
sqlite3 grades.db
```

This should create a new database called
"grades.db", and open the sqlite3 prompt.

You can view the location of your database
with `.database`, and leave your session
prompt with `.quit` -- on my machine this
process looks like this:

```
kieran@rodion: ~/dev/sql/sot/exercises master ⚡
$ sqlite3 grades.db
SQLite version 3.7.13 2012-07-17 17:46:21
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .database
seq  name             file
---  ---------------  ----------------------------------------------------------
0    main             /Users/kieran/dev/sql/sot/exercises/grades.db
sqlite> .quit

kieran@rodion: ~/dev/sql/sot/exercises master ⚡
```

If none of this is working, now would be a good time to ask for help!

### Creating your first table

First thing's first -- let's create a simple table to get us started.

The `create table` command takes several parameters, the table name,
the column definition, and any _constraints_ that we have on the table.

Lets create the first table from the slides, which stores an integer
student ID, a name, a course name, and a grade. We also add a composite
primary key of (ID, Name, Course) -- this is an example of a uniqueness
constraint (i.e. there can never be two rows in this table with the same
values for those attributes).

```
CREATE TABLE Grades (
    StudentID INTEGER,
    Name STRING,
    Course STRING,
    Grade STRING,
    PRIMARY KEY (StudentID, Name, Course)
)
```

You can view your database schema by issuing the `.schema` command, which
should display our newly created Grades table.

### Inserting some data

Now we can insert a row into our grades table, using the `INSERT` command.

The syntax is `INSERT INTO <tablename> VALUES (<value 1>, <value 2>....);`

So to insert a new result into our Grades table we issue the following command:

```
INSERT INTO Grades VALUES (1234, "your name", "COMP102", "A+");
```

We can show the uniqueness constraint holds by trying to insert a new row with
the same values for the primary key:

```
INSERT INTO Grades VALUES (1234, "your name", "COMP102", "C-");
```

You should get an error like `Error: columns StudentID, Name, Course are not unique`.

A little sqlite3 oddity worth noting here is that you can insert values that don't
agree with the schema definition (e.g. you can insert a string into the INTEGER
student ID column)!

Think about the implications of that -- and some of the very unexpected results you
could end up with.

### Viewing your data

At this point, we think we inserted some data, but much like Schrödinger's cat we can't
be too sure it's still there until we actually view it.

To do this we can use the `SELECT` command:

```
SELECT StudentID, Name, Course, Grade FROM Grades;
```

We can also write `SELECT * FROM Grades`, the asterisk is shorthand for all the
columns in the table.

You should be able to see the rows you inserted are now saved to the database.

### Constraining our data

Unfortunately our table definition still isn't bullet proof -- there's a special
value in SQL called `NULL` that is used to represent an absence of a value. Because
we didn't specify a `NOT NULL` constraint for our columns, we can insert values that
don't make sense in our domain (that is, a row in our grades column should never
be missing a value!).

For example, try:

```
INSERT INTO Grades VALUES (null, null, null, null);
```

There are of course some occasions where you would want to represent the _possible_
existence of a value -- can you think of any extra columns that we could add onto
a grades table that would be candidates for a nullable column?

In sqlite3 we can't just adjust the columns, so we'll have to drop and re-create the
table. To do this issue a `DROP TABLE Grades` command, which removes the table and
all associated data. Next, re-run your create table command, but add the directive
`NOT NULL` after each column declaration (e.g. `StudentID INTEGER NOT NULL,`).

If you're stuck [here's one I prepared earlier](https://gist.github.com/kjgorman/35a2f13d0cec5351f90e).

Now inserting null values is not possible! :+1:

### Normalising our data model

Alas, we are going to drop this table again. As we saw in the presentation, the
way we're storing our data has some redundancy in our student ID and names. To
remove this redundancy we're going to normalise our table to [Second normal form](http://en.wikipedia.org/wiki/Second_normal_form).

The new design we want is:

```
 ------------------                                     -----------------------------------
|      Students    |                                   |               Grades              |
 ------------------                                     -----------------------------------
| StudentID | Name |   <----(foreign key relation)---- | StudentID | Course | Year | Grade |
 ------------------                                     -----------------------------------
|  int      | str  |                                   |   int     | str    | int  | str   |
 ------------------                                     -----------------------------------
```

The way we establish a foreign key relation is to add a constraint when we're
creating the column (in our case StudentID). The constraint syntax is:

```
REFERENCES <table> (<column_name>)
```

For backwards compatibility reasons foreign keys are off by default in sqlite, so let's
turn them back on! Issue the pragma command to enable them:

```
PRAGMA foreign_keys = ON;
```

Going from our first table example, try and create this new schema design (don't forget
to drop your Grades table). You should be able to tack on the foreign key reference to
your column definition in the same way you had to add the `NOT NULL` constraint.

If you're stuck, [the "here's one I prepared earlier" gist also has an example](https://gist.github.com/kjgorman/35a2f13d0cec5351f90e).


### Selecting data from multiple tables

Now that we have spread our data over multiple tables if we want to be able to reconstitute our original rows of grades we need to perform a _join_.

Joins represent combinations of tables based on certain criteria -- as we saw in the slides they correspond to ways you can combine sets.

First though we'll need to insert some data into our new tables. Let's start by inserting some students

```
INSERT INTO Student VALUES (1, "Foo");
INSERT INTO Student VALUES (2, "Bar");
INSERT INTO Student VALUES (3, "Quux");
```

And next some grades (you should just be able to copy paste these into your session prompt):

```
INSERT INTO Grades VALUES (1, "COMP102", 2014, "A");
INSERT INTO Grades VALUES (1, "COMP103", 2014, "A");
INSERT INTO Grades VALUES (2, "COMP103", 2014, "B");
INSERT INTO Grades VALUES (2, "COMP102", 2014, "B");
INSERT INTO Grades VALUES (3, "COMP103", 2014, "C");
INSERT INTO Grades VALUES (3, "COMP102", 2014, "C");
```

Now we can join the two tables together in a select statement:

```
SELECT * FROM Student s INNER JOIN Grades g;
```

You should see about 3 * 6 results -- every combination of the two tables rows. Because we have not specified a join condition, sqlite has just given us every possible combination (or in other words, a cartesian product!)

We're generally not too interested in seeing an unconstrained product of two tables, in our case we're looking for the intersection of the two tables, based off the StudentID attribute. This will give us just the grades that are for each student. We can specify that join condition by adding an `ON` clause to our select:

```
SELECT * FROM Student s INNER JOIN Grades g ON s.StudentID = g.StudentID;
```

### Outer joins

Now let's insert another student:

```
INSERT INTO Student VALUES (4, "Baz");
```

And re-issue our joining select. You should see that you have the same results as before, because "Baz" has no grades for us to intersect with.

Let's say we wanted to list all students, and their grades _if they have any_. To do this we need an outer join. If an inner join is an intersection, then an outer join can be thought of as an intersection combined with a union -- that is, it will give us the intersecting values of some tables, as well as the values in a specified table.

You can have left, right, or full outer joins, which union the values in either the left, right, or both tables involved in the join. The names make sense when you look at it like a set operation:

![joins](http://kjgorman.com/static/joins.png)

So let's change our previous join to a left outer join:

```
SELECT * FROM Student s LEFT OUTER JOIN Grades g ON s.StudentID = g.StudentID;
```

You should now see that we have the previous three students and their grades, and then Baz with empty values for grades.

Question: what is it about our current data model that means a _right_ outer join would be meaningless?

### Normalisation round two

Now that we've mastered the art of splitting columns off from a table and being able to re-join them, let's go back to thinking about our data model. Another weak spot we have at the moment is how we treat the actual grade value. Currently that column is just a non-null string, meaning we could take a paper and end up with a grade of "Z-" or something equally non-sensical.

We could apply an additional constraint to that column, sqlite supports constraints on inserts that can restrict the value to being one of a possible set of values, so we could use that to keep them within A-D with a + or a -.

A more relational approach would be to use the concept of a [reference table](http://en.wikipedia.org/wiki/Reference_table). Because we know that a grade can only ever be one of an enumerated set, we could create a table that has a row for each grade, then join our course grades to that table.

Let's revise our design to include a grade points table, like this:

```
 ------------------         ----------------------------------------       --------------------
|      Students    |       |               Grades                   |     |      GradePoints   |
 ------------------         ----------------------------------------       --------------------
| StudentID | Name |   <-- | StudentID | Course | Year | GradePoint | --> | GradePoint | Label |
 ------------------         ----------------------------------------       --------------------
|  int      | str  |       |   int     | str    | int  | int        |     |  int       | str   |
 ------------------         ----------------------------------------       --------------------
```

So we should then be able to `INSERT INTO GradePoints VALUES (9, "A+");`.

Make sure you capture the foreign key relation from Grades to GradePoints!

If you're stuck, [the "here's one I prepared earlier" gist also has an example](https://gist.github.com/kjgorman/35a2f13d0cec5351f90e).

Once you've created these tables you can download some reference data for the next section:

* [GradePoints.sql](https://gist.githubusercontent.com/kjgorman/8ecfd8006d1310ed54d2/raw/339862f13472220b3d26e6e2d5e7f3bbc5071bcb/GradePoints.sql)
* [Students.sql](https://gist.githubusercontent.com/kjgorman/93cb27de2bc3b47f6dea/raw/45b22b7da2fe25364721f1b6c024d38eb7e357b2/students.sql)
* [Grades.sql](https://gist.githubusercontent.com/kjgorman/46bc2743e3c83658e500/raw/e04cc141614da50b7ec6fef526085934777eb5fa/grades.sql)

To insert the data into your session, use the `.read` command, it takes the path to the files as an argument.

```
sqlite> .read ~/path/to/grades.sql
```

You will need to have created your tables exactly as that schema diagram shows, as the order of the values
we're inserting is significant. If you've done things in a different order it could be easier at this point
just to grab the version from the "here's one I prepared earlier" file and re-setup your schema.

You can then determine the number of rows in a table by using the `SELECT COUNT(*) FROM <table>` command.

You should end up with:

```
sqlite> SELECT COUNT(*) FROM Grades;
1745
sqlite> SELECT COUNT(*) FROM Student;
100
sqlite> SELECT COUNT(*) FROM GradePoints;
9
sqlite>
```

### Filtering data

Now that we have more grade data then we could reasonably be expected to look at it one go, we need to start filtering it to subsets.

We can provide a conditional clause to our select statements to filter data to certain subsets. For example, to find all the grades for StudentID 42:

```
SELECT * FROM Grades WHERE StudentID = 42;
```

Or we can find all grades for a SWEN course (the percentage character is the wildcard operator):

```
SELECT * FROM Grades WHERE Course LIKE "SWEN%";
```

Question: can you find all the 200 level courses only using `LIKE`? Why or why not? If not, what would you change to allow us to do this?

Exercise: can you combine a join with a where clause to return all student ids that got a grade starting with an A or end with a minus (i.e. you must use the grade label property rather than listing the corresponding grade points). Try add another join to return the student names as well.

### Aggregating data

We can also aggregate our data using either aggregate functions, or adding a `group by` clause to our query.

You've already seen your first aggregating function, `COUNT()`. This function takes a set of rows and aggregates them into a single result row, whose value is the number of rows aggregated. [SQLite also supports a few other functions, like SUM or AVG](http://www.sqlite.org/lang_aggfunc.html).

We can use the `AVG` function to find an overall grade point average:

```
SELECT AVG(GradePoint) FROM Grades;
```

You can use `GROUP BY` clauses to perform aggregation over certain attributes of a table. For example, if we wanted to find the grade point average for each of year of data we can issue the query:

```
SELECT Year, AVG(GradePoint) FROM Grades GROUP BY Year;
```

You can have multiple columns included in a grouping clause, and can combine them with where clauses to filter the data before it is grouped.

Exercise: Write a query that returns the grade point average for each COMP course since 2012.

Exercise: Use the `min()` aggregate function to find the course with the lowest overall GPA (you're going to need to combine two selects to do this, one for the averages, and one for the minimum).

Exercise: Write a query that uses a student id to return an "academic transcript" of (Name, Course, Year, Grade label) in descending order by year (this requires joining all three tables).

Exercise: Find the names of the students that got an A+ in COMP261.

### Checkpoint

Hopefully by now you have an understanding of how a relational model is laid out, and can be applied to concrete domain model like a student database. You should have the basics down in terms of selecting, joining, filtering and aggregating data. These basic tools go a long way to building more complex applications and reporting systems over more complicated stores of data.

I have no idea how much time we have left for these exercises, so this point might be a good place to call it a night. From these simple examples you should be able to explore more about relational databases in your spare time. I would recommend looking at starting up a rails project and understanding how the ruby (and rails) ecosystem is used to manage model driven design in terms of rake and migrations. If you're on windows or interested in moving into the C# area (maybe you want to work at Xero or Trademe) then I would recommend getting IIS express, a copy of SQL server express, and working through a MVC5 tutorial using the entity framework and seeing how model driven development works on the Microsoft stack. It would also be helpful to do both and compare the strengths and weaknesses of the two systems!

### Extra things of interest (or perhaps just more things to do while you wait for the pizza to get here because I horribly underestimated how quickly you would get through the first bit)

Looking up data quickly in a database is a very important aspect of using a relational database. In addition to the core table structure database engines maintain [indices](http://en.wikipedia.org/wiki/Database_index) that allow for O(log n) look up of values.

When you issue a query to a database system, an optimiser engine will attempt to devise a _query plan_ that most efficiently returns the data you're looking for. You can ask your engine to explain the actual query strategy it uses for a given query by prefixing the query with `EXPLAIN QUERY PLAN`. For example, try these queries:

```
EXPLAIN QUERY PLAN SELECT StudentID FROM Grades WHERE StudentID = 42;
EXPLAIN QUERY PLAN SELECT StudentID, GradePoint FROM Grades WHERE StudentID = 42;
EXPLAIN QUERY PLAN SELECT StudentID FROM GRADES WHERE StudentID BETWEEN 40 AND 45;
EXPLAIN QUERY PLAN SELECT GradePoint FROM GRADES WHERE GradePoint = 9;
```

Notice where the engine was able to use a covering index lookup, a normal index lookup, and a full table scan.

If you've taken an algorithms class you should hopefully know what a B-tree is (otherwise [the wikipedia article would be a good start](http://en.wikipedia.org/wiki/B-tree)). An index in a database is essentially a B-tree over certain attributes, which allows quicker look ups for queries over those attributes.

A primary key always forms an index over those attributes used in the key (that's why the first three of those query plans were able to exploit an index despite us not explicitly adding one to our table).

Indices are an optimisation that sacrifices memory for query speed.
Because we need to store the values from the attributes of the index,
we end up duplicating entries of data. This also means that when we
are doing a lot of writes to a database there is an additional overhead
in maintaining a well balanced tree.

However the benefit is that sometimes we can get all the data we need
for a query from the index itself, without having to actually hit the
table itself. For example in this query:

```
sqlite> EXPLAIN QUERY PLAN SELECT StudentID FROM Grades WHERE StudentID = 42;
0|0|0|SEARCH TABLE Grades USING COVERING INDEX sqlite_autoindex_Grades_1 (StudentID=?) (~10 rows)
```

Because we are selecting a subset of the primary key, this query is
_covered_ by an index. This means that we can quickly retrieve the
data, and we get a fairly accurate estimation of the size of the
data (~10 rows) because we know its going to be directly proportional
to the fill factor and depth of our B-tree.

When we do a query that is not exclusively over indexed attributes
like:

```
sqlite> EXPLAIN QUERY PLAN SELECT StudentID, GradePoint FROM Grades WHERE StudentID = 42;
0|0|0|SEARCH TABLE Grades USING INDEX sqlite_autoindex_Grades_1 (StudentID=?) (~10 rows)
```

Then we cannot use the covering index, because we need to actually read
the extra value (GradePoint, here) from the row on disk.

```
sqlite> EXPLAIN QUERY PLAN SELECT GradePoint FROM Grades WHERE GradePoint = 9;
0|0|0|SCAN TABLE Grades (~100000 rows)
```

Now when we select a value using a non-indexed filter in the WHERE clause
we don't use any index at all -- instead we need to do a table scan. A
table scan is just a linear scan of all the rows in the table, obviously
the slowest way of retrieving the data, and additionally difficult to
estimate (here we can see the optimiser thinks there's around a hundred
thousand rows -- off by a factor!)

Try explaining a plan where you join onto one of the other tables that
don't have a composite primary key -- you should see that the lookup
is very precise.

In more powerful database systems the query planning tools are very
sophisticated, and the management and tuning of databases and their
queries becomes very complicated. It's possible to specialise in the
managament and tuning of databases and become a [database administrator](http://dbareactions.com/).

### Transactions

In order for a database to meet the atomicity and isolation guarantees
from the ACID principles, all commands that have a visible effect (like
an insert, update or delete) need to occur inside a transaction.

A transaction groups one to many operations, which are then committed
(or rolled back) atomically.

For example, you can open a transaction, alter some data, but then
rollback the transaction and the data stays in its normal state:

```
sqlite> BEGIN TRANSACTION;
sqlite> UPDATE GradePoints SET Label = "Z" WHERE GradePoint = 9;
sqlite> SELECT * FROM GradePoints WHERE GradePoint = 9;
9|Z
sqlite> ROLLBACK;
sqlite> SELECT * FROM GradePoints WHERE GradePoint = 9;
9|A+
```

If you have an open transaction and an error occurs, then the
transaction is automatically rolled back for you. While perhaps
not an error you can get the idea by starting a transaction and
modifying the data, then just exiting the session without committing.
When you re-connect your session, the statements issued in the
transaction won't have had an effect on the data.

Transactions become particularly important when you're dealing
with multiple users, as isolation guarantees generally mean that
the data being manipulated needs to be locked for the duration
of the transaction.

When you don't have any locks on a transaction, then several kinds
of inconsistent phenomena can occur:

  * Dirty read: a dirty read occurs if you are allowed to read data
from a table that hasn't been committed in another transaction. This
means that the transaction could be rolled back, and the data you
read will never have existed!
  * Non-repeatable read: basically what the name says, this can occur
if you issue two select statements in a transaction, and between the
two selects another transaction has changed the value of the data
being selected.
  * Phantom reads: these are similar to non-repeatable reads, but
occur when the query is over a range (e.g. WHERE Id BETWEEN 1 AND 10)
and another transaction inserts or deletes a row within that range,
so that the two queries over the range return different results.

The wikipedia page for [isolation](http://en.wikipedia.org/wiki/Isolation_(database_systems))
goes into more depth about how you can specify isolation levels that
stop these from occurring.

Understanding isolation levels and the locking affect they have is
very important when you are developing an application that needs to be
used simultaneously by many clients. A database like sqlite however is
generally designed to be used by a single client, and as such has a very
broad approach to locking (it just locks all tables on a write). This
makes it appropriate for something like an app that's only ever being
accessed by the host phone, but relatively terrible for a "cloud"
application, where you have many thin clients to a central service.

Try opening up two terminal tabs side by side and running two sessions
and see how the interaction between two transactions works in sqlite.
Try introduce a third session and see if you can introduce a deadlock
by having each session waiting on another!