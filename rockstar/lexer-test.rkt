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
 (list (token 'COMMENT #:skip? #t)))

(check-equal?
 (lex "(Are we taking about \"Mixtape Logic\" or \"Album Logic\"?)")
 (list (token 'COMMENT #:skip? #t)))

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
 (list (token 'NEWLINE "\n")
       (token 'NEWLINE "\n")
       (token 'NEWLINE "\n")))

;; Reserved terms

(check-equal?
 (lex "taking")
 (list (token "taking" "taking")))

;; Whitespace

(check-equal?
 (lex " ")
 (list (token 'WHITESPACE " " #:skip? #t)))

(check-equal?
 (lex "\t")
 (list (token 'WHITESPACE "\t" #:skip? #t)))

;; Simple variable

(check-equal?
 (lex "X")
 (list (token 'SIMPLE-VAR "x")))

(check-equal?
 (lex "phone")
 (list (token 'SIMPLE-VAR "phone")))

(check-equal?
 (lex "Let X be with 10")
 (list (token 'Let "Let")
       (token 'WHITESPACE " " #:skip? #t)
       (token 'SIMPLE-VAR "x")
       (token 'WHITESPACE " " #:skip? #t)
       (token 'be "be")
       (token 'WHITESPACE " " #:skip? #t)
       (token 'with "with")
       (token 'WHITESPACE " " #:skip? #t)
       (token 'NUMBER 10)))

 ;; Common variable

 (check-equal?
  (lex "My phone")
  (list (token 'COMMON-VAR "my-phone")))

 (check-equal?
  (lex "An apple")
  (list (token 'COMMON-VAR "an-apple")))

 ;; Proper variable

 (check-equal?
  (lex "Customer ID")
  (list (token 'PROPER-VAR "Customer-Id")))

 ;; Pronoun

 (check-equal?
  (lex "It")
  (list (token 'PRONOUN "it")))

 ;; Mysterious

 (check-equal?
  (lex "mysterious")
  (list (token 'MYSTERIOUS "mysterious")))

 ;; Null

 (check-equal?
  (lex "nothing")
  (list (token 'NULL "nothing")))

 ;; Boolean

 (check-equal?
  (lex "true")
  (list (token 'BOOLEAN "true")))

 ;; Number

 (check-equal?
  (lex "123")
  (list (token 'NUMBER 123)))

 (check-equal?
  (lex "1.23")
  (list (token 'NUMBER 1.23)))