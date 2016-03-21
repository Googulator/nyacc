;;; nyacc/lang/matlab/util.scm - matlab processing code
;;; 
;;; Copyright (C) 2016 Matthew R. Wette
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

;; utilities for processing output trees

(define-module (nyacc lang matlab util)
  #:export (
	    apply-ml-sem ;; apply static semantics
	    declify-ffile declify-script
	    name-expr->decl
	    )
  #:use-module (nyacc lang util)
  #:use-module (ice-9 pretty-print)
  #:use-module ((sxml fold) #:select (foldts*-values))
  #:use-module (sxml match)
  )

;; probably also need some sort of overall declaration form
;; need an example

;; need to remove aref-or-call
;; only way is to know if ident is variable or function
;; local variables
;; @item
;; global variables
;; @item
;; function arguments
;; @item
;; look for str2func
;; @item
;; look in dict for function
;; @item
;; if function argument is function then use will always be w/ ftn ref (@@).
;; @item
;; varargs
(define (apply-ml-sem tree . rest)
  (let* ((ml-dict (if (pair? rest) (car rest) '()))
	 )
    tree))

;; decl
;; decl: fctn, struct, array, double, int
#;(define (name-expr->c-decl name expr) ;; => decl
  (sxml-match expr
    ((aref-or-call (ident "zeros") ,ex-l)
     #f)))

;; track vardict - type-usage, a list of:
;;   'float 'fixed 'float-a 'fixed-a 'struct 'aorf

(define (fout fmt . args)
  (apply simple-format #t fmt args))


;; dict = ((name . (type rank)) ...)
;; OR     ((name type . rank) ...)
(define (d-add-type dict name type)
  (let ((resp (assoc-ref dict name)))
    (cond
     ((not resp) (acons name type #f))
     ((eqv? (cadr resp) type) dict)
     (else (acons name (cons type (cddr resp)) dict)))))
 
(define (d-add-rank dict name rank)
  (let ((resp (assoc-ref dict name)))
    (cond
     ((not resp) (acons name #f rank))
     ((eqv? (cddr resp) rank) dict)
     (else (acons name (cons rank (cddr resp)) dict)))))

(define (d-push dict)
  (list (cons '@P dict)))

(define (d-pop dict)
  (assq-ref dict '@P))

;; @edeffn lval->ident lval [disp] => string
;; Given an lval return the root identifier name as a string.
;; @var{disp} is the disposition (e.g., struct) of the lval
(define* (lval->ident lval #:optional (disp 'unknown))
  (sxml-match lval
    ((ident ,name) (cons name disp))
    ((sel ,ident ,lval) (lval->ident lval 'struct))
    ((array-ref ,lval ,ex-l)
     (case disp
       ((struct) (lval->ident lval disp))
       (else (lval->ident lval 'array))))
    ((aref-or-call ,lval ,ex-l)
     (case disp
       ((struct) (lval->ident lval disp))
       (else (lval->ident lval 'array))))
    (,otherwise
     (throw 'util-error "unknown lval: ~S" lval))))

(define (binary-rank lval rval)
  (and lval rval (max lval rval)))

;; @deffn expr->rank expr => #f,0,1,..
;; Return rank of expression, if it can be determined.
(define* (expr->rank expr #:optional (dict '()))
  (case (sx-tag expr)
    ((ident) (and=> (assoc-ref dict (sx-ref expr 1)) cdr))
    ((sel) (expr->rank (sx-ref expr 2) dict))
    ((array-ref) (length (sx-tail (sx-ref expr 2) 1)))
    ((add sub mul div) (binary-rank (sx-ref expr 1) (sx-ref expr 2)))
    (else
     (throw 'util-error "unknown expr: ~S" expr))))
    
;; dictionary
;; (name . (fixed rank)) if type == float fixed
;; (name . (float rank)) if type == float fixed
;; (name . (var rank)) if type == float fixed
;; (name . (fctn pub?))

;; @deffn declify-ffile tree [dict] => tree
;; This needs work.
;; The idea is to end up with declarations for a matlab function-file.
;; The filename function should be public, all others private.
(define (declify-ffile tree . rest)
  
  (define (fD tree seed dict) ;; => (values tree seed dict)
    (sxml-match tree
      ((function-file (@ (file ,name)) . ,rest)
       (values tree '()
	       (cons*
		(cons name (cons 'fctn #t))
		(cons "file" name)
		dict)))

      ((fctn-decl (ident ,name) . ,rest)
       (values
	(sx-set-attr!
	 tree 'scope (if (equal? name (assoc-ref dict "file")) "pub" "prv"))
	'() dict))

      ((assn (aref-or-call ,expr ,ex-l) . ,rval)
       (values `(assn (array-ref ,expr ,ex-l)) '() dict))
      
      ((assn ,lval ,rval)
       ;;(fout "lval->ident=>~S\n" (lval->ident lval))
       ;;(values tree '() (d-add-rank dict name (length (sx-tail lval 1)))))
       (values tree '() dict))

      (,otherwise
       (values tree '() dict))))

  (define (fU tree seed dict kseed kdict) ;; => (values seed dict)
    ;;(fout "tree-tag=~S kseed=~S\n" (car tree) kseed)
    (case (car tree)
      ((float fixed)
       (values
	(cons (sx-set-attr! (reverse kseed) 'rank "0") seed)
	dict))
      
      #;((fctn-decl)
       (values
	(cons (reverse kseed) seed)
	(d-pop kdict)))
      
      (else
       (values
	(if (null? seed) (reverse kseed) ; w/o this top node is list
	    (cons (reverse kseed) seed))
	dict))))

  (define (fH tree seed dict) ;; => (values seed dict)
    (values (cons tree seed) dict))

  (let*
      ((ml-dict (if (pair? rest) (car rest) '()))
       (ty-dict '())
       (sx (foldts*-values fD fU fH tree '() ty-dict))
       )
    sx))

;; @deffn declify-script tree [dict] => tree
;; This needs work.
;; The idea is to end up with declarations for a matlab function-file.
;; The filename function should be public, all others private.
(define (declify-script tree . rest)
  
  (define (fD tree seed dict) ;; => (values tree seed dict)
    (sxml-match tree
      ((script-file (@ (file ,name)) . ,rest)
       (values tree '()
	       (cons*
		(cons "file" name)
		dict)))

      ((assn (aref-or-call ,expr ,ex-l) . ,rval)
       (values `(assn (array-ref ,expr ,ex-l)) '() dict))
      
      ((assn (ident ,name) (aref-or-call (ident "struct") ,ex-l))
       (let ((kvl (let iter ((kvl '()) (al (sx-tail ex-l 1)))
		    (if (null? al) (reverse kvl)
			(iter (cons (list (car al) (cadr al))
				    kvl) (cddr al)))))
	     )
	 (fout "struct ~S\n" name) 
	 (pretty-print kvl)
	 (values tree '() dict)))
       
      ((assn ,lval ,rval)
       ;;(fout "lval->ident=>~S\n" (lval->ident lval))
       ;;(fout "    ->rank =>~S\n" (expr->rank lval))
       (values tree '() dict))

      (,otherwise
       (values tree '() dict))))

  (define (fU tree seed dict kseed kdict) ;; => (values seed dict)
    ;;(fout "tree-tag=~S kseed=~S\n" (car tree) kseed)
    (case (car tree)
      ((float fixed)
       (values
	(cons (sx-set-attr! (reverse kseed) 'rank "0") seed)
	dict))
      
      (else
       (values
	(if (null? seed) (reverse kseed) ; w/o this top node is list
	    (cons (reverse kseed) seed))
	dict))))

  (define (fH tree seed dict) ;; => (values seed dict)
    (values (cons tree seed) dict))

  (let*
      ((ml-dict (if (pair? rest) (car rest) '()))
       (ty-dict '())
       (sx (foldts*-values fD fU fH tree '() ty-dict))
       )
    sx))

;; --- last line ---
