#lang br

(require brag/support)

;; Variable reserved terms
(define-lex-abbrev variable-reserved-terms
  (:or "a" "an" "the" "my" "or" "your"
       "A" "An" "The" "My" "Or" "Your"))

;; Pronoun reserved terms
(define-lex-abbrev pronoun-reserved-terms
  (:or "it" "he" "she" "him" "her" "they" "them" "ze"
       "hir" "zie" "zir" "xe" "xem" "ve" "ver"))

;; Mysterious reserved terms
(define-lex-abbrev mysterious-reserved-terms
  (:or "Mysterious" "mysterious"))

;; Null reserved terms
(define-lex-abbrev null-reserved-terms
  (:or "Null" "null" "nothing" "nowhere" "nobody" "empty" "gone"))

;; Boolean reserved terms
(define-lex-abbrev boolean-reserved-terms
  (:or "Boolean" "true" "false" "maybe" "definitely maybe"
       "right" "yes" "ok" "wrong" "no" "lies"))

;; Type reserved terms
(define-lex-abbrev type-reserved-terms
  (:or mysterious-reserved-terms
       null-reserved-terms
       boolean-reserved-terms))

;; Assignment reserved terms
(define-lex-abbrev assignment-reserved-terms
  (:or "Put" "put" "into"
       "Let" "let" "be"))

;; Operator reserved terms
(define-lex-abbrev operator-reserved-terms
  (:or "+" "plus" "with"
       "-" "minus" "without"
       "*" "times" "of"
       "/" "over"))

;; Reserved terms
(define-lex-abbrev reserved-terms
  (:or variable-reserved-terms
       pronoun-reserved-terms
       type-reserved-terms
       assignment-reserved-terms
       operator-reserved-terms))

;; Create lexer
(define rockstar-lexer
  (lexer-srcloc
   ;; Newline
   ["\n" (token 'NEWLINE lexeme)]
   ;; Comment
   [(from/to "(" ")") (token 'COMMENT #:skip? #t)]
   ;; Whitespace
   [whitespace (token 'WHITESPACE lexeme)]
   ;; Quote s
   [(:seq (:+ "'") "s" (:+ whitespace)) (token 'QUOTE-S lexeme)]
   ;; Item (Ignored single quote)
   [(:- (from/stop-before (:+ (:or alphabetic "'")) (:or whitespace "\n"))
        (:or (:seq any-string (:seq (:+ "'") "s" (:+ whitespace)) any-string)
             (:seq any-string (:seq (:+ "'") "s"))
             (:seq any-string (:+ "'"))))
    (token (string-replace lexeme "'" "")
           (string-replace lexeme "'" ""))]
   ;; Ignored other single quotes
   ["'" (token 'ignored-quote #:skip? #t)]
   ;; Number
   [(:or (:+ numeric)
         (:seq (:+ numeric) "." (:+ numeric)))
    (token 'NUMBER (string->number lexeme))]
   ;; String
   [(from/to "\"" "\"")
    (token 'STRING
           (substring lexeme
                      1 (sub1 (string-length lexeme))))]))

(provide rockstar-lexer)