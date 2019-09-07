#lang br/quicklang

(provide (rename-out [r-module-begin #%module-begin])
         (matching-identifiers-out #rx"^r-" (all-defined-out)))

(define-macro (r-module-begin (r-program STATEMENT ...))
  (with-pattern
      ([(r-program REAL-STATEMENT ...)
        (init-all-variables #'(r-program STATEMENT ...) '())])
    #'(#%module-begin
       REAL-STATEMENT ...
       (void))))

;; Phase 1
(begin-for-syntax
  (require racket/list
           syntax/stx)
  ;; initialize all variables
  (define (init-all-variables target-stx global-var-ids)
    ;; distinguish non-func-def statements from func-def statements
    (define not-func-def-stxs
      (filter (lambda (stx)
                (and (syntax-property stx 'r-statement)
                     (stx-pair? stx)
                     (not (eq? (syntax->datum (stx-car stx)) 'r-func-def))))
              (stx->list target-stx)))
    ;; find all ids of called functions from not-func-def-stxs
    (define called-func-ids
      (remove-duplicates
       (for/list ([not-func-def-stx not-func-def-stxs]
                  #:when (and (stx-pair? not-func-def-stx)
                              (stx-pair? (stx-cdr not-func-def-stx))
                              (eq? (syntax->datum (stx-car not-func-def-stx))
                                   'r-func-call)))
         (stx-car (stx-cdr not-func-def-stx)))
       #:key syntax->datum))
    ;; find all ids of non-global variables from not-func-def-stxs
    (define non-global-var-ids
      (remove-duplicates
       (for*/list ([not-func-def-stx not-func-def-stxs]
                   [stx (in-list (stx-flatten not-func-def-stx))]
                   #:when (and (syntax-property stx 'r-var)
                               ;; not global-var-id
                               (not (findf (lambda (global-var-id)
                                             (eq? (syntax->datum global-var-id)
                                                  (syntax->datum stx)))
                                           global-var-ids))
                               ;; not called-func-id
                               (not (findf (lambda (called-func-id)
                                             (eq? (syntax->datum called-func-id)
                                                  (syntax->datum stx)))
                                           called-func-ids))))
         stx)
       #:key syntax->datum))
    ;; create init statements
    (define init-stmts
      (map (lambda (var-stx)
             #`(r-init-var #,var-stx))
           non-global-var-ids))
    ;; find the index of first statement in target-stx
    (define first-stmt-index
      (index-where (stx->list target-stx)
                   (lambda (stx)
                     (syntax-property stx 'r-statement))))
    ;; split target-stx into two parts
    (define-values (left-half right-half)
      (split-at (stx->list target-stx) first-stmt-index))
    ;; insert init statements to target-stx
    (define target-stx-with-init-stmts
      (append left-half init-stmts right-half))
    ;; process r-func-def in target-stx and return result
    (for/list ([stx (stx->list target-stx-with-init-stmts)])
      (cond
        [(and (stx-pair? stx)
              (eq? (syntax->datum (stx-car stx)) 'r-func-def))
         (init-all-variables stx
                             (append global-var-ids
                                     non-global-var-ids))]
        [else stx]))))

;; =========== [Initialize Variable] ===========

(define-macro (r-init-var ID)
  #'(define ID '__mysterious__))

;; =========== [Assignment] ===========

(define-macro (r-put VAL ID)
  #'(set! ID VAL))

;; =========== [Boolean Expression] ===========

(define-macro-cases r-and-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(and LEFT RIGHT)])

(define-macro-cases r-or-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(or LEFT RIGHT)])

(define-macro-cases r-nor-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(nor LEFT RIGHT)])

(define-macro-cases r-not-expr
  [(_ VAL) #'VAL]
  [(_ _ VAL) #'(not VAL)])

;; =========== [Comparison Expression] ===========

(define-macro-cases r-cmp-expr
  [(_ VAL) #'VAL])

;; =========== [Arithmetic Expression] ===========

(define-macro-cases r-add-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(+ LEFT RIGHT)])

(define-macro-cases r-sub-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(- LEFT RIGHT)])

(define-macro-cases r-mul-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(* LEFT RIGHT)])

(define-macro-cases r-div-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(/ LEFT RIGHT)])

;; =========== [Input & Output] ===========

;; Input
(define-macro-cases r-input
  [(_ "Listen")
   #'(let* ([str (read-line)]
            [num (string->number (string-trim str))])
       (or num str))]
  [(_ "Listen to" ID)
   #'(set! ID (let* ([str (read-line)]
                     [num (string->number (string-trim str))])
                (or num str)))])

;; Output
(define-macro (r-output VAL)
  #'(displayln VAL))

;; =========== [List] ===========

;; Value List
(define-macro-cases r-value-list
  [(_ VAL) #'VAL]
  [(_ VAL ...) #'(list VAL ...)])