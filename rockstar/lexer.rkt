#lang br

(require brag/support)

;; Variable reserved term
(define (variable-reserved-term? str)
  (or (eqv? str "a")
      (eqv? str "an")
      (eqv? str "the")
      (eqv? str "my")
      (eqv? str "or")
      (eqv? str "your")
      (eqv? str "A")
      (eqv? str "An")
      (eqv? str "The")
      (eqv? str "My")
      (eqv? str "Or")
      (eqv? str "Your")))

;; Pronoun reserved term
(define (pronoun-reserved-term? str)
  (or (eqv? str "it")
      (eqv? str "he")
      (eqv? str "she")
      (eqv? str "him")
      (eqv? str "her")
      (eqv? str "they")
      (eqv? str "them")
      (eqv? str "ze")
      (eqv? str "hir")
      (eqv? str "zie")
      (eqv? str "zir")
      (eqv? str "xe")
      (eqv? str "xem")
      (eqv? str "ve")
      (eqv? str "ver")))

;; Mysterious reserved term
(define (mysterious-reserved-term? str)
  (or (eqv? str "Mysterious")
      (eqv? str "mysterious")))

;; Null reserved term
(define (null-reserved-term? str)
  (or (eqv? str "Null")
      (eqv? str "null")
      (eqv? str "nothing")
      (eqv? str "nowhere")
      (eqv? str "nobody")
      (eqv? str "empty")
      (eqv? str "gone")))

;; Boolean reserved term
(define (boolean-reserved-term? str)
  (or (eqv? str "Boolean")
      (eqv? str "true")
      (eqv? str "false")
      (eqv? str "maybe")
      (eqv? str "definitely maybe")
      (eqv? str "right")
      (eqv? str "yes")
      (eqv? str "ok")
      (eqv? str "wrong")
      (eqv? str "no")
      (eqv? str "lies")))

;; Type reserved term
(define (type-reserved-term? str)
  (or (mysterious-reserved-term? str)
      (null-reserved-term? str)
      (boolean-reserved-term? str)))

;; Assignment reserved term
(define (assignment-reserved-term? str)
  (or (eqv? str "Put")
      (eqv? str "put")
      (eqv? str "into")
      (eqv? str "Let")
      (eqv? str "let")
      (eqv? str "be")))

;; Operator reserved term
(define (operator-reserved-term? str)
  (or (eqv? str "+")
      (eqv? str "plus")
      (eqv? str "with")
      (eqv? str "-")
      (eqv? str "minus")
      (eqv? str "without")
      (eqv? str "*")
      (eqv? str "times")
      (eqv? str "of")
      (eqv? str "/")
      (eqv? str "over")))

;; Reserved term
(define (reserved-term? str)
  (or (variable-reserved-term? str)
      (pronoun-reserved-term? str)
      (type-reserved-term? str)
      (assignment-reserved-term? str)
      (operator-reserved-term? str)))

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