#lang br

(require brag/support)

;; Simple variable
(define-lex-abbrev simple-var
  (:- (:+ alphabetic)
      reserved-terms))

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
  (:seq common-var-prefix (:+ whitespace)
        (:- (:+ lower-case)
            reserved-terms)))

;; Proper noun
(define-lex-abbrev proper-noun
  (:- (:seq upper-case (:* alphabetic))
      reserved-terms))

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
(define-lex-abbrev true-type
  (:or "true"
       "right"
       "yes"
       "ok"))

(define-lex-abbrev false-type
  (:or "false"
       "wrong"
       "no"
       "lies"))

(define-lex-abbrev boolean-reserved-terms
  (:or "maybe"
       "definitely maybe"))

;; Poetic Copula
(define-lex-abbrev poetic-copula
  (:or "is" "are" "was" "were"))

;; Poetic literal reserved terms
(define-lex-abbrev poetic-reserved-terms
  (:or poetic-copula "says"))

;; Assignment reserved terms
(define-lex-abbrev assignment-reserved-terms
  (:or "Put" "put" "into"
       "Let" "let" "be"))

;; Increment reserved terms
(define-lex-abbrev increment-reserved-terms
  (:or "Build" "up"))

;; Decrement reserved terms
(define-lex-abbrev decrement-reserved-terms
  (:or "Knock" "down"))

;; Arithmetic reserved terms
(define-lex-abbrev arithmetic-reserved-terms
  (:or "+" "plus" "with"
       "-" "minus" "without"
       "*" "times" "of"
       "/" "over"))

;; Comparison reserved terms
(define-lex-abbrev comparison-reserved-terms
  (:or "is" "is not" "isnt" "aint" "as" "than" 
       "higher" "greater" "bigger"  "stronger"
       "lower"  "less"    "smaller" "weaker"
       "high"   "great"   "big"     "strong"
       "low"    "little"  "small"   "weak"))

;; Logical Operation
(define-lex-abbrev logical-reserved-terms
  (:or "and" "or" "nor" "not"))

;; Input & Output
(define-lex-abbrev stream-reserved-terms
  (:or "Listen"    "listen"
       "Listen to" "listen to"
       "Say"       "say"
       "Shout"     "shout"
       "Whisper"   "whisper"
       "Scream"    "scream"))

;; Conditional reserved terms
(define-lex-abbrev cond-reserved-terms
  (:or "If" "Else"))

;; Loop reserved terms
(define-lex-abbrev loop-reserved-terms
  (:or "While" "Until"
       "break" "Break it down"
       "continue" "Take it to the top"))

;; Function reserved terms
(define-lex-abbrev function-reserved-terms
  (:or "takes"
       "taking"
       "Give back"))

;; List separator
(define-lex-abbrev list-separator
  (:or ","
       "&"
       "and"
       ", and"
       "n"))

;; Reserved terms
(define-lex-abbrev reserved-terms
  (:or common-var-prefix
       boolean-reserved-terms
       poetic-reserved-terms
       assignment-reserved-terms
       increment-reserved-terms
       decrement-reserved-terms
       arithmetic-reserved-terms
       comparison-reserved-terms
       logical-reserved-terms
       stream-reserved-terms
       cond-reserved-terms
       loop-reserved-terms
       function-reserved-terms
       list-separator))

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
                 ;; Ture
                 [true-type
                  (token 'TRUE lexeme)]
                 ;; False
                 [false-type
                  (token 'FALSE lexeme)]
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
                         (string->symbol
                          (string-downcase lexeme)))]
                 ;; Common variable
                 [common-var
                  (token 'COMMON-VAR
                         (string->symbol
                          (string-join
                           (map string-downcase
                                (string-split lexeme)) "-")))]
                 ;; Proper variable
                 [proper-var
                  (token 'PROPER-VAR
                         (string->symbol
                          (string-join
                           (map string-titlecase
                                (string-split lexeme)) "-")))])])
       (lex ip))]))

(provide rockstar-lexer)