#lang info
(define version "0.1")
(define collection 'multi)
(define deps '(["base" #:version "6.2"]
               "find-parent-dir"
               "html-lib"
               ["markdown-ng" #:version "0.1"]
               txexpr
               "racket-index"
               ["rackjure" #:version "0.9"]
               "reprovide-lang"
               "scribble-lib"
               "scribble-text-lib"
               "srfi-lite-lib"
               "web-server-lib"))
(define build-deps '("at-exp-lib"
                     "net-doc"
                     "racket-doc"
                     "rackunit-lib"
                     "scribble-doc"
                     "scribble-text-lib"
                     "web-server-doc"))
(define test-omit-paths '("example/"))
