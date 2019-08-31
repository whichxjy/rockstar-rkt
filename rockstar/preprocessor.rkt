#lang racket

(define (preprocess ip)
  (define op (open-output-string))
  (let loop()
    (define ch (read-char ip))
    (unless (eof-object? ch)
      (cond
        ;; avoid ignoring the single quote in string
        [(eqv? (peek-char ip) #\")
         (write (read ip) op)]
        ;; single quote that is not in string
        [(eqv? ch #\')
         ;; 1. replace the single quote followed by a lowercase 's' with " is "
         ;; 2. all other single quotes are ignored
         (define next-two-char (peek-string 2 0 ip))
         (when (and (not (eof-object? next-two-char))
                    (or (string=? next-two-char "s ")
                        (string=? next-two-char "s\t")))
           (read-string 2 ip)
           (write-string " is " op))]
        [else
         (write-char ch op)])
      (loop)))
  (open-input-string (get-output-string op)))

(provide preprocess)