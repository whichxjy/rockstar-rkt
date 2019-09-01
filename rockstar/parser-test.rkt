#lang br

(require "parser.rkt" "tokenizer.rkt" brag/support)

(define str #<<HERE
(Let my phone be 123
Put 456 into your apple
Build my world up
Knock the walls down
Knock the walls down, down
Let my bag be 123 + 456
Put the whole of your heart into my hands
Let the children be without fear
Let Ta be without fear
Let X be with 10
Let X be 1 with 2, 3, 4
Let X be "foo" with "bar", and "baz"
Let Abc be Tommy is nobody)
Let truth be my sister is higher than me
HERE
)

(parse-to-datum (apply-tokenizer make-tokenizer str))