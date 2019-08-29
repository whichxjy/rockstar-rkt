#lang br

(require "parser.rkt" "tokenizer.rkt" brag/support)

(define str #<<HERE
(haha)
Put wrong into my phone
Let abc be 123
Let Hello World be 123
HERE
)

(parse-to-datum (apply-tokenizer make-tokenizer str))