;; examples/nyacc/lang/c99/tryit.scm

;; Copyright (C) 2020-2021 Matthew R. Wette
;; 
;; Copying and distribution of this file, with or without modification,
;; are permitted in any medium without royalty provided the copyright
;; notice and this notice are preserved.  This file is offered as-is,
;; without any warranty.

(add-to-load-path (getcwd))

(use-modules (nyacc lang c99 parser))
(use-modules (nyacc lang c99 cxeval))
(use-modules (nyacc lang c99 pprint))
(use-modules (nyacc lang c99 munge))
(use-modules (nyacc lang c99 munge-base))
(use-modules (nyacc lang c99 cpp))
(use-modules (nyacc lang c99 util))
(use-modules (nyacc lang c99 ffi-help))
(use-modules (nyacc lang sx-util))
(use-modules (nyacc lang util))
(use-modules (nyacc lex))
(use-modules (nyacc util))
(use-modules (sxml fold))
(use-modules (sxml xpath))
(use-modules ((srfi srfi-1) #:select (fold-right)))
(use-modules (ice-9 pretty-print))

(define (sf fmt . args) (apply simple-format #t fmt args))
(define pp pretty-print)
(define ppin (lambda (sx) (pretty-print sx #:per-line-prefix "  ")))
(define pp99 (lambda (sx) (pretty-print-c99 sx #:per-line-prefix "  ")))
(define cep current-error-port)
(define (sferr fmt . args) (apply simple-format (cep) fmt args))
(define (pperr sx) (pretty-print sx (cep) #:per-line-prefix "  "))
(define (ppe99 sx) (pretty-print-c99 sx (cep) #:per-line-prefix "  "))

(define *cpp-defs* (get-gcc-cpp-defs))
(define *inc-dirs* (get-gcc-inc-dirs))
(define *inc-help* c99-def-help)

(define *mode* (make-parameter 'code))
(define *debug* (make-parameter #f))
(define *xdef?* (lambda (name mode) (memq mode '(code decl))))

(define* (parse-file file #:key cpp-defs inc-dirs mode debug)
  (with-input-from-file file
    (lambda ()
      (parse-c99 #:cpp-defs (or cpp-defs *cpp-defs*)
		 #:inc-dirs (or inc-dirs *inc-dirs*)
		 #:inc-help *inc-help*
		 #:mode (or mode (*mode*))
		 #:debug (or debug (*debug*))
		 #:show-incs #f
		 #:xdef? *xdef?*))))

(define* (parse-string str
		       #:optional (tyns '())
		       #:key cpp-defs inc-dirs mode debug)
  (with-input-from-string str
    (lambda ()
      (parse-c99 tyns
		 #:cpp-defs (or cpp-defs *cpp-defs*)
		 #:inc-dirs (or inc-dirs *inc-dirs*)
		 #:inc-help *inc-help*
 		 #:mode (or mode (*mode*))
		 #:debug (or debug (*debug*))
		 #:show-incs #f
		 #:xdef? *xdef?*))))

(define (parse-string-list . str-l)
  (parse-string (apply string-append str-l)))

(use-modules (nyacc lang arch-info))
(use-modules ((system foreign) #:prefix ffi:))
(use-modules (ice-9 match))

(define (fold p s l)
  (let loop ((s s) (l l))
    (if (null? l) s (loop (p (car l) s) (cdr l)))))

(define-syntax-rule (pass-if mesg expr)
  (begin
    (display mesg)
    (newline)
    (pp expr)))

(define (remove-comments tree)
  (define (fD seed tree) '())
  (define (fU seed kseed tree)
    (sx-match tree
      ((comment ,text) seed)
      (,_ (if (pair? seed) (cons (reverse kseed) seed) (reverse kseed)))))
  (define (fH seed node) (cons node seed))
  (foldts fD fU fH '() tree))

(when #f
  (let* ((code "int foo = sizeof(int(*)());")
	 (tree (or (parse-string code) (error "parse failed")))
	 (udict (c99-trans-unit->udict tree))
	 (udecl (assoc-ref udict "foo"))
	 (expr (sx-ref* udecl 2 2 1))
	 )
    (sf "declaration::\n")
    (pp udecl)
    (sf "extract initializer expression:\n")
    (pp expr)
    (sf "evaluate:\n")
    (sf "x = ~S\n" (eval-c99-cx expr))))
(when #f
  (let* ((code "int intx;\n")
	 (tree (or (parse-string code) (error "parse failed")))
	 )
    (sf "~A\n" code)
    (ppin tree)
    (pp99 tree)
    ))
(when #f
  (let* ((code "int foo(int x) asm(\"foo\");")
	 ;;(code "int foo(int x);")
	 (tree (parse-string code)))
    (pp code) (pp tree) (pp99 tree) (newline)
    ))
(when #f
  (let* ((code "*(x->y->z)")
	 (tree (parse-c99x code)))
    (pp code) (pp tree) (pp99 tree) (newline)
    ))
(when #f
  (let* ((code
	  (string-append
	   "void foo() { __asm__ goto (\"mov r0,r1\" : "
	   ": [mcu] \"I\" (123), [ssr] \"X\" (456) "
	   " : \"foo\", \"bar\" : error ); }"))
	 (tree (parse-string code #:mode 'decl))
 	 )
    (pp tree)
    #t))

(when #f
  (let* ((code
	  (string-append
	   "#define sei() __asm__ __volatile__ (\"sei\" ::: \"memory\")\n"
	   "int foo() { sei(); }\n"
	   ))
	 (tree (parse-string code #:mode 'code))
 	 )
    #t))
(when #f
  (let* ((code "int foo() { spice->meas[1].pin = &mega->portD.pin[0]; }\n")
	 (tree (parse-string code #:mode 'code)))
    (pp tree)
    #t))

(when #f
  (let* ((code
	  (string-append
	   "#define ISR(vector, ...) void vector (__VA_ARGS__) \n"
	   "ISR(__vector__12__) { int x; }\n"))
	 (tree (parse-string code #:mode 'code)))
    (pp tree)
    (pp99 tree)
    ))

(when #f
  (let* ((code "typedef enum { A, B=3, C } foo;")
	 (tree (or (parse-string code) (error "parse failed")))
	 (udict (c99-trans-unit->udict tree))
	 (udecl (assoc-ref udict "foo"))
	 (edl (sx-ref* udecl 1 2 1 1))
	 (xxx (canize-enum-def-list edl))
	 )
    (pp udecl)
    (pp edl)
    (pp xxx)
    ))

(when #f
  (let* ((code
	  (string-append
	   #|
	   "int foo() {\n"
	   "  typedef int foo_t;\n"
	   "  {\n"
	   "    typedef int foo_t[3];\n"
	   "    1;\n"
	   "  }\n"
	   "}\n"
	   |#
	   "typedef int foo_t;\n"
	   "int foo() {\n"
	   "  typedef int foo_t[3];\n"
	   "  1;\n"
	   "}\n"
	   ))
	 (tree (parse-string code #:mode 'code)))
    (pp tree)))

(when #f                               ; bug #60474
  (let* ((code
	  (string-append
	   "const int x = 1;\n"
	   ))
	 (tree (parse-string code #:mode 'code))
	 (udict (c99-trans-unit->udict tree))
	 (udecl (assoc-ref udict "x"))
	 (specl (sx-ref udecl 1))
	 (declr (sx-ref udecl 2))
	 )
    (pp udecl)
    (call-with-values (lambda () (cleanup-udecl specl declr))
      (lambda (specl declr)
	(pp `(udecl ,specl ,declr))))
    ))

(when #f
  (let* ((code
	  (string-append
	   "#define bar(X) #X\n"
	   "#define foo(X) bar(X)\n"
	   "char *s = foo('abc');\n"))
	 (tree (parse-string code #:mode 'decl)))
    (pp tree)))

(when #f
  (let* ((code
	  (string-append
           "#if 1\n"
           "#define g_abort() abort ()\n"
           "#else\n"
           "void g_abort (void);\n"
           "#endif\n"
           "int x;\n"))
	   (tree (parse-string code #:mode 'decl)))
	  (pp tree)
	  ))

(when #f
  (let* ((code
	  (string-append
	   "typedef struct { int x; double y; } foo_t;\n"
	   ;;"void bar(foo_t);\n"
	   "int x = sizeof(foo_t);\n"
	   ))
	 (tree (parse-string code #:mode 'code))
	 )
    (pp tree)
    ))

(when #f
  (let* ((code
	  (string-append
	   "const int x = 1;\n"
	   ))
	 (tree (parse-string code #:mode 'code))
	 (udict (c99-trans-unit->udict tree))
	 (udecl (assoc-ref udict "x"))
	 (specl (sx-ref udecl 1))
	 (declr (sx-ref udecl 2))
	 )
    (pp udecl)
    (pp (cleanup-udecl specl declr))
    ))

(when #t
  (let* ((code
	  (string-append
	   "typedef struct {\n"
	   " int x;\n"
	   " union { int a; int b; };\n"
	   " int y;\n"
	   " union { int c[3]; double d; };\n"
	   ;;" int z;\n"
	   "} foo_t;\n"
	   "foo_t s1;\n"
	   ))
	 (tree (parse-string code #:mode 'code))
	 (udict (c99-trans-unit->udict tree))
	 (udecl (assoc-ref udict "s1"))
	 (udecl (expand-typerefs udecl udict))
	 (mdecl (udecl->mdecl udecl))
	 (mtail (cdr mdecl))
	 )
    ;;(pp tree)
    ;;(pp udecl)
    ;;(pp mdecl)
    ;;(pp (mtail->bs-desc mtail))
    (pp (mtail->ffi-desc mtail))
    ))

(when #f				; bug #60474
  (let* ((code
	  (string-append
	   "const int x = 1;\n"
	   ))
	 (tree (parse-string code #:mode 'code))
	 (udict (c99-trans-unit->udict tree))
	 (udecl (assoc-ref udict "x"))
	 (specl (sx-ref udecl 1))
	 (declr (sx-ref udecl 2))
	 )
    (pp udecl)
    (call-with-values (lambda () (cleanup-udecl specl declr))
      (lambda (specl declr)
	(pp `(udecl ,specl ,declr))))
    ))

;; --- last line ---
