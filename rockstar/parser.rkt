#lang brag

;; Rockstar program
r-program : [r-line] (NEWLINE [r-line])*
;; Line
r-line : r-statement

;; Statement
r-statement : r-assignment
;; Assignment
r-assignment : r-put | r-let
;; Put
r-put : ("Put" | "put") r-expr "into" r-var
;; Let
r-let : ("Let" | "let") r-var "be" r-expr

;; Expression
r-expr : r-constant | r-literal | r-expr
;; Constant
r-constant : r-mysterious | r-null | r-boolean
;; Literal
r-literal : r-number | r-string

;; Mysterious
r-mysterious : "mysterious"
;; Null
r-null : "null" | "nothing" | "nowhere"
       | "nobody" | "empty" | "gone"
;; Boolean
r-boolean : r-true | r-false
r-true : "true" | "right" | "yes" | "ok"
r-false : "false" | "wrong" | "no" | "lies"
;; Number
r-number : NUMBER
;; String
r-string : STRING

;; Variable
r-var : r-simple-var | r-common-var | r-proper-var
;; Simple Variable
r-simple-name : NORMAL-NAME | LOWER-NAME | PROPER-NAME
r-simple-var : r-simple-name
;; Common Variable
r-common-var-prefix : "A" | "a"
                    | "An" | "an"
                    | "The" | "the"
                    | "My" | "my"
                    | "Or" | "or"
                    | "Your" | "your"
r-common-name : LOWER-NAME
r-common-var : r-common-var-prefix r-common-name
;; Proper Variable
r-proper-name : PROPER-NAME
r-proper-var : r-proper-name r-proper-name+

;; Pronoun
r-pronoun : "It" | "it"
          | "He" | "he"
          | "She" | "she"
          | "Him" | "him"
          | "Her" | "her"
          | "They" | "they"
          | "Them"| "them"
          | "Ze" | "ze"
          | "Hir" | "hir"
          | "Zie" | "zie"
          | "Zir" | "zir"
          | "Xe" | "xe"
          | "Xem" | "xem"
          | "Ve" | "ve"
          | "Ver" | "ver"