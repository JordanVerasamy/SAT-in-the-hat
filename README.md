DPLL Boolean Satisfiability Solver
==================================

This is a naive implementation of the DPLL algorithm for solving boolean expressions in CNF. In general, we just try "guessing" that an unknown variable is true, and recursively trying to solve the resulting expression - if that fails, then "guess" that the variable was false instead. If this guessing was our only strategy, then we would have an average case take O(2^n) time. However, we have some tactics that let us skip "guessing" and know for sure what certain variables must be.

These tactics are:

1. Pure Literal Elimination:

If any variable x exists only in its positive form x, then we definitely know that setting x to true will never make the boolean expression false. The same applies to variables x who only appear in their negative form -x: setting x to false will never make the expression false.

2. Unit Propagation:

A unit clause is a clause who contains one unknown variable x and all other variables are false. Whenever we encounter a unit clause while solving a CNF, we know that the only way the CNF will be true is to make x true.

Using these tactics often cascades - propagating a unit clause gives us more information which allows us to find another unit clause, etc. This means that large portions of the search often occur due to these tactics rather than backtracking, which means the average case of this solver is much more efficient than O(2^n).
