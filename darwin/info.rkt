#lang info
(define raco-commands '(("darwin" (submod darwin/main main) "run Darwin" #f)))
(define scribblings '(("darwin.scrbl" (multi-page))))
(define clean '("compiled" "doc" "doc/darwin"))
