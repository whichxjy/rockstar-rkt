#lang br

(require brag/support)

(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define rockstar-lexer
  (lexer-srcloc
   ["\n" (token 'NEWLINE lexeme)]
   [whitespace (token 'WHITESPACE lexeme)]
   [(from/to "(" ")") (token 'COMMENT #:skip? #t)]
   [(:or digits (:seq digits "." digits))
    (token 'NUMBER (string->number lexeme))]
   [(from/to "\"" "\"")
    (token 'STRING
           (substring lexeme
                      1 (sub1 (string-length lexeme))))]))

(provide rockstar-lexer)