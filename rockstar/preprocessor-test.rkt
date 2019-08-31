#lang racket

(require "preprocessor.rkt" rackunit)

;; Unit tests for preprocessor
(define (pre str)
  (get-output-string (preprocess (open-input-string str))))

(check-equal? (pre "") "")

(check-equal? (pre "'''''") "")

(check-equal? (pre "''s''") "s")

(check-equal? (pre "''s ''") " is ")

(check-equal? (pre "''s\t''") " is ")

(check-equal?
 (pre "Hello World")
 "Hello World")

(check-equal?
 (pre "H'e'l'l'o' W'o'r'l'd'")
 "Hello World")

(check-equal?
 (pre "It's not cool")
 "It is not cool")

(check-equal?
 (pre "out \" in ''' in \" out")
 "out\" in ''' in \" out")

(check-equal?
 (pre "out \"It's not cool\" out")
 "out\"It's not cool\" out")