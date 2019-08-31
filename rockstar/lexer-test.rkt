#lang br

(require "lexer.rkt" brag/support rackunit)

;; Unit tests for lexer

(define (lex str)
  (apply-port-proc rockstar-lexer str))

;; Empty

(check-equal? (lex "") empty)

;; Comment

(check-equal?
 (lex "(What about Logic?)")
 (list (srcloc-token (token 'COMMENT #:skip? #t)
                     (srcloc 'string 1 0 1 19))))

(check-equal?
 (lex "(Are we taking about \"Mixtape Logic\" or \"Album Logic\"?)")
 (list (srcloc-token (token 'COMMENT #:skip? #t)
                     (srcloc 'string 1 0 1 55))))

;; String

(check-equal?
 (lex "\"Hello San Francisco\"")
 (list (token 'STRING "Hello San Francisco")))

(check-equal?
 (lex "\"\\\"Hello\\\" \\\"San\\\" \\\"Francisco\\\"\"")
 (list (token 'STRING"\"Hello\" \"San\" \"Francisco\"")))

;; Newline

(check-equal?
 (lex "\n\n\n")
 (list (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 1 0 1 1))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 2 0 2 1))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 3 0 3 1))))

;; Reserved terms

(check-equal?
 (lex "mysterious")
 (list (srcloc-token (token "mysterious" "mysterious")
                     (srcloc 'string 1 0 1 10))))

(check-equal?
 (lex "taking")
 (list (srcloc-token (token "taking" "taking")
                     (srcloc 'string 1 0 1 6))))

(check-equal?
 (lex "true")
 (list (srcloc-token (token "true" "true")
                     (srcloc 'string 1 0 1 4))))

;; Whitespace

(check-equal?
 (lex " ")
 (list (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 0 1 1))))

(check-equal?
 (lex "\t")
 (list (srcloc-token (token 'WHITESPACE "\t" #:skip? #t)
                     (srcloc 'string 1 0 1 1))))

;; Simple variable

(check-equal?
 (lex "X")
 (list (srcloc-token (token 'SIMPLE-VAR "x")
                     (srcloc 'string 1 0 1 1))))

(check-equal?
 (lex "phone")
 (list (srcloc-token (token 'SIMPLE-VAR "phone")
                     (srcloc 'string 1 0 1 5))))

;; Common variable

(check-equal?
 (lex "My phone")
 (list (srcloc-token (token 'COMMON-VAR "my-phone")
                     (srcloc 'string 1 0 1 8))))

(check-equal?
 (lex "An apple")
 (list (srcloc-token (token 'COMMON-VAR "an-apple")
                     (srcloc 'string 1 0 1 8))))

;; Proper variable

(check-equal?
 (lex "Customer ID")
 (list (srcloc-token (token 'PROPER-VAR "Customer-Id")
                     (srcloc 'string 1 0 1 11))))

;; Pronoun

(check-equal?
 (lex "It")
 (list (srcloc-token (token 'PRONOUN "it")
                     (srcloc 'string 1 0 1 2))))

;; Number

(check-equal?
 (lex "123")
 (list (srcloc-token (token 'NUMBER 123)
                     (srcloc 'string 1 0 1 3))))

(check-equal?
 (lex "1.23")
 (list (srcloc-token (token 'NUMBER 1.23)
                     (srcloc 'string 1 0 1 4))))