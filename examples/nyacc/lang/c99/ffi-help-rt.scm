;;; example/nyacc/lang/c99/ffi-help-rt.scm
;;;
;;; Copyright (C) 2016-2017 Matthew R. Wette
;;;
;;; This software is covered by the GNU GENERAL PUBLIC LICENCE, Version 3,
;;; or any later version published by the Free Software Foundation.  See
;;; the file COPYING included with the nyacc distribution.

;; runtime for generated ffi-compiled dot-ffi files

(define-module (ffi-help-rt)
  #:export (fh-type?
	    fh-object?
	    define-fh-compound-type define-fh-compound-type/p
	    ;;define-fh-compound-type/pp
	    define-fh-pointer-type
	    define-fh-enum
	    define-fh-function define-fh-function/p
	    pointer-to
	    unwrap~fixed unwrap~float unwrap~pointer
	    wrap-void*
	    )
  #:use-module (bytestructures guile)
  #:use-module ((system foreign) #:prefix ffi:)
  #:version (0 10 0)
  )

;; ffi-helper base type (aka class) with fields
;; 0 unwrap
;; 1 pointer-to : (pointer-to foo_t-obj) => address-of-obj
;; 2 points-to : (points-to address-of-obj) => foo_t-obj
;;   dereference : (dereference address-of-obj) => foo_t-obj
;; NOTES:
;; 1) we don't need wrap
;; 2) we don't need unwrap unless we want generic unwrap
(define ffi-helper-type
  (make-vtable
   (string-append standard-vtable-fields "prpwpw")
   (lambda (v p)
     (display "#<ffi-helper-type>" p))))

;; @deffn {Procedure} fh-type? type
;; This predicate tests for FH types.
;; @end deffn
(define (fh-type? type)
  (and (struct? type)
       (struct-vtable? type)
       (eq? (struct-vtable type) ffi-helper-type)))

;; @deffn {Procedure} fh-object? obj
;; This predicate tests for FH objects.
;; @end deffn
(define (fh-object? obj)
  (and
   (struct? obj)
   (fh-type? (struct-vtable obj))))

(define (fht-unwrap obj)
  (struct-ref obj (+ vtable-offset-user 0)))
(define (fht-pointer-to obj)
  (struct-ref obj (+ vtable-offset-user 1)))
(define (fht-points-to obj)
  (struct-ref obj (+ vtable-offset-user 2)))

;; We call make-struct here but we are actually making a vtable
;; We should check with struct-vtable?
;; name as symbol
(define* (make-fht name unwrap pointer-to points-to printer)
  ;;(simple-format #t "make-fht: ~S\n" name)
  (let* ((ty (make-struct/no-tail ffi-helper-type
				  (make-struct-layout "pw") ;; 1 slot for value
				  printer unwrap pointer-to points-to))
	 (vt (struct-vtable ty)))
    (set-struct-vtable-name! vt name)
    ty))

;; type printer for bytestructures-based types
(define (make-bs-printer type)
  (lambda (obj port)
    (display "#<" port)
    (display type port)
    (when #f
      (display " bs-desc:0x" port)
      (display (number->string
		(ffi:scm->pointer
		 (struct-ref obj 0))
		16) port))
    (when #t
      (display " 0x" port)
      (display (number->string
		(ffi:pointer-address
		 (ffi:scm->pointer
		  (bytestructure-bytevector
		   (struct-ref obj 0))))
		16) port))
    (display ">" port)))

;; @deffn {Syntax} define-fh-compound-type name desc
;; @deffnx {Syntax} define-fh-compound-type/p name desc
;; @deffnx {Syntax} define-fh-compound-type/pp name desc
;; The first form generates an FY aggregate type based on a bytestructure
;; descriptor.  The second and third forms will build, in addition,
;; pointer-to type and pointer-to-pointer-to type.
;; @end deffn
(define-syntax define-fh-compound-type
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ type desc)
       (with-syntax ((unwrap (gen-id x "unwrap-" #'type))
		     (type? (gen-id x #'type "?"))
		     (make (gen-id x "make-" #'type))
		     (wrap (gen-id x "wrap-" #'type))
		     (bs-ref (gen-id x #'type "-bs-ref")))
	 #'(begin
	     (define (unwrap obj)
	       (bytestructure-bytevector (struct-ref obj 0)))
	     (define type
	       (make-fht (quote type) unwrap #f #f
			 (make-bs-printer (quote type))))
	     (define (type? obj)
	       (and (fh-object? obj) (eq? (struct-vtable obj) type)))
	     #;(define (make . args)
	       (make-struct/no-tail type (apply bytestructure desc args)))
	     (define make
	       (case-lambda
		((arg)
		 (if (bytestructure? arg)
		     (make-struct/no-tail type arg)
		     (make-struct/no-tail type (bytestructure desc arg))))
		(args
		 (make-struct/no-tail type (apply bytestructure desc args)))))
	     (define (wrap raw)	; raw is bytevector
	       (make-struct/no-tail type (bytestructure desc raw)))
	     (define (bs-ref obj)
	       (struct-ref obj 0))
	     (export type type? make wrap unwrap bs-ref)))))))

;; @deffn {Procedure} ref<->deref! p-type type
;; This procedure will ``connect'' the two types so that the procedures
;; @code{pointer-to} and @code{points-to} work.
;; @end deffn
(define-syntax ref<->deref!
  (lambda (x)
    (define (gen-id tmpl-id . args)
      (define (stx->str stx) (symbol->string (syntax->datum stx)))
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ p-type type)
       (with-syntax ((p-make (gen-id x "make-" #'type "*"))
		     (p-desc (gen-id x  #'type "-*desc"))
		     (make (gen-id x "make-" #'type)))
	 #'(begin
	     (struct-set!		; pointer-to
	      type (+ vtable-offset-user 1)
	      (lambda (obj)
		(p-make
		 (ffi:pointer-address
		  (ffi:bytevector->pointer
		   (bytestructure-bytevector (struct-ref obj 0)))))))
	     (struct-set!		; points-to
	      type (+ vtable-offset-user 2)
	      (lambda (obj) ;; CHECK THIS
		(make (bytestructure-ref p-desc '* obj))))))))))

(define-syntax define-fh-compound-type/p
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ type desc)
       (with-syntax ((p-type (gen-id x #'type "*"))
		     (p-desc (gen-id x #'type "-*desc"))
		     (p-make (gen-id x "make-" #'type "*"))
		     (make (gen-id x "make-" #'type)))
	 #'(begin
	     (define-fh-compound-type type desc)
	     (define p-desc (bs:pointer desc))
	     (export p-desc)
	     (define-fh-compound-type p-type p-desc)
	     (ref<->deref! p-type type)))))))

(define-syntax define-fh-pointer-type
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ type desc)			; based on bytestructure
       (with-syntax ((p-desc (gen-id x #'type "-*desc"))
		     (p-make (gen-id x "make-" #'type "*"))
		     (make (gen-id x "make-" #'type))
		     (pred (gen-id x #'type "?"))
		     (wrap (gen-id x "wrap-" #'type))
		     (unwrap (gen-id x "unwrap-" #'type)))
	 (simple-format (current-error-port)
			"define-fh-pointer-type needs work\n")
	 #'(begin
	     (define p-desc (bs:pointer p-desc))
	     (export p-desc)
	     (define-fh-compound-type type desc))))
      ((_ type)		      ; based on guile pointer wrapper
       (with-syntax ((pred (gen-id x #'type "?"))
		     (wrap (gen-id x "wrap-" #'type))
		     (unwrap (gen-id x "unwrap-" #'type)))
	 #'(begin
	     (ffi:define-wrapped-pointer-type
	      type pred wrap unwrap
	      (lambda (obj port)
		(display "#<" port)
		(display (symbol->string (quote #'type)) port)
		(display " 0x" port)
		(display (number->string (ffi:pointer-address (unwrap obj)) 16)
			 port)
		(display ">" port)))
	     (export type pred wrap unwrap))))
      )))

(define-syntax define-fh-enum
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ type nv-map)			; based on bytestructure
       (with-syntax ((unwrap (gen-id x "unwrap-" #'type))
		     (wrap (gen-id x "wrap-" #'type))
		     (unwrap* (gen-id x "unwrap-" #'type "*"))
		     )
         #'(begin
	     (define wrap
	       (let ((vnl (map (lambda (pair) (cons (cdr pair) (car pair)))
			       nv-map)))
		 (lambda (code) (assq-ref vnl code))))
	     (define unwrap
	       (let ((nvl nv-map))
		 (lambda (name) (assq-ref nvl name))))
	     (define (unwrap* obj) ;; ugh
	       (error "pointer to enum type not done"))
	     (export wrap unwrap unwrap*)
	     ))))))

(define (make-enum-printer type)
  (lambda (obj port)
    (display "#<" port)
    (display type port)
    (display " " port)
    (display (struct-ref obj 0))
    (display ">" port)))

(define-syntax NEW-define-fh-enum-type
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ type nv-map)
       (with-syntax ((type? (gen-id x #'type "?"))
		     (make (gen-id x "make-" #'type))
		     (wrap (gen-id x "wrap-" #'type))
		     (unwrap (gen-id x "unwrap-" #'type)))
	 #`(begin
	     (define wrap
	       (let ((vnl (map (lambda (pair) (cons (cdr pair) (car pair)))
			       nv-map)))
		 (lambda (raw)
		   (make-struct/no-tail type (assq-ref vnl raw)))))
	     (define (unwrap obj)
	       (assq-ref nv-map (struct-ref obj 0)))
	     (define type
	       (make-fht (quote type) wrap unwrap #f #f
			 (make-enum-printer #'type)))
	     (define (type? obj)
	       (and (fh-object? obj)
		    (eq? (struct-vtable obj) type)))
	     (export make wrap unwrap type type?)))))))
	     
(define-syntax define-fh-function
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ name return-t args-t)
       (with-syntax ((wrap (gen-id x "wrap-" #'name))
		     (unwrap (gen-id x "unwrap-" #'name)))
	 #'(begin
	     (define (wrap proc)
	       (ffi:procedure->pointer return-t proc args-t))
	     (define (unwrap ptr)
	       (ffi:pointer->procedure return-t ptr args-t))
	     ))))))

(define-syntax define-fh-function/p
  (lambda (x)
    (define (stx->str stx)
      (symbol->string (syntax->datum stx)))
    (define (gen-id tmpl-id . args)
      (datum->syntax
       tmpl-id
       (string->symbol
	(apply string-append
	       (map (lambda (ss) (if (string? ss) ss (stx->str ss))) args)))))
    (syntax-case x ()
      ((_ name return-t args-t)
       (with-syntax ((wrap (gen-id x "wrap-" #'name))
		     (unwrap (gen-id x "unwrap-" #'name))
		     (wrap* (gen-id x "wrap-" #'name "*"))
		     (unwrap* (gen-id x "unwrap-" #'name "*")))
	 #'(begin
	     (define-fh-function name return-t args-t)
	     (define wrap* wrap)
	     (define unwrap* unwrap)
	     ))))))

;; right now this returns a ffi pointer
;; it should probably be a bs:pointer
(define (pointer-to obj)
  ((fht-pointer-to (struct-vtable obj)) obj))

;; now support for the base types
(define (unwrap~fixed obj)
  (cond
   ((number? obj) obj)
   ((bytestructure? obj) (bytestructure-ref obj))
   ((fh-object? obj) (struct-ref obj 0))
   (else (error "type mismatch"))))

(define unwrap~float unwrap~fixed)

;; unwrap-enum has to be inside module

;; FFI wants to see a ffi:pointer type
(define (unwrap~pointer obj)
  (cond
   ;;((ffi:pointer? obj) (ffi:pointer-address obj))
   ((ffi:pointer? obj) obj)
   ((bytestructure? obj) (ffi:make-pointer (bytestructure-ref obj)))
   ;;((fh-object? obj) (ffi:make-pointer (unwrap~pointer (struct-ref obj 0))))
   (else (error "expecting pointer type"))))

(define (wrap-void* raw)
  (ffi:make-pointer raw))

;; --- last line ---
;; (pointer->bytevector ptr len) => bytevector
;; (bytevector->pointer bv) => pointer

;; another way to handle this is to define the types
;; (define foo_t-desc (bs:struct ...))
;; (define-type foo_t foo_t-desc)
;; (define foo_t-*desc (bs:pointer foo_t-desc))
;; (define-type foo_t* foo_t-*desc)
;; (ref<->deref foo_t* foo_t)

;; typedef struct { ... } foo_t;
;; (define foo_t-desc (bs:struct ...))
;; (define-compound-type foo_t foo_t-desc)
;;   (define foo_t (make-struct ...))
;;   (define foo_t*-desc (bs:pointer foo_t-desc))
;; (define obj (make-foo_t #(...)))
;; (pointer-to obj) => p-obj
;; (unwrap-foo_t*
;;   (dereference-pointer
;;     (bytevector->pointer
;;        (bytestructure-bytevector p-obj))))

