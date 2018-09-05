;;; nyacc/lang/octave/parser.scm - parsing 

;; Copyright (C) 2016,2018 Matthew R. Wette
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
;; along with this library; if not, see <http://www.gnu.org/licenses/>.

;;; Code:

(define-module (nyacc lang octave parser)
  #:export (parse-oct read-oct-stmt read-oct-file)
  #:use-module (nyacc lex)
  #:use-module (nyacc parse)
  #:use-module (nyacc lang util))

(include-from-path "nyacc/lang/octave/body.scm")

;; === static semantics

;; 1) assn: "[ ... ] = expr" => multi-assign
;; 2) matrix: "[ int, int, int ]" => ivec
;; 3) matrix: "[ ... (fixed) ... ]" => error
;; .) colon-expr => fixed-colon-expr

(use-modules (nyacc lang sx-util))
(use-modules (sxml fold))
(use-modules ((srfi srfi-1) #:select (fold)))
(use-modules (ice-9 pretty-print))
(define (sferr fmt . args) (apply simple-format (current-error-port) fmt args))
(define (pperr exp)
  (pretty-print exp (current-error-port) #:per-line-prefix "  "))

(define (fixed-colon-expr? expr)
  (sx-match expr
    ((colon-expr (fixed ,s) (fixed ,e)) #t)
    ((colon-expr (fixed ,s) (fixed ,i) (fixed ,e)) #t)
    (else #f)))

(define (fixed-expr? expr)
  (define (fixed-primary-expr? expr)
    (sx-match expr
      ((fixed ,val) #t)
      ((add ,lt ,rt) (and (fixed-expr? lt) (fixed-expr? rt)))
      ((sub ,lt ,rt) (and (fixed-expr? lt) (fixed-expr? rt)))
      ((mul ,lt ,rt) (and (fixed-expr? lt) (fixed-expr? rt)))
      (else #f)))
  (or (fixed-primary-expr? expr)
      (eq? 'fixed-colon-expr (sx-tag expr))))

(define (float-expr? expr)
  (define (float-primary-expr? expr)
    (sx-match expr
      ((float ,val) #t)
      ((add ,lt ,rt) (and (float-expr? lt) (float-expr? rt)))
      ((sub ,lt ,rt) (and (float-expr? lt) (float-expr? rt)))
      ((mul ,lt ,rt) (and (float-expr? lt) (float-expr? rt)))
      ((div ,lt ,rt) (and (float-expr? lt) (float-expr? rt)))
      (else #f)))
  (float-primary-expr? expr))

(define (fixed-vec? row)
  (fold (lambda (elt fx) (and fx (fixed-expr? elt))) #t (sx-tail row)))

(define (float-vec? row)
  (fold (lambda (elt fx) (and fx (float-expr? elt))) #t (sx-tail row)))

(define (float-mat? mat)
  (fold (lambda (row fx) (and fx (float-vec? row))) #t
	(map sx-tail (sx-tail mat))))

(define (check-matrix mat)
  (let* ((rows (sx-tail mat))
	 (nrow (length rows))
	 (row1 (if (positive? nrow) (car rows) #f)))
    (cond
     ((zero? nrow) mat)
     ((and (= 1 nrow) (fixed-vec? row1)) `(fixed-vector . ,(cdr row1)))
     ((float-mat? mat) `(float-matrix . ,(cdr mat)))
     (else mat))))

;; @deffn {Procedure} update-octave-tree tree => tree
;; change find multiple value assignment and change to @code{multi-assn}.
;; @end deffn
(define (update-octave-tree tree)

  (define (fU tree)
    (sx-match tree
      ((assn (@ . ,attr) (matrix (row . ,elts)) ,rhs)
       `(multi-assn (@ . ,attr) (lval-list . ,elts) ,rhs))
      ((colon-expr . ,rest)
       (if (fixed-colon-expr? tree) `(fixed-colon-expr . ,(cdr tree)) tree))
      ((matrix . ,rest)
       (check-matrix tree))
      (else tree)))
  
  (define (fH tree)
    tree)
  
  (cadr (foldt fU fH `(*TOP* ,tree))))

;; === file parser 

(include-from-path "nyacc/lang/octave/mach.d/oct-tab.scm")
(include-from-path "nyacc/lang/octave/mach.d/oct-act.scm")

(define gen-octave-lexer (make-octave-lexer-generator oct-mtab))

;; Parse given a token generator.
(define raw-parser
  (make-lalr-parser (acons 'act-v oct-act-v oct-tables)))

(define* (parse-oct #:key debug)
  (catch
   'parse-error
   (lambda ()
     (raw-parser (gen-octave-lexer) #:debug debug))
   (lambda (key fmt . args)
     (apply simple-format (current-error-port) fmt args)
     #f)))

(define (read-oct-file port env)
  (with-input-from-port port
    (lambda ()
      (if (eof-object? (peek-char port))
	  (read-char port)
	  (update-octave-tree
	   (parse-oct #:debug #f))))))

;; === interactive parser

(include-from-path "nyacc/lang/octave/mach.d/octia-tab.scm")
(include-from-path "nyacc/lang/octave/mach.d/octia-act.scm")

(define raw-ia-parser
  (make-lalr-parser
   (acons 'act-v octia-act-v octia-tables)
   #:interactive #t))

(define (parse-oct-stmt lexer)
  (catch 'nyacc-error
    (lambda ()
      (raw-ia-parser lexer #:debug #f))
    (lambda (key fmt . args)
      (apply simple-format (current-error-port) fmt args)
      #f)))

(define gen-octave-ia-lexer (make-octave-lexer-generator octia-mtab))

(define read-oct-stmt
  (let ((lexer (gen-octave-ia-lexer)))
    (lambda (port env)
      (cond
       ((eof-object? (peek-char port))
	(read-char port))
       (else
	(let* ((stmt (with-input-from-port port
		      (lambda () (parse-oct-stmt lexer))))
	       (stmt (update-octave-tree stmt)))
	  ;;(sferr "stmt=~S\n" stmt)
	  (cond
	   ((equal? stmt '(empty-stmt)) #f)
	   (stmt)
	   ;;(else (flush-input-after-error port) #f)
	   )))))))

;; --- last line ---
