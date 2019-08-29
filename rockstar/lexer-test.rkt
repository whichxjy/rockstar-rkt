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
 (list (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 0 1 1))))

(check-equal?
 (lex "\t")
 (list (srcloc-token (token 'WHITESPACE "\t" #:skip? #t)
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

;; Single Quote

(check-equal?
 (lex "'''''")
 (list (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 0 1 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 1 2 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 2 3 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 3 4 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 4 5 1))))

(check-equal?
 (lex "''''s ")
 (list (srcloc-token (token 'QUOTE-S "''''s ")
                     (srcloc 'string 1 0 1 6))))

(check-equal?
 (lex "'s   ")
 (list (srcloc-token (token 'QUOTE-S "'s   ")
                     (srcloc 'string 1 0 1 5))))

(check-equal?
 (lex "s's   ")
 (list (srcloc-token (token 'LOWER-NAME "s")
                     (srcloc 'string 1 0 1 1))
       (srcloc-token (token 'QUOTE-S "'s   ")
                     (srcloc 'string 1 1 2 5))))

(check-equal?
 (lex "ss'ss ")
 (list (srcloc-token (token 'LOWER-NAME "ssss")
                     (srcloc 'string 1 0 1 5))
       (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 5 6 1))))

(check-equal?
 (lex "It's red")
 (list (srcloc-token (token "It" "It")
                     (srcloc 'string 1 0 1 2))
       (srcloc-token (token 'QUOTE-S "'s ")
                     (srcloc 'string 1 2 3 3))
       (srcloc-token (token 'LOWER-NAME "red")
                     (srcloc 'string 1 5 6 3))))

(check-equal?
 (lex "abc''''d\n")
 (list (srcloc-token (token 'LOWER-NAME "abcd")
                     (srcloc 'string 1 0 1 8))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 1 8 9 1))))

(check-equal?
 (lex "abcd''''\n")
 (list (srcloc-token (token 'LOWER-NAME "abcd")
                     (srcloc 'string 1 0 1 4))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 4 5 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 5 6 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 6 7 1))
       (srcloc-token (token 'ignored-quote #:skip? #t)
                     (srcloc 'string 1 7 8 1))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string 1 8 9 1))))

(check-equal?
 (lex "ain't ")
 (list (srcloc-token (token 'LOWER-NAME "aint")
                     (srcloc 'string 1 0 1 5))
       (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 5 6 1))))

;; Reserved terms

(check-equal?
 (lex "mysterious")
 (list (srcloc-token (token "mysterious" "mysterious")
                     (srcloc 'string 1 0 1 10))))

(check-equal?
 (lex "let")
 (list (srcloc-token (token "let" "let")
                     (srcloc 'string 1 0 1 3))))

(check-equal?
 (lex "t'r'u'e")
 (list (srcloc-token (token "true" "true")
                     (srcloc 'string 1 0 1 7))))

;; Name

(check-equal?
 (lex "my phone")
 (list (srcloc-token (token "my" "my")
                     (srcloc 'string 1 0 1 2))
       (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 2 3 1))
       (srcloc-token (token 'LOWER-NAME "phone")
                     (srcloc 'string 1 3 4 5))))

(check-equal?
 (lex "WHAT THE HELL")
 (list (srcloc-token (token 'PROPER-NAME "WHAT")
                     (srcloc 'string 1 0 1 4))
       (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 4 5 1))
       (srcloc-token (token 'PROPER-NAME "THE")
                     (srcloc 'string 1 5 6 3))
       (srcloc-token (token 'WHITESPACE " " #:skip? #t)
                     (srcloc 'string 1 8 9 1))
       (srcloc-token (token 'PROPER-NAME "HELL")
                     (srcloc 'string 1 9 10 4))))

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