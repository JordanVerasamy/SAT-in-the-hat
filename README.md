RackSATinator
==================================

This is a naive implementation of the DPLL algorithm for solving boolean expressions in CNF. In general, we just try "guessing" that an unknown variable is true, and recursively trying to solve the resulting expression - if that fails, then "guess" that the variable was false instead. If this guessing was our only strategy, then we would have an average case of O(2^n). However, we have some tactics that let us skip "guessing" and know for sure what certain variables must be.

These tactics are:

Pure Literal Elimination:

If any variable x exists only in its positive form x, then we definitely know that setting x to true will never make the boolean expression false. The same applies to variables x who only appear in their negative form -x: setting x to false will never make the expression false.

Unit Propagation:

A unit clause is a clause who contains one unknown variable x and all other variables are false. Whenever we encounter a unit clause while solving a CNF, we know that the only way the CNF will be true is to make x true.

Using these tactics often cascades - propagating a unit clause gives us more information which allows us to find another unit clause, etc. This means that large portions of the search often occur due to these tactics rather than backtracking, which means the average case of this solver is much more efficient than O(2^n).

Usage
=====

Make sure your booolean expression is written in CNF (AND of ORs) form. We are going to input a list of lists of variables, with the inner lists corresponding to OR clauses and the outer list corresponding to an AND operator. Assign an index number to each variable. Each time that that variable appears, replace it with its index number - negative if negated, positive if not negated. For example, suppose we have the CNF boolean expression

`(A v B v ~C) ^ (B v C) ^ (A v ~B) ^ (~A v ~C)`

Then I can enumerate the variables like so:

`A: 1`
`B: 2`
`C: 3`

Then write a list of lists corresponding to the expression, replacing every instance of A with 1, ~A with -1, and so on:

`(list (list 1 2 -3) (list 2 3) (list 1 -2) (list -1 -3))`

Using this list of lists as an input to solve-CNF returns the set of assignments that satisfies the expression.

`(solve-CNF (list (list 1 2 -3) (list 2 3) (list 1 -2) (list -1 -3)))`

which returns

`(list 1 2 -3)`

The sign on an index number corresponds to that variable's truth value. In other words, this should be interpreted as meaning, "Assign A to true, B to be true, and C to be false. Then the expression (A v B v ~C) ^ (B v C) ^ (A v ~B) ^ (~A v ~C) is true."

This works (and rather efficiently, too!) for _any_ boolean expression in CNF. Try it out!
