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

;; Poetic constant literal

(check-equal?
 (lex "is true")
 (list (token 'BE-POETIC-CONSTANT "true")))

(check-equal?
 (lex "is nobody")
 (list (token 'BE-POETIC-CONSTANT "nobody")))

(check-equal?
 (lex "is mysterious")
 (list (token 'BE-POETIC-CONSTANT "mysterious")))

;; Poetic string literal

(check-equal?
 (lex "says Hello San Francisco!\n")
 (list (token 'SAY-SOMETHING "Hello San Francisco!")
       (token 'NEWLINE "\n")))

(check-equal?
 (lex "says Hello back\n")
 (list (token 'SAY-SOMETHING "Hello back")
       (token 'NEWLINE "\n")))

;; Poetic number literal

(check-equal?
 (lex "was a lovestruck ladykiller")
 (list (token 'BE-POETIC-NUMBER 100)))

(check-equal?
 (lex "was a dancer")
 (list (token 'BE-POETIC-NUMBER 16)))

(check-equal?
 (lex "is on the loose")
 (list (token 'BE-POETIC-NUMBER 235)))

(check-equal?
 (lex "were ice. A life unfulfilled; wakin' everybody up, taking booze and pills")
 (list (token 'BE-POETIC-NUMBER 3.1415926535)))

(check-equal?
 (lex "was without")
 (list (token 'BE-POETIC-NUMBER 7)))