#lang br

(require brag/support)

;; Variable reserved term
(define (variable-reserved-term? str)
  (or (string=? str "A") (string=? str "a")
      (string=? str "An") (string=? str "an")
      (string=? str "The") (string=? str "the")
      (string=? str "My") (string=? str "my")
      (string=? str "Or") (string=? str "or")
      (string=? str "Your") (string=? str "your")))

;; Pronoun reserved term
(define (pronoun-reserved-term? str)
  (or (string=? str "It") (string=? str "it")
      (string=? str "He") (string=? str "he")
      (string=? str "She") (string=? str "she")
      (string=? str "Him") (string=? str "him")
      (string=? str "Her") (string=? str "her")
      (string=? str "They") (string=? str "they")
      (string=? str "Them") (string=? str "them")
      (string=? str "Ze") (string=? str "ze")
      (string=? str "Hir") (string=? str "hir")
      (string=? str "Zie") (string=? str "zie")
      (string=? str "Zir") (string=? str "zir")
      (string=? str "Xe") (string=? str "xe")
      (string=? str "Xem") (string=? str "xem")
      (string=? str "Ve") (string=? str "ve")
      (string=? str "Ver") (string=? str "ver")))

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

;; Function Reserved term
(define (function-reserved-term? str)
  (or (string=? str "takes")
      (string=? str "taking")
      (string=? str "Give")
      (string=? str "back")
      (string=? str "and")
      (string=? str ",")
      (string=? str "&")
      (string=? str "n")))

;; Reserved term
(define (reserved-term? str)
  (or (variable-reserved-term? str)
      (pronoun-reserved-term? str)
      (type-reserved-term? str)
      (assignment-reserved-term? str)
      (operator-reserved-term? str)
      (function-reserved-term? str)))

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
(define rockstar-lexer
  (lexer-srcloc
   ;; Newline
   ["\n" (token 'NEWLINE lexeme)]
   ;; Comment
   [(from/to "(" ")") (token 'COMMENT #:skip? #t)]
   ;; Whitespace
   [whitespace (token 'WHITESPACE lexeme #:skip? #t)]
   ;; Quote s
   [(:seq (:+ "'") "s" (:+ whitespace)) (token 'QUOTE-S lexeme)]
   ;; Item (Ignored single quote)
   [(:- (from/stop-before (:+ (:or alphabetic "'")) (:or whitespace "\n"))
        (:or (:seq any-string (:seq (:+ "'") "s" (:+ whitespace)) any-string)
             (:seq any-string (:seq (:+ "'") "s"))
             (:seq any-string (:+ "'"))))
    (let ([item (string-replace lexeme "'" "")])
      (cond
        [(reserved-term? item)
         (token item item)]
        [(first-letter-upper-case? item)
         (token 'PROPER-NAME item)]
        [(only-lower-case? item)
         (token 'LOWER-NAME item)]
        [(only-letters? item)
         (token 'NORMAL-NAME item)]
        [else
         (error "Something is Wrong")]))]
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