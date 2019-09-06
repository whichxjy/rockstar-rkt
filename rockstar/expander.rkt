#lang br/quicklang

(define-macro (r-module-begin (r-program STATEMENT ...))
  (with-pattern
      ([(r-program REAL-STATEMENT ...)
        (init-all-variables #'(r-program STATEMENT ...) '())])
    #'(#%module-begin
       '(REAL-STATEMENT ...)
       (void))))
(provide (rename-out [r-module-begin #%module-begin]))

;; Phase 1
(begin-for-syntax
  (require racket/list
           syntax/stx)
  ;; initialize all variables
  (define (init-all-variables target-stx global-var-ids)
    ;; distinguish non-func-def statements from other func-def statements
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
             (datum->syntax #f
                            (format-datum '(r-init-var ~a)
                                          (syntax->datum var-stx))))
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