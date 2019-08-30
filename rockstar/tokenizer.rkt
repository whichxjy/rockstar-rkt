#lang br

(require "lexer.rkt" brag/support)

;; Reserved terms
(define-lex-abbrev reserved-terms
  (:or "You" "Me"))

;; Make tokenizer
(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token)
    (rockstar-lexer ip))
  next-token)

(provide make-tokenizer)