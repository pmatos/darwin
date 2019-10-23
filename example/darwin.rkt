#lang darwin/config

;; Called early when Darwin launches. Use this to set parameters defined
;; in darwin/params.
(define/contract (init)
  (-> any)
  (current-scheme/host "http://www.example.com")
  (current-title "My Blog")
  (current-author "The Unknown Author"))

;; Called once per post and non-post page, on the contents.
(define/contract (enhance-body xs)
  (-> (listof xexpr/c) (listof xexpr/c))
  ;; Here we pass the xexprs through a series of functions.
  (~> xs
      (syntax-highlight #:python-executable (if (eq? (system-type) 'windows)
                                                "python.exe"
                                                "python")
                        #:line-numbers? #t
                        #:css-class "source")
      (auto-embed-tweets #:parents? #t)
      (add-racket-doc-links #:code? #t #:prose? #f)))

;; Called from `raco darwin --clean`.
(define/contract (clean)
  (-> any)
  (void))
