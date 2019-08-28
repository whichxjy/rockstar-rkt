#lang brag

r-program : [r-line] (NEWLINE [r-line])*
r-line : r-statement
r-statement : r-assignment
r-assignment : r-put
r-put : "Put" r-expr "into" r-var
letter : upper-case-letter | lower-case-letter
upper-case-letter : "A" | "B" | "C" | "D" | "E"
                  | "F" | "G" | "H" | "I" | "J"
                  | "K" | "L" | "M" | "N" | "O"
                  | "P" | "Q" | "R" | "S" | "T"
                  | "U" | "V" | "W" | "X" | "Y"
                  | "Z"
lower-case-letter : "a" | "b" | "c" | "d" | "e"
                  | "f" | "g" | "h" | "i" | "j"
                  | "k" | "l" | "m" | "n" | "o"
                  | "p" | "q" | "r" | "s" | "t"
                  | "u" | "v" | "w" | "x" | "y"
                  | "z"