;;; nyacc/lang/mlang/compile-tree-il.scm compile mlang sxml to tree-il

;; Copyright (C) 2018,2023 Matthew Wette
;;
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;;
;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public License
;; along with this library; if not, see <http://www.gnu.org/licenses/>

;;; Notes:

;; limitations:
;; 1) Variables cannot be introduced by lhs expression.  That is,
;;    The variable @code{a} can be generated by @code{a = 1} but not by
;;    @code{a(1) = 1} or @code{a.x = 1}.

;;; Code:

(define-module (nyacc lang mlang compile-tree-il)
  #:export (compile-tree-il show-mlang-sxml show-mlang-xtil)
  #:use-module (nyacc lang mlang xlib)
  #:use-module (nyacc lang nx-lib)
  #:use-module (nyacc lang nx-util)
  #:use-module (nyacc lang sx-util)
  #:use-module ((sxml fold) #:select (foldts*-values))
  #:use-module ((srfi srfi-1) #:select (fold fold-right append-reverse last))
  #:use-module (language tree-il)
  #:use-module (ice-9 match))

(define (sferr fmt . args)
  (apply simple-format (current-error-port) fmt args))
(use-modules (ice-9 pretty-print))
(define (pperr tree)
  (pretty-print tree (current-error-port) #:per-line-prefix "  " #:width 130))

(define xlib-mod '(nyacc lang mlang xlib))
(define xlib-module (resolve-module xlib-mod))
(define (xlib-ref name) `(@@ (nyacc lang mlang xlib) ,name))

(define (op-call op kseed)
  (rev/repl 'call (xlib-ref op) kseed))

(define (lookup name dict)
  (or (nx-lookup name dict)
      (nx-lookup-in-env name xlib-module)))

;; This will push undeclared lexicals up one level.  Needs cleanup?
(define (pop-scope dict)
  (let ((pdict (nx-pop-scope dict)))
    (let loop ((prev #f) (next dict))
      (cond
       ((eq? '@L (caar next)) (cond (prev (set-cdr! next pdict) dict)
                                    (else pdict)))
       ((eq? '@P (caar next)) (cdar next))
       (else (loop (car next) (cdr next)))))))

;; @deffn {Procedure} function-scope? dict
;; Looks up the dict levels to see if there exists a @code{'@F} tag,
;; which denotes that context is in a function.
;; @end deffn
(define (function-scope? dict)
  (let loop ((dict dict))
    (cond
     ((nx-top-level? dict) #f)
     ((assq '@F dict) #t)
     (else (loop (nx-pop-scope dict))))))

(define (maybe-add-symbol name dict)
  (if (lookup name dict) dict (nx-add-symbol name dict)))

;; Add toplevel def's from dict before evaluating expression.  This puts
;; @var{expr} at the end of a chain of @code{seq}'s that execution
;; conditional defines to a void.  See @code{make-toplevel-defcheck}.
(define (add-topdefs dict expr)
  (let loop ((refs dict))
    (cond
     ((null? refs) expr)
     ((string? (caar refs)) ;; add define if not in toplevel
      (let* ((env0 (lookup '@M dict))
             (name (caar refs))
             (ref (nx-lookup-in-env name env0)))
        (if ref
            (loop (cdr refs))
            `(seq (define ,(string->symbol name) (void)) ,(loop (cdr refs))))))
     ((eq? '@top (caar refs)) expr)
     (else (loop (cdr refs))))))

;; @deffn {Procedure} display-result? tree
;; Predicate that looks at @code{term} attribute to determine if user wants
;; the result of this statement displayed.  In Guile, this is implemented as
;; a return value for the translated statement.
;; @end deffn
(define (display-result? tree)
  (and=> (sx-attr-ref tree 'term)
         (lambda (t) (not (string=? t ";")))))

;; @deffn {Procedure} make-for lvar iter body dict
;; lvar: loop variable -- (lexical i i-1234) or (toplevel i)
;; @var{iter} is an iterator
;; TODO: deal with cases where lvar is local scope or non-local scope
;; @example
;; (let loop (($ivar (iter-first iter)))
;;    (when $ivar
;;      (set! lvar $ivar)
;;      body 
;;      (loop (iter:next $iter $ivar))))
;; @end example
;; @end deffn
(define-public (make-for lvar expr body dict)
  (let* ((toplev? (eq? 'toplevel (car lvar)))
         (ivar `(lexical $ivar ,(genxsym "$ivar")))
         ;;
         (rsym (genxsym "$iter")) (rval `(lexical $iter ,rsym))
         (frst `(call ,(xlib-ref 'ml:iter-first) ,rval))
         (next `(call ,(xlib-ref 'ml:iter-next) ,rval ,ivar)) ; ???
         (ilsym (genxsym "iloop"))
         (olsym (genxsym "oloop"))
         (bsym (nx-lookup-gensym "break" dict))
         (csym (nx-lookup-gensym "continue" dict))
         (inext `(call (lexical iloop ,ilsym) ,next))
         (ifrst `(call (lexical iloop ,ilsym) ,frst))
         (ocall `(call (lexical oloop ,olsym)))
         (iloop `(lambda ((name . iloop))
                   (lambda-case (((,(cadr ivar)) #f #f #f () (,(caddr ivar)))
                                 (if ,ivar
                                     (seq (set! ,lvar ,ivar)
                                          (seq ,body ,inext))
                                     (void))))))
         (ohdlr `(lambda () (lambda-case (((k) #f #f #f () (,(genxsym "k")))
                                          ,inext))))
         (oloop (make-thunk `(prompt #t (lexical continue ,csym) ,ifrst ,ohdlr)
                            #:name 'oloop))
         (hdlr `(lambda () (lambda-case (((k) #f #f #f () (,(genxsym "k")))
                                         (void)))))
         )
    ;; NOTE: the range could also go into the letrec
    `(let ($iter break continue) (,rsym ,bsym ,csym)
          (,expr
           (primcall make-prompt-tag (const break))
           (primcall make-prompt-tag (const continue)))
          (letrec (iloop oloop) (,ilsym ,olsym) (,iloop ,oloop)
                  (prompt #t (lexical break ,bsym) ,ocall ,hdlr)))))

;; turn
;; @example
;;  ((set! (lexical foo foo-1) (lambda ...) (set! (lexical bar bar-1) ...)
;; into
;;  ((foo bar ...) (foo-1 bar-1 ...) ((lambda ...) (lambda ...) ...))
;; @end example
(define (funcs->letrec main rest)
  (let loop ((names '()) (gsyms '()) (vals '()) (funcs rest))
    (if (null? funcs)
        (let* ((nref (cadr main)) (name (cadr nref)) (gsym (caddr nref))
               (names (cons name (reverse names)))
               (gsyms (cons gsym (reverse gsyms)))
               (vals (cons (caddr main) (reverse vals))))
          `(letrec ,names ,gsyms ,vals ,nref))
        (let* ((func (car funcs)) (nref (cadr func))
               (name (cadr nref)) (gsym (caddr nref)))
          (loop (cons name names) (cons gsym gsyms) (cons (caddr func) vals)
                (cdr funcs))))))

;;(define (trim-func-names dict)

;; @deffn {Procedure} xlang-sxml->xtil exp env opts
;; Compile extension SXML tree to external Tree-IL representation.
;; This one is public because it's needed for debugging the compiler.
;; @end deffn
(define (xlang-sxml->xtil exp env opts)

  (define (rem-empties stmts)
    (filter (lambda (item) (not (eq? 'empty-stmt (sx-tag item)))) stmts))
  
  (define (fD tree seed dict) ;; => tree seed dict
    (define +SP (make-+SP tree))

    (sx-match tree

      ((ident ,name)
       (if (member name '("nargsin" "nargsout"))
           (let ((dict (nx-add-lexicals "nargsin" "nargsout" dict)))
             (values '() (lookup name dict) dict))
           (values '() (lookup name dict) dict)))

      ((fixed ,sval)
       (values '() `(const ,(string->number sval)) dict))

      ((float ,sval)
       (values '() `(const ,(string->number sval)) dict))

      ((string ,sval)
       (values '() `(const ,sval) dict))

      ((sel (ident ,name) ,expr)
       (values `(sel ,name ,expr) '() dict))

      ((switch ,expr . ,rest)
       ;; Convert
       ;;  (switch expr (case a stmtL) (case b stmtL) ... (otherwise stmtL))
       ;; to
       ;;  (xswitch expr (xif expr stmtL (xif expr stmtL ...  stmtL))
       (values
        `(xswitch ,expr
                  ,(let loop ((tail rest))
                     (cond
                      ((null? tail) '(empty-stmt))
                      ((eq? 'otherwise (sx-tag (car tail)))
                       (sx-ref (car tail) 1))
                      ((eq? 'case (sx-tag (car tail)))
                       `(xif (eq (ident "swx-val") ,(sx-ref (car tail) 1))
                             ,(sx-ref (car tail) 2) ,(loop (cdr tail))))
                      (else (nx-error "unsupported case-expr")))))
        '()
        (acons '@L "switch"
               (nx-add-lexicals "swx-val" "break" (nx-push-scope dict)))))

      ((if ,expr ,stmts . ,rest)
       ;; Convert
       ;;  (if expr stmt (elseif expr stmt) ... (else stmt))
       ;; to
       ;;  (xif expr stmt (xif expr stmt ...  stmt))
       (values
        `(xif ,expr ,stmts
              ,(let loop ((tail rest))
                 (cond
                  ((null? tail) '(empty-stmt))
                  ((eq? 'else (sx-tag (car tail))) (sx-ref (car tail) 1))
                  ((eq? 'elseif (sx-tag (car tail)))
                   `(xif ,(sx-ref (car tail) 1) ; cond
                         ,(sx-ref (car tail) 2) ; then
                         ,(loop (cdr tail))))   ; else
                  (else (nx-error "oops")))))
        '() dict))

      ((while . ,rest)
       (values tree '()
               (acons '@L "while"
                      (nx-add-lexicals "break" "continue" (nx-push-scope dict)))))

      ((for (ident ,name) . ,rest)
       ;;(sferr "for:\n") (pperr tree)
       (let* ((ref (lookup name dict))
              (dict (if (and ref (eq? 'lexical (car ref))) dict
                        (nx-add-symbol name dict)))
              (dict (nx-push-scope dict))
              (dict (nx-add-lexicals "break" "continue" dict)))
         (values tree '() dict)))
      ((for . ,rest) (nx-error "syntax error: for"))

      ;; (assn (ident ,name) ,rhs))=> (var-assn (ident ,name) ,rhs)
      ;; (assn (aref-or-call ,aexp ,expl)) => (elt-assn ,aexp ,expl ,rhs)
      ;; (assn (sel ,ident ,expr) ,rhs) => (mem-assn ,ident ,expr ,rhs)
      ;; (assn . ,other) => syntax error
      ((assn (@ . ,attr) (ident ,name) ,rhsx)   ; assign variable
       (values `(var-assn (@ . ,attr) (ident ,name) ,rhsx) '()
               (maybe-add-symbol name dict)))
      ((assn (@ . ,attr) (aref-or-call ,aexp ,expl) ,rhsx) ; assign element
       (values `(elt-assn (@ . ,attr) ,aexp ,expl ,rhsx) '() dict))
      ((assn (@ . ,attr) (sel (ident ,name) ,expr) ,rhsx) ; assign member
       (values `(mem-assn (@ . ,attr) ,expr ,name ,rhsx) '() dict))
      
      ((assn . ,other) (nx-error "syntax error: assn"))

      ;; This is like
      ;; @example
      ;;   [x, y] = f(a)
      ;; @end example
      ;; @example
      ;; (call-with-values
      ;;   (lambda () (f a))
      ;;  (lambda (arg0 arg1 . $rest) (set! x arg0) (set! y arg1)))
      ;; @end example
      ((multi-assn (@ . ,attr) (lval-list . ,elts) ,rhsx)
       (let loop ((lvxl '()) (dict dict) (elts elts) (ix 0))
         (if (null? elts)
             (values
              `(multi-assn (@ . ,attr) (lval-list . ,(reverse lvxl)) ,rhsx)
              '() dict)
             (let* ((n (string-append "arg" (number->string ix)))
                    (s (string->symbol n)) (g (genxsym n)) (rv `(lexical ,s ,g)))
               (sx-match (car elts)
                 ((ident ,name)
                  (loop (cons `(var-assn (ident ,name) ,rv) lvxl)
                        (maybe-add-symbol name dict) (cdr elts) (1+ ix)))
                 ((aref-or-call ,ax ,xl)
                  (loop (cons `(elt-assn ,ax ,xl ,rv) lvxl)
                        dict (cdr elts) (1+ ix)))
                 ((sel (ident ,name) ,expr)
                  (loop (cons `(mem-assn ,expr ,name ,rv) lvxl)
                        dict (cdr elts) (1+ ix)))
                 (,_ (nx-error "bad lhs syntax")))))))
      ((multi-assn . ,rest) (nx-error "syntax error: multi-assn"))

      ((stmt-list . ,stmts)
       (values `(stmt-list . ,(rem-empties stmts)) '() dict))

      ;; Notes:
      ;; 1) We add toplevel if function is toplevel, otherwise it appears
      ;;    in a function-file and we have already set up dict entries.
      ;; 2) In the following (1) placement of "return" and (2) use of fold
      ;;    (vs fold-right) is critical for fctn-defn handling in fU.
      ((fctn-defn (fctn-decl (ident ,name)
                             (ident-list . ,inargs)
                             (ident-list . ,outargs)
                             . ,comms)
                  ,stmt-list)
       (let* ((dict (if (nx-top-level? dict) (nx-add-symbol name dict) dict))
              (dict (nx-push-scope dict))
              (dict (fold (lambda (sx dt) (nx-add-lexical (sx-ref sx 1) dt))
                          dict inargs))
              (dict (fold (lambda (sx dt) (nx-add-lexical (sx-ref sx 1) dt))
                          dict outargs))
              (dict (nx-add-lexical "return" dict))
              (dict (acons '@F name dict))
              (dstr (if (null? comms) ""
                        (string-join (map cadr (cdr comms)) "\n"))))
         ;; TODO: add docstring @code{dstr}
         ;;(sferr "fctn aft dict:\n") (pperr dict)
         (values
          `(fctn-defn (fctn-decl (ident ,name) (ident-list . ,inargs)
                                 (ident-list . ,outargs) (string ,dstr))
                      ,stmt-list)
          '() dict)))
      ((fctn-defn . ,rest) (nx-error "syntax error: function def"))

      ((command (ident ,cname) . ,args)
       (unless (string=? cname "global") (nx-error "bad command: ~S" cname))
       (values
        '() '()
        (fold
         (lambda (arg dict) (nx-add-toplevel (sx-ref arg 1) dict))
         dict args)))

      ((function-file . ,tail)
       ;; Here we add provide ability for forward refs to all functions.
       (values tree '()
               (fold (lambda (tree dict)
                       (sx-match tree
                         ((fctn-defn (fctn-decl (ident ,name) . ,_1) . ,_2)
                          (nx-add-lexical name dict))
                         (,_ dict)))
                     (nx-push-scope dict) tail)))

      (,_
       (values tree '() dict))))

  (define (fU tree seed dict kseed kdict) ;; => seed dict
    (define +SP (make-+SP tree))
    
    ;; This routine rolls up processes leaves into the current branch.
    ;; We have to be careful about returning kdict vs dict.
    ;; Approach: always return kdict or (pop-scope kdict)
    (when #f
      (sferr "fU: ~S\n" (if (pair? tree) (car tree) tree))
      ;;(sferr "    kseed=~S\n    seed=~S\n" kseed seed)
      ;;(pperr tree)
      )
    ;; (case ((pair? tree) all stuff) (pair? kseed) ... (else 
    (if
     (null? tree) (if (null? kseed)
                      (values seed kdict)               ; fD said ignore
                      (values (cons kseed seed) kdict)) ; fD replacement

     (case (car tree)

       ;; before leaving add a call to make sure all toplevels are defined
       ((*TOP*)
        (let ((tail (rtail kseed)))
          (cond
           ((null? tail) (values '(void) kdict)) ; just comments
           (else (values (add-topdefs kdict (car kseed)) kdict)))))

       ((comm) (values seed kdict))

       ((script)
        (let* ((tail (delete '(void) (rtail kseed)))
               (tail (if (pair? tail) tail '(void))) ; needed?
               (body (fold-right
                      (lambda (stmt body) (if body `(seq ,stmt ,body) stmt))
                      #f tail)))
          (values (cons body seed) kdict)))

       ((function-file)
        ;; This puts all the functions into a letrec and defins a toplevel
        ;; to that.  The letrec returns the top function ref.
        ;; Also, we pop scope and add toplevel to parent scope.
        (let* ((tail (delete '(void) (rtail kseed)))
               (main (car tail))
               (rest (cdr tail))
               (lrec (funcs->letrec main rest))
               (name (symbol->string (cadadr main)))
               (xdict (nx-add-toplevel name (pop-scope kdict)))
               (nref (lookup name xdict))
               (body `(set! ,nref ,lrec)))
          (values (cons body seed) xdict)))

       ;; For functions, need to check kdict for lexicals and add them.
       ((fctn-defn)
        (let* ((tail (rtail kseed))
               (decl (list-ref tail 0))
               (n-ref (list-ref decl 1))
               (name (cadr n-ref))
               (iargs (cdr (list-ref decl 2))) ; in reverse order
               (oargs (cdr (list-ref decl 3))) ; in reverse order
               (lvars (let loop ((ldict kdict))
                        (cond
                         ((eq? '@F (caar ldict)) oargs)
                         ((and (pair? (cdar ldict)) (eq? 'lexical (cadar ldict)))
                          (cons (cdar ldict) (loop (cdr ldict))))
                         (else (loop (cdr ldict))))))
               ;; Ensure that last call is a return.
               (body (list-ref tail 1))
               ;; Set up the return prompt expr
               (ptag (lookup "return" kdict))
               (body (with-escape ptag body))
               ;; The tail expression is return value(s).
               (rval (case (length oargs)
                       ((0) nx-undefined-xtil)
                       ((1) (car oargs))
                       (else `(primcall values ,@oargs))))
               (body `(seq ,body ,rval))
               ;; Now wrap in local `let'
               (body
                (let loop ((nl '()) (ll '()) (vl '()) (vs lvars))
                  (if (null? vs)`(let ,nl ,ll ,vl ,body)
                      (let* ((n (list-ref (car vs) 1))
                             (l (list-ref (car vs) 2))
                             (v (cond
                                 ((eq? n 'nargsin)
                                  `(call ,(xlib-ref 'ml:narg) . ,iargs))
                                 ((eq? n 'nargsout)
                                  `(call ,(xlib-ref 'ml:narg) . ,oargs))
                                 (else nx-undefined-xtil))))
                        (loop (cons n nl) (cons l ll) (cons v vl) (cdr vs))))))
               ;; default value is nx-undefined
               (fctn
                `(set! ,n-ref (lambda ((name . ,name) (language . nx-mlang))
                                (lambda-case
                                 ((() ,(map cadr iargs) #f #f
                                   ,(map (lambda (v) nx-undefined-xtil) iargs)
                                   ,(map caddr iargs)) ,body))))))
          (values (cons fctn seed) (pop-scope kdict))))

       ;; fctn-decl: handled by fctn-defn case

       ((stmt-list)
        (let* ((tail (rtail kseed))
               (body (fold-right
                      (lambda (stmt body) (if body `(seq ,stmt ,body) stmt))
                      #f tail)))
          (values (cons body seed) kdict)))

       ;; Statements
       ((empty-stmt)
        (values (cons '(void) seed) kdict))

       ((expr-stmt)
        (values (cons (car kseed) seed) kdict))

       ;; Assignment needs to deal with all left hand expressions.
       ((var-assn) ;; variable assignment
        (let* ((tail (rtail kseed))
               (lhs (car tail))
               (rhs (cadr tail))
               (stmt `(set! ,lhs ,rhs))
               (disp (display-result? tree)))
          ;;(sferr "var-assn:\n") (pperr kseed) ;;(pperr lhs) (pperr rhs)
          (values (cons (if disp `(seq ,stmt ,lhs) stmt) seed) kdict)))

       ((elt-assn) ;; element assignment
        (let* ((tail (rtail kseed))
               (aexp (list-ref tail 0))
               (expl `(primcall list ,@(cdr (list-ref tail 1))))
               (rhsx (list-ref tail 2))
               (stmt `(call ,(xlib-ref 'ml:elt-assn) ,aexp ,expl ,rhsx)))
          (values (cons stmt seed) kdict)))

       ((mem-assn) ;; member assignment
        (let* ((tail (rtail kseed))
               (expr (list-ref tail 0))
               (name `(const ,(string->symbol (list-ref tail 1))))
               (rhsx (list-ref tail 2))
               (stmt `(call ,(xlib-ref 'ml:struct-set!) ,expr ,name ,rhsx)))
          (values (cons stmt seed) kdict)))

       ((multi-assn)
        ;; This executes a call within a call-with-values where the values
        ;; handler does a sequence of set! for lhs args.
        ;;   [a, b(1), c.n] = f(1, 2, 3);
        ;; =>
        ;;   (call-with-values
        ;;       (lambda () (f 1 2 3))
        ;;     (lambda ($arg0 $arg1 $arg2 . $rest)
        ;;       (set! a $arg0)
        ;;       (ml:elt-assn b 1 $arg1)
        ;;       (ml:mem-assn c "n" $arg2)))
        (let* ((body (car kseed))
               (lhsxs (cdadr kseed))    ; expr's generated by fD above
               (avars (map last lhsxs)) ; rhs of var-assn, -elt or -mem
               (rest (genxsym "$rest"))
               (disp (display-result? tree))
               (blok (vblock lhsxs))
               (blok (if (display-result? tree)
                         `(seq ,blok (primcall values ,@avars))
                         blok))
               (body `(primcall
                       call-with-values ,(make-thunk body)
                       (lambda ()
                         (lambda-case ((,(map cadr avars) #f $rest #f
                                        () (,@(map caddr avars) ,rest))
                                       ,blok))))))
          (values (cons body seed) kdict)))

       ;; looping
       ;; 1) mlang does have break statement, and continue I think
       ;; 2) for needs index and should call ml:iter-first ml:iter-next
       ;; 3) BUG top-levels can be introduced here, but we pop scope
       ;;    so these need to be moved to function or global scope
       ;; 4) for-loops do not restrict scope of the iteration var
       
       ;; ("for" ident "=" expr term stmt-list "end"
       ((for) ;; TODO
        (let* ((tail (rtail kseed))
               (lvar (list-ref tail 0)) ; lvar
               (expr (list-ref tail 1)) ; expr
               (body (list-ref tail 2)) ; stmt-list
               (stmt (make-for lvar expr body kdict)))
          (values (cons stmt seed) (pop-scope kdict))))
       
       ((while)
        (let* ((tail (rtail kseed))
               (expr `(if (primcall zero? ,(car tail)) (const #f) (const #t)))
               (body (cdr tail)))
          (values (cons (make-while expr body kdict) kseed) (pop-scope kdict))))

       ;; @code{if} converted to @code{xif} in fD
       ((xif)
        (let* ((tail (rtail kseed))
               (cond1 `(if (primcall zero? ,(car tail)) (const #f) (const #t)))
               (then1 (cadr tail))
               (else1 (caddr tail)))
          (values (cons `(if ,cond1 ,then1 ,else1) seed) kdict)))
       
       ;; converted in @code{fD} from switch, case-list, case, otherwise
       ((xswitch)
        (let* ((body (car kseed))
               (expr (cadr kseed))
               (swxv (lookup "swx-val" kdict))
               (swxg (caddr swxv)))
          (values
           (cons `(let (swx-val) (,swxg) (,expr) ,body) kseed)
           (pop-scope kdict))))

       ((return)
        (values
         (cons `(abort ,(lookup "return" kdict) () (const ())) seed)
         kdict))

       ((command) ;; TODO
        (let ((args (rtail kseed)))
          (values (cons `(call (xlib-ref 'ml:command) ,@args) seed) kdict)))

       ((expr-list)
        (values (cons (reverse kseed) seed) kdict))

       ((colon-expr fixed-colon-expr)
        (let* ((tail (rtail kseed))
               (lb (list-ref tail 0))
               (inc (if (= 2 (length tail)) '(const 1) (list-ref tail 1)))
               (ub (list-ref tail (if (= 2 (length tail)) 1 2))))
          (values (cons `(call ,(xlib-ref 'make-ml:range) ,lb ,inc ,ub) seed)
                  kdict)))

       ((or) (values (+SP (cons (op-call 'ml:or kseed) seed)) kdict))
       ((and) (values (+SP (cons (op-call 'ml:and kseed) seed)) kdict))
       ((eq) (values (+SP (cons (op-call 'ml:eq kseed) seed)) kdict))
       ((ne) (values (+SP (cons (op-call 'ml:ne kseed) seed)) kdict))
       ((lt) (values (+SP (cons (op-call 'ml:lt kseed) seed)) kdict))
       ((gt) (values (+SP (cons (op-call 'ml:gt kseed) seed)) kdict))
       ((le) (values (+SP (cons (op-call 'ml:le kseed) seed)) kdict))
       ((ge) (values (+SP (cons (op-call 'ml:ge kseed) seed)) kdict))
       
       ((add) (values (+SP (cons (op-call 'ml:+ kseed) seed)) kdict))
       ((sub) (values (+SP (cons (op-call 'ml:- kseed) seed)) kdict))
       ((dot-add) (values (+SP (cons (op-call 'ml:.+ kseed) seed)) kdict))
       ((dot-sub) (values (+SP (cons (op-call 'ml:.- kseed) seed)) kdict))
       ((mul) (values (+SP (cons (op-call 'ml:* kseed) seed)) kdict))
       ((div) (values (+SP (cons (op-call 'ml:/ kseed) seed)) kdict))
       ((ldiv) (values (+SP (cons (op-call 'ml:\ kseed) seed)) kdict))
       ((pow) (values (+SP (cons (op-call 'ml:^ kseed) seed)) kdict))
       ((dot-mul) (values (+SP (cons (op-call 'ml:.* kseed) seed)) kdict))
       ((dot-div) (values (+SP (cons (op-call 'ml:./ kseed) seed)) kdict))
       ((dot-pow) (values (+SP (cons (op-call 'ml:.^ kseed) seed)) kdict))
       
       ((neg) (values (+SP (cons (op-call 'ml:neg kseed) seed)) kdict))
       ((pos) (values (+SP (cons (op-call 'ml:pos kseed) seed)) kdict))
       ((not) (values (+SP (cons (op-call 'ml:not kseed) seed)) kdict))
       
       ((transpose) (values (+SP (cons (op-call 'ml:xpose kseed) seed)) kdict))
       ((conj-transpose)
        (values (+SP (cons (op-call 'ml:cj-xpose kseed) seed)) kdict))

       ;; aref-or-call
       ((aref-or-call)
        (let ((proc-or-array (cadr kseed)) (args (cdar kseed)))
          (values
           (cons `(call ,(xlib-ref 'ml:aref-or-call) ,proc-or-array ,@args)
                 seed)
           kdict)))

       ((sel)
        (values
         (cons `(call ,(xlib-ref 'ml:struct-ref) ,(car kseed)
                      (const ,(string->symbol (cadr kseed))))
               seed)
         kdict))

       ;; @section Matrix Constructs
       ;; Static semantics will extract the following:
       ;; @itemize
       ;; @item 1-D matrices (aka vectors) with only scalar integers:
       ;; These can include @code{+-*} expressions.  Used for indices.
       ;; @item 2-D matrices with only scalar floats:
       ;; These can include @code{+-*/} expressions. More efficient than ...
       ;; @item other matrices:
       ;; If a matrix expression includes, say, a variable reference, then the
       ;; dimension of that variable can only be determined at run-time.
       ;; @end itemize

       ;; row
       ((row)
        (values (cons (reverse kseed) seed) kdict))
       
       ;; matrix TODO
       ((matrix)
        (values (cons `(const 1001) seed) kdict))

       ((float-matrix)
        ;; In a `let', create an array and then set a row at a time.
        ;; In the following M=nrow-1, N=ncol-1.
        ;; (let (($aval (make-array 'f64 nrow ncol))
        ;;   (ml:array-set-row! 0 (list a00 a01 ... a0N))
        ;;   ...
        ;;   (ml:array-set-row! M (list aM0 aM1 ... aMN))
        ;;   $aval)
         (let* ((tail (rtail kseed))
                (row1 (car tail))
                (ncol (length (sx-tail row1)))
                (asym (genxsym "$aval"))
                (aval `(lexical $aval ,asym))
                (nrow (length tail))
                (makea `(call (toplevel make-typed-array) (const f64)
                              (const 0.0) (const ,nrow) (const ,ncol)))
                (body (let loop ((ix 0) (rows tail))
                        (if (null? rows) aval
                            `(seq (call ,(xlib-ref 'ml:array-set-row!)
                                        ,aval (const ,ix)
                                        (primcall list . ,(cdar rows)))
                                  ,(loop (1+ ix) (cdr rows))))))
                (expr `(let ($aval) (,asym) (,makea) ,body)))
           (values (cons expr seed) kdict)))
         
       ((fixed-vector)
        (values (cons `(primcall vector . ,(rtail kseed)) seed) kdict))

       ;; cell-array

       ;; ident, fixed, float, string, comm

       ((@) (values seed kdict))

       (else
        (cond
         ((null? seed) (values (reverse kseed) kdict))
         (else (values (cons (reverse kseed) seed) kdict)))))))

  (define (fH leaf seed dict)
    (values (if (null? leaf) seed (cons leaf seed)) dict))

  (foldts*-values fD fU fH `(*TOP* ,exp) '() env)
  )

(define show-sxml #f)
(define (show-mlang-sxml v) (set! show-sxml v))
(define show-xtil #f)
(define (show-mlang-xtil v) (set! show-xtil v))

(define (compile-tree-il exp env opts)
  (when show-sxml (sferr "sxml:\n") (pperr exp))
  (let ((cenv (if (module? env) (acons '@top #t (acons '@M env xdict)) env)))
    (if exp 
        (call-with-values
            (lambda () (xlang-sxml->xtil exp cenv opts))
          (lambda (exp cenv)
            (when show-xtil (sferr "tree-il:\n") (pperr exp))
            (values (parse-tree-il exp) env cenv)
            ;;(values (parse-tree-il '(const "[hello]")) env cenv)
            ))
        (values (parse-tree-il '(void)) env cenv))))

;; --- last line ---
