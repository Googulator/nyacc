;;; nyacc/lang/tsh/compile-tree-il.scm - compile tclish sxml to tree-il

;; Copyright (C) 2021 Matthew R. Wette
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

;; 1) Derived from tcl/compile-tree-il.scm.

;;; Todo:

;; 1) clean up fD handling of set

;;; Code:

(define-module (nyacc lang tsh compile-tree-il)
  #:export (compile-tree-il show-tsh-sxml show-tsh-xtil)
  #:use-module (nyacc lang tsh xlib)
  #:use-module (nyacc lang nx-util)
  #:use-module (nyacc lang sx-util)
  #:use-module ((sxml fold) #:select (foldts*-values))
  #:use-module ((srfi srfi-1) #:select (fold fold-right append-reverse))
  #:use-module (srfi srfi-88)           ; string->keyword
  #:use-module (language tree-il)
  #:use-module (ice-9 match)
  ;;#:use-module (system base compile)
  )
(use-modules (ice-9 pretty-print))
(define (sferr fmt . args)
  (apply simple-format (current-error-port) fmt args))
(define (pperr tree)
  (pretty-print tree (current-error-port) #:per-line-prefix "  "))

(define xlib-mod '(nyacc lang tsh xlib))
(define xlib-module (resolve-module xlib-mod))
(define (xlib-ref name) `(@@ (nyacc lang tsh xlib) ,name))

;; scope must be manipulated at execution time
;; the @code{proc} command should push-scope
(define push-scope nx-push-scope)
(define pop-scope nx-pop-scope)
(define (Xpush-scope dict)
  (let ((child (nx-push-scope dict)))
    (sferr "push:\n") (pperr child)
    child))
(define (X-pop-scope dict)
  (let ((parent (nx-pop-scope dict)))
    (sferr "pop:\n") (pperr parent)
    parent))
(define top-level? nx-top-level?)
(define add-toplevel nx-add-toplevel)
(define add-lexical nx-add-lexical)
(define add-lexicals nx-add-lexicals)
(define add-variable nx-add-variable)
(define (lookup name dict)
  (or (nx-lookup name dict)
      (nx-lookup-in-env name xlib-module)))

(define make-opcall (opcall-generator xlib-mod))

(define (opcall-node op seed kseed kdict)
  (values (cons (rev/repl 'call (xlib-ref op) kseed) seed) kdict))

;; for lt + rt, etc
(define (op-call op kseed)
  (rev/repl 'call (xlib-ref op) kseed))
(define (op-call/prim op kseed)
  (rev/repl 'prim-call op kseed))

(define (make-function name arity body)
  (let* ((meta '((language . nx-tsh)))
	 (meta (if name (cons `(name . ,name) meta) meta)))
    `(lambda ,meta (lambda-case (,arity ,body)))))

(define (make-+SP tree)
  (lambda (obj)
    (set-source-properties! obj (source-properties tree))
    obj))

;; @deffn {Procedure} sxml->xtil exp env opts
;; Compile SXML tree to external Tree-IL representation.
;; @end deffn
			  
(define-public (sxml->xtil exp env opts)

  (define (fD tree seed dict) ;; => tree seed dict
    (define +SP (make-+SP tree))
    (when #f
      (sferr "fD: ~S\n" tree)
      )
    (sx-match tree

      ((keychar ,sval)
       (values '() (+SP `(const ,(string->keyword sval))) dict))

      ((keyword ,sval)
       (values '() (+SP `(const ,(string->keyword sval))) dict))

      ((string ,sval)
       (values '() (+SP `(const ,sval)) dict))

      ((float ,sval)
       (values '() (+SP `(const ,(string->number sval))) dict))

      ((fixed ,sval)
       (values '() (+SP `(const ,(string->number sval))) dict))

      #;((symbol ,sval)
      (values '() `(const ,(string->symbol sval)) dict))
      ((ident ,sval)
       (values '() (+SP `(const ,(string->symbol sval))) dict))

      ((eval . ,stmts)
       (values tree '() (add-lexical "return" (push-scope dict))))
      
      #;((deref ,name)
       (let ((ref (lookup name dict)))
	 (unless ref (throw 'tsh-error "undefined variable: ~S" name))
 	 (values '() (+SP ref) dict)))

      #;((deref-indexed ,name ,expr-list)
       (let ((ref (lookup name dict)) (proc (xlib-ref 'tsh:array-ref)))
	 (unless ref (throw 'tsh-error "undefined variable: ~A" name))
	 (values '() (+SP `(call ,proc ,ref ,expr-list)) dict)))

      ((switch . ,stmts)
       (values tree '() (add-lexicals "swx~val" "break" (push-scope dict))))

      ((for . ,stmts)
       (values tree '() (add-lexicals "continue" "break" (push-scope dict))))
      
      ((while . ,stmts)
       (values tree '() (add-lexicals "continue" "break" (push-scope dict))))
      
      ((proc (ident ,name) (arg-list . ,args) ,body)
       ;; replace each name with (lexical name gsym)
       ;;(sferr "proc dict:\n") (pperr dict)
       (let* ((dict (add-variable name dict))
	      (nref (lookup name dict))
	      (dict (push-scope dict))
	      ;; clean this up
	      (dict (fold (lambda (a d) (add-lexical (cadadr a) d)) dict args))
	      (args (fold-right ;; replace arg-name with lexical-ref
		     (lambda (a l)
		       (cons (cons* (car a) (lookup (cadadr a) dict) (cddr a))
			     l)) '() args))
	      (dict (add-lexical "return" dict))
	      (dict (acons '@F name dict))
              (proc `(proc ,nref (arg-list . ,args) ,body)))
	 (values (+SP proc) '() dict)))

      ((incr (ident ,var) ,val)
       (values (+SP `(incr ,var ,val)) '() dict))
      ((incr (ident ,var))
       (values (+SP `(incr ,var (const 1))) '() dict))
      ((incr/ix (ident ,var) ,ix ,val)
       (values (+SP `(incr/ix ,var ,ix ,val)) '() dict))
      ((incr/ix (ident ,var) ,ix)
       (values (+SP `(incr/ix ,var ,ix (const 1))) '() dict))
      
      ((set (ident ,name) ,value)
       (let* ((dict (nx-ensure-variable name dict))
              (nref (lookup name dict)))
	 (values (+SP `(set ,nref ,value)) '() dict)))

      ((set-indexed (ident ,name) ,index ,value)
       (let ((nref (lookup name dict)))
	 (unless nref (throw 'tsh-error "not defined: ~S" name))
	 (values (+SP `(set-indexed ,nref ,index ,value)) '() dict)))

      ((call (ident ,name) . ,args)
       (let ((ref (lookup name dict)))
	 (unless ref (throw 'tsh-error "not defined: ~S" name))
	 (values (+SP `(call ,ref . ,args)) '() dict)))

      ((use . ,strpath)
       (let* ((sympath (map string->symbol strpath))
              (path (map (lambda (sym) `(const ,sym)) sympath))
              (parg `(primcall list ,@path))
              (stmt `(call (@@ (nyacc lang nx-lib) nx-use-module) ,parg))
              (dict (hash-fold
                     (lambda (key val dict) (nx-add-toplevel key dict))
                     dict (module-obarray (resolve-interface sympath)))))
         (values '() (+SP stmt) dict)))

      ((script . ,stmts)
       (values tree '() (add-lexical "return" (push-scope dict))))

      ;; don't process resolved references
      ((@@ ,module ,symbol)
       (values '() tree dict))

      (,_
       ;;(sferr "fD: default\n") (pperr tree) (sferr "\n")
       (values tree '() dict))))

  (define (fU tree seed dict kseed kdict) ;; => seed dict
    (define +SP (make-+SP tree))
    (when #f
      ;;(sferr "fU: ~S\n" (if (pair? tree) (car tree) tree))
      ;;(sferr "    kseed=~S\n    seed=~S\n" kseed seed)
      (sferr "fU: ~S, tree, kseed, seed\n" (if (pair? tree) (car tree) tree))
      (pperr tree) (pperr kseed) (pperr seed)
      (sferr "\n")
      ;;(pperr tree)
      )
    ;; This routine rolls up processes leaves into the current branch.
    ;; We have to be careful about returning kdict vs dict.
    ;; Approach: always return kdict or (pop-scope kdict)
    (if
     (null? tree) (if (null? kseed)
		      (values seed kdict) 
		      (values (cons kseed seed) kdict))
     
     (case (car tree)

       ;; before leaving add a call to make sure all toplevels are defined
       ((*TOP*)
	(let ((tail (rtail kseed)))
	  (cond
	   ((null? tail) (values '(void) kdict)) ; just comments
	   (else (values (car kseed) kdict)))))

       ((script)
	(values (cons (block (rtail kseed)) seed) (pop-scope kdict)))

       ((stmt-list)
        (let* ((stmtl (rtail kseed))
               (blk (block stmtl))
               (blk (+SP blk)))
	  (values (cons blk seed) kdict)))

       ((comment)
	(values seed kdict))

       ((proc)
	;;(sferr "proc (reverse kseed):\n") (pperr (reverse kseed))
	(let* ((tail (rtail kseed))
	       (name-ref (list-ref tail 0))
	       (argl (list-ref tail 1))
	       (body (block (list-tail tail 2)))
	       (ptag (lookup "return" kdict))
	       (arity (make-arity argl))
	       ;; add locals : CLEAN THIS UP -- used in nx-octave also
	       (lvars (let loop ((ldict kdict))
			(if (eq? '@F (caar ldict)) '()
			    (cons (cdar ldict) (loop (cdr ldict))))))
               ;;(xxx (begin (sferr "loop\n") (pperr lvars) (quit)))
	       (body (let loop ((nl '()) (ll '()) (vl '()) (vs lvars))
                       ;; ^ this is wrap-bindings in javascript
		       (if (null? vs)
			   `(let ,nl ,ll ,vl ,body)
			   (loop
			    (cons (list-ref (car vs) 1) nl)
			    (cons (list-ref (car vs) 2) ll)
			    (cons '(void) vl)
			    (cdr vs)))))
	       ;;
	       (body (with-escape/arg ptag body))
	       (fctn (make-function (cadr name-ref) arity body))
	       (fctn (+SP fctn))
	       (stmt (if (eq? 'toplevel (car name-ref))
			 `(define ,(cadr name-ref) ,fctn)
			 `(set! ,name-ref ,fctn))) ;; never used methinks
	       )
	  ;;(sferr "proc ~S:\n" name-ref) (pperr tail) (pperr fctn)
	  (values (cons stmt seed) (pop-scope kdict))))

       ((return)
	(let ((ret `(abort ,(lookup "return" kdict)
			   (,(if (> (length kseed) 1) (car kseed) '(void)))
			   (const ()))))
	  (values (cons (+SP ret) seed) kdict)))

       ((X-arg-list)
	(sferr "arg-list:\n") (pperr (reverse kseed)) (quit)
	)

       ;; conditional: elseif and else are translated by the default case
       ((if)
	(let* ((tail (rtail kseed))
	       (cond-expr `(primcall not (primcall zero? ,(list-ref tail 0))))
	       (then-expr (list-ref tail 1))
	       (rest-part (list-tail tail 2))
	       (rest-expr
		(let loop ((rest-part rest-part))
		  (match rest-part
		    ('() '(void))
		    (`((else ,body)) (block body))
		    (`((elseif ,cond-part ,body-part) . ,rest)
		     `(if (primcall not (primcall zero? ,cond-part))
			  ,body-part
			  ,(loop (cdr rest-part)))))))
	       (stmt (+SP `(if ,cond-expr ,then-expr ,rest-expr))))
	  (values (cons stmt seed) kdict)))
       ((elseif else)
	(values (cons (reverse kseed) seed) kdict))

       ((switch)
	(let* ((val (lookup "swx~val" kdict))
	       (sw (if (eq? (caar kseed) 'default)
		       (make-switch val (cdr kseed) (car kseed))
		       (make-switch val kseed '(void)))))
	  (values (cons (+SP sw) seed) (pop-scope kdict))))

       
       ((case)
	(let ((val (+SP (reverse kseed))))
	  (values 
	   (if (and (pair? seed) (eq? (caar seed) 'default))
	       (cons* (car seed) val (cdr seed)) ;; default first
	       (cons val seed))
	   kdict)))
       
       ;; for allows continue and break
       ((for)
        (let* ((body (list-ref kseed 0))
               (next (list-ref kseed 1))
               (test `(primcall not (primcall zero? ,(list-ref kseed 2))))
               (init (list-ref kseed 3))
               (form (make-for init test next body kdict)))
	(values (cons (+SP form) seed) (pop-scope kdict))))

       ((while)
	(let* ((test `(primcall not (primcall zero? ,(list-ref kseed 1))))
	       (body (list-ref kseed 0))
	       (form (make-while test body kdict)))
	  (values (cons (+SP form) seed) (pop-scope kdict))))

       ((set)
	(let* ((value (car kseed))
	       (nref (cadr kseed))
	       (toplev? (eq? (car nref) 'toplevel))
	       (val (if toplev?
			`(define ,(cadr nref) ,value)
			`(set! ,nref ,value))))
	  (values (cons (+SP val) seed) kdict)))

       ((set-indexed)
	(let* ((value (car kseed))
	       (indx (cadr kseed))
	       (nref (caddr kseed))
	       (val `(call ,(xlib-ref 'tsh:indexed-set!) ,nref ,indx ,value)))
	  (values (cons (+SP val) seed) kdict)))

       #;((body)
	(values (cons (block (rtail kseed)) seed) kdict))
       
       ((call)
	(values (cons (+SP `(call . ,(rtail kseed))) seed) kdict))

       ((eval)
	(let ((body (with-escape/arg (lookup "return" kdict) (car kseed))))
 	  (values (cons (+SP body) seed) (pop-scope kdict))))

       ((empty-stmt)
	(values seed kdict))

       ;; others to add: incr foreach while continue break
       ;; need incr-indexed
       ((incr)
	(let* ((tail (rtail kseed))
	       (name (car tail))
	       (expr (cadr tail))
	       (vref (lookup name kdict))
	       (stmt `(set! ,vref (primcall + ,vref ,expr))))
	  (values (cons (+SP stmt) seed) kdict)))

       ((source)
	(let ((stmt `(call (@@ (nyacc lang tsh xlib) tsh:source)
			   ,(car kseed)
			   ;;(call (toplevel current-module))
			   )))
	  (values (cons (+SP stmt) seed) kdict)))

       ((format)
	(let* ((tail (rtail kseed))
	       (stmt `(call ,(xlib-ref 'sprintf) . ,tail)))
	  (values (cons (+SP stmt) seed) kdict)))

       ((expr-list)
        (values (cons (+SP `(primcall list ,@(rtail kseed))) seed) kdict))

       ((last)
        (values
         (cons (+SP `(call ,(xlib-ref 'last) . ,(rtail kseed))) seed)
         kdict))
        
       ((expr)
	;;(sferr "expr:~S\n" kseed)
	(values (cons (+SP (car kseed)) seed) kdict))

       ;; pos neg ~ not
       ((pos) (values (+SP (cons (op-call 'tsh:pos kseed) seed)) kdict))
       ((neg) (values (+SP (cons (op-call 'tsh:neg kseed) seed)) kdict))
       ((lognot) (values (+SP (cons (op-call 'tsh:lognot kseed) seed)) kdict))
       ((not) (values (+SP (cons (op-call 'tsh:not kseed) seed)) kdict))

       ;; mul div mod add sub
       ((mul) (values (+SP (cons (op-call 'tsh:* kseed) seed)) kdict))
       ((div) (values (+SP (cons (op-call 'tsh:/ kseed) seed)) kdict))
       ((mod) (values (+SP (cons (op-call 'tsh:% kseed) seed)) kdict))
       ((add) (values (+SP (cons (op-call 'tsh:+ kseed) seed)) kdict))
       ((sub) (values (+SP (cons (op-call 'tsh:- kseed) seed)) kdict))
       
       ;; lshift rshift rrshift
       ((lshift) (values (+SP (cons (op-call 'tsh:lshift kseed) seed)) kdict))
       ((rshift) (values (+SP (cons (op-call 'tsh:rshift kseed) seed)) kdict))

       ;; lt gt le ge
       ((eq) (values (+SP (cons (op-call 'tsh:eq kseed) seed)) kdict))
       ((ne) (values (+SP (cons (op-call 'tsh:ne kseed) seed)) kdict))
       ((lt) (values (+SP (cons (op-call 'tsh:lt kseed) seed)) kdict))
       ((gt) (values (+SP (cons (op-call 'tsh:gt kseed) seed)) kdict))
       ((le) (values (+SP (cons (op-call 'tsh:le kseed) seed)) kdict))
       ((ge) (values (+SP (cons (op-call 'tsh:ge kseed) seed)) kdict))

       ((deref)
        (let* ((name (car kseed))
               (ref (lookup name kdict)))
	  (unless ref (throw 'tsh-error "undefined variable: ~S" name))
          (values (+SP (cons ref seed)) kdict)))

       ((deref-indexed)
        (let* ((tail (rtail kseed))
               (name (car tail))
               (ref (lookup name kdict))
               (args (cdr tail))
               (proc (xlib-ref 'tsh:indexed-ref)))
	  (unless ref (throw 'tsh-error "undefined variable: ~A" name))
	  (values (+SP (cons `(call ,proc ,ref ,@args) seed)) kdict)))

       ((const)
        (values (+SP (cons (reverse kseed) seed)) kdict))

       (else
	(unless (member (car tree)
			'(@@ toplevel lexical abort arg-list arg rest-arg))
	  (sferr "MISSED: ~S\n" (car tree)))
	(cond
	 ((null? seed) (values (reverse kseed) kdict))
	 (else (values (cons (reverse kseed) seed) kdict)))))))

  (define (fH leaf seed dict)
    (values (cons leaf seed) dict))

  (catch 'tsh-error
    (lambda () (foldts*-values fD fU fH `(*TOP* ,exp) '() env))
    (lambda (key fmt . args)
      (apply simple-format (current-error-port)
	     (string-append "*** tsh: " fmt "\n") args)
      (values '(void) env))))

(define show-sxml #f)
(define (show-tsh-sxml v) (set! show-sxml v))
(define show-xtil #f)
(define (show-tsh-xtil v) (set! show-xtil v))
(define* (debug-tsh #:optional (arg #t))
  (set! show-sxml arg) (set! show-xtil arg))
(export debug-tsh)

(define (compile-tree-il exp env opts)
  (when show-sxml (sferr "sxml:\n") (pperr exp) (unless exp (quit)))
  ;; Need to make an interp.  All TCLish commands execute in an interp
  ;; so need (interp-lookup at turntime)
  (let ((cenv (if (module? env) (cons* `(@top . #t) `(@M . ,env) xdict) env)))
    (if exp 
	(call-with-values
	    (lambda ()
	      (when #f
		(sferr "sxml src prop:\n")
		(pperr (add-src-prop-attr exp)))
	      (sxml->xtil exp cenv opts)
	      ;;(values #f cenv)
	      )
	  (lambda (exp cenv)
	    (when show-xtil (sferr "tree-il:\n") (pperr exp))
	    (values (parse-tree-il exp) env cenv)
	    ;;(values (parse-tree-il '(const "[hello]")) env cenv)
     	    )
	  )
	(values (parse-tree-il '(void)) env cenv))))

;; --- last line ---
