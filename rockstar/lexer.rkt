#lang br

(require brag/support)

;; Variable reserved terms
(define-lex-abbrev variable-reserved-terms
  (:or "A"    "a"
       "An"   "an"
       "The"  "the"
       "My"   "my"
       "Or"   "my"
       "Your" "your"))

;; Pronoun reserved terms
(define-lex-abbrev pronoun-reserved-terms
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

;; Mysterious reserved terms
(define-lex-abbrev mysterious-reserved-terms
  (:or "Mysterious" "mysterious"))

;; Null reserved terms
(define-lex-abbrev null-reserved-terms
  (:or "Null"
       "null"
       "nothing"
       "nowhere"
       "nobody"
       "empty"
       "gone"))

;; Boolean reserved terms
(define-lex-abbrev boolean-reserved-terms
  (:or "Boolean"
       "true"
       "false"
       "maybe"
       "definitely maybe"
       "right"
       "yes"
       "ok"
       "wrong"
       "no"
       "lies"))

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
  (:or variable-reserved-terms
       pronoun-reserved-terms
       type-reserved-terms
       assignment-reserved-terms
       operator-reserved-terms
       function-reserved-terms))

;; Return #t if str starts with an uppercase letter, #f otherwise.
(define (first-letter-upper-case? str)
  (and (string? str)
       (positive? (string-length str))
       (char-upper-case? (string-ref str 0))))

;; Return #t if str contains only lowercase letters (a-z), #f otherwise.
(define (only-lower-case? str)
  (and (string? str)
       (positive? (string-length str))
       (andmap char-lower-case? (string->list str))))

;; Return #t if str contains only letters (a-z & A-Z), #f otherwise.
(define (only-letters? str)
  (and (string? str)
       (positive? (string-length str))
       (andmap char-alphabetic? (string->list str))))

;; Create lexer
(define (rockstar-lexer ip)
  (cond
    ;; Comment
    [(eqv? (peek-char ip) #\()
     (let ([lex (lexer-srcloc
                 [(from/to "(" ")")
                  (token 'COMMENT #:skip? #t)])])
       (lex ip))]
    ;; String
    [(eqv? (peek-char ip) #\")
     (token 'STRING (read ip))]
    ;; Single quote
    [(eqv? (peek-char ip) #\')
     (cond
       [(or (string=? (peek-string 3 0 ip) "'s ")
            (string=? (peek-string 3 0 ip) "'s\t"))
        ;; Single quote s
        (token 'SINGLE-QUOTE-S (read-string 3 ip))]
       [else
        ;; Ignored single quote
        (token 'IGNORED-SINGLE-QUOTE (read-char ip) #:skip? #t)])]
    [else
     (define lex
       (lexer-srcloc
        ;; EOF
        [(eof) eof]
        ;; Newline
        ["\n" (token 'NEWLINE lexeme)]
        ;; Reserved terms
        [reserved-terms (token lexeme lexeme)]
        ;; Whitespace
        [(:+ whitespace) (token 'WHITESPACE lexeme #:skip? #t)]
        ;; Number
        [(:or (:+ numeric)
              (:seq (:+ numeric) "." (:+ numeric)))
         (token 'NUMBER (string->number lexeme))]))
     (lex ip)]))

(provide rockstar-lexer)