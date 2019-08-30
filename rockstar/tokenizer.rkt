#lang br

(require brag/support)

;; Reserved terms
(define-lex-abbrev reserved-terms
  (:or "You" "Me"))

;; Make tokenizer
(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token)
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
  next-token)

(provide make-tokenizer)