;;; lang/c99/body.scm
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

;; Notes on the code design may be found in doc/nyacc/lang/c99-hg.info

;; @section The C99 Parser Body
;; This code provides the front end to the C99 parser, including the lexical
;; analyzer and optional CPP processing.  In @code{'file} mode the lex'er
;; passes CPP statements to the parser; in @code{'code} mode the lex'er
;; parses and evaluates the CPP statements.  In the case of included files
;; (e.g., via @code{#include <file.h>}) the include files are parsed if
;; not in @code{inc-help}.  The a-list @code{inc-help} maps
;; include file names to typenames (e.g., @code{stdio.h} to @code{FILE}) and
;; CPP defines (e.g., "INT_MAX=12344").

;; issue w/ brlev: not intended to beused with `extern "C" {'

(use-modules ((srfi srfi-9) #:select (define-record-type)))
(use-modules ((sxml xpath) #:select (sxpath)))
(use-modules (ice-9 pretty-print)) ;; for debugging

(define-record-type cpi
  (make-cpi-1)
  cpi?
  (debug cpi-debug set-cpi-debug!)	; debug #t #f
  (defines cpi-defs set-cpi-defs!)	; #defines
  (incdirs cpi-incs set-cpi-incs!)	; #includes
  (inc-tynd cpi-itynd set-cpi-itynd!)	; a-l of incfile => typenames
  (inc-defd cpi-idefd set-cpi-idefd!)	; a-l of incfile => defines
  (ptl cpi-ptl set-cpi-ptl!)		; parent typename list
  (ctl cpi-ctl set-cpi-ctl!)		; current typename list
  (blev cpi-blev set-cpi-blev!)		; curr brace/block level
  )

;;.@deffn Procedure split-cppdef defstr => (<name> . <repl>)| \
;;     (<name>  <args> . <repl>)|#f
;; Convert define string to a dict item.  Examples:
;; @example
;; "ABC=123" => '("ABC" . "123")
;; "MAX(X,Y)=((X)>(Y)?(X):(Y))" => ("MAX" ("X" "Y") . "((X)>(Y)?(X):(Y))")
;; @end example
;; @end deffn
(define (split-cppdef defstr)
  (let ((x2st (string-index defstr #\()) ; start of args
	(x2nd (string-index defstr #\))) ; end of args
	(x3 (string-index defstr #\=)))  ; start of replacement
    (cond
     ((not x3) #f)
     ((and x2st x3)
      ;;(if (not (eq? (1+ x2nd) x3)) (c99-err "bad CPP def: ~S" defstr))
      (cons* (substring defstr 0 x2st)
	     (string-split
	      (string-delete #\space (substring defstr (1+ x2st) x2nd))
	      #\,)
	     (substring defstr (1+ x3))))
     (else
      (cons (substring defstr 0 x3) (substring defstr (1+ x3)))))))

;; @deffn Procedure make-cpi debug defines incdirs inchelp
;; I think there is a potential bug here in that the alist of cpp-defs/helpers
;; should be last-in-first-seen ordered.  Probably helpers low prio.
;; @end deffn
(define (make-cpi debug defines incdirs inchelp)
  ;; convert inchelp into inc-file->typenames and inc-file->defines
  ;; Any entry for an include file which contains `=' is considered
  ;; a define; otherwise, the entry is a typename.

  (define (split-helper helper)
    (let ((file (car helper)))
      (let iter ((tyns '()) (defs '()) (ents (cdr helper)))
	(cond
	 ((null? ents) (values (cons file tyns) (cons file defs)))
	 ((split-cppdef (car ents)) =>
	  (lambda (def) (iter tyns (cons def defs) (cdr ents))))
	 (else (iter (cons (car ents) tyns) defs (cdr ents)))))))

  (let* ((cpi (make-cpi-1)))
    (set-cpi-debug! cpi debug)		; print states debug 
    (set-cpi-defs! cpi (map split-cppdef defines)) ; list of define strings
    (set-cpi-incs! cpi incdirs)		; list of include dir's
    (set-cpi-ptl! cpi '())		; list of lists of typenames
    (set-cpi-ctl! cpi '())		; list of typenames
    (set-cpi-blev! cpi 0)		; brace/block level
    ;; Break up the helpers into typenames and defines.
    (let iter ((itynd '()) (idefd '()) (helpers inchelp))
      (cond ((null? helpers)
	     (set-cpi-itynd! cpi itynd)
	     (set-cpi-idefd! cpi idefd))
	    (else
	     (call-with-values
		 (lambda () (split-helper (car helpers)))
	       (lambda (ityns idefs)
		 (iter (cons ityns itynd) (cons idefs idefd) (cdr helpers)))))))
    ;; Assign builtins.
    (and=> (assoc-ref (cpi-itynd cpi) "__builtin")
	   (lambda (tl) (set-cpi-ctl! cpi (append tl (cpi-ctl cpi)))))
    (and=> (assoc-ref (cpi-idefd cpi) "__builtin")
	   (lambda (tl) (set-cpi-defs! cpi (append tl (cpi-defs cpi)))))
    ;;(fmterr "cpi-defs=\n")
    ;;(pretty-print (cpi-defs cpi) (current-error-port))
    ;; Return the populated info.
    cpi))

(define *info* (make-fluid #f))
	  
;; @deffn {Procedure} typename? name
;; Called by lexer to determine if symbol is a typename.
;; Check current sibling for each generation.
;; @end deffn
(define (typename? name)
  (let ((cpi (fluid-ref *info*)))
    (if (member name (cpi-ctl cpi)) #t
        (let iter ((ptl (cpi-ptl cpi)))
	  (if (null? ptl) #f
	      (if (member name (car ptl)) #t
		  (iter (cdr ptl))))))))

(define cpi-inc-blev!
  (case-lambda
   ((info) (set-cpi-blev! info (1+ (cpi-blev info))))
   (() (cpi-inc-blev! (fluid-ref *info*)))))
(define cpi-dec-blev!
  (case-lambda
   ((info) (set-cpi-blev! info (1- (cpi-blev info))))
   (() (cpi-dec-blev! (fluid-ref *info*)))))
(define cpi-top-blev?
  (case-lambda
   ((info) (zero? (cpi-blev info)))
   (() (cpi-top-blev? (fluid-ref *info*)))))

;; @deffn {Procedure} add-typename name
;; Helper for @code{save-typenames}.
;; @end deffn
(define (add-typename name)
  (let ((cpi (fluid-ref *info*)))
    (set-cpi-ctl! cpi (cons name (cpi-ctl cpi)))))

(define (cpi-push)	;; on #if
  (let ((cpi (fluid-ref *info*)))
    (set-cpi-ptl! cpi (cons (cpi-ctl cpi) (cpi-ptl cpi)))
    (set-cpi-ctl! cpi '())))

(define (cpi-shift)	;; on #elif #else
  (set-cpi-ctl! (fluid-ref *info*) '()))

(define (cpi-pop)	;; on #endif
  (let ((cpi (fluid-ref *info*)))
    (set-cpi-ctl! cpi (append (cpi-ctl cpi) (car (cpi-ptl cpi))))
    (set-cpi-ptl! cpi (cdr (cpi-ptl cpi)))))

;; @deffn {Procedure} find-new-typenames decl
;; Helper for @code{save-typenames}.
;; Given declaration return a list of new typenames (via @code{typedef}).
;; @end deffn
(define (find-new-typenames decl)

  ;; like declr-id in util2.scm
  (define (declr->id-name declr)
    (case (car declr)
      ((ident) (sx-ref declr 1))
      ((init-declr) (declr->id-name (sx-ref declr 1)))
      ((comp-declr) (declr->id-name (sx-ref declr 1)))
      ((array-of) (declr->id-name (sx-ref declr 1)))
      ((ptr-declr) (declr->id-name (sx-ref declr 2)))
      ((ftn-declr) (declr->id-name (sx-ref declr 1)))
      ((scope) (declr->id-name (sx-ref declr 1)))
      (else (error "coding bug: " declr))))
       
  (let* ((spec (sx-ref decl 1))
	 (stor (sx-find 'stor-spec spec))
	 (id-l (sx-ref decl 2)))
    (if (and stor (eqv? 'typedef (caadr stor)))
	(let iter ((res '()) (idl (cdr id-l)))
	  (if (null? idl) res
	      (iter (cons (declr->id-name (sx-ref (car idl) 1)) res)
		    (cdr idl))))
	'())))

;; @deffn {Procedure} save-typenames decl
;; Save the typenames for the lexical analyzer and return the decl.
;; @end deffn
(define (save-typenames decl)
  ;; This finds typenames using @code{find-new-typenames} and adds via
  ;; @code{add-typename}.  Then return the decl.
  (for-each add-typename (find-new-typenames decl))
  decl)

;; ------------------------------------------------------------------------

(define (c99-err . args)
  (apply throw 'c99-error args))

;; @deffn {Procedure} read-cpp-line ch => #f | (cpp-xxxx)??
;; Given if ch is #\# read a cpp-statement.
;; The standard implies that comments are tossed here but we keep them
;; so that they can end up in the pretty-print output.
;; @end deffn
(define (read-cpp-line ch)
  (if (not (eq? ch #\#)) #f
      (let iter ((cl '()) (ch (read-char)))
	(cond
	 ((eof-object? ch) (throw 'cpp-error "CPP lines must end in newline"))
	 ((eq? ch #\newline) (unread-char ch) (list->string (reverse cl)))
	 ((eq? ch #\\)
	  (let ((c2 (read-char)))
	    (if (eq? c2 #\newline)
		(iter cl (read-char))
		(iter (cons* c2 ch cl) (read-char)))))
	 ((eq? ch #\/) ;; swallow comments, event w/ newlines
	  (let ((c2 (read-char)))
	    (cond
	     ((eqv? c2 #\*)
	      (let iter2 ((cl2 (cons* #\* #\/ cl)) (ch (read-char)))
		(cond
		 ((eq? ch #\*)
		  (let ((c2 (read-char)))
		    (if (eqv? c2 #\/)
			(iter (cons* #\/ #\* cl2) (read-char)) ;; keep comment
			(iter2 (cons #\* cl2) c2))))
		 (else
		  (iter2 (cons ch cl2) (read-char))))))
	     (else
	      (iter (cons #\/ cl) c2)))))
	 (else (iter (cons ch cl) (read-char)))))))

;; @deffn {Procedure} find-file-in-dirl file dirl => path
;; @end deffn
(define (find-file-in-dirl file dirl)
  (let iter ((dirl dirl))
    (if (null? dirl) #f
	(let ((p (string-append (car dirl) "/" file)))
	  (if (access? p R_OK) p (iter (cdr dirl)))))))

(define (def-xdef? name mode)
  (not (eqv? mode 'file)))

;; @deffn {Procedure} gen-c-lexer [#:mode mode] [#:xdef? proc] => procedure
;; Generate a context-sensitive lexer for the C99 language.  The generated
;; lexical analyzer reads and passes comments and optionally CPP statements
;; to the parser.  The keyword argument @var{mode} will determine if CPP
;; statements are passed (@code{'file} mode) or parsed and executed
;; (@code{'file} mode) as described above.  Comments will be passed as
;; ``line'' comments or ``lone'' comments: lone comments appear on a line
;; without code.  The @code{xdef?} keyword argument allows user to pass
;; a predicate which determines whether CPP symbols in code are expanded.
;; The default predicate is
;; @example
;; (define (def-xdef? mode name) (eqv? mode 'code))
;; @end example
;; @end deffn
(define gen-c-lexer
  ;; This gets ugly in order to handle cpp.
  ;;.need to add support for num's w/ letters like @code{14L} and @code{1.3f}.
  ;; todo: I think there is a bug wrt the comment reader because // ... \n
  ;; will end up in same mode...  so after
  ;; int x; // comment
  ;; the lexer will think we are not at BOL.
  (let* ((match-table c99-mtab)
	 (read-ident read-c-ident)
	 (read-comm read-c-comm)
	 ;;
	 (ident-like? (make-ident-like-p read-ident))
	 ;;
	 (strtab (filter-mt string? match-table)) ; strings in grammar
	 (kwstab (filter-mt ident-like? strtab))  ; keyword strings =>
	 (keytab (map-mt string->symbol kwstab))  ; keywords in grammar
	 (chrseq (remove-mt ident-like? strtab))  ; character sequences
	 (symtab (filter-mt symbol? match-table)) ; symbols in grammar
	 (chrtab (filter-mt char? match-table))	  ; characters in grammar
	 ;;
	 (read-chseq (make-chseq-reader chrseq))
	 (assc-$ (lambda (pair) (cons (assq-ref symtab (car pair)) (cdr pair))))
	 ;;
	 (t-ident (assq-ref symtab '$ident))
	 (t-typename (assq-ref symtab 'typename))
	 (xp1 (sxpath '(cpp-stmt define)))
	 (xp2 (sxpath '(decl))))
    ;; mode: 'code|'file|'decl
    ;; xdef?: (proc name mode) => #t|#f  : do we expand #define?
    (lambda* (#:key (mode 'code) (xdef? #f))
      (let ((bol #t)		 ; begin-of-line condition
	    (suppress #f)	 ; parsing cpp expanded text (kludge?)
	    (ppxs (list 'keep))	 ; CPP execution state stack
	    (info (fluid-ref *info*))	; info shared w/ parser
	    ;;(brlev 0)			; brace level
	    (x-def? (or xdef? def-xdef?))
	    )
	;; Return the first (tval . lval) pair not excluded by the CPP.
	(lambda ()

	  (define (add-define tree)
	    (let* ((tail (cdr tree))
		   (name (car (assq-ref tail 'name)))
		   (args (assq-ref tail 'args))
		   (repl (car (assq-ref tail 'repl)))
		   (cell (cons name (if args (cons args repl) repl))))
	      (set-cpi-defs! info (cons cell (cpi-defs info)))))
	  
	  (define (rem-define name)
	      (set-cpi-defs! info (delete name (cpi-defs info))))
	  
	  (define (apply-helper file)
	    ;;(when (string=? file "stddef.h") (pretty-print (cpi-itynd info)))
	    (let* ((tyns (assoc-ref (cpi-itynd info) file))
		   (defs (assoc-ref (cpi-idefd info) file)))
	      (when tyns
		(for-each add-typename tyns)
		(set-cpi-defs! info (append defs (cpi-defs info))))
	      tyns))

	  (define (inc-stmt->file stmt)
	    (let* ((arg (cadr stmt))
		   (arg (if (ident-like? arg) ;; #include MYFILE
			    (expand-cpp-macro-ref arg (cpi-defs info))
			    arg))
		   (len (string-length arg)))
	      (substring arg 1 (1- len))))

	  (define (inc-file->path file)
	    (find-file-in-dirl file (cpi-incs info)))

	  (define (code-if stmt)
	    (case (car ppxs)
	      ((skip-look skip-done skip) ;; don't eval if excluded
	       (set! ppxs (cons 'skip ppxs)))
	      (else
	       (let* ((defs (cpi-defs info))
		      (val (eval-cpp-cond-text (cadr stmt) defs)))
		 (if (not val) (c99-err "unresolved: ~S" (cadr stmt)))
		 (if (eq? 'keep (car ppxs))
		     (if (zero? val)
			 (set! ppxs (cons 'skip-look ppxs))
			 (set! ppxs (cons 'keep ppxs)))
		     (set! ppxs (cons 'skip-done ppxs))))))
	    stmt)

	  (define (code-elif stmt)
	    (case (car ppxs)
	      ((skip) #t) ;; don't eval if excluded
	      (else
	       (let* ((defs (cpi-defs info))
		      (val (eval-cpp-cond-text (cadr stmt) defs)))
		 (if (not val) (c99-err "unresolved: ~S" (cadr stmt)))
		 (case (car ppxs)
		   ((skip-look) (if (not (zero? val)) (set-car! ppxs 'keep)))
		   ((keep) (set-car! ppxs 'skip-done))))))
	    stmt)

	  (define (code-else stmt)
	    (case (car ppxs)
	      ((skip-look) (set-car! ppxs 'keep))
	      ((keep) (set-car! ppxs 'skip-done)))
	    stmt)

	  (define (code-endif stmt)
	    (set! ppxs (cdr ppxs))
	    stmt)
	  
	  (define (eval-cpp-incl/here stmt) ;; => stmt
	    (let* ((file (inc-stmt->file stmt))
		   (path (inc-file->path file)))
	      ;;(fmterr "include ~S\n" path)
	      (cond
	       ((apply-helper file))
	       ((not path) (c99-err "not found: ~S" file)) ; file not found
	       (else (set! bol #t) (push-input (open-input-file path))))
	      stmt))

	  (define (eval-cpp-incl/tree stmt) ;; => stmt
	    ;; include file as a new tree
	    (let* ((file (inc-stmt->file stmt))
		   (path (inc-file->path file)))
	      ;;(fmterr "include ~S\n" path)
	      (cond
	       ((apply-helper file) stmt)		 ; use helper
	       ((not path) (c99-err "not found: ~S" file)) ; file not found
	       ((with-input-from-file path run-parse) => ; add tree to stmt
		(lambda (tree)
		  (for-each add-define (xp1 tree))
		  (append stmt (list tree)))))))

	  (define (eval-cpp-stmt/code stmt) ;; => stmt
	    (case (car stmt)
	      ((if) (code-if stmt))
	      ((elif) (code-elif stmt))
	      ((else) (code-else stmt))
	      ((endif) (code-endif stmt))
	      (else
	       (if (eqv? 'keep (car ppxs))
		   (case (car stmt)
		     ((include) (eval-cpp-incl/here stmt))
		     ((define) (add-define stmt) stmt)
		     ((undef) (rem-define (cadr stmt)) stmt)
		     ((error) (c99-err "error: #error ~A" (cadr stmt)))
		     ((pragma) stmt) ;; ignore for now
		     (else
		      (fmterr "stmt: ~S\n" stmt)
		      (error "1: bad cpp flow stmt")))))))
	       
	  (define (eval-cpp-stmt/decl stmt) ;; => stmt
	    (case (car stmt)
	      ((if) (code-if stmt))
	      ((elif) (code-elif stmt))
	      ((else) (code-else stmt))
	      ((endif) (code-endif stmt))
	      (else
	       (if (eqv? 'keep (car ppxs))
		   (case (car stmt)
		     ((include)		; use tree unless inside braces
		      (if (cpi-top-blev? info)
			  (eval-cpp-incl/tree stmt)
			  (eval-cpp-incl/here stmt)))
		     ((define) (add-define stmt) stmt)
		     ((undef) (rem-define (cadr stmt)) stmt)
		     ((error) (c99-err "error: #error ~A" (cadr stmt)))
		     ((pragma) stmt) ;; ignore for now
		     (else
		      (fmterr "stmt: ~S\n" stmt)
		      (error "2: bad cpp flow stmt")))
		   stmt))))
	       
	  (define (eval-cpp-stmt/file stmt) ;; => stmt
	    (case (car stmt)
	      ((if) (cpi-push) stmt)
	      ((elif else) (cpi-shift) stmt)
	      ((endif) (cpi-pop) stmt)
	      ((include) (eval-cpp-incl/tree stmt))
	      ((define) (add-define stmt) stmt)
	      ((undef) (rem-define (cadr stmt)) stmt)
	      ((error) stmt)
	      ((pragma) stmt) ;; need to work this
	      (else
	       (fmterr "stmt: ~S\n" stmt)
	       (error "3: bad cpp flow stmt"))))

	  ;; Maybe evaluate the CPP statement.
	  (define (eval-cpp-stmt stmt)
	    (with-throw-handler
	     'cpp-error
	     (lambda ()
	       (case mode
		 ((code) (eval-cpp-stmt/code stmt))
		 ((decl) (eval-cpp-stmt/decl stmt))
		 ((file) (eval-cpp-stmt/file stmt))
		 (else (error "lang/c99 coding error"))))
	     (lambda (key fmt . rest)
	       (report-error fmt rest)
	       (throw 'c99-error "CPP error"))))

	  ;; Predicate to determine if we pass the cpp-stmt to the parser.
	  ;; @itemize
	  ;; If code mode, never
	  ;; If file mode, all except includes between { }
	  ;; If decl mode, only defines and includes outside {}
	  ;; @end itemize
	  (define (pass-cpp-stmt? stmt)
	    (case mode
	      ((code) #f)
	      ((decl) (and (cpi-top-blev? info)
			   (memq (car stmt) '(include define))))
	      ((file) (or (cpi-top-blev? info)
			  (not (eqv? (car stmt) 'include))))
	      (else (error "lang/c99 coding error"))))

	  ;; Composition of @code{read-cpp-line} and @code{eval-cpp-line}.
	  (define (read-cpp-stmt ch)
	    ;;(and=> (read-cpp-line ch) cpp-line->stmt))
	    (let ((line (read-cpp-line ch)))
	      (if line
		  (begin
		    ;;(fmterr "[~S]\n" line)
		    (cpp-line->stmt line))
		  #f)))

	  ;; Recheck for expansions that turn from plain text to macro call:
	  ;; @example
	  ;; #define ABC(X,Y) ((X)+(Y))
	  ;; #define DEF ABC
	  ;; int x = DEF(1,2);
	  ;; @end example
	  (define (recheck-repl repl defs name)
	    (if (ident-like? repl)
		(or (expand-cpp-macro-ref repl defs (list name)) repl)
		repl))

	  (define (read-token)
	    (let iter ((ch (read-char)))
	      (cond
	       ((eof-object? ch)
		(set! suppress #f)
		(if (pop-input) (iter (read-char)) (assc-$ '($end . "#<eof>"))))
	       ((eq? ch #\newline) (set! bol #t) (iter (read-char)))
	       ((char-set-contains? c:ws ch) (iter (read-char)))
	       (bol
		(set! bol #f)
		(cond ;; things that depend on bol only
 		 ((read-comm ch #t) => assc-$)
		 ((read-cpp-stmt ch) =>
		  (lambda (stmt)
		    (let ((stmt (eval-cpp-stmt stmt))) ; eval can add tree
		      (if (pass-cpp-stmt? stmt)
			  (assc-$ `(cpp-stmt . ,stmt))
			  (iter (read-char))))))
		 (else (iter ch))))
	       ((read-ident ch) =>
		(lambda (name)
		  (let ((symb (string->symbol name))
			(defs (cpi-defs info)))
		    (cond
		     ((and (not suppress)
			   (if (procedure? x-def?) (x-def? name mode) x-def?)
			   (expand-cpp-macro-ref name defs))
		      => (lambda (repl)
			   (set! suppress #t) ; don't rescan
			   (push-input
			    (open-input-string
			     (recheck-repl repl defs name)))
			   (iter (read-char))))
		     ((assq-ref keytab symb)
		      => (lambda (t) (cons t name)))
		     ((typename? name)
		      (cons (assq-ref symtab 'typename) name))
		     (else
		      (cons (assq-ref symtab '$ident) name))))))
	       ((read-c-num ch) => assc-$)
	       ((read-c-string ch) => assc-$)
	       ((read-c-chlit ch) => assc-$)
	       ((read-comm ch #f) => assc-$)
	       ((and (char=? ch #\{)	; ugly tracking of block-lev in lexer
		     (eqv? 'keep (car ppxs)) (cpi-inc-blev! info) #f) #f)
	       ((and (char=? ch #\})	; ugly tracking of block-lev in lexer
		     (eqv? 'keep (car ppxs)) (cpi-dec-blev! info) #f) #f)
	       ((read-chseq ch) => identity)
	       ((assq-ref chrtab ch) => (lambda (t) (cons t (string ch))))
	       ((eqv? ch #\\) ;; C allows \ at end of line to continue
		(let ((ch (read-char)))
		  (cond ((eqv? #\newline ch) (iter (read-char))) ;; extend line
			(else (unread-char ch) (cons #\\ "\\"))))) ;; parse err
	       (else (cons ch (string ch))))))

	  ;; Loop between reading tokens and skipping tokens via CPP logic.
	  (let iter ((pair (read-token)))
	    ;;(fmterr "lx iter=>~S\n" pair)
	    (case (car ppxs)
	      ((keep)
	       pair)
	      ((skip-done skip-look skip)
	       (iter (read-token)))
	      (else (error "coding error"))))
	  )))))

;; --- last line ---
