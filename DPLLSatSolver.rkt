#lang racket


;; a Literal is one of:
;; -true
;; -false
;; -integer with 1+ representing variables and -1- representing negated variables

;; a Clause is a:
;; (listof Literal)
;; which is true iff any of its Literals are true.

;; a CNF is a:
;; (listof Clause)
;; which is true iff all of its Clauses are true.

;; an Assignment is a:
;; (listof (list int boolean))
;; where the int is a variable and the bool is the value we've assigned to it

(define (solve-SAT assignment CNF)
  (cond
    ;;base case
    [(no-unassigned-variables? assignment CNF) 
     (CNF-is-true? assignment CNF)]
    ;;Pure Literal Elimination
    [(not (equal? false (get-pure-literal CNF)))
     (solve-SAT (append assignment (list (get-pure-literal CNF) true)) CNF)]
    ;;Unit Propagation
    [(not (equal? false (get-unit-literal CNF)))
     (solve-SAT (append assignment (list (get-unit-literal CNF) true)) CNF)]
    ;;Backtrack
    [else
     (or (solve-SAT (append assignment (list (get-unknown-literal CNF) true)) CNF)
         (solve-SAT (append assignment (list (get-unknown-literal CNF) false)) CNF))]))