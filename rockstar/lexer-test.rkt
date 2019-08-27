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

;; Comment

(check-equal?
 (lex "(What about Logic?)")
 (list (srcloc-token (token 'COMMENT #:skip? #t)
                     (srcloc 'string 1 0 1 19))))

(check-equal?
 (lex "(Are we taking about \"Mixtape Logic\" or \"Album Logic\"?)")
 (list (srcloc-token (token 'COMMENT #:skip? #t)
                     (srcloc 'string 1 0 1 55))))

;; Reserved terms

(check-equal?
 (lex "mysterious")
 (list (srcloc-token (token "mysterious" "mysterious")
                     (srcloc 'string 1 0 1 10))))

(check-equal?
 (lex "let")
 (list (srcloc-token (token "let" "let")
                     (srcloc 'string 1 0 1 3))))

;; Number

(check-equal?
 (lex "123")
 (list (srcloc-token (token 'NUMBER 123)
                     (srcloc 'string 1 0 1 3))))

(check-equal?
 (lex "1.23")
 (list (srcloc-token (token 'NUMBER 1.23)
                     (srcloc 'string 1 0 1 4))))

;; String

(check-equal?
 (lex "\"Hello San Francisco\"")
 (list (srcloc-token (token 'STRING "Hello San Francisco")
                     (srcloc 'string 1 0 1 21))))