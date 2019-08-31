#lang br

(require "parser.rkt" "tokenizer.rkt" brag/support)

(define str #<<HERE
(Let my phone be 123)
(Put 456 into your apple)
(Build my world up)
(Knock the walls down)
(Knock the walls down, down)
HERE
)

(parse-to-datum (apply-tokenizer make-tokenizer str))