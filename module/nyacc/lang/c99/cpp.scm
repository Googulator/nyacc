;; lang/c/cpp.scm
;;
;; Copyright (C) 2015-2017 Matthew R. Wette
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by 
;; the Free Software Foundation, either version 3 of the License, or 
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of 
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; C preprocessor macro expansion and condition text parse-and-eval
;; ref: https://gcc.gnu.org/onlinedocs/gcc-3.0.1/cpp_3.html

(define-module (nyacc lang c99 cpp)
  #:export (
	    cpp-line->stmt
	    eval-cpp-cond-text
	    expand-cpp-macro-ref
	    parse-cpp-expr
	    find-incl-in-dirl
	    scan-arg-literal
	    eval-cpp-expr)
  #:use-module (nyacc parse)
  #:use-module (nyacc lex)
  #:use-module (nyacc lang util)
  #:use-module (rnrs arithmetic bitwise)
  #:use-module (ice-9 match)
  #:use-module (ice-9 textual-ports)
  #:use-module (system base pmatch)
  )

(define c99-std-defs
  '("__DATE__" "__FILE__" "__LINE__" "__STDC__" "__STDC_HOSTED__"
    "__STDC_VERSION__" "__TIME__"))

(define (c99-std-def? str)
  (let iter ((defs c99-std-defs))
    (cond
     ((null? defs) #f)
     ((string=? (car defs) str) #t)
     (else (iter (cdr defs))))))

(define (c99-std-val str)
  (cond
   ((string=? str "__DATE__") "M01 01 2001")
   ((string=? str "__FILE__") "(unknown)")
   ((string=? str "__LINE__") "0")
   ((string=? str "__STDC__") "1")
   ((string=? str "__STDC_HOSTED__") "0")
   ((string=? str "__STDC_VERSION__") "201701")
   ((string=? str "__TIME__") "00:00:00")
   (else #f)))

(define inline-whitespace (list->char-set '(#\space #\tab)))

;;.@deffn {Procedure} skip-il-ws ch
;; Skip in-line whitespace
;; @end deffn
(define (skip-il-ws ch)
  (cond
   ((eof-object? ch) ch)
   ((char-set-contains? inline-whitespace ch) (skip-il-ws (read-char)))
   (else ch)))

;; Not sure about this. We want to turn a list of tokens into a string
;; with proper escapes.
(define (esc-c-str str)
  (list->string
   (string-fold-right
    (lambda (ch chl)
      (case ch
	((#\\ #\") (cons* #\\ ch chl))
	(else (cons ch chl))))
    '() str)))

(define ident-like? (make-ident-like-p read-c-ident))

;; @deffn {Procedure} read-ellipsis ch
;; read ellipsis
;; @end deffn
(define (read-ellipsis ch)
  (cond
   ((eof-object? ch) #f)
   ((char=? ch #\.) (read-char) (read-char) "...") ; assumes correct syntax
   (else #f)))

;; @deffn {Procedure} find-incl-in-dirl file dirl next => path
;; Find path to include file expression, (i.e., @code{<foo.h>} or
;; @code{"foo.h"}.  If @code{"foo.h"} form look in current directory first.
;; If @var{next} is true then remove current directory from search path.
;; @*Refs:
;; @itemize
;; @item https://gcc.gnu.org/onlinedocs/cpp/Search-Path.html
;; @item https://gcc.gnu.org/onlinedocs/cpp/Wrapper-Headers.html
;; @end itemize
;; @end deffn
(define (find-incl-in-dirl file dirl next)
  (let* ((cid (and=> (port-filename (current-input-port)) dirname))
	 (file-type (string-ref file 0)) ;; #\< or #\"
	 (file-name (substring file 1 (1- (string-length file))))
	 (dirl (if (and cid (char=? #\" file-type)) (cons cid dirl) dirl)))
    (let iter ((dirl dirl))
      (if (null? dirl) #f
	  (if (and next (string=? (car dirl) cid))
	      (iter (cdr dirl))
	      (let ((p (string-append (car dirl) "/" file-name)))
		(if (access? p R_OK) p (iter (cdr dirl)))))))))

;; @deffn {Procedure} cpp-define
;; Reads CPP define from current input and generates a cooresponding sxml
;; expression.
;; @example
;;   (define (name "ABC") (repl "123"))
;; OR
;;   (define (name "ABC") (args "X" "Y") (repl "X+Y"))
;; @example
;; @end deffn
(define (cpp-define)

  (define (p-args la) ;; parse args
    (if (eq? la #\()
	(let iter ((args '()) (la (skip-il-ws (read-char))))
	  (cond
	   ((eq? la #\)) (reverse args))
	   ((read-c-ident la) =>
	    (lambda (arg) (iter (cons arg args) (skip-il-ws (read-char)))))
	   ((read-ellipsis la) =>
	    (lambda (arg) (iter (cons arg args) (skip-il-ws (read-char)))))
	   ((eq? la #\,) (iter args (skip-il-ws (read-char))))))
	(begin (if (char? la) (unread-char la)) #f)))

  (define (p-rest la) ;; parse rest
    (cond ((eof-object? la) "")
	  (else (unread-char la) (get-string-all (current-input-port)))))

  (let* ((name (read-c-ident (skip-il-ws (read-char))))
	 (args (or (p-args (read-char)) '()))
	 (repl (p-rest (skip-il-ws (read-char)))))
    (if (pair? args)
	`(define (name ,name) (args . ,args) (repl ,repl))
	`(define (name ,name) (repl ,repl)))))
	

;; @deffn {Procedure} cpp-include
;; Parse CPP include statement.
(define (cpp-include)
  (define (iter cl ch end-ch)
    (if (eq? ch end-ch)  (list->string (reverse (cons ch cl)))
	(iter (cons ch cl) (read-char) end-ch)))
   (let ((ch (skip-il-ws (read-char))))
     (cond
      ((char=? ch #\<) (iter (list #\<) (read-char) #\>))
      ((char=? ch #\") (iter (list #\") (read-char) #\"))
      ((read-c-ident ch))
      (else (throw 'cpp-error "bad include")))))

;; @deffn {Procedure} cpp-line->stmt line defs => (stmt-type text)
;; Parse a line from a CPP statement and return a parse tree.
;; @example
;; (parse-cpp-stmt "define X 123") => (define "X" "123")
;; (parse-cpp-stmt "if defined(A) && defined(B) && defined(C)"
;; => (if "defined(A) && defined(B) && defined(C)")
;; @end example
;; To evaluate the @code{if} statements use @code{parse-cpp-expr} and
;; @code{eval-cpp-expr}.
;; @end deffn
(define (cpp-line->stmt line)
  (define (rd-ident) (read-c-ident (skip-il-ws (read-char))))
  (define (rd-num) (and=> (read-c-num (skip-il-ws (read-char))) cdr))
  (define (rd-rest) (let ((ch (skip-il-ws (read-char))))
		      (if (not (eof-object? ch)) (unread-char ch))
		      (get-string-all (current-input-port))))
  (with-input-from-string line
    (lambda ()
      (let ((ch (skip-il-ws (read-char))))
	(cond
	 ((read-c-ident ch) =>
	  (lambda (cmds)
	    (let ((cmd (string->symbol cmds)))
	      (case cmd
		((include) `(include ,(cpp-include)))
		((include_next) `(include-next ,(cpp-include)))
		((define) (cpp-define))
		((undef) `(undef ,(rd-ident)))
		((ifdef)
		 `(if ,(string-append "defined(" (rd-ident) ")" (rd-rest))))
		((ifndef)
		 `(if ,(string-append "!defined(" (rd-ident) ")" (rd-rest))))
		((if elif else endif line error warning pragma)
		 (list cmd (rd-rest)))
		(else
		 (list 'warning (simple-format #f "unknown CPP: ~S" line)))))))
	 ((read-c-num ch) => (lambda (num) `(line ,num ,(rd-rest))))
	 (else (error "missing code")))))))
	    

(include-from-path "nyacc/lang/c99/mach.d/cpptab.scm")
(include-from-path "nyacc/lang/c99/mach.d/cppact.scm")

(define cpp-raw-parser
  (make-lalr-parser
   (list (cons 'len-v cpp-len-v) (cons 'pat-v cpp-pat-v)
	 (cons 'rto-v cpp-rto-v) (cons 'mtab cpp-mtab)
	 (cons 'act-v cpp-act-v))))

(define (cpp-err fmt . args)
  (apply throw 'cpp-error fmt args))

;; Since we want to be able to get CPP statements with comment in tact
;; (e.g., for passing to @code{pretty-print-c99}) we need to remove
;; comments when parsing CPP expressions.  We convert a comm-reader
;; into a comm-skipper here.  And from that generate a lexer generator.
(define cpp-comm-skipper
  (let ((reader (make-comm-reader '(("/*" . "*/")))))
    (lambda (ch)
      (reader ch #f))))

;; generate a lexical analyzer per string
(define gen-cpp-lexer
  (make-lexer-generator cpp-mtab
			#:comm-skipper cpp-comm-skipper
			#:chlit-reader read-c-chlit
			#:num-reader read-c-num))

;; @deffn {Procedure} parse-cpp-expr text => tree
;; Given a string returns a cpp parse tree.  This is called by
;; @code{eval-cpp-expr}.  The text will have had all CPP defined symbols
;; expanded already so no identifiers should appear in the text.
;; A @code{cpp-error} will be thrown if a parse error occurs.
;; @end deffn
(define (parse-cpp-expr text)
  (with-throw-handler
   'nyacc-error
   (lambda ()
     (with-input-from-string text
       (lambda () (cpp-raw-parser (gen-cpp-lexer)))))
   (lambda (key fmt . args)
     (apply throw 'cpp-error fmt args))))

;; @deffn {Procedure} eval-cpp-expr tree [options] => datum
;; Evaluate a tree produced from @code{parse-cpp-expr}.
;; Options include optional dictionary for defines and values
;; and @code{#:inc-dirs} for @code{has_include} etc
;; @end deffn
(define* (eval-cpp-expr tree #:optional (dict '()) #:key (inc-dirs '()))
  (letrec
      ((tx (lambda (tr ix) (sx-ref tr ix)))
       (tx1 (lambda (tr) (tx tr 1)))
       (ev (lambda (ex ix) (eval-expr (sx-ref ex ix))))
       (ev1 (lambda (ex) (ev ex 1)))	; eval expr in arg 1
       (ev2 (lambda (ex) (ev ex 2)))	; eval expr in arg 2
       (ev3 (lambda (ex) (ev ex 3)))	; eval expr in arg 3
       (eval-expr
	(lambda (tree)
	  (case (car tree)
	    ((fixed) (string->number (cnumstr->scm (tx1 tree))))
	    ((char) (char->integer (string-ref (tx1 tree) 0)))
	    ((defined) (if (assoc-ref dict (tx1 tree)) 1 0))
	    ((has-include)
	     (if (find-incl-in-dirl (tx1 tree) inc-dirs #f) 1 0))
	    ((has-include-next)
	     (if (find-incl-in-dirl (tx1 tree) inc-dirs #t) 1 0))
	    ((pre-inc post-inc) (1+ (ev1 tree)))
	    ((pre-dec post-dec) (1- (ev1 tree)))
	    ((pos) (ev1 tree))
	    ((neg) (- (ev1 tree)))
	    ((not) (if (zero? (ev1 tree)) 1 0))
	    ((mul) (* (ev1 tree) (ev2 tree)))
	    ((div) (/ (ev1 tree) (ev2 tree)))
	    ((mod) (modulo (ev1 tree) (ev2 tree)))
	    ((add) (+ (ev1 tree) (ev2 tree)))
	    ((sub) (- (ev1 tree) (ev2 tree)))
	    ((lshift) (bitwise-arithmetic-shift-left (ev1 tree) (ev2 tree)))
	    ((rshift) (bitwise-arithmetic-shift-right (ev1 tree) (ev2 tree)))
	    ((lt) (if (< (ev1 tree) (ev2 tree)) 1 0))
	    ((le) (if (<= (ev1 tree) (ev2 tree)) 1 0))
	    ((gt) (if (> (ev1 tree) (ev2 tree)) 1 0))
	    ((ge) (if (>= (ev1 tree) (ev2 tree)) 1 0))
	    ((equal) (if (= (ev1 tree) (ev2 tree)) 1 0))
	    ((noteq) (if (= (ev1 tree) (ev2 tree)) 0 1))
	    ((bitwise-not) (lognot (ev1 tree)))
	    ((bitwise-or) (logior (ev1 tree) (ev2 tree)))
	    ((bitwise-xor) (logxor (ev1 tree) (ev2 tree)))
	    ((bitwise-and) (logand (ev1 tree) (ev2 tree)))
	    ((or) (if (and (zero? (ev1 tree)) (zero? (ev2 tree))) 0 1))
	    ((and) (if (or (zero? (ev1 tree)) (zero? (ev2 tree))) 0 1))
	    ((cond-expr) (if (zero? (ev1 tree)) (ev3 tree) (ev2 tree)))
	    ;; hacks for use in util2.scm:canize-enum-def-list:
	    ;; If ident is defined then it should have already been expanded.
	    ;; So then only enum defs remain which should be valid expressions.
	    ((ident) (or (and=> (assoc-ref dict (tx1 tree)) string->number) 0))
	    ((p-expr) (ev1 tree))
	    ((cast) (ev2 tree))
	    (else (error "incomplete eval-cpp-expr implementation"))))))
    (eval-expr tree)))

;;.@deffn {Procedure} rtokl->string reverse-token-list => string
;; Convert reverse token-list to string.
;; @end deffn
(define (rtokl->string tokl)

  ;; Turn reverse chl into a string and insert it into the string list stl.
  (define (add-chl chl stl)
    (if (null? chl) stl (cons (list->string chl) stl)))

  ;;(sferr "\nrtokl->string=~S\n" tokl)
  ;; Works like this: Scan through the list of tokens (key-val pairs or
  ;; lone characters).  Lone characters are collected in a list (@code{chl});
  ;; pairs are converted into strings and combined with list of characters
  ;; into a list of strings.  When done the list of strings is combined to
  ;; one string.  (The token 'argval is expansion of argument.)
  (let iter ((stl '())		   ; list of strings to reverse-append
	     (chl '())		   ; char list
	     (nxt #f)		   ; next string to add after chl
	     (tkl tokl))	   ; input token list
    (cond
     (nxt
      (iter (cons nxt (add-chl chl stl)) '() #f tkl))
     ((null? tkl)
      (apply string-append (add-chl chl stl)))
     ((char? (car tkl))
      (iter stl (cons (car tkl) chl) nxt (cdr tkl)))
     (else
      (pmatch tkl
	((($ident . ,rval) $dhash ($ident . ,lval) . ,rest)
	 (iter stl chl nxt
	       (acons '$ident (string-append lval rval) (list-tail tkl 3))))
	((($ident . ,arg) $hash . ,rest)
	 (iter stl chl (string-append "\"" arg "\"") (list-tail tkl 2)))
	((($ident . ,iden) ($ident . ,lval) . ,rest)
	 (iter stl chl iden rest))
	((($ident . ,iden) . ,rest)
	 (iter stl chl iden rest))
	((($string . ,val) . ,rest)
	 (iter stl (cons #\" chl) (esc-c-str val) (cons #\" rest)))
	((($echo . ,val) . ,rest)
	 (iter stl chl val rest))
	(($space $space . ,rest)
	 (iter stl chl nxt rest))
	(($space . ,rest)
	 (iter stl (cons #\space chl) nxt rest))
	((,asis . ,rest)
	 (iter stl chl asis rest))
	(,otherwise
	 (error "no match" tkl)))))))

;; We just scanned "defined", now need to scan the arg to inhibit expansion.
;; For example, we have scanned "defined"; we now scan "(FOO)" or "FOO", and
;; return "defined(FOO)" or "defined FOO".
(define (scan-defined-arg)
  (let* ((ch (skip-il-ws (read-char))) (no-ec (not (char=? ch #\())))
    (let iter ((chl (list ch)) (ch (skip-il-ws (read-char))))
      (cond
       ((eof-object? ch)
	(if no-ec
	    (list->string (cons #\space (reverse chl)))
	    (cpp-err "illegal argument to `defined'")))
       ((char-set-contains? c:ir ch)
	(iter (cons ch chl) (read-char)))
       (no-ec
	(unread-char ch)
	(list->string (cons #\space (reverse chl))))
       ((char=? #\) (skip-il-ws ch))
	(list->string (reverse (cons #\) chl))))
       (else
	(cpp-err "illegal argument to  `defined'"))))))

;; must be (\s*<xxx>\s*) OR (\s*"xxx"\s*) => ("<xxx>") OR ("\"xxx\"")
(define (scan-arg-literal)
  (let ((ch (read-char)))
    ;; if exit, then did not defined __has_include(X)=__has_include__(X)
    (if (or (eof-object? ch) (not (char=? #\( ch))) (error "expedcting `('")))
  (let iter ((chl '()) (ch (skip-il-ws (read-char))))
    (cond
     ((eof-object? ch) (cpp-err "illegal argument"))
     ((char=? #\) ch)
      (let iter2 ((res '()) (chl chl))
	(cond
	 ((null? chl)
	  (string-append "(\"" (esc-c-str (list->string res)) "\")"))
	 ((and (null? res) (char-whitespace? (car chl))) (iter2 res (cdr chl)))
	 (else (iter2 (cons (car chl) res) (cdr chl))))))
     (else (iter (cons ch chl) (read-char))))))

(define (scan-cpp-input defs used end-tok)
  ;; Works like this: scan for tokens (comments, parens, strings, char's, etc).
  ;; Tokens are collected in a (reverse ordered) list (tkl) and merged together
  ;; to a string on return using @code{rtokl->string}.  Keep track of expanded
  ;; identifiers and rerun if something got expanded.  Also, keep track of
  ;; ## and spaces so that we can parse ID /* foo */ ## /* bar */ 123
  ;; as well as ABC/*foo*/(123,456).

  (define (trim-spaces tkl)
      (if (and (pair? tkl) (eqv? '$space (car tkl)))
	  (trim-spaces (cdr tkl))
	  tkl))

  (define (finish rr tkl)
    ;;(sferr "finish ~S ~S\n" rr tkl)
    (let* ((tkl (if end-tok (trim-spaces tkl) tkl))
	   (repl (rtokl->string tkl)))
      (if (pair? rr)
	  (cpp-expand-text repl defs (append rr used)) ;; re-run
	  repl)))
     
  ;;(sferr "scan-cpp-input end-tok=~S\n" end-tok)
  (let iter ((rr '())			; list symbols resolved
	     (tkl '())			; token list of
	     (lv 0)			; level
	     (ch (skip-il-ws (read-char)))) ; next character
    ;;(unless end-tok (sferr "tkl=~S ch=~S\n" tkl ch))
    (cond
     ((eof-object? ch) (finish rr tkl))
     ((and (eqv? end-tok ch) (zero? lv))
      (unread-char ch) (finish rr tkl))
     ((and end-tok (char=? #\) ch) (zero? lv))
      (unread-char ch) (finish rr tkl))
     ((or (char-set-contains? c:ws ch)	; whitespace
	  (read-c-comm ch #f))		; comment
      (iter rr (cons '$space tkl) lv (skip-il-ws (read-char))))
     ((read-c-ident ch) =>
      (lambda (iden)
	(cond
	 ((string=? iden "defined")
	  (iter rr
		(acons '$echo (string-append iden (scan-defined-arg)) tkl)
		lv (read-char)))
	 ((member iden '("__has_include__" "__has_include_next__"))
	  (cond
	   ((scan-arg-literal) =>
	    (lambda (arg)
	      (iter rr (acons '$echo (string-append iden arg) tkl)
		    lv (read-char))))
	   (else 
	    (iter rr (acons '$ident iden tkl) lv (read-char)))))
	 (else
	  (let ((rval (expand-cpp-macro-ref iden defs used)))
	    (if rval
		(iter #t (cons rval tkl) lv (read-char))
		(iter rr (acons '$ident iden tkl) lv (read-char))))))))
     ((read-c-string ch) =>
      (lambda (pair) (iter rr (cons pair tkl) lv (read-char))))
     ((char=? #\( ch) (iter rr (cons ch tkl) (1+ lv) (read-char)))
     ((char=? #\) ch) (iter rr (cons ch tkl) (1- lv) (read-char)))
     (else
      (iter rr (cons ch tkl) lv (read-char))))))

;; @deffn {Procedure} collect-args argl defs used => argd
;; Collect arguments to a macro which appears in C code.  If not looking at
;; @code{(} return @code{#f}, else scan and eat up to closing @code{)}.
;; If multiple whitespace characters are skipped at the front then only
;; one @code{#\space} is re-inserted.
;; @end deffn
(define (collect-args argl defs used)
  (let iter1 ((sp #f) (ch (read-char)))
    (cond
     ((eof-object? ch) (if sp (unread-char #\space)) #f)
     ((char-set-contains? inline-whitespace ch) (iter1 #t (read-char)))
     ((char=? #\( ch)
      (let iter2 ((argl argl) (argv '()) (ch ch))
	(cond
	 ((eqv? ch #\)) (reverse argv))
	 ((null? argl) (cpp-err "arg count"))
	 ((and (null? (cdr argl)) (string=? (car argl) "..."))
	  (let ((val (scan-cpp-input defs used #\))))
	    (iter2 (cdr argl) (acons "__VA_ARGS__" val argv) (read-char))))
	 ((or (char=? ch #\() (char=? ch #\,))
	  (let* ((val (scan-cpp-input defs used #\,)))
	    (iter2 (cdr argl) (acons (car argl) val argv) (read-char))))
	 (else
	  (error "cpp.scm, collect-args: coding error")))))
     (else (unread-char ch) (if sp (unread-char #\space)) #f))))

;; @deffn {Procedure} px-cpp-ftn-repl argd repl => string
;; pre-expand CPP function where @var{argd} is an a-list of arg name
;; and replacement and repl is the defined replacement
;; 
;; argd is alist of arguments and token lists
;; if end-tok == #f ignore levels
;; ident space fixed float chseq hash dhash arg
;; need to decide if we should use `(space ,tkl) or `((space) ,tkl)
;; This should replace args and execute hash and double-hash ??
;; @end deffn
(define (px-cpp-ftn argd repl)
  (with-input-from-string repl
    (lambda ()
      ;;(sferr "px-cpp-ftn argd=~S repl=~S\n" argd repl)
      (px-cpp-ftn-1 argd))))

(define (px-cpp-ftn-1 argd)

  ;; Turn reverse chl into a string and insert it into the token stream.
  (define (ins-chl chl stl)
    (if (null? chl) stl (cons (list->string (reverse chl)) stl)))

  (define (rem-space chl)
    (let iter ((chl chl))
      (cond
       ((null? chl) chl)
       ((char-set-contains? c:ws (car chl)) (iter (cdr chl)))
       (else chl))))

  (define (mk-string str) (string-append "\"" (esc-c-str str) "\""))

  (let iter ((stl '())			; string list
	     (chl '())			; character list
	     (nxt #f)			; next string after char list
	     (ch (read-char)))		; next character
    ;;(sferr "px-1: stl=~S chl=~S nxt=~S ch=~S\n" stl chl nxt ch)
    (cond
     (nxt (iter (cons nxt (ins-chl chl stl)) '() #f ch))
     ((eof-object? ch)
      (apply string-append (reverse (ins-chl chl stl))))
     ((char-set-contains? c:ws ch)
      (iter stl (cons #\space chl) nxt (skip-il-ws (read-char))))
     ((read-c-comm ch #f) (iter stl (cons #\space chl) nxt (read-char)))
     ((read-c-string ch) =>
      (lambda (st) (iter stl chl (mk-string (cdr st)) (read-char))))
     ((char=? #\( ch) (iter stl (cons ch chl) nxt (read-char)))
     ((char=? #\) ch) (iter stl (cons ch chl) nxt (read-char)))
     ((read-c-ident ch) =>		; replace if aval
      (lambda (iden)
	(iter stl chl (or (assoc-ref argd iden) iden) (read-char))))
     ((char=? #\# ch)
      (let ((ch (read-char)))
	(if (eqv? ch #\#)
	    (iter stl (rem-space chl) nxt (skip-il-ws (read-char)))
	    (let* ((aref (read-c-ident (skip-il-ws ch)))
		   (aval (assoc-ref argd aref)))
	      (if (not aref) (cpp-err "expecting arg-ref"))
	      (if (not aval) (cpp-err "expecting arg-val"))
	      (iter stl chl (mk-string aval) (read-char))))))
     (else (iter stl (cons ch chl) nxt (read-char))))))
  
;; @deffn {Procedure} cpp-expand-text text defs [used] => string
;; Expand the string @var{text} using the provided CPP @var{defs} a-list.
;; Identifiers in the list of strings @var{used} will not be expanded.
;; @end deffn
(define* (cpp-expand-text text defs #:optional (used '()))
  (with-input-from-string text
    (lambda () (scan-cpp-input defs used #f))))

;; === exports =======================

;; @deffn {Procedure} eval-cpp-cond-text text [defs] => string
;; Evaluate CPP condition expression (text).
;; Undefined identifiers are replaced with @code{0}.
;; @end deffn
(define* (eval-cpp-cond-text text #:optional (defs '()) #:key (inc-dirs '()))
  (with-throw-handler
   'cpp-error
   (lambda ()
     (let* ((rhs (cpp-expand-text text defs))
	    (exp (parse-cpp-expr rhs)))
       (eval-cpp-expr exp defs #:inc-dirs inc-dirs)))
   (lambda (key fmt . args)
     (report-error fmt args)
     (throw 'c99-error "CPP error"))))

;; @deffn {Procedure} expand-cpp-macro-ref ident defs [used] => repl|#f
;; Given an identifier seen in the current input, this checks for associated
;; definition in @var{defs} (generated from CPP defines).  If found as simple
;; macro, the expansion is returned as a string.  If @var{ident} refers
;; to a macro with arguments, then the arguments will be read from the
;; current input.  The format of the @code{defs} entries are
;; @example
;; ("ABC" . "123")
;; ("MAX" ("X" "Y") . "((X)>(Y)?(X):(Y))")
;; @end example
;; @end deffn
(define* (expand-cpp-macro-ref ident defs #:optional (used '()))
  (let ((rval (assoc-ref defs ident)))
    (cond
     ((member ident used) #f)
     ((string? rval)
      (let* ((used (cons ident used))
	     (repl (cpp-expand-text rval defs used)))
	(if (ident-like? repl)
	    (or (expand-cpp-macro-ref repl defs used) repl)
	    repl)))
     ((pair? rval)
      (and=> (collect-args (car rval) defs used)
	     (lambda (argd)
	       (let* ((used (cons ident used))
		      (prep (px-cpp-ftn argd (cdr rval)))
		      (repl (cpp-expand-text prep defs used)))
		 (if (ident-like? repl)
		     (or (expand-cpp-macro-ref repl defs used) repl)
		     repl)))))
     ((c99-std-val ident) => identity)
     (else #f))))

;;; --- last line ---
