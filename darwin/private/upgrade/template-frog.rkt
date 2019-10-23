#lang scribble/text
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;; Evaluates to text for a darwin.rkt equivalent of a user's old .darwinrc. ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@(require racket/format
          racket/function
          "old-config.rkt")

@;; Intended to run in same dir as .darwinrc
@(define darwinrc ".darwinrc")

@(define (get sym def)
   (get-config sym def darwinrc))

@(define get/v (compose1 ~v get))

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#lang darwin/config

;; Called early when Darwin launches. Use this to set parameters defined
;; in darwin/params.
(define/contract (init)
  (-> any)
  @;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  @;; Many darwinrc items directly correspond to parameters that still ;;
  @;; exist, and the user should set in their `init`, here.          ;;
  @;; (For the rest, see `enhance-body` below.)                      ;;
  @;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  @(define (p sym def)
     @list{(current-@sym @(get/v sym def))})
  @p['scheme/host "http://www.example.com"]
  @p['uri-prefix #f]
  @p['title "Untitled Site"]
  @p['author "The Unknown Author"]
  @p['editor "$EDITOR"]
  @p['editor-command "{editor} {filename}"]
  @p['show-tag-counts? #t]
  @p['permalink "/{year}/{month}/{title}.html"]
  @p['index-full? #f]
  @p['feed-full? #f]
  @p['max-feed-items 999]
  @p['decorate-feed-uris? #t]
  @p['feed-image-bugs? #f]
  @p['posts-per-page 10]
  @p['index-newest-first? #t]
  @p['posts-index-uri "/index.html"]
  @p['source-dir "_src"]
  @p['output-dir "."])

;; Called once per post and non-post page, on the contents.
(define/contract (enhance-body xs)
  (-> (listof xexpr/c) (listof xexpr/c))
  @;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  @;; The remaining darwinrc items control whether we call certain ;;
  @;; body-enhancing functions, or, are arguments to them:       ;;
  @;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Here we pass the xexprs through a series of functions.
  (~> xs
      @(add-newlines
        (list
         @list{(syntax-highlight #:python-executable @(get/v 'python-executable "python")
                                 #:line-numbers? @(get/v 'pygments-linenos? #t)
                                 #:css-class @(get/v 'pygments-cssclass "source"))}
         @(when (get 'auto-embed-tweets? #t)
            @list{(auto-embed-tweets #:parents? @(get/v 'embed-tweet-parents? #t))})
         @(let ([code?  (get 'racket-doc-link-code? #t)]
                [prose? (get 'racket-doc-link-prose? #f)])
            @(when (or code? prose?)
               @list{(add-racket-doc-links #:code? @~v[code?] #:prose? @~v[prose?])}))))))

;; Called from `raco darwin --clean`.
(define/contract (clean)
  (-> any)
  (void))
