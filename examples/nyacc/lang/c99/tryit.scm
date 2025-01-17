;; examples/nyacc/lang/c99/tryit.scm

;; Copyright (C) 2020-2024 Matthew Wette
;;
;; Copying and distribution of this file, with or without modification,
;; are permitted in any medium without royalty provided the copyright
;; notice and this notice are preserved.  This file is offered as-is,
;; without any warranty.

;;(add-to-load-path (getcwd))

(use-modules (ice-9 pretty-print))
(use-modules (ice-9 match))
(use-modules ((srfi srfi-1) #:select (last fold-right fold)))
(use-modules (srfi srfi-11))            ; let-values
(use-modules (rnrs arithmetic bitwise))
(use-modules ((system foreign) #:prefix ffi:))
(use-modules (sxml fold))
(use-modules ((sxml xpath) #:hide (filter)))

(use-modules (nyacc lang c99 parser))
(use-modules (nyacc lang c99 cxeval))
(use-modules (nyacc lang c99 pprint))
(use-modules (nyacc lang c99 munge))
(use-modules (nyacc lang c99 munge-base))
(use-modules (nyacc lang c99 cpp))
(use-modules (nyacc lang c99 util))
(use-modules (nyacc lang c99 ffi-help))
(use-modules (nyacc lang arch-info))
(use-modules (nyacc lang sx-util))
(use-modules (nyacc lang util))
(use-modules (nyacc lex))
(use-modules (nyacc util))


(define (sf fmt . args) (apply simple-format #t fmt args))
(define pp pretty-print)
(define ppin (lambda (sx) (pretty-print sx #:per-line-prefix "  ")))
(define pp99 (lambda (sx) (pretty-print-c99 sx #:per-line-prefix "  ")))
(define cep current-error-port)
(define (sferr fmt . args) (apply simple-format (cep) fmt args))
(define (pperr sx) (pretty-print sx (cep) #:per-line-prefix "  "))
(define (ppe99 sx) (pretty-print-c99 sx (cep) #:per-line-prefix "  "))

(define (pp99s exp)
  (call-with-output-string (lambda (port) (pretty-print-c99 exp port))))


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

;; bug #60474
(when #f
  (let* ((code "const int x = 1;\n")
         (tree (parse-string code #:mode 'code))
         (udict (c99-trans-unit->udict tree))
         (udecl (assoc-ref udict "x"))
         (specl (sx-ref udecl 1))
         (declr (sx-ref udecl 2)))
    (pp udecl)
    (call-with-values (lambda () (cleanup-udecl specl declr))
      (lambda (specl declr)
        (pp `(udecl ,specl ,declr))))))

(when #f
  (let* ((code "typedef int foo_t; foo_t foo[] = { 1, 2, 3, 4 };" )
         (tree (parse-string code #:mode 'decl))
         (udict (c99-trans-unit->udict tree)))
    (pp tree)
    (pp udict)))

;; with-arch from (nyacc lang arch-info)
(when #f
  (let* ((code
          (string-append
           "typedef struct {\n"
           "  char c;\n"
           "  void *p;\n"
           "} foo_t;\n"
           ))
         (tree (parse-string code #:mode 'code))
         (udict (c99-trans-unit->udict tree))
         (udecl (assoc-ref udict "foo_t"))
         (type-name '(type-name (decl-spec-list (type-spec (typename "foo_t")))))
         )
    (display code) (newline)
    (with-arch "native"
      (sf "native:\n")
      (sf "  size=~S\n" (eval-sizeof-type `(sizeof-type ,type-name) udict))
      (sf "  align=~S\n" (eval-alignof-type `(alignof-type ,type-name) udict)))
    (with-arch "avr"
      (sf "avr:\n")
      (sf "  size=~S\n" (eval-sizeof-type `(sizeof-type ,type-name) udict))
      (sf "  align=~S\n" (eval-alignof-type `(alignof-type ,type-name) udict)))
    ))

(when #f
  ;; bad printout: typedef (const) void *gconstpointer;
  ;; fixed
  (let* ((tree  '(udecl (decl-spec-list
                         (stor-spec (typedef))
                         (type-qual (const))
                         (type-spec (void)))
                        (init-declr
                         (ptr-declr (pointer) (ident "gconstpointer"))))))
    (pretty-print-c99 tree)))

;; symbol could have init-zer so need
;; (initzer->data

;; shortened types?
;; (decl (decl-spec-list (type-spec ...)) (declr-list (declr))
;; => (type (type-spec ...) (param-declr ...)

;; @deffn {Procedure} num-lit-suffix lit-str => list
;; Return the trailing characters in a numeric literal.
;; @end deffn
(define (num-lit-suffix lit-str)
  (let loop ((chl '()) (ix (1- (string-length lit-str))))
    (cond
     ((zero? ix) chl)
     ((char-numeric? (string-ref lit-str ix)) chl)
     (else (loop (cons (string-ref lit-str ix) chl) (1- ix))))))

;; @deffn literal-type-spec
;; For a literal return a reasonable type spec. @*
;; @end deffn
(define (literal-type-spec lit)
  (match lit
    (`(fixed-type ,sval) `(fixed-type "int"))
    ))

(when #f
  (let* ((code
          (string-append
           ;;"enum { NN = sizeof(int), MM = sizeof(long) };\n"
           "typedef enum { N1 = 1, N2 = 2 } num_t;\n"
           "typedef struct { int m; double b[N2]; } bar_t;\n"
           ;;"typedef struct { int x; double z[3][4]; bar_t bar; } foo1_t;\n"
           ;;"typedef struct { int r; double c[2]; } foo2_t;\n"
           ;;"typedef struct { int s; double d[5]; } foo3_t;\n"
           ;;"typedef struct { foo1_t f1; foo2_t *f2; foo3_t f3[N]; } foo_t;\n"
           ))
         (tree (parse-string code))
         (udict (c99-trans-unit->udict tree))
         (udict (udict-add-enums udict))
         ;;(udecl (udict-ref udict "foo_t"))
         (udecl (udict-ref udict "bar_t"))
         (xdecl (expand-typerefs udecl udict))
         (mdecl (udecl->mdecl xdecl))
         (mtail (cdr mdecl))
         )
    ;;(sf "~A\n" code)
    ;;(pp udict)
    (pp (sizeof-mtail mtail udict))
    (pp (find-offsets mtail udict))
    0))

(when #f
  (let* ((code
          (string-append
           "typedef struct { double d; char c; } foo_t[3];\n"
           "int x = sizeof(foo_t);\n"
           ))
         (tree (parse-string code))
         (udict (c99-trans-unit->udict tree))
         ;;(udecl (udict-ref udict "x"))
         (foo-t '(type-name
                  (decl-spec-list (type-spec (typename "foo_t")))))
         (sz-exp `(sizeof-type ,foo-t))
         )
    (sf "Expect (3 . 16), get:\n")
    (pp (find-offsets foo-t udict))
    (pp (find-sizes foo-t udict))
    (sf "\ntotal size = ~A\n" (eval-sizeof-type sz-exp udict))
    0))

(when #f
  (let* ((code "int foo = sizeof(\"$ABCDEF\")*2;")
         (tree (or (parse-string code) (error "parse failed")))
         (udict (c99-trans-unit->udict tree))
         (udecl (assoc-ref udict "foo"))
         (expr (sx-ref* udecl 2 2 1))
         )
    (sf "declaration::\n")
    (pp udecl)
    (sf "evaluate:\n")
    (sf "x = ~S\n" (eval-c99-cx expr))))

(when #f
  (let* ((code
          (string-append
           "typedef enum let { A = 1, B = 2 } let_t;\n"
           "typedef struct { double x; let_t y; } foo_t;\n"
           ;;"int res = sizeof(foo_t);\n"
           ))
         (tree (parse-string code))
         (udict (c99-trans-unit->udict tree))
         (foo-t '(type-name
                  (decl-spec-list (type-spec (typename "foo_t")))))
         )
    (pp (find-types foo-t udict '("let_t")))
    0))

;; bug 57949
(when #f
  (let* ((code "
typedef struct _GObjectClass {
  void *construct_properties;
  void *(*constructor)(unsigned long type, unsigned int n_construct_properties
      , void *construct_properties); } GObjectClass;\n")
         (code "struct foo { void bar(void); };\n")
         (tree (parse-string code))
         (tree (remove-comments tree))
         (udict (c99-trans-unit->udict tree))
         ;;(udecl (assoc-ref udict "GObjectClass"))
         ;;(udecl (assoc-ref udict '(struct . "_GObjectClass")))
         (udecl (assoc-ref udict '(struct . "foo")))
         (fdecl (fh-cnvt-udecl udecl udict))
         (sdecl (with-input-from-string fdecl read))
         )
    ;;(pp udecl)
    (display fdecl)
    ;;(pp sdecl)
    0))

;; bug 62546
(when #f
  (let* ((code "#define FOO(/*hello*/X) (X)\nint x = FOO(1);\n")
         (tree (parse-string code)))
    (pp tree)
    0))

(when #f
  (*debug* #t)
  ;;(pperr (parse-string "int (foo);"))
  ;;(pperr (parse-string "int (bar)();"))
  (pperr (parse-string "int foo(foo_t);"))
  (newline (current-error-port))
  (pperr (parse-string "typedef int foo_t; int foo(foo_t x);"))
  )

(when #f
  (let* ((tree (parse-file "zz.c"))
         (stmt (last tree))
         (sngl `(trans-unit ,stmt))
         )
    (pp sngl)
    (pp99 sngl)
    0))

;; source-properties
(when #f
  (let* ((tree (parse-file "test1.c"))
         (node (and tree (sx-ref* tree 1)) )
         )
    (pp node)
    (sf "(source-properties node) => ~S\n" (source-properties node))
    ;;(pp99 tree)
    #t))

(when #f
  (let* ((code
          (string-append
           "typedef struct foo foo_t;\n"
           "typedef struct foo { int x; } foo_t;\n"
           ;;"int bar(foo_t *foo_t);\n"
           "int bar(foo_t foo_t);\n"    ; works
           ))
         (tree (parse-string code))
         )
    (pp tree)))


(when #f
  (let* ((code
          (string-append
           "int (*foo)();\n"
           ;;"int (*bar);\n"
           ))
         (tree (parse-string code))
         )
    (pp tree)))

;; bug #63604
(when #f
  ;;(*debug* #t)
  (let* ((code "int foo(const float color[static 4]);")
         ;;(code "float color[static 4];")
         (tree (parse-string code))
         )
    (pp tree)
    ))

(when #f
  (let* ((code "char *f = \"hello\\n\\\"world\\\"\";")
         (tree (parse-string code))
         )
    (pp tree)
    (pp99 tree)
    ))

(when #f
  (let* ((make-cpi (@@ (nyacc lang c99 parser) make-cpi))
         (defs '("FOO=1" "BAR(X)=(X+1)"))
         (info (make-cpi #f #f defs '(".") '())))
    (pp info)
    #f))

(when #f
  (let* ((code
          (string-append
           "#define X 1\n"
           "int x1 = X;\n"
           "#pragma push_macro(\"X\")\n"
           "int x2 = X;\n"
           "#undef X\n"
           "int x3 = X;\n"
           "#define X 2\n"
           "int x4 = X;\n"
           "#pragma pop_macro(\"X\")\n"
           "int x5 = X;\n"
           ))
         (tree (parse-string code))
         )
    ;;(pp tree)
    #f))

#|
(define (specl-type specl)
    (sx-match (sx-find 'type-spec (sx-tail specl))
      ((type-spec (fixed-type ,name))
       name)
      ;; May need case for ((type-spec (typename "foo_t"))
      (,hmm (sf "missed ~S\n" hmm) (quit))
      ))

;; new: need alignof before sizeof
(define (sizeof-mtail mtail udict) ;; => (values size align)

  (define (exec/decl decl size base-align update)
    (let ((mtail (sx-tail (sx-find 'type-spec (sx-ref decl 1))))
          (declrs (or (and=> (sx-ref decl 2) sx-tail) '((ident "_")))))
      (let loop ((size size) (base-align base-align) (declrs declrs))
        (if (null? declrs)
            (values size base-align)
            (call-with-values
                (lambda ()
                  (sizeof-mtail
                   (cdr (m-unwrap-declr (car declrs) mtail)) udict))
              (lambda (elt-sz elt-al)
                (loop (update elt-sz elt-al size)
                      (max elt-al base-align) (cdr declrs))))))))

  (match mtail
    (`((pointer-to) . ,rest)
     (values (sizeof-basetype '*) (alignof-basetype '*)))
    (`((fixed-type ,name))
     (values (sizeof-basetype name) (alignof-basetype name)))
    (`((float-type ,name))
     (values (sizeof-basetype name) (alignof-basetype name)))
    (`((array-of ,dim) . ,rest)
     (let ((mult (eval-c99-cx dim udict)))
       (call-with-values
           (lambda ()
             (sizeof-mtail rest udict))
         (lambda (size align)
           (values (* mult size) align)))))
    (`((struct-def (field-list . ,fields)))
     (let loop ((size 0) (align 0) (flds fields))
       (cond
        ((null? flds) (values (incr-size 0 align size) align))
        ((eq? 'comp-decl (sx-tag (car flds)))
         (call-with-values
             (lambda () (exec/decl (car flds) size align incr-size))
           (lambda (size align)
             (loop size align (cdr flds)))))
        (else (loop size align (cdr flds))))))
    (`((struct-def (ident ,name) (field-list . ,fields)))
     (sizeof-mtail `((struct-def (field-list . ,fields))) udict))
    (`((union-def (field-list . ,fields)))
     (let loop ((size 0) (align 0) (flds fields))
       (cond
        ((null? flds) (values (incr-size 0 align size) align))
        ((eq? 'comp-decl (sx-tag (car flds)))
         (call-with-values
             (lambda () (exec/decl (car flds) size align maxi-size))
           (lambda (size align)
             (loop size align (cdr flds)))))
        (else (loop size align (cdr flds))))))
    (`((union-def (ident ,name) (field-list . ,fields)))
     (sizeof-mtail `((union-def (field-list . ,fields))) udict))
    (`((enum-ref . ,rest))
     (values (sizeof-basetype "int") (alignof-basetype "int")))
    (`((enum-def . ,rest))
     (values (sizeof-basetype "int") (alignof-basetype "int")))
    (_ (sferr "c99/eval-sizeof-mtail: missed\n") (pperr mtail)
       (throw 'c99-error "coding error"))))

(define* (sizeof-specl/declr specl declr #:optional (udict '())) ;; => values
  (let* ((udecl `(udecl ,specl ,declr))
         (xdecl (expand-typerefs udecl udict))
         (mdecl (udecl->mdecl xdecl)))
    (sizeof-mtail (cdr mdecl) udict)))
|#

#|
|#
;; bitfield offset size pos
;; most C compilers:
;; For many C compilers the type written for a named bit-field (int, short,
;; or other integer type) imposes an alignment for the entire structure, as
;; if the structure really did contain an ordinary field of that type.  In
;; addition, the bit-field is placed within the structure so that it would
;; fit within such a field, not crossing a boundary for it.

;; type for unnamed bitfield does not affect alignment
(define (bitfield-aln flds)

  #;(let loop ((bfal 0) (flds flds))
    (if (null? flds) bfal
        (sx-match (car flds)
          ;;
          )))

  #f)

#;(define (process-flds fields)
  (define soi (sizeof-basetype "int"))
  (let loop ((offs base) (aln 0) (dsg #f)
             (decls '()) (flds fields))
    (if (null? flds) size
        (sx-match (car flds)
          ((comp-udecl
            ,specl
            (comp-declr (bit-field (ident ,name) (p-expr (fixed ,bsiz)))))
           (let ((bsiz (string->number bsiz)))
             (if (> (+ shift bsiz) soi)
                 (loop (+ offs soi) bsiz dsg decls (cdr flds))
                 (loop offs (+ shift bsiz) dsg decls (cdr flds)))))
          (,_
           (pp (car flds))
           (loop offs aln dsg decls (cdr flds)))
          ))))

;; eval-sizeof-mtail mmissed:
;; ((bit-field (p-expr (fixed "16"))))
;;  (fixed-type "unsigned int"))

(when #f
  (let* ((code
          (string-append
           "struct foo {\n"
           ;;"  int x;\n"
           "  int y1: 1;\n"
           "  long : 0;\n"
           "  int y2: 2;\n"
           ;;"  int y3: 3;\n"
           ;;"  int z;\n"
           "} x;\n"
           ))
         (tree (parse-string code))
         (flds0 (sx-tail (sx-ref* tree 1 1 1 1 2)))
         (flds1 (fold-right dictize-decl '() flds0))
         (flds1 (fold-right unitize-decl '() flds0))
         (flds (map udecl->mdecl flds1))
         )
    ;;(pp tree)
    ;;(pp decl)
    ;;(pp flds0)
    ;;(pp flds1)
    (pp flds)
    ;;(process-flds flds)
    #f))

;; __builtin_offsetof(...)
;; --- last line ---
