okay cool so uh welcome to sql101 with me, kieran

i work at xero as a software engineer, and am actually a graduate of both the
swen degree here at vic, as well as the summer of tech program itself -- i was
actually sat listening to this talk a few years back, so hopefully y'all will
find it useful

uh so i guess before we just jump into it we'll just try and figure out sort of
what the skill level is in the room as it were.

so like, how many people here know like, conceptually, what a relational
database is?

and like, how many people have actually worked with a relational database
before? like postgres, mysql or microsoft sql server or something?

aight aight aight

so i guess what we're going to be talking about today is uh relational databases

and so they sort of stemmed from this thing called the relational model that
this cool dude invented. he's edgar codd and basically he was hanging out back
in like the 70s when he worked for like, IBM or whatever

and so back then they were just beginning to actually have like, large and
persistent stores of data and so they were trying to figure out like a good
approach to getting a whole bunch of cross referenced data organised while
minimising like duplication and unnecessary data

so basically what he came up was this idea of like a "relation" which was
basically a set of tuples, like a collection of smaller arrays of related data,
where those smaller collections all had a common set of attributes

and so it ends up looking a little like this, conceptually, where you have like
a tuple of attributes at the top that defines the pattern that everything
follows, then you have this big set of rows with this same pattern, where each
of those rows is like, an individual example of the general pattern

and so i guess that's like the sort of theoretical model that he's using, and
that got implemented in the form of relational databases. so now we can take
some domain object and represent its data in like this relational model and
store that efficiently on disk

so like, the example we're going to be using today is a grades database, like,
records a student and a course and a grade sort of thing.

so in a modern database the concept of the "set of values" sort of looks like
this, which we call a table, and then in the table you have columns which define
those attributes, then going across we have individual rows that represent sort
of separate entity in this table in each row

uh and so when i've been describing this thing as a set i actually mean like a
proper set, in the sense that there is a uniqueness guarantee here that says
that each of these rows have to be different from each other -- and sort of if
you flip that around it means they all have to be uniquely identifiable

so what we do is we define this thing called a "key", which is basically a
subset of the columns that we say can be used to uniquely identify a row

so in our case we have the id, name, and the course being the primary key so
that's basically saying like, student id, a name, and a course then we can find
exactly that row -- and we'll sort of see later on why we care about being able
to quickly find things based on a smaller subset of these attributes once we get
to the practical section

buuut this is sort of not a very good model we've developed here, because
there's a bunch of duplication in our table, like, half these values are
actually just there to describe an individual student, which is sort of crazy
redundant and also really uh fragile right, because it's like, we have to make
sure that all of these values are always in sync with one another

and so if we have to update one of these rows then we have to update all of them
at the same time just to make sure we aren't going to have anything inconsistent
going on -- and so the way we describe this data is labelling it "denormalised"

so codd and some other people back in the day basically wanted to remove this
redundance in your models, and they came up with these things called "normal
forms" which basically can be used to describe how "normalised" the data is

so this is currently in the first normal form, which is sort of the lowest
possible level of normalisation -- and so in general what that means is that our
relations aren't quite cohesive enough, and we're going to have to do a little
uh refactoring i guess to split some of this data out

and so what we can do is derive two tables here, one that describes students and
another one that describes grades -- and we can see that they have this little
relation in here that basically joins these two together, and we call that a
"foreign key" relation

and so you can see that this is called foreign key because the target columns
over here basically have to be the primary key, because that's what we have to
use to uniquely identify basically the student each of these grades is
associated with

but now that we've split these rows into two different tables if we want to
be able to do something with information from either table that doesn't appear
in the intersecting columns, like, find all the grades for a student by name or
something then we need to be able to join these two tables back together

and so this is another place where that nice kind of theoretical model comes
into play again because these joins are basically just set operations, and so
when we want to join these two tables back together based on the student id
thats called an inner join -- and so when you look at what that looks like, it's
literally just the intersection of the two sets

and so all of the join operations basically just turn out to be these set
operations between the relations, so like there's a thing called left outer
join, which in our case would take the all the rows from the students table, and
append all the grades that they have in the other table, if they exist, and so
that just ends up looking like this basically

and so we basically have this really elegant model that codd came up with way
back in you know the 70s or whatever that basically allows us to store data in a
consistent way, with very little redundancy or duplication, and then operate
over that data in a really pleasant way, which is like, pretty amazing when you
think about all the other sort of major paradigm shifts that have occurred in
computing over that period -- it sort of rates this right up there with other
sort of really fundamental pieces of computer science like with C and unix and
stuff right

uh but then there's like this sort of other world that databases inhabit which
some people like to call like, the real world or whatever -- and that's where we
have a bunch of nasty failure cases and weird interactions that are possible
when we actually have these systems running in production, and they're another
sort of major area of strength for any decent relational database system

so for example these databases need to be persistent storage outside of the
runtime of our application so we run into these questions around like, what
happens when our operating system crashes, or someone you know trips over a plug
or something like that right -- like in order to sort of have these guarantees
around like the referential integrity of the foreign keys and stuff we need to
have some pretty strong rules in place to handle this

and so another major one you have is when you get multiple people operating on
the same data at once -- and so like an example from xero would be when you have
a single outstanding invoice of $100, and like we're just a web app right so you
can have multiple people on different computers interacting with these documents
at the same time

so like imagine two people try and record a payment at the same time for
different amounts on that invoice, and you know in an ideal world that will
figure out it should have 25 remaining, but you know in a naive design that
could end up with 50 or 75 depending on you know, which one of those writes
basically one that race condition and got there first

and so thats a single example of a more insidious problem here which is
referred to in general as multi-user isolation, and there are actually a bunch
of different problems around how these interactions occur in terms of exactly
when data becomes visible to other users and they've all got these crazy names
like dirty reads, phantom reads, non-repeatable reads

basically the whole situation gets kind of complicated pretty quickly

but luckily for us, all relational models follow these principals called ACID
which are basically some guarantees around how the database will behave in these
sort of annoyingly wrinkly edge cases

the first one is atomicity -- and so the idea here is that an atom is supposed
to be like, the smallest indivisible element in a system right -- and so the
idea of having an atomic database basically says that transactions within the
database must be atomic. either the whole thing succeeds or the whole thing
fails. and so this kind of guarantee helps us out a lot with that issue of what
happens if the system crashes underneath us right, because we now have this
guarantee that we still have referential integrity because we know no writes can
sort of just be half done if that makes sense

the next one is consistency and its quite closely related, but it basically says
that if you make some assertions about what a consistent state is in your
database with like primary keys for uniqueness, and foreign keys for that
referential integrity, then this principle basically says you can only ever
transition from consistent states to new consistent states.

so if you had two writes, one that inserted a grade and another that inserted a
student, its not possible for you to insert that grade before the student
exists, and likewise you can't delete a student when they still have grades,
unless you explicitly make that delete cascade back to the referring entities

the next one is isolation -- and this is basically aimed at that multi-user
problem i was talking about, where the idea is that all operations in a database
need to be able to be made serializable so that broadly means that you can
always put things into the right order so that two transactions running at the
same time can interact with one another

and finally the last one is about durability, and this is a key one for a
persistent data store, but it basically says that any acknowledged write in the
database needs to end up on disk -- so it should be impossible for example for
me to update a record in memory, have the system completely crash, then be
unable to retrieve that updated row from the database when i restart

and so those four principles make some pretty strong assertions about the
consistency of the database basically, and that helps us as developers of
applications basically in knowing that our data we're working on is consistent.

its probably also worth mentioning at this point that these are actually quite
restrictive in the way they work, so there is this sort of alternative movement
where people are trying to figure out ways to write databases that aren't so
hard-core on the consistency front so they can improve things like availability
and latency and stuff. buuut that's basically another talk in its own right so
we can't really talk about it now -- just be aware that it exists

uh and so now that we've sort of got passed the theoretical sort of
underpinnings to these systems we can talk about how we actually interact with
the databases

and so basically there's this thing that's called the structured query language
-- and thats a standard language that basically says how to operate on relations
and stuff. and so this standard is basically implemented by different vendors
for their products, so you end up with like transact SQL for MSSQL server, and
then postgres and mysql have their own systems, but they all share basically the
same common operations

so like at the coarse level you can obviously make new tables then delete them,
and those operations are just called create table, and then drop table

uh and then you have methods for manipulating the records in the table and so
these are pretty straight up -- you can insert, delete, or update which is all
pretty straightforward

then you get the method of actually reading data out of the table, and thats
done with these things called "selects" -- and i guess in the literature you
would refer to them as projections of the sets. basically there's this general
pattern where you select some rows from a table where those values satisfy a
certain condition. so you might be like select grade from grades where year is
2014 or whatever

and so those are basically the core tools in your toolbox right -- inserting,
updating deleting and reading. and so for this bit i didn't really want to talk
that much about them because you've probably already heard me talk for way too
long already, so we can just jump straight into working on some exercises
