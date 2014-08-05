 -- welcome
 -- what level of knowledge do we have?
 -- relational, 70s, codd is cool
 -- sets of tuples of attributes
 -- tables of rows of columns
 -- sets -> uniqueness -> keys (as in key - value)
 -- redundancy, 70s constraints, normalisation
 -- joins, sets
 -- elegance, longevity (grounded in mathematics)
 -- real world constraints in addition to theory
 -- e.g. how does our persistent storage handle
    crashes?
 -- what if two users are manipulating data at
    the same time (e.g. account _transactions_)
 -- there are HEAPS of possible ways things can
    go wrong in a distributed system (i.e. when
    you allow concurrent actions)
 -- ACID semantics
 -- ACID is restrictive, particularly in terms of
    concurrent users... sometimes too restrictive
    when we are designing highly available systems
    (e.g. take a look at alternative systems like riak
     or cassandra)
 -- that's all (the theoretical stuff) folks!
 -- we can interact with the database using another
    standard