#lang br

(require "parser.rkt" "tokenizer.rkt" brag/support)

(define str #<<HERE
"Hello \"  \t \" World"
HERE
)

(parse-to-datum (apply-tokenizer make-tokenizer str))