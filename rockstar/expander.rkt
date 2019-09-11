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
  #'(define ID r-mysterious))

;; =========== [Assignment] ===========

(define-macro (r-put VAL ID)
  #'(set! ID VAL))

(define-macro-cases r-let
  [(_ ID VAL) #'(set! ID VAL)]
  [(_ ID OP VAL)
   #'(let ([expr (cond
                   [(eq? OP '+) r-add-expr]
                   [(eq? OP '-) r-sub-expr]
                   [(eq? OP '*) r-mul-expr]
                   [(eq? OP '/) r-div-expr])])
       (set! ID (first (expr (list ID)
                             (list VAL)))))])

;; =========== [Increment & Decrement] ===========

(define-macro (r-increment ID UP ...)
  #'(set! ID (first (r-add-expr (list ID)
                                (list (length (list UP ...)))))))

(define-macro (r-decrement ID DOWN ...)
  #'(set! ID (first (r-sub-expr (list ID)
                                (list (length (list DOWN ...)))))))

;; =========== [Expression] ===========

(define-macro (r-expr VAL) #'(first VAL))

;; =========== [Boolean Expression] ===========

(define-macro-cases r-and-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(list (apply and (append LEFT RIGHT)))])

(define-macro-cases r-or-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(list (apply or (append LEFT RIGHT)))])

(define-macro-cases r-nor-expr
  [(_ VAL) #'VAL]
  [(_ LEFT RIGHT) #'(list (apply nor (append LEFT RIGHT)))])

(define-macro-cases r-not-expr
  [(_ VAL) #'VAL]
  [(_ _ VAL) #'(if (= (length VAL) 1)
                   (list (not (first VAL)))
                   (error "not: too much arguments"))])

;; =========== [Comparison Expression] ===========

(define-macro-cases r-cmp-expr
  [(_ VAL) #'VAL]
  [(_ LEFT OP RIGHT)
   #'(let ([cmp (lambda (left right)
                  (r-cmp left OP right))])
       (list (reduce cmp (append LEFT RIGHT))))])

(define (r-cmp left op right)
  (cond
    ;; <Mysterious> <op> Mysterious
    [(and (mysterious? left) (mysterious? right))
     (if (eq? op '==) #t #f)]
    ;; <Non-Mysterious> <op> Mysterious
    [(and (not (mysterious? left)) (mysterious? right))
     (if (eq? op '!=) #t #f)]
    ;; String <op> Number
    [(and (string? left) (number? right))
     (let ([left-num (string->number left)])
       (and left-num
            (r-cmp left-num op right)))]
    ;; String <op> Boolean
    [(and (string? left) (boolean? right))
     (let ([left-bool (string->boolean left)])
       (r-cmp left-bool op right))]
    ;; String <op> Null
    [(and (string? left) (null? right))
     (if (eq? op '!=) #t #f)]
    ;; Number <op> Boolean
    [(and (number? left) (boolean? right))
     (let ([left-bool (number->boolean left)])
       (r-cmp left-bool op right))]
    ;; Number <op> Null
    [(and (number? left) (null? right))
     (r-cmp left op 0)]
    ;; Boolean <op> Null
    [(and (boolean? left) (null? right))
     (r-cmp left op #f)]
    ;; Equality comparison for same type
    [(and (eq? op '==) (type=? left right))
     (equal? left right)]
    [(and (eq? op '!=) (type=? left right))
     (not (equal? left right))]
    ;; Ordering comparison for number
    [(and (number? left) (number? right))
     (let ([cmp (cond
                  [(eq? op '>) >]
                  [(eq? op '<) <]
                  [(eq? op '>=) >=]
                  [(eq? op '<=) <=])])
       (cmp left right))]
    ;; Ordering comparison for string
    [(and (string? left) (string? right))
     (let ([cmp (cond
                  [(eq? op '>) string>?]
                  [(eq? op '<) string<?]
                  [(eq? op '>=) string>=?]
                  [(eq? op '<=) string<=?])])
       (cmp left right))]
    [else
     (error "Fail to compare")]))

;; =========== [Comparison Operator] ===========
 
(define-macro r-is-equal-op #''==)
(define-macro r-is-not-equal-op #''!=)
(define-macro r-is-greater-op #''>)
(define-macro r-is-smaller-op #''<)
(define-macro r-is-great-op #''>=)
(define-macro r-is-small-op #''<=)
(define-macro r-is-not-greater-op #''<=)
(define-macro r-is-not-smaller-op #''>=)
(define-macro r-is-not-great-op #''<)
(define-macro r-is-not-small-op #''>)

;; =========== [Arithmetic Expression] ===========

(define-cases r-add-expr
  [(_ val) val]
  [(_ left right)
   (list (reduce r-add (append left right)))])

(define-cases r-sub-expr
  [(_ val) val]
  [(_ left right)
   (list (reduce r-sub (append left right)))])

(define-cases r-mul-expr
  [(_ val) val]
  [(_ left right)
   (list (reduce r-mul (append left right)))])

(define-cases r-div-expr
  [(_ val) val]
  [(_ left right)
   (list (reduce r-div (append left right)))])

;; =========== [Arithmetic Function] ===========

(define (r-add left right)
  (cond
    [(and (string? left) (string? right))
     (string-append left right)]
    [else
     (+ left right)]))

(define (r-sub left right)
  (- left right))

(define (r-mul left right)
  (cond
    [(and (integer? left) (string? right))
     (make-dup-string right left)]
    [(and (string? left) (integer? right))
     (make-dup-string left right)]
    [else
     (* left right)]))

(define (r-div left right)
  (/ left right))

;; =========== [Arithmetic Operator] ===========

(define-macro r-add-op #''+)
(define-macro r-sub-op #''-)
(define-macro r-mul-op #''*)
(define-macro r-div-op #''/)

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
(define (r-output val)
  (cond
    [(null? val)
     (newline)]
    [(boolean? val)
     (displayln (boolean->string val))]
    [else
     (displayln val)]))

;; =========== [Block] ===========

(define-macro (r-block STATEMENT ...)
  #'(begin STATEMENT ...))

;; =========== [Conditional] ===========

(define-macro-cases r-if
  [(_ COND TBLOCK)
   #'(when COND TBLOCK)]
  [(_ COND TBLOCK FBLOCK)
   #'(if COND TBLOCK FBLOCK)])

;; =========== [Loop] ===========

(define continue-ccs empty)

(define (push-cc! x)
  (set! continue-ccs (cons x continue-ccs)))

(define (pop-cc!)
  (define top-cc (first continue-ccs))
  (set! continue-ccs (rest continue-ccs))
  top-cc)

(define-macro (r-while COND BLOCK)
  #'(with-handlers ([break-loop-signal?
                     (lambda (exn-val)
                       (void (pop-cc!)))])
      (let/cc here-cc
        (void (push-cc! here-cc)))
      (unless COND
        (r-break))
      BLOCK
      (r-continue)))

(define-macro (r-until COND BLOCK)
  #'(with-handlers ([break-loop-signal?
                     (lambda (exn-val)
                       (void (pop-cc!)))])
      (let/cc here-cc
        (void (push-cc! here-cc)))
      (when COND
        (r-break))
      BLOCK
      (r-continue)))

(struct break-loop-signal ())

(define (r-break)
  (raise (break-loop-signal)))

(define (r-continue)
  (when (empty? continue-ccs)
    (error "continue without loop"))
  (define top-cc (first continue-ccs))
  (top-cc (void)))

;; =========== [Function] ===========

(define-macro (r-func-def FUNC-NAME VARS STATEMENT ...)
  #'(set! FUNC-NAME
          (lambda VARS
            (define return-val (mysterious))
            (with-handlers ([return-func-signal?
                             (lambda (exn-val)
                               (set! return-val (return-func-signal-val exn-val)))])
              STATEMENT ...)
            return-val)))

(struct return-func-signal (val))

(define (r-func-return val)
  (raise (return-func-signal val)))

(define-macro r-func-call #'#%app)

;; =========== [List] ===========

;; Value List
(define-macro (r-value-list VAL ...)
  #'(list VAL ...))

;; =========== [Type] ===========

;; Mysterious
(struct mysterious ())

(define-macro r-mysterious #'(mysterious))

;; Null
(define-macro r-null #''__null__)

(define (null? value)
  (eq? value '__null__))

;; Boolean
(define-macro r-true #'#t)
(define-macro r-false #'#f)

(define (boolean->string bool)
  (if bool "true" "false"))

;; Number
(define (number->boolean num)
  (if (= num 0) #f #t))

;; String
(define (string->boolean str)
  (if (string=? str "") #f #t))

(define (make-dup-string base-str times)
  (for/fold ([result ""])
            ([i (in-range times)])
    (string-append result base-str)))

;; Type checking
(define (type=? left right)
  (or (and (mysterious? left) (mysterious? right))
      (and (null? left) (null? right))
      (and (boolean? left) (boolean? right))
      (and (number? left) (number? right))
      (and (string? left) (string? right))))

;; =========== [Helper] ===========

(define (reduce func xs)
  (cond
    [(null? xs) null]
    [else
     (for/fold ([acc (first xs)])
               ([i (in-list (rest xs))])
       (func acc i))]))