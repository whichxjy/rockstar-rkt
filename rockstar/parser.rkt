#lang brag

r-program : [r-line] (NEWLINE [r-line])*
r-line : r-statement
r-statement : r-assignment
r-assignment : r-put
r-put : "Put" r-expr "into" r-var
;; Variable
r-var : r-simple-var | r-common-var | r-proper-var
;; Simple Variable
r-simple-name : NORMAL-NAME | LOWER-NAME | PROPER-NAME
r-simple-var : r-simple-name
;; Common Variable
r-common-name : LOWER-NAME
r-common-var : "my" r-common-name
;; Proper Variable
r-proper-name : PROPER-NAME
r-proper-var : r-proper-name+