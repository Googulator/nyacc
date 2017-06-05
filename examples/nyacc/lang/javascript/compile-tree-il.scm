;;; compile javascript sxml from parser to tree-il
;;;
;;; Copyright (C) 2015-2017 Matthew R. Wette
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by 
;;; the Free Software Foundation, either version 3 of the License, or 
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of 
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (nyacc lang javascript compile-tree-il)
  #:export (compile-tree-il js-sxml->tree-il-ext)
  #:use-module (nyacc lang javascript jslib)
  #:use-module ((sxml match) #:select (sxml-match))
  #:use-module ((sxml fold) #:select (foldts*-values))
  #:use-module ((srfi srfi-1) #:select (fold))
  #:use-module (language tree-il)
  )
(use-modules (ice-9 pretty-print))

;; === portability ===================
;; guile 2.0 => 2.0 changes:
;; 1) (apply ... => (call ...
;; 2) (apply (primitive cons) ... => (primcall cons ...
;; 3) (begin ex1 ex2 ... => (seq ex1 (seq ex2 (seq ex3 ...

(define-syntax-rule (if-guile-20 then else)
  (if (string=? "2.0" (effective-version)) then else))

;; guile 2.0 or 2.2
(define il-call (if-guile-20 'apply 'call))
(define (make-call proc . args) (cons* il-call proc args))
(define (make-pcall name . args)
  (if-guile-20 (cons* 'apply `(primitive ,name) args)
	       (cons* 'primcall name args)))
(define (il-begin . expr-list)
  (if-guile-20
   (cons 'begin expr-list)
   (let iter ((xl expr-list))
     (cons* 'seq (car xl) (if (null? xl) '(void) (iter (cdr xl)))))))

;; === debugging =====================

(define (sferr fmt . args)
  (apply simple-format (current-error-port) fmt args))
(define (pperr tree)
  (pretty-print tree (current-error-port) #:per-line-prefix "  "))

;; @heading variable scope
;; Variables in the compiler are kept in a scope-stack with the highest
;; level being the current module.  Why do I convert to xxx?

;; We catch FunctionDecl and VariableDecl's on the way down and generate new
;; lexical scope and variable declartions let forms or function xxx

;; function declarations are always just a list of args;
;; @example
;;   function foo(x, y) { return x + y; }
;; =>
;;   (define foo (lambda @args (+ 
;; @end example
;; we just use rest arg and then express each
;; var reference as (list-ref @args index)
;; Another option is to use case-lambda ...

;; @subheading non-tail return
;; need to use prompts here, I think ... Hey just use let/ec ?
;; @example
;; (let/ec return ((var1 val1) (var2 val2)) ... (return x) ...)
;; @end example

;; SourceElements occurs in a Program (top-level) or as Function Body
;; We translate Program to begin
;; We translate FunctionBody to let

;; the dictionary will maintain entries with
;; '(lexical var JS~123)
;; variable references are of the forms
;; @table @code
;; @item (toplevel name)
;; top level env
;; @item (@ mod name)
;; exported module refernce
;; @item (@@ mod name)
;; unexported
;; @item (lexical name gensym)
;; lexical scoped variable
;; @end table

;; === symbol table ================

;; push/pop scope level
(define (push-scope dict)
  (list (cons '@l (1+ (assq-ref dict '@l))) (cons '@P dict)))
(define (pop-scope dict)
  (or (assq-ref dict '@P) (error "coding error: too many pops")))
(define (top-level? dict)
  (eqv? 0 (assoc-ref dict '@l)))

;; Add toplevel to dict, return dict
(define (add-toplevel name dict)
  (acons name `(toplevel ,(string->symbol name)) dict))

;; Add lexical to dict, return dict
(define (add-lexical name dict)
  (acons name `(lexical ,(string->symbol name) ,(gensym "JS~")) dict))

;; (add-lexicals name1 name2 ... dict) 
(define (add-lexicals . args)
  (let iter ((args args))
    (if (null? (cddr args)) (add-lexical (car args) (cadr args))
	(add-lexical (car args) (iter (cdr args))))))

;; Add lexcial or toplevel based on level.
(define (add-symboldef name dict)
  ;;(sferr "add-symboldef for ~S at @l=~S\n" name (assq-ref dict '@l))
  (if (positive? (assq-ref dict '@l))
      (add-lexical name dict)
      (add-toplevel name dict)))

;; add label for continue break.  The value will be a pair
;; with car the continue ref and cdr the break ref
(define (add-label name dict)
  (acons name (cons #f #f) dict))

(define (lookup name dict)
  ;;(when (string=? name "foo") (sferr "lookup ~S\n" name) (pperr dict))
  (cond
   ((not dict) #f)
   ((null? dict) #f)
   ((assoc-ref dict name))		; => value
   ((assoc-ref dict '@P) =>		; parent level
    (lambda (dict) (lookup name dict)))
   (else
    (let* ((env (assoc-ref dict '@M))	; host module, aka top level
	   (sym (string->symbol name))
	   (var (module-variable env sym)))
      (if (not var) #f
	  `(@@ ,(module-name env) ,sym))))))

;; @deffn {Procedure} find-exit type dict => gensym
;; used along with @code{with-exit} (see below)
;; (find-exit 'break dict) => JS~1234
;; @end deffn
(define find-exit
  (let ((tmap '((break . "~break") (continue . "~continue")
		(loop . "~loop") (return . "~return"))))
    (lambda* (type dict #:key label)
      (let* ((sym (lookup (assq-ref tmap type) dict)))
	(if (not sym) (error "JS: exit not found:" type))
	(caddr sym)))))
    
;; === code-gen utilities ==============

(define jslib-mod '(nyacc lang javascript jslib))

(define (rtail kseed)
  (cdr (reverse kseed)))

;; @deffn {Procedure} make-let bindings exprs
;; Generates a Tree-IL let form from arguments, where @var{bindings} looks like
;; @example
;; (((lexical v JS~5897) #<unspecified>)
;;  ((lexical w JS~5898) (const 3)))
;; @end example
;; @noindent
;; and @var{exprs} is a list of expressions, to something like
;; @example
;; (let (v w) (JS~5897 JS~5898) (#<unspecified> (const 3)) . exprs)
;; @end example
;; @end deffn
(define (make-let bindings exprs)
  (let iter ((names '()) (gsyms '()) (vals '()) (binds bindings))
    (if (null? binds)
	`(let ,(reverse names) ,(reverse gsyms) ,(reverse vals) (begin ,@exprs))
	(iter (cons (car (cdaar binds)) names)
	      (cons (cadr (cdaar binds)) gsyms)
	      (cons (cadar binds) vals)
	      (cdr binds)))))

;; @deffn {Procedure} with-exit name body
;; use for return and break where break is passed '(void)
;; @end deffn
(define (with-exit-arg name body)
  (let ((arg-sym (gensym "JS~")))
    `(prompt
      (const ,name)
      ,body
      (lambda-case (((cont arg) #f #f #f () (,(gensym "JS~") ,arg-sym))
		    (lexical arg ,arg-sym))))))

(define (with-exit-handler name body handler)
  `(prompt
    (const ,name)
    ,body
    (lambda-case (((cont) #f #f #f () (,(gensym "JS~")))
		  ,handler))))

;; @deffn {Procedure} make-thunk expr => `(lambda ...)
;; Generate a thunk.
;; @end deffn
(define* (make-thunk expr #:key name)
  `(lambda ,(if name '((name)) '()) (lambda-case ((() #f #f #f () ()) ,expr))))

;; body needs a line to build "var arguments" from Array(@args)
;; Right now args is the gensym of the rest argument named @code{@@args}.
(define* (make-function args body #:key name)
  (if (not args) (error "no args"))
  `(lambda ,(if name `((name ,name)) '())
     (lambda-case ((() #f @args #f () (,args)) ,body))))

;; @deffn {Procedure} resolve-ref ref => exp
;; Resolve a possible reference (lval) to an expression (rval).
;; Right now this will convert an object-or-array ref to its value
;; via @code{js-ooa-get}.  If @code{toplevel} or @code{lexical} just
;; return it.
;; @end deffn
(define (resolve-ref ref)
  (case (car ref)
    ((toplevel lexical) ref)
    (else `(apply (@@ ,jslib-mod js-ooa-get) ,ref))))

;; @deffn {Procedure} op-on-ref ref op ord => `(let ...)
;; This routine generates code for @code{ref++}, etc where @var{ref} is
;; a @code{toplevel}, @code{lexical} or @emph{ooa-ref} (object or array
;; reference).  The argument @var{op} is @code{'js:+} or @code{'js:-} and
;; @var{ord} is @code{'pre} or @code{'post}.
;; @end deffn
(define (op-on-ref ref op ord)
  (let* ((sym (gensym "JS~"))
	 (val (case (car ref)
		((toplevel) ref)
		((lexical) ref)
		(else `(apply (@@ ,jslib-mod js-ooa-get) ,ref))))
	 (loc `(lexical ~ref ,sym))
	 (sum `(apply (@@ ,jslib-mod ,op) (const 1) ,loc))
	 (set (case (car ref)
		((toplevel lexical) `(set! ,ref ,sum))
		(else `(apply (@@ ,jslib-mod js-ooa-put) ,ref ,sum))))
	 (rval (case ord ((pre) val) ((post) loc))))
    `(let (~ref) (,sym) (,val) (begin ,set ,rval))))

;; for lt + rt, etc
(define (op-call op kseed)
  (rev/repl 'apply `(@@ ,jslib-mod ,op) kseed))
(define (op-call/prim op kseed)
  (rev/repl 'apply `(primitive ,op) kseed))

;; deffn {Procedure} op-assn kseed => `(set! lhs rhs)
;; op-assn: for lhs += rhs etc
;; end deffn
(define op-assn
  (let ((opmap
	 '((mul-assign . js:*) (div-assign . js:/) (mod-assign . js:%)
	   (add-assign . js:+) (sub-assign . js:-) (lshift-assign . js:lshift)
	   (rshift-assign . js:rshift) (rrshift-assign . js:rrshift)
	   (and-assign . js:and) (xor-assign . js:xor) (or-assign . js:or)
	   (assign . #f))))
    (lambda (kseed)
      (let ((lhs (caddr kseed))
	    (op (assq-ref opmap (caadr kseed)))
	    (rhs (car kseed)))
	(if op
	    `(set! ,lhs ,(make-call `(@@ ,jslib-mod ,op) lhs rhs))
	    `(set! ,lhs ,rhs))))))

;; reverse list but replace new head with @code{head}
;; @example
;; (rev/repl 'a '(4 3 2 1)) => '(a 2 3 4)
;; @end example
(define rev/repl
  (case-lambda
   ((arg0 revl)
    (let iter ((res '()) (inp revl))
      (if (null? (cdr inp)) (cons arg0 res)
	  (iter (cons (car inp) res) (cdr inp)))))
   ((arg0 arg1 revl)
    (let iter ((res '()) (inp revl))
      (if (null? (cdr inp)) (cons* arg0 arg1 res)
	  (iter (cons (car inp) res) (cdr inp)))))
   ))

;; ====================================
	 
;; @deffn {Procedure} js-xml->tree-il-ext exp env opts
;; Compile javascript SXML tree to external tree-il representation.
;; This one is public because it's needed for debugging the compiler.
;; @end deffn
(define (js-sxml->tree-il-ext exp env opts)

  ;; In the case where we pick off ``low hanging fruit'' we need to coordinate
  ;; the actions of the up and down handlers.   The down handler will provide
  ;; a kid-seed in order and generate a null list.  The up handler, upon seeing
  ;; a null list, will just incorporate the kids w/o the normal reverse.

  ;; @deffn {Procedure} remove-empties src-elts-tail => src-elts-tail
  ;; @end deffn
  (define (remove-empties src-elts-tail)
    (let iter ((src src-elts-tail))
      (if (null? src) '()
	  (let ((elt (car src)) (rest (cdr src)))
	    (if (eq? (car elt) 'EmptyStatement)
		(iter rest)
		(cons elt (iter rest)))))))

  ;; @deffn {Procedure} labelable-stmt? stmt => #f|stmt
  ;; This predicate determines if the statement can have a preceeding label.
  ;; @end deffn
  (define (labelable-stmt? stmt)
    (memq (car stmt) '(do while for for-in BreakStatement LabelledStatement)))
  
  ;; @deffn {Procedure} cleanup-labels src-elts-tail => src-elts-tail
  ;; Assumes all top-level EmptyStatements have been removed.
  ;; This reduces @code{LabelledStatement}s to the form
  ;; @example
  ;; @dots{} (LabelledStatement id iter-stmt) @dots{}
  ;; @dots{} (LabelledStatement id (LabelledStatement id iter-stmt)) @dots{}
  ;; @end example
  ;; @noindent
  ;; where @code{iter-stmt} is @code{do}, @code{while}, @code{for} or
  ;; @code{switch}, or removes them if not preceeding iteration statement.
  ;; @end deffn
  (define (cleanup-labels src-elts-tail)
    (let iter ((src src-elts-tail))
      (if (null? src) '()
	  (if (eq? (caar src) 'LabelledStatement)
	      (call-with-values
		  (lambda ()
		    (let* ((elt (car src)) (rest (cdr src))
			   (id (cadr elt)) (stmt (caddr elt)))
		      (if (eqv? 'EmptyStatement (car stmt))
			  (if (and (pair? rest) (labelable-stmt? (car rest)))
			      (values id (car rest) (cdr rest))
			      (values id stmt rest))
			  (if (labelable-stmt? stmt)
			      (values id stmt rest)
			      (values id '(EmptyStatement) (cons stmt rest))))))
		(lambda (id stmt rest)
		  (if (eqv? 'EmptyStatement (car stmt))
		      (begin
			(simple-format (current-error-port)
				       "removing misplaced label: ~A\n"
				       (cadr id))
			(iter rest))
		      (cons `(LabelledStatement ,id ,stmt) (iter rest)))))
	      (cons (car src) (iter (cdr src)))))))

  
  ;; @deffn {Procedure} fold-in-blocks src-elts-tail => src-elts-tail
  ;; Look through source elements.  Change every var xxx to a
  ;; @example
  ;; (@dots{} (VariableStatement (VariableDeclrationList ...)) @dots{})
  ;; @end example
  ;; @noindent
  ;; (@dots{} (VariableDeclarationList ...) (Block @dots{}))
  ;; @example
  ;; @dots{} @{ var a = 1; @dots{} @}
  ;; @end example
  ;; @noindent
  ;; We assume no elements of @code{SourceElements} is text.
  ;; @end deffn
  (define (fold-in-blocks src-elts-tail)
    (let iter ((src  src-elts-tail))
      (if (null? src) '()
	  (let ((elt (car src)) (rest (cdr src)))
	    ;;(simple-format #t "=> ~S\n" (car elt))
	    (if (eq? (car elt) 'VariableStatement)
		(list (cons* 'Block (cadr elt) (iter rest)))
		(cons elt (iter rest)))))))
		     
  (define (fD tree seed dict) ;; => tree seed dict
    ;; This handles branches as we go down the tree.  We do two things here:
    ;; @enumerate
    ;; @item Pick off low hanging fruit: items we can completely convert
    ;; @item trap places where variables are declared and maybe bump scope
    ;; Add symbols to the dictionary, keeping track of lexical scope.
    ;; @end enumerate
    ;; declarations: we need to trap ident references and replace them
    
    ;;(sferr "fD: tree=~S ...\n" (car tree))
    (sxml-match tree

      ((Identifier ,name)
       ;;(sferr "fD: ret null\n")
       (let ((ref (lookup name dict)))
	 (if (not ref) (error "lookup 2 failed"))
	 (values '() ref dict)))
      
      ((PrimaryExpression (this))
       (error "not implemented: PrimaryExpression (this)"))
	      
      ((PrimaryExpression (Identifier ,name))
       ;;(when (string=? name "foo") (sferr "======\n"))
       (let ((ident (lookup name dict)))
	 (if (not ident) (error "JS: identifier not found:" name))
	 (values '() ident dict)))

      ((PrimaryExpression (NullLiteral ,null))
       (values '() '(const js:null) dict))

      ((BooleanLiteral ,true-or-false)
       (values '() `(const ,(char=? (string-ref true-or-false 0) #\t)) dict))

      ((PrimaryExpression (NumericLiteral ,val))
       (values '() `(const ,(string->number val)) dict))

      ((PrimaryExpression (StringLiteral ,str))
       (values '() `(const ,str) dict))

      ((PropertyNameAndValue (Identifier ,name) ,expr)
       (values `(PropertyNameAndValue (PropertyName ,name) ,expr) '() dict))

      ((obj-ref ,expr (Identifier ,name))
       (values `(ooa-ref ,expr (PropertyName ,name)) '() dict))

      ((Block ,elts ...)
       ;; see comments on SourceElements below
       (let* ((elts (remove-empties elts))
	      (elts (cleanup-labels elts))
	      (elts (fold-in-blocks elts))
	      )
	 (unless #t
	   (sferr "Bl was:\n") (pperr tree)
	   (sferr "Bl is:\n") (pperr (cons 'Block elts)))
	 ;;(values (cons 'Block elts) '() dict)))
	 (values tree '() dict)))
      
      ((VariableDeclaration (Identifier ,name) . ,rest)
       ;;(sferr "fU: VD\n") (pperr dict)
       (let* ((dict1 (add-symboldef name dict))
	      (tree1 (lookup name dict1)))
	 (if (not tree1) (error "lookup failed"))
	 (values `(VariableDeclaration ,tree1 . ,rest) '() dict1)))

      ((do ,rest ...)
       (values tree '() (add-lexicals "~loop" "~break" "~continue" 
				      (push-scope dict))))

      ((while ,rest ...)
       (values tree '() (add-lexicals "~loop" "~break" "~continue"
				      (push-scope dict))))

      ((for ,rest ...)
       (values tree '() (add-lexicals "~loop" "~break" "~continue"
				      (push-scope dict))))

      ((for-in ,rest ...)
       (values tree '() (add-lexicals "~loop" "~break" "~continue"
				      (push-scope dict))))

      ((switch ,rest ...)
       (values tree '() (add-lexical "~break" (push-scope dict))))

      ((LabelledStatement (Identifier ,name) ,stmt)
       ;; TODO: how to push down in scope
       ;; idea: go down to the "do"; push scope as above and add labels
       (values tree '() (add-label name dict)))

      ((FunctionDeclaration (Identifier ,name) ,rest ...)
       (values tree '()
	       (add-lexical "~return" (push-scope (add-symboldef name dict)))))
      
      ((FunctionExpression (Identifier ,name) ,rest ...)
       (values tree '()
	       (add-lexical "~return" (add-lexical name (push-scope dict)))))
      
      ((FunctionExpression ,rest ...)
       ;; symbol is a hack
       (values tree '() (add-symboldef "*anon*" (push-scope dict))))
      
      ((FormalParameterList ,idlist ...)
       ;; For all functions we just use rest arg and then express each
       ;; var reference as (list-ref @args index)
       ;; Another option is to use case-lambda ...
       (let* ((args (add-lexical "@args" dict))
	      (gsym (list-ref (car args) 3)) ; need gensym ref
	      (dikt (fold
		     (lambda (name indx seed)
		       (acons name (make-call `(toplevel list-ref)
					      `(lexical @args ,gsym)
					      `(const ,indx))
			      seed))
		     args
		     (map cadr idlist)
		     (let iter ((r '()) (n (length idlist))) ;; n-1 ... 0
		       (if (zero? n) r (iter (cons (1- n) r) (1- n))))
		     ))
	      )
	 (values tree '() dikt)))
      
      ((SourceElements . ,elts) ;; a list of statements and fctn-decls
       ;; Fix up list of source elements.
       ;; 1) Remove EmptyStatements.
       ;; 2) If LabelledStatement has EmptyStatement, merge with following
       ;;    do, while, for or switch.  Otherwise remove.
       ;; 3) Make to VDL always followed by a Block to end of SourceElements.
       (let* ((elts (remove-empties elts))
	      (elts (cleanup-labels elts))
	      (elts (if (top-level? dict) elts (fold-in-blocks elts))))
	 (unless #t
	   (sferr "SE was:\n") (pperr tree)
	   (sferr "SE is:\n") (pperr (cons 'SourceElements elts)))
	 (values (cons 'SourceElements elts) '() dict)))

      (,otherwise
       ;;(sferr "fD: otherwise\n") (pperr tree)
       (values tree '() dict))
      ))

  (define (fU tree seed dict kseed kdict) ;; => seed dict
    ;;(sferr "fU: kseed=~S\n    seed=~S\n" kseed seed) (pperr tree)
    ;; This routine rolls up processes leaves into the current branch.
    ;; We have to be careful about returning kdict vs dict.
    ;; Approach: always return kdict or (pop-scope kdict)
    (if
     (null? tree) (values (cons kseed seed) dict)
     
     (case (car tree)
       ((*TOP*)
	(values kseed kdict))

       ;; Identifier: handled in fD above

       ;; PrimaryExpression (w/ ArrayLiteral or ObjectLiteral only)
       ((PrimaryExpression)
	(values (cons (car kseed) seed) kdict))
      
       ;; ArrayLiteral
       ;; mkary is just primitive vector
       ((ArrayLiteral)
	(let ((exp (apply make-call `(@@ ,jslib-mod mkary) (car kseed))))
	  (values (cons exp seed) kdict)))
       
       ;; ElementList
       ((ElementList)
	(values (cons (rtail kseed) seed) kdict))

       ;; Elision: e.g., (Elision "3")
       ;; Convert to js:undefined: a bit of a hack for now, but wtf.
       ((Elision)
	(let* ((len (string->number (car kseed)))
	       (avals (make-list len '(void))))
	  (values (append avals seed) kdict)))

       ;; ObjectLiteral
       ((ObjectLiteral)
	(values (cons (car kseed) seed) kdict))
       
       ;; PropertyNameAndValueList
       ((PropertyNameAndValueList)
	(values
	 (cons `(apply (@@ ,jslib-mod mkobj) ,@(rtail kseed)) seed)
	 kdict))

       ;; PropertyNameAndValue
       ((PropertyNameAndValue)
	;;(values (cons* (car kseed) `(const ,(cadr kseed)) seed) kdict))
	(values (cons* (car kseed) (cadr kseed) seed) kdict))

       ;; PropertyName
       ((PropertyName)
	(values (cons `(const ,(car kseed)) seed) kdict))

       ;; ooa-ref (object-or-array ref), a cons cell: (dict name)
       ;; => (cons <expr> <name>)
       ((ooa-ref)
	(values
	 (cons (make-pcall 'cons (resolve-ref (cadr kseed)) (car kseed)) seed)
	 kdict))

       ;; obj-ref: converted to aoo-ref in fD

       ;; new: for now just call object
       ((new) (values (cons (car kseed) seed) kdict))
       
       ;; CallExpression
       ((CallExpression)
	(values (cons (rev/repl 'apply kseed) seed) kdict))

       ;; ArgumentList
       ((ArgumentList) ;; append-reverse-car ??? 
	(values (append (rtail kseed) seed) kdict))

       ;; post-inc
       ((post-inc)
	(values (cons (op-on-ref (car kseed) 'js:+ 'post) seed) kdict))
	
       ;; post-dec
       ((post-dec)
	(values (cons (op-on-ref (car kseed) 'js:- 'post) seed) kdict))

       ;; delete
       ;; void
       ;; typeof

       ;; pre-inc
       ((pre-inc)
	(values (cons (op-on-ref (car kseed) 'js:+ 'pre) seed) kdict))

       ;; pre-dec
       ((pre-dec)
	(values (cons (op-on-ref (car kseed) 'js:- 'pre) seed) kdict))


       ;; pos neg
       ((pos) (values (cons (op-call 'js:pos kseed) seed) kdict))
       ((neg) (values (cons (op-call 'js:neg kseed) seed) kdict))
       ;; ~
       ;; not

       ;; mul div mod add sub
       ((mul) (values (cons (op-call 'js:* kseed) seed) kdict))
       ((div) (values (cons (op-call 'js:/ kseed) seed) kdict))
       ((mod) (values (cons (op-call 'js:% kseed) seed) kdict))
       ((add) (values (cons (op-call 'js:+ kseed) seed) kdict))
       ((sub) (values (cons (op-call 'js:- kseed) seed) kdict))
       
       ;; lshift rshift rrshift
       ((lshift) (values (cons (op-call 'js:lshift kseed) seed) kdict))
       ((rshift) (values (cons (op-call 'js:rshift kseed) seed) kdict))
       ((rrshift) (values (cons (op-call 'js:rrshift kseed) seed) kdict))

       ;; lt gt le ge
       ((lt) (values (cons (op-call 'js:lt kseed) seed) kdict))
       ((gt) (values (cons (op-call 'js:gt kseed) seed) kdict))
       ((le) (values (cons (op-call 'js:le kseed) seed) kdict))
       ((ge) (values (cons (op-call 'js:ge kseed) seed) kdict))
       
       ;; instanceof
       ;; in
       ;; eq
       ;; neq
       ;; eq-eq
       ;; neq-eq
       ;; bit-and
       ;; bit-xor
       ;; bit-or
       ;; and
       ;; or

       ;; ConditionalExpression => (if expr a b)
       ((ConditionalExpression)
	(values
	 (cons `(if ,(caddr kseed) ,(cadr kseed) ,(car kseed)) seed) kdict))

       ;; AssignmentExpression
       ;; assign mul-assign div-assign od-assign add-assign sub-assign
       ;; lshift-assign rshift-assign rrshift-assign and-assign
       ;; xor-assign or-assign
       ((AssignmentExpression)
	(values (cons (op-assn kseed) seed) kdict))

       ;; expr-list

       ;; Block
       ((Block)
	;;(sferr "Bl tree 1st:\n") (pperr (cadr tree))
	;;(sferr "Bl kids:\n") (pperr (cadr (reverse kseed)))
	(let* ((tail (rtail kseed))
	       (exp1 (if (pair? tail) (car tail) #f))
	       (blck (if (and exp1 (eqv? 'bindings (car exp1)))
			 (make-let (cdar tail) (cdr tail))
			 (cons 'begin tail)))
	       )
	  ;;(pperr blck)
	  (values (cons blck seed) kdict)))

       ;; VariableStatement
       ((VariableStatement)
	(values (cons (car kseed) seed) kdict))

       ;; VariableDeclarationList
       ((VariableDeclarationList)
	(let* ((top (= 0 (assq-ref dict '@l))) ; at top ?
	       (top (top-level? dict))
	       (tag (if top 'begin 'bindings)) ; begin or bindings for let
	       (tail (rtail kseed)))
	  ;;(sferr "VDL:\n") (pperr expr)
	  ;; kdict here because that brings in new xxx
	  (values (cons (cons tag tail) seed) kdict)))
       
       ;; VariableDeclaration
       ((VariableDeclaration)
	;;(sferr "VD: seed=~S kseed=~S\n\n" #f kseed)
	(let* ((top (= 0 (assq-ref dict '@l))) ; at top ?
	       (w/i (= 3 (length kseed))) ; w/ initializer
	       (elt0 (list-ref kseed 0))
	       (elt1 (list-ref kseed 1)))
	  (values
	   (cons
	    (if top
		(if w/i ;; toplevel defines
		    `(define ,(cadr elt1) ,elt0)
		    `(define ,(cadr elt0) (void)))
		(if w/i ;; bindings for let
		    (list elt1 elt0)
		    (list elt0 '(void))))
	    seed)
	   kdict)))
       
       ;; Initializer
       ((Initializer)		       ; just grab the single argument
	(values (cons (car kseed) seed) kdict))

       ;; EmptyStatement
       ((EmptyStatement)		; ignore
	(values seed dict))

       ;; ExpressionStatement
       ((ExpressionStatement)	       ; just grab the single argument
	(values (cons (car kseed) seed) kdict))

       ;; IfStatement
       ((IfStatement)
	(values (cons (if (= 3 (length kseed))
			  `(if ,(cadr kseed) ,(car kseed) (void))
			  `(if ,(caddr kseed) ,(cadr kseed) ,(car kseed)))
		      seed) kdict))

       ;; iter-stmts: "do", "while" and "for"
       ;;
       ;; @item During fD we push scope w/ a ~loop variable.
       ;; @item During fU we use that loop to generate a closure to loop
       ;;
       ;; "continue" and "break"
       ;; These will need either two prompts or one prompt and tail calls ???
       ;; * break:
       ;;   (prompt (const break)
       ;;     (let (~loop (lambda () ...)
       ;; * continue: hmmm ...
       ;; Maybe we should add reference, ~cont, to evaluate and set that
       ;; to (const #t) for "while" and to the expr for "do"
       ;; if labelled Continue then make sure it's before an iter-stmt

       
       ;; do: "do" stmt "while" expr ;
       ((do)
	(let* ((expr (car kseed))	; the condition
	       (stmt (cadr kseed))	; the statement to execute
	       ;; get lexicals for ~loop ~break ~continue
	       (lvar (lookup "~loop" kdict)) ; (lexical ~loop JS~1235)
	       (lsym (caddr lvar))	     ; JS~1235
	       (btag (find-exit 'break kdict))
	       (ctag (find-exit 'continue kdict))
	       ;; make the body of the loop
	       (body `(begin ,stmt (if ,expr ,(make-call lvar) (void))))
	       ;; add prompt for "continue"; "break" if condition fails
       	       ;; NEEDS CLEANUP
	       ;;(hdlr `(if ,expr (void) (abort (const ,btag) () (const '()))))
	       (hdlr `(if ,expr
			  ,(make-call lvar)
			  (abort (const ,btag) () (const '()))))
	       (ctag-lexical (assoc-ref "~continue" kdict))
	       (body (with-exit-handler ctag body hdlr))
	       ;; add letrec for loop
	       (body `(letrec (~loop ~cont) (,lsym ,ctag)
			      (,(make-thunk body)
			       (apply (primitive make-prompt-tag)))
			      ,(make-call lvar)))
	       ;; add prompt for "break"
	       (body (with-exit-handler btag body '(void))))
	  (values (cons body seed) (pop-scope kdict))))
	
       ;; while:
       ((while)
	(let* ((expr (cadr kseed)) (stmt (car kseed))
	       (lvar (lookup "~loop" kdict)) (lsym (caddr lvar))
	       (btag (find-exit 'break kdict))
	       (ctag (find-exit 'continue kdict))
	       (body `(if ,expr (begin ,stmt ,(make-call lvar)) (void)))
	       (body (with-exit-handler ctag body '(void)))
	       (body `(letrec (~loop) (,lsym) (,(make-thunk body))
			      ,(make-call lvar)))
	       (body (with-exit-handler btag body '(void))))
	  (values (cons body seed) (pop-scope kdict))))
	
       ;; for    : pop-scope needed
       ;; for-in : pop-scope needed

       ;; NoExpression (used by for and for-in)
       ((NoExpression)
	(values (cons '(void) seed) kdict))
       
       ;; ContinueStatement: abort w/ zero args
       ((ContinueStatement)
	(values
	 (cons
	  (if (> (length kseed) 1)
	      (error "continue w/ id arg not supported (yet)")
	      `(abort (const ,(find-exit 'continue kdict)) () (const '())))
	  seed) kdict))

       ;; BreakStatement: abort w/ zero args
       ((BreakStatement)
	(values
	 (cons
	  (if (> (length kseed) 1)
	      (error "break w/ id arg not supported (yet)")
	      `(abort (const ,(find-exit 'break kdict)) () (const '())))
	  seed) kdict))

       ;; ReturnStatement: abort w/ one arg
       ((ReturnStatement)
	(values
	 (cons `(abort (const ,(find-exit 'return kdict))
		       (,(if (> (length kseed) 1) (car kseed) '(void)))
		       (const '()))
	       seed) kdict))

       ;; WithStatement
       ;; SwitchStatement: pop-scope needed
       ;; CaseBlock
       ;; CaseClauses
       ;; CaseClause
       ;; DefaultClause
       
       ;; LabelledStatement
       ((LabelledStatement)
	(sferr "skipping labelled statement\n")
	(values (cons (car kseed) seed) kdict))

       ;; ThrowStatement
       ;; TryStatement
       ;; Catch
       ;; Finally

       ;; FunctionDeclaration (see also fU)
       ((FunctionDeclaration)
	(let* ((il-name (cadr kseed))
	       (name (case (car il-name)
			((@ @@) (caddr il-name)) (else (cadr il-name))))
	       (args (list-ref (lookup "@args" kdict) 2))
	       (ptag (find-exit 'return kdict))
	       (body (with-exit-arg ptag `(begin ,@(car kseed))))
	       (fctn `(define ,name ,(make-function args body #:name name))))
	  (values (cons fctn seed) (pop-scope kdict))))

       ;; FunctionExpression
       ((FunctionExpression)
	(let* ((args (list-ref (lookup "@args" kdict) 2))
	       (ptag (find-exit 'return kdict))
	       (body (with-exit-arg ptag `(begin ,@(car kseed))))
	       (fctn (make-function args body)))
	  (values (cons fctn seed) (pop-scope kdict))))

       ;; FormalParameterList
       ((FormalParameterList) ;; all in @code{@@args}.
	(values seed kdict))

       ;; Program
       ((Program)
	(values (cons 'begin (car kseed)) kdict))
       
       ;; SourceElements
       ((SourceElements)
	;; return kdict here because we may need to peel off decls'
	(values (cons (rtail kseed) seed) kdict))

       (else
	;;(sferr "fU: kseed=~S  [else]\n    seed=~S\n" kseed seed) (pperr tree)
	(cond
	 ((null? seed) (values (reverse kseed) kdict))
	 ;;((null? kseed) (values (cons (car tree) seed) dict)) ;; ???
	 (else (values (cons (reverse kseed) seed) kdict)))))))

  (define (fH leaf seed dict)
    (values (cons leaf seed) dict))

  ;; We generate a dictionary with the env (module?) available at the top.
  (let ((dict (acons `@M env JSdict))
	(sexp `(*TOP* ,exp)))
    (foldts*-values fD fU fH sexp '() dict)))

;; @deffn {Procedure} compile-tree-il exp env opts => 
(define (compile-tree-il exp env opts)
  ;;(sferr "sxml:\n") (pperr exp)
  (let* ((xrep (js-sxml->tree-il-ext exp env opts)))
    (sferr "tree-il:\n") (pperr xrep)
    (values (parse-tree-il '(const "[skip compile & execute]")) env env)
    (values (parse-tree-il xrep) env env)
    ))

;; --- last line ---
