#lang br

(require "parser.rkt" "tokenizer.rkt" brag/support)

(define str #<<HERE
Hello takes X and Y
Give back 123

Let Abc be 123
HERE
)

(parse-to-datum (apply-tokenizer make-tokenizer str))