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
       (init-var GLOBAL-VAR-ID) ...
       REAL-STATEMENT ...
       (void))))