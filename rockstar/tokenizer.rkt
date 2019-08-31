#lang br

(require "lexer.rkt" "preprocessor.rkt" brag/support)

;; Make tokenizer
(define (make-tokenizer ip [path #f])
  (define prep-ip (preprocess ip))
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token)
    (rockstar-lexer prep-ip))
  next-token)

(provide make-tokenizer)