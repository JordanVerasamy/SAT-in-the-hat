#lang racket

;; a Literal is an:
;; integer x with 1+ representing variables and -1- representing negated variables
;; which is true iff (contains? assignment (list x true))

;; a Clause is a:
;; (listof Literal)
;; which is true iff any of its Literals are true.

;; a CNF is a:
;; (listof Clause)
;; which is true iff all of its Clauses are true.

;; an Assignment is a:
;; (list int)
;; where the int is a variable that is true (so 4 means variable 4 is true, whereas -2 means variable 2 is false)

(define (contains? value list)
  (cond
    [(empty? list)
     false]
    [(equal? (first list) value)
     true]
    [else
     (contains? value (rest list))]))

(define (no-unassigned-variables? assignment CNF)
  (cond
    [(empty? CNF)
     true]
    [(empty? (first CNF))
     (no-unassigned-variables? assignment (rest CNF))]
    [(or (contains? (first (first CNF)) assignment) (contains? (* -1 (first (first CNF))) assignment))
     (no-unassigned-variables? assignment (append (list (rest (first CNF))) (rest CNF)))]
    [else
     false]))

(define (clause-is-true? assignment clause)
  (cond
    [(empty? clause)
     false]
    [(contains? (first clause) assignment)
     true]
    [else
     (clause-is-true? assignment (rest clause))]))

(define (CNF-is-true? assignment CNF)
  (equal? CNF (filter (lambda (x) (clause-is-true? assignment x)) CNF)))

(define (solve-SAT assignment CNF)
  (cond
    ;;base case
    [(no-unassigned-variables? assignment CNF) 
     (CNF-is-true? assignment CNF)]
    ;;Pure Literal Elimination
    [(not (equal? false (get-pure-literal CNF)))
     (solve-SAT (append assignment (get-pure-literal CNF)) CNF)]
    ;;Unit Propagation
    [(not (equal? false (get-unit-literal CNF)))
     (solve-SAT (append assignment (get-unit-literal CNF)) CNF)]
    ;;Backtrack
    [else
     (or (solve-SAT (append assignment (get-unknown-literal CNF)) CNF)
         (solve-SAT (append assignment (* -1 (get-unknown-literal CNF))) CNF))]))
     





