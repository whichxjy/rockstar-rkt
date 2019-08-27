#lang br

(require "lexer.rkt" brag/support rackunit)

;; Unit tests for lexer

(define (lex str)
  (apply-port-proc rockstar-lexer str))

;; Empty

(check-equal? (lex "") empty)

;; Newline

(check-equal?
 (lex "\n\n\n")
 (list (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 1 0 1 1))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 2 0 2 1))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 3 0 3 1))))

;; Whitespace

(check-equal?
 (lex " ")
 (list (srcloc-token (token 'WHITESPACE " ")
                     (srcloc 'string 1 0 1 1))))

(check-equal?
 (lex "\t")
 (list (srcloc-token (token 'WHITESPACE "\t")
                     (srcloc 'string 1 0 1 1))))

;; String

(check-equal?
 (lex "(What about Logic?)")
 (list (srcloc-token (token 'COMMENT #:skip? #t)
                     (srcloc 'string 1 0 1 19))))

(check-equal?
 (lex "(Are we taking about \"Mixtape Logic\" or \"Album Logic\"?)")
 (list (srcloc-token (token 'COMMENT #:skip? #t)
                     (srcloc 'string 1 0 1 55))))

;; Number

(check-equal?
 (lex "123")
 (list (srcloc-token (token 'NUMBER 123)
                     (srcloc 'string 1 0 1 3))))

(check-equal?
 (lex "1.23")
 (list (srcloc-token (token 'NUMBER 1.23)
                     (srcloc 'string 1 0 1 4))))