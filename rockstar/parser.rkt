#lang brag

;; Rockstar program
r-program : [(r-line | r-func-def)] (/NEWLINE [(r-line | r-func-def)])*

;; Line
r-line : r-statement | r-func-return

;; Statement
r-statement : r-operation

;; Expression
r-expr : r-arithmetic-expr

;; Value
r-value : r-var | r-literal | r-pronoun
;; Literal
r-literal : r-constant | r-number | r-string
;; Constant
r-constant : r-mysterious | r-null | r-boolean

;; Operation
r-operation : r-crement | r-assignment

;; Increment & Decrement
r-crement : r-increment | r-decrement
;; Increment
r-increment : "Build" r-var "up" ("," "up")*
;; Decrement
r-decrement : "Knock" r-var "down" ("," "down")*

;; Assignment
r-assignment : r-put | r-let
;; Put
r-put : ("Put" | "put") r-expr "into" r-var
;; Let
r-let : ("Let" | "let") r-var "be" [r-compoundable-op] r-expr

;; Arithmetic Expression
r-arithmetic-expr : r-add-expr | r-sub-expr
r-add-expr : [(r-add-expr | r-sub-expr) r-add-op] (r-mul-expr | r-div-expr)
r-sub-expr : [(r-add-expr | r-sub-expr) r-sub-op] (r-mul-expr | r-div-expr)
r-mul-expr : [(r-mul-expr | r-div-expr) r-mul-op] r-value
r-div-expr : [(r-mul-expr | r-div-expr) r-div-op] r-value
;; Arithmetic Operator
@r-add-op : "+" | "plus" | "with"
@r-sub-op : "-" | "minus" | "without"
@r-mul-op : "*" | "times" | "of"
@r-div-op : "/" | "over"

;; Compoundable Operator
@r-compoundable-op : r-add-op | r-sub-op | r-mul-op | r-div-op

;; Function Definition
r-func-def : r-func-name "takes" r-parameter (("and" | "," | "&" | ("," "and") | "n") r-parameter)*
             NEWLINE
             (r-line NEWLINE)*
             r-func-return
             NEWLINE
;; Function Return Statement
r-func-return : "Give back" r-expr
;; Function Call
r-func-call : r-func-name "taking" r-argument (("," | "&" | ("," "and") | "n") r-argument)*
;; Function Name
r-func-name : r-var
;; Function Parameter
r-parameter : r-var
;; Function Argument
r-argument : r-var | r-literal

;; Variable
r-var : SIMPLE-VAR | COMMON-VAR | PROPER-VAR

;; Pronoun
r-pronoun : PRONOUN

;; Mysterious
r-mysterious : MYSTERIOUS
;; Null
r-null : NULL
;; Boolean
r-boolean : BOOLEAN
;; Number
r-number : NUMBER
;; String
r-string : STRING