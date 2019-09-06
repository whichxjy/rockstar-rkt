#lang brag

;; Rockstar program
r-program : [r-statement] (/NEWLINE [r-statement])*

;; Statement
@r-statement : r-operation | r-expr
             | r-input | r-output
             | r-if | r-while | r-until | r-break | r-continue
             | r-func-def | r-func-return | r-func-call

;; Value
@r-value : r-func-call | r-var | r-literal | r-pronoun
;; Literal
@r-literal : r-constant | r-number | r-string
;; Constant
@r-constant : r-mysterious | r-null | r-boolean

;; Operation
r-operation : r-assignment | r-crement

;; Assignment
r-assignment : r-put | r-let
;; Put
r-put : ("Put" | "put") r-expr "into" r-var
;; Let
r-let : ("Let" | "let") r-var "be" [r-compoundable-op] r-expr

;; Increment & Decrement
r-crement : r-increment | r-decrement
;; Increment
r-increment : "Build" r-var "up" ("," "up")*
;; Decrement
r-decrement : "Knock" r-var "down" ("," "down")*

;; Expression
r-expr : r-and-expr | r-or-expr | r-nor-expr

;; Boolean Expression: and & or & nor
r-and-expr : [(r-and-expr | r-or-expr | r-nor-expr) r-and-op] r-cmp-expr
r-or-expr : [(r-and-expr | r-or-expr | r-nor-expr) r-or-op] r-cmp-expr
r-nor-expr : [(r-and-expr | r-or-expr | r-nor-expr) r-nor-op] r-cmp-expr
;; Logical Operator: and & or & nor
@r-and-op: "and"
@r-or-op: "or"
@r-nor-op: "nor"

;; Comparison Expression
r-cmp-expr : [r-cmp-expr r-cmp-op] r-arithmetic-expr
;; Comparison Operator
@r-cmp-op : r-equality-op | r-greater-op | r-smaller-op | r-great-op | r-small-op
@r-equality-op : ("is" | "is not" | "isnt" | "aint")
@r-greater-op : r-equality-op ("higher" | "greater" | "bigger" | "stronger") "than"
@r-smaller-op : r-equality-op ("lower" | "less" | "smaller" | "weaker") "than"
@r-great-op : r-equality-op ("high" | "great" | "big" | "strong") "as"
@r-small-op : r-equality-op ("low" | "little" | "small" | "weak") "as"

;; Arithmetic Expression
@r-arithmetic-expr : r-add-expr | r-sub-expr
r-add-expr : [(r-add-expr | r-sub-expr) r-add-op] (r-mul-expr | r-div-expr)
r-sub-expr : [(r-add-expr | r-sub-expr) r-sub-op] (r-mul-expr | r-div-expr)
r-mul-expr : [(r-mul-expr | r-div-expr) r-mul-op] r-not-expr
r-div-expr : [(r-mul-expr | r-div-expr) r-div-op] r-not-expr
;; Arithmetic Operator
@r-add-op : "+" | "plus" | "with"
@r-sub-op : "-" | "minus" | "without"
@r-mul-op : "*" | "times" | "of"
@r-div-op : "/" | "over"
;; Compoundable Operator
@r-compoundable-op : r-add-op | r-sub-op | r-mul-op | r-div-op

;; Logical Not Expression
r-not-expr : r-not-op* r-value-list
;; Logical Not Operator
@r-not-op : "not"

;; Input
r-input : "Listen" | ("Listen to" r-var)
;; Output
r-output : ("Say" | "Shout" | "Whisper" | "Scream") r-expr

;; Block
@r-block : r-statement (/NEWLINE r-statement)* /NEWLINE

;; Conditional
r-if : "If" r-expr
       [r-if-consequent]
       [r-else]
r-if-consequent : r-statement
                | (NEWLINE r-block)
r-else : ("Else" r-statement)
       | (NEWLINE "Else" r-statement)
       | (NEWLINE "Else" NEWLINE r-block)

;; Loop
r-while : "While" r-expr r-loopable
r-until : "Until" r-expr r-loopable
r-loopable : r-statement
           | (NEWLINE r-block)
r-break : "break" | "Break it down"
r-continue : "continue" | "Take it to the top"

;; Function Definition
r-func-def : r-var "takes" r-var-list NEWLINE
             r-block
;; Function Return Statement
r-func-return : "Give back" r-expr
;; Function Call
r-func-call : r-var "taking" r-expr-list

;; Expression List Separator
r-expr-list-sep : "," | "&" | ", and" | "n"
;; Expression List
r-expr-list : r-expr (r-expr-list-sep r-expr)*

;; Value List Separator
r-value-list-sep : r-expr-list-sep
;; Value List
r-value-list : r-value (r-value-list-sep r-value)*

;; Variable List Separator
@r-var-list-sep : r-expr-list-sep | "and"
;; Variable List
r-var-list : r-var (r-var-list-sep r-var)*

;; Variable
@r-var : SIMPLE-VAR | COMMON-VAR | PROPER-VAR

;; Pronoun
@r-pronoun : PRONOUN

;; Mysterious
@r-mysterious : MYSTERIOUS
;; Null
@r-null : NULL
;; Boolean
@r-boolean : BOOLEAN
;; Number
@r-number : NUMBER
;; String
@r-string : STRING