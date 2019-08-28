#lang br

(require brag/support)

;; Variable reserved term
(define (variable-reserved-term? str)
  (or (string=? str "a")
      (string=? str "an")
      (string=? str "the")
      (string=? str "my")
      (string=? str "or")
      (string=? str "your")
      (string=? str "A")
      (string=? str "An")
      (string=? str "The")
      (string=? str "My")
      (string=? str "Or")
      (string=? str "Your")))

;; Pronoun reserved term
(define (pronoun-reserved-term? str)
  (or (string=? str "it")
      (string=? str "he")
      (string=? str "she")
      (string=? str "him")
      (string=? str "her")
      (string=? str "they")
      (string=? str "them")
      (string=? str "ze")
      (string=? str "hir")
      (string=? str "zie")
      (string=? str "zir")
      (string=? str "xe")
      (string=? str "xem")
      (string=? str "ve")
      (string=? str "ver")))

;; Mysterious reserved term
(define (mysterious-reserved-term? str)
  (or (string=? str "Mysterious")
      (string=? str "mysterious")))

;; Null reserved term
(define (null-reserved-term? str)
  (or (string=? str "Null")
      (string=? str "null")
      (string=? str "nothing")
      (string=? str "nowhere")
      (string=? str "nobody")
      (string=? str "empty")
      (string=? str "gone")))

;; Boolean reserved term
(define (boolean-reserved-term? str)
  (or (string=? str "Boolean")
      (string=? str "true")
      (string=? str "false")
      (string=? str "maybe")
      (string=? str "definitely maybe")
      (string=? str "right")
      (string=? str "yes")
      (string=? str "ok")
      (string=? str "wrong")
      (string=? str "no")
      (string=? str "lies")))

;; Type reserved term
(define (type-reserved-term? str)
  (or (mysterious-reserved-term? str)
      (null-reserved-term? str)
      (boolean-reserved-term? str)))

;; Assignment reserved term
(define (assignment-reserved-term? str)
  (or (string=? str "Put")
      (string=? str "put")
      (string=? str "into")
      (string=? str "Let")
      (string=? str "let")
      (string=? str "be")))

;; Operator reserved term
(define (operator-reserved-term? str)
  (or (string=? str "+")
      (string=? str "plus")
      (string=? str "with")
      (string=? str "-")
      (string=? str "minus")
      (string=? str "without")
      (string=? str "*")
      (string=? str "times")
      (string=? str "of")
      (string=? str "/")
      (string=? str "over")))

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