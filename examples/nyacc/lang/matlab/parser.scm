;; nyacc/lang/matlab/parser.scm

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

(define-module (nyacc lang matlab parser)
  #:export (parse-ml ml-stmt-reader ml-file-reader)
  #:use-module (nyacc lex)
  #:use-module (nyacc parse)
  #:use-module (nyacc lang util))

(include-from-path "nyacc/lang/matlab/body.scm")

;; === static semantics

(use-modules (sxml fold))
(use-modules (nyacc lang sx-util))

;; @deffn {Procedure} update-matlab-tree tree => tree
;; change find multiple value assignment and change to @code{multi-assn}.
;; @end deffn
(define (update-matlab-tree tree)

  (define (fU tree)
    (sx-match tree
      ((assn (matrix (row . ,elts)) ,rhs)
       `(multi-assn (lval-list . ,elts) ,rhs))
      (else tree)))
  
  (define (fH tree)
    tree)
  
  (cadr (foldt fU fH `(*TOP* ,tree))))

;; === file parser 

(include-from-path "nyacc/lang/matlab/mach.d/mltab.scm")
(include-from-path "nyacc/lang/matlab/mach.d/mlact.scm")

(define gen-matlab-lexer (make-matlab-lexer-generator ml-mtab))

;; Parse given a token generator.
(define raw-parser
  (make-lalr-parser 
   (list
    (cons 'len-v ml-len-v)
    (cons 'pat-v ml-pat-v)
    (cons 'rto-v ml-rto-v)
    (cons 'mtab ml-mtab)
    (cons 'act-v ml-act-v))))

(define* (parse-ml #:key debug)
  (catch
   'parse-error
   (lambda ()
     (raw-parser (gen-matlab-lexer) #:debug debug))
   (lambda (key fmt . args)
     (apply simple-format (current-error-port) fmt args)
     #f)))

(define (ml-file-reader port env)
  (with-input-from-port port
    (lambda ()
      (if (eof-object? (peek-char port))
	  (read-char port)
	  (update-matlab-tree
	   (parse-ml #:debug #f))))))

;; === interactive parser

(include-from-path "nyacc/lang/matlab/mach.d/ia-mltab.scm")
(include-from-path "nyacc/lang/matlab/mach.d/ia-mlact.scm")

(define gen-ia-matlab-lexer (make-matlab-lexer-generator ia-ml-mtab))

(define raw-ia-parser
  (make-lalr-parser
   (list (cons 'len-v ia-ml-len-v) (cons 'pat-v ia-ml-pat-v)
	 (cons 'rto-v ia-ml-rto-v) (cons 'mtab ia-ml-mtab)
	 (cons 'act-v ia-ml-act-v))
   #:interactive #t))

(define (parse-ml-stmt lexer)
  (catch 'nyacc-error
    (lambda ()
      (raw-ia-parser lexer #:debug #f))
    (lambda (key fmt . args)
      (apply simple-format (current-error-port) fmt args)
      #f)))

(define ml-stmt-reader
  (let ((lexer (gen-ia-matlab-lexer)))
    (lambda (port env)
      (cond
       ((eof-object? (peek-char port))
	(read-char port))
       (else
	(let* ((stmt (with-input-from-port port
		      (lambda () (parse-ml-stmt lexer))))
	       (stmt (update-matlab-tree stmt)))
	  (cond
	   ((equal? stmt '(empty-stmt)) #f)
	   (stmt)
	   ;;(else (flush-input-after-error port) #f)
	   )))))))


;; ... (assn (
;;

;; --- last line ---
