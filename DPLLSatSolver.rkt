#lang racket

;; --------------------------------------------------------------------
;; DPLL SAT SOLVER
;; --------------------------------------------------------------------
;; Jordan Verasamy
;; December 2014
;; --------------------------------------------------------------------
;; Uses the DPLL boolean satisfiability algorithm to solve boolean
;; expressions stated in conjunctive normal form (CNF).
;; --------------------------------------------------------------------


;; Type Definitions:
;; --------------------------------------------------------------------

;; a Literal is an:
;; integer x with x > 0 representing variable x being true and -x representing variable x being false
;; A Literal is true iff (contains? x assignment)

;; a Clause is a:
;; (listof Literal)
;; which is true iff any of its Literals are true.

;; a CNF is a:
;; (listof Clause)
;; which is true iff all of its Clauses are true.

;; an Assignment is a:
;; (list int)
;; where the int is a variable that is true (so 4 means variable 4 is true, whereas -2 means variable 2 is false)


;; Algorithm:
;; --------------------------------------------------------------------

;; This is a naive implementation of the DPLL algorithm for solving boolean expressions in CNF.
;; In general, we just try "guessing" that an unknown variable is true, and recursively trying to
;; solve the resulting expression - if that fails, then "guess" that the variable was false instead.
;; If this guessing was our only strategy, then we would have an average case take O(2^n) time.
;; However, we have some tactics that let us skip "guessing" and know for sure what certain variables must be.

;; These tactics are:

;; 1. Pure Literal Elimination:
;; If any variable x exists only in its positive form x, then we definitely know that setting x to true will
;; never make the boolean expression false. The same applies to variables x who only appear in their negative
;; form -x: setting x to false will never make the expression false.

;; 2. Unit Propagation:
;; A `unit clause` is a clause who contains one unknown variable x and all other variables are false. Whenever
;; we encounter a unit clause while solving a CNF, we know that the only way the CNF will be true is to make x true.

;; Using these tactics often cascades - propagating a unit clause gives us more information which allows us
;; to find another unit clause, etc. This means that large portions of the search often occur due to these
;; tactics rather than backtracking, which means the average case of this solver is much more efficient than O(2^n).

;; --------------------------------------------------------------------


;; contains: X (listof X) -> Boolean
;; Returns true if and only if `list` contains `value`
(define (contains? value list)
  (cond
    [(empty? list)
     false]
    [(equal? (first list) value)
     true]
    [else
     (contains? value (rest list))]))


;; CNF-is-true: Assignment CNF -> Boolean
;; Returns true if and only if all clauses in `CNF` are true when applying `assignment`
(define (CNF-is-true? assignment CNF)
  (local
    [
     
     (define (clause-is-true? assignment clause)
       (cond
         [(empty? clause)
          false]
         [(contains? (first clause) assignment)
          true]
         [else
          (clause-is-true? assignment (rest clause))]))]
    
    (equal? CNF (filter (lambda (x) (clause-is-true? assignment x)) CNF))))


;; get-unassigned-variables-clause: Assignment Clause -> (listof Literal)
;; Returns a list of all variables in `clause` that are not assigned in `assignment`
(define (get-unassigned-variables-clause assignment clause)
  (local
    [
     
     ;; helper function that returns the list I want but has duplicates
     (define (get-unassigned-variables-clause-helper assignment clause)
       (cond
         [(empty? clause)
          empty]
         [(or (contains? (first clause) assignment) (contains? (* -1 (first clause)) assignment))
          (get-unassigned-variables-clause-helper assignment (rest clause))]
         [else
          (cons (first clause) (get-unassigned-variables-clause-helper assignment (rest clause)))]))]
    
    (remove-duplicates (get-unassigned-variables-clause-helper assignment clause))))


;; get-unassigned-variables: Assignment CNF -> (listof Literal)
;; Returns a list of all variables in `CNF` that are not assigned in `assignment`
(define (get-unassigned-variables assignment CNF)
  (remove-duplicates
   (map (lambda (x) (cond
                      [(< x 0)
                       (* -1 x)]
                      [else
                       x]))
        (foldr append empty (map (lambda (x) (get-unassigned-variables-clause assignment x)) 
                                 CNF)))))


;; get-pure-literal: Assignment CNF -> (union Literal false)
;; if there exists some unassigned literal that appears only as x or only as -x in CNF, return that literal
;; otherwise, return false
(define (get-pure-literal assignment CNF)
  (local
    [
     
     ;; helper function that returns true if and only if `value` appears at least once as a positive
     (define (appears-true? value CNF)
       (cond
         [(empty? CNF)
          false]
         [(contains? value (first CNF))
          true]
         [else
          (appears-true? value (rest CNF))]))
     
     ;; helper function that returns true if and only if `value` appears at least once as a negative
     (define (appears-false? value CNF)
       (cond
         [(empty? CNF)
          false]
         [(contains? (* -1 value) (first CNF))
          true]
         [else
          (appears-false? value (rest CNF))]))
     
     ;; helper function that gets what we want by recursing on `unassigned` 
     (define (get-pure-literal-helper assignment CNF unassigned)
       (cond
         [(empty? unassigned)
          false]
         [(and (appears-true? (first unassigned) CNF) (not (appears-false? (first unassigned) CNF)))
          (first unassigned)]
         [(and (appears-false? (first unassigned) CNF) (not (appears-true? (first unassigned) CNF)))
          (* -1 (first unassigned))]
         [else
          (get-pure-literal-helper assignment CNF (rest unassigned))]))]
    
    ;; return the result of the helper, allowing `unassigned` to start as the list of
    ;; literals in `CNF` that are unassigned (i.e. don't occur in `assignment`
    (get-pure-literal-helper assignment CNF (get-unassigned-variables assignment CNF))))


;; get-unit-literal: Assignment CNF -> (union Literal false)
;; If `CNF` contains some clause of the form (FALSE v ... v FALSE v X) then return X
;; otherwise, return false
(define (get-unit-literal assignment CNF)
  (local
    [
     
     ;; helper function that returns true iff `clause` contains at least one true literal
     (define (contains-true? assignment clause)
       (cond
         [(empty? clause)
          false]
         [(contains? (first clause) assignment)
          true]
         [else
          (contains-true? assignment (rest clause))]))
     
     ;; helper function that gets what we want by recursing on `unassigned` 
     (define (get-unit-literal-clause-helper assignment clause unassigned)
       (cond
         [(and (not (contains-true? assignment clause)) (equal? 1 (length unassigned)))
          (first unassigned)]
         [else
          false]))
     
     ;; helper function that applies get-unit-literal-clause-helper by initializing 
     ;; `unassigned` using get-unassigned-variables-clause
     (define (get-unit-literal-clause assignment clause)
       (get-unit-literal-clause-helper assignment clause (get-unassigned-variables-clause assignment clause)))]
    
    ;; recursively look through `CNF` and find a unit literal (if it exists) using get-unit-literal-clause
    (cond
      [(empty? CNF)
       false]
      [(not (equal? false (get-unit-literal-clause assignment (first CNF))))
       (get-unit-literal-clause assignment (first CNF))]
      [else
       (get-unit-literal assignment (rest CNF))])))


;; solve-CNF: CNF -> (union Assignment false)
;; if a set of variable assignments satisfying CNF exists, return it
;; otherwise, return false
(define (solve-CNF CNF)
  (local
    [
     
     ;; all the main logic of the program - uses `assignment` as an accumulator, starting at empty and
     ;; gradually building up a list that assigns variables to be either true or false
     (define (solve-CNF-logic assignment CNF)
       (cond
         ;; base case: terminate here if there are no variables left to assign
         [(empty? (get-unassigned-variables assignment CNF))
          ;; if our set of assignments satisfy CNF, return that set
          ;; otherwise, return false
          (cond
            [(CNF-is-true? assignment CNF)
             assignment]
            [else
             false])]
         ;; Pure Literal Elimination: if any variable only appears as x, 
         ;; we can plug in "true" for x, and the opposite for -x and false
         [(not (equal? false (get-pure-literal assignment CNF)))
          (solve-CNF-logic (append assignment (list (get-pure-literal assignment CNF))) CNF)]
         ;; Unit Propagation: if any clause only has one unknown variable x and all other
         ;; variables are false, then we can plug in "true" for x
         [(not (equal? false (get-unit-literal assignment CNF)))
          (solve-CNF-logic (append assignment (list (get-unit-literal assignment CNF))) CNF)]
         ;; Backtrack: if the above tactics don't apply, then branch the search
         [else
          (or (solve-CNF-logic (append assignment (list (first (get-unassigned-variables assignment CNF))))
                               CNF)
              (solve-CNF-logic (append assignment (list (* -1 (first (get-unassigned-variables assignment CNF)))))
                               CNF))]))]
    
    ;; apply the logic function and pass empty as the initial state of the `assignment` accumulator
    (sort (solve-CNF-logic empty CNF) (lambda (x y) (< (abs x) (abs y))))))
