#lang br/quicklang

(define-macro (r-module-begin (r-program STATEMENT ...))
  (with-pattern
      ([(NOT-FUNC-DEF-STATEMENT ...)
        (find-not-func-def-statements #'(STATEMENT ...))]
       [(GLOBAL-VAR-ID ...)
        (find-global-var-ids #'(NOT-FUNC-DEF-STATEMENT ...))]
       [(REAL-STATEMENT ...)
        (insert-init-statements #:stmt-stxs #'(STATEMENT ...)
                                #:global-var-ids #'(GLOBAL-VAR-ID ...))])
    #'(#%module-begin
       (r-init-var GLOBAL-VAR-ID) ...
       REAL-STATEMENT ...
       (void))))

(begin-for-syntax
  (require racket/list
           syntax/stx)
  ;; initialize all variables
  (define (init-all-variables target-stx global-vars)
    ;; distinguish r-func-def statements from other types of statements
    (define-values not-func-def-stxs func-def-stxs
      (for/lists (not-func-def-stxs func-def-stxs)
                 ([stx (in-list (stx->list target-stx))]
                  #:when (syntax-property stx 'r-statement))
        (cond
          [(eq? (syntax->datum (stx-car stx)) 'r-func-def)
           ;; stx is function definition statement
           (values empty stx)]
          [else
           ;; stx isn't function definition statement
           (values stx empty)])))
    ;; find all ids of non-global variables from not-func-def-stxs
    (define non-global-vars
      (remove-duplicates
       (for/list ([stx (in-list (stx-flatten not-func-def-stxs))]
                  #:when (syntax-property stx 'r-var))
         stx)
       #:key syntax->datum))