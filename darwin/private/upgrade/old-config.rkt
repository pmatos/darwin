#lang racket/base

;; This is only used to read the deprecated .darwinrc -- from which we attempt
;; to create an equivalent darwin.rkt for users.

(require racket/dict
         racket/file
         racket/match
         racket/runtime-path
         racket/string
         "../verbosity.rkt")

(provide maybe-darwinrc->darwin.rkt
         get-config)

(define-runtime-path template-darwin.rkt "template-darwin.rkt")

(define (maybe-darwinrc->darwin.rkt top)
  (when (file-exists? (build-path top ".darwinrc"))
    (define darwin.rkt (build-path top "darwin.rkt"))
    (unless (file-exists? darwin.rkt)
      (prn0 "Creating darwin.rkt from .darwinrc -- see upgrade documentation.")
      (flush-output)
      (parameterize ([current-directory top])
        (with-output-to-file darwin.rkt
          #:mode 'text #:exists 'error
          (λ () (dynamic-require template-darwin.rkt #f)))
        (add-deprecation-comment-to-.darwinrc)))))

(define config #f) ;; (hash/c symbol? any/c)
(define (get-config name default cfg-path) ;; (symbol? any/c path? -> any/c)
  ;; Read all & memoize
  (unless config
    (set! config (read-config cfg-path)))
  (cond [(dict-has-key? config name)
         (define v (dict-ref config name))
         (cond [(string? default) v]
               [(boolean? default) v]
               [(number? default)
                (or (string->number v)
                    (begin
                      (eprintf
                       "Expected number for ~a. Got '~a'. Using default: ~a\n"
                       name v default)
                      default))]
               [else (raise-type-error 'get-config
                                       "string, boolean, or number"
                                       v)])]
        [else default]))

(define (read-config p)
  (cond [(file-exists? p)
         (for/hasheq ([s (file->lines p)])
           (match s
             [(pregexp "^(.*)#?.*$" (list _ s))
              (match s
                [(pregexp "^\\s*(\\S+)\\s*=\\s*(.+)$" (list _ k v))
                 (values (string->symbol k) (maybe-bool v))]
                [else (values #f #f)])]
             [_ (values #f #f)]))]
        [else (make-hasheq)]))

(define (maybe-bool v) ;; (any/c -> (or/c #t #f any/c))
  (match v
    [(or "true" "#t") #t]
    [(or "false" "#f") #f]
    [else v]))

(define (add-deprecation-comment-to-.darwinrc)
  (define s (string-join (list (make-string 76 #\#)
                               "#"
                               "# THIS FILE IS NO LONGER USED."
                               "# Use darwin.rkt instead."
                               "#"
                               (make-string 76 #\#)
                               (file->string ".darwinrc" #:mode 'text))
                         "\n"))
  (display-to-file s ".darwinrc"
                   #:mode 'text
                   #:exists 'replace))
