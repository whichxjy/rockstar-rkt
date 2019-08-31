#lang br

(require brag/support)

;; Simple variable
(define-lex-abbrev simple-var
  (:+ alphabetic))

;; Common variable prefix
(define-lex-abbrev common-var-prefix
  (:or "A"    "a"
       "An"   "an"
       "The"  "the"
       "My"   "my"
       "Or"   "my"
       "Your" "your"))

;; Common variable
(define-lex-abbrev common-var
  (:seq common-var-prefix (:+ whitespace) (:+ lower-case)))

;; Proper noun
(define-lex-abbrev proper-noun
  (:seq upper-case (:* alphabetic)))

;; Proper variable
(define-lex-abbrev proper-var
  (:seq proper-noun (:* (:seq " " proper-noun))))

;; Pronoun
(define-lex-abbrev pronoun
  (:or "It"   "it"
       "He"   "he"
       "She"  "she"
       "Him"  "him"
       "Her"  "her"
       "They" "they"
       "Them" "them"
       "Ze"   "ze"
       "Hir"  "hir"
       "Zie"  "zie"
       "Zir"  "zir"
       "Xe"   "xe"
       "Xem"  "xem"
       "Ve"   "ve"
       "Ver"  "ver"))

;; Mysterious
(define-lex-abbrev mysterious-type
  (:or "Mysterious" "mysterious"))

;; Null
(define-lex-abbrev null-type
  (:or "null"
       "nothing"
       "nowhere"
       "nobody"
       "empty"
       "gone"))

;; Boolean
(define-lex-abbrev boolean-type
  (:or "true"
       "false"
       "maybe"
       "definitely maybe"
       "right"
       "yes"
       "ok"
       "wrong"
       "no"
       "lies"))

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

;; Function Reserved terms
(define-lex-abbrev function-reserved-terms
  (:or "takes"
       "taking"
       "Give back"
       "and"
       ","
       "&"
       ", and"
       "n"))

;; Reserved terms
(define-lex-abbrev reserved-terms
  (:or assignment-reserved-terms
       operator-reserved-terms
       function-reserved-terms))

;; Create lexer
(define (rockstar-lexer ip)
  (cond
    ;; Comment
    [(eqv? (peek-char ip) #\()
     (let ([lex (lexer
                 [(from/to #\( #\))
                  (token 'COMMENT #:skip? #t)])])
       (lex ip))]
    ;; String
    [(eqv? (peek-char ip) #\")
     (token 'STRING (read ip))]
    [else
     (let ([lex (lexer
                 ;; Newline
                 ["\n" (token 'NEWLINE lexeme)]
                 ;; Reserved terms
                 [reserved-terms (token lexeme lexeme)]
                 ;; Whitespace
                 [(:+ (:or #\space #\tab))
                  (token 'WHITESPACE lexeme #:skip? #t)]
                 ;; Mysterious
                 [mysterious-type
                  (token 'MYSTERIOUS lexeme)]
                 ;; Null
                 [null-type
                  (token 'NULL lexeme)]
                 ;; Boolean
                 [boolean-type
                  (token 'BOOLEAN lexeme)]
                 ;; Number
                 [(:or (:+ numeric)
                       (:seq (:+ numeric) "." (:+ numeric)))
                  (token 'NUMBER (string->number lexeme))]
                 ;; Pronoun
                 [pronoun
                  (token 'PRONOUN
                         (string-downcase lexeme))]
                 ;; Simple variable
                 [simple-var
                  (token 'SIMPLE-VAR
                         (string-downcase lexeme))]
                 ;; Common variable
                 [common-var
                  (token 'COMMON-VAR
                         (string-join
                          (map string-downcase
                               (string-split lexeme)) "-"))]
                 ;; Proper variable
                 [proper-var
                  (token 'PROPER-VAR
                         (string-join
                          (map string-titlecase
                               (string-split lexeme)) "-"))])])
       (lex ip))]))

(provide rockstar-lexer)