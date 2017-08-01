;; auto-generated by ffi-help.scm

(define-module (librsvg)
  #:use-module (system ffi-help-rt)
  #:use-module ((system foreign) #:prefix ffi:)
  #:use-module (bytestructures guile)
  )
(dynamic-link "libm")
(dynamic-link "libgio-2.0")
(dynamic-link "libgdk_pixbuf-2.0")
(dynamic-link "libgobject-2.0")
(dynamic-link "libglib-2.0")
(dynamic-link "libintl")
(dynamic-link "libcairo")
(dynamic-link "librsvg-2")

;; access to enum symbols and #define'd constants:
(define librsvg-symbol-val
  (let ((sym-tab '()))
    (lambda (k) (assq-ref sym-tab k))))
(export librsvg-symbol-val)

(define (unwrap-enum obj)
  (cond ((number? obj) obj)
        ((symbol? obj) (librsvg-symbol-val obj))
        ((fh-object? obj) (struct-ref obj 0))
        (else (error "type mismatch"))))

(define librsvg-types
  ())
(export librsvg-types)

;; --- last line ---
