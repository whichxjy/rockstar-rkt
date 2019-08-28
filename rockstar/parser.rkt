#lang brag

r-program : [r-line] (NEWLINE [r-line])*
r-line : r-statement
r-statement : r-assignment
r-assignment : r-put
r-put : "Put" r-expr "into" r-var