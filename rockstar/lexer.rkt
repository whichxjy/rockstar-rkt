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
  (:or "Listen" "Listen to"
       "Say" "Shout" "Whisper" "Scream"))

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

;; Poetic number
(define-lex-abbrev poetic-number
  (:seq whole-number-part (:? (:seq "." frac-number-part))))

;; Whole number part
(define-lex-abbrev whole-number-part
  (:seq (:* whole-number-digit-separator)
        (:+ (:seq poetic-digit
                  (:* whole-number-digit-separator)))))

;; Fractional number part
(define-lex-abbrev frac-number-part
  (:seq (:* frac-number-digit-separator)
        (:* (:seq poetic-digit
                  (:* frac-number-digit-separator)))))

;; Poetic digit
(define-lex-abbrev poetic-digit
  (:+ alphabetic))

;; Whole number digit separator
(define-lex-abbrev whole-number-digit-separator
  (char-complement (:or alphabetic "." "\n")))

;; Fractional number digit separator
(define-lex-abbrev frac-number-digit-separator
  (char-complement (:or alphabetic "\n")))

;; Whole number part list -> number
(define (whole-num-list->number num-list)
  (for/fold ([sum 0])
            ([digit num-list]
             [power (in-range (sub1 (length num-list)) -1 -1)])
    (+ sum (* digit (expt 10 power)))))

;; Fractional number part list -> number
(define (frac-num-list->number num-list)
  (for/fold ([sum 0])
            ([digit num-list]
             [k (in-naturals 1)])
    (+ sum (* digit (expt 10 (- k))))))

;; Decimal number string -> number
(define (decimal-str->number str)
  ;; split the string into a list and drop the copula
  (define str-list (drop
                    (string-split
                    (string-replace str "." " . ")
                    #px"[^.a-zA-Z]+") 1))
  ;; find the first period
  (define first-period-index
    (index-of str-list "."))
  ;; split the list into two parts
  (define-values (whole-number-str-list frac-number-str-list-with-period)
    (split-at str-list first-period-index))
  (define frac-number-str-list
    (remove* '(".") frac-number-str-list-with-period))
  ;; map string-lists to number-lists
  (define whole-number-list
    (map (lambda (str)
           (modulo (string-length str) 10))
           whole-number-str-list))
  (define frac-number-list
    (map (lambda (str)
           (modulo (string-length str) 10))
           frac-number-str-list))
  ;; calculate the whole number part and fractional number part
  (define whole-number-part
    (whole-num-list->number whole-number-list))
  (define frac-number-part
    (frac-num-list->number frac-number-list))
  ;; add the whole number part and fractional number part
  (exact->inexact (+ whole-number-part frac-number-part)))
  
;; Integral number string -> number
(define (integral-str->number str)
  ;; split the string into a list and drop the copula
  (define str-list (drop
                    (string-split str #px"[^a-zA-Z]+")
                    1))
  ;; map string-list to number-list
  (define integral-number-list
    (map (lambda (str)
           (modulo (string-length str) 10))
           str-list))
  ;; calculate the integral number
  (define intergal-number
    (whole-num-list->number integral-number-list))
  ;; return result
  intergal-number)

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
                               (string-split lexeme)) "-"))]
                 ;; Poetic constant literal
                 [(:seq poetic-copula #\space (:or mysterious-type
                                                   null-type
                                                   boolean-type))
                  (token 'BE-POETIC-CONSTANT
                         (second (string-split lexeme)))]
                 ;; Poetic string literal
                 [(:seq "says" (from/stop-before #\space "\n"))
                  (token 'SAY-SOMETHING
                         (substring lexeme 5))]
                 ;; Poetic number literal
                 [(:seq poetic-copula #\space (from/stop-before poetic-number "\n"))
                  (token 'BE-POETIC-NUMBER
                         (cond
                           [(string-contains? lexeme ".")
                            (decimal-str->number lexeme)]
                           [else
                            (integral-str->number lexeme)]))])])
       (lex ip))]))

(provide rockstar-lexer)