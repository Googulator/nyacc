;;; lang/octave/body.scm
;;;
;;; Copyright (C) 2015,2018 Matthew R. Wette
;;;
;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public
;;; License as published by the Free Software Foundation; either
;;; version 3 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public License
;;; along with this library; if not, see <http://www.gnu.org/licenses/>

;; @deffn add-file-attr tl => tl
;; Given a tagged-list this routine adds an attribute @code{(file basename)}
;; which is the basename (with @code{.m} removed) of the current input.
;; This is used for the top-level node of the octave parse tree to indicate
;; from which file the script or function file originated.  For example,
;; @example
;; (function-file (@ (file "myftn")) (fctn-defn (ident "myftn") ...
;; @end example
(define (add-file-attr tl)
  (let ((fn (port-filename (current-input-port))))
    (if fn (tl+attr tl 'file (basename fn ".m")) tl)))

;;; === lexical analyzer

(define (octave-read-string ch)
  (if (not (eq? ch #\')) #f
      (let loop ((cl '()) (ch (read-char)))
	(cond ((eq? ch #\\)
	       (let ((c1 (read-char)))
		 (if (eq? c1 #\newline)
		     (loop cl (read-char))
		     (loop (cons c1 cl) (read-char)))))
	      ((eq? ch #\')
	       (let ((nextch (read-char)))
		 (if (eq? #\' nextch)
		     (loop (cons ch cl) (read-char))
		     (begin
		       (unread-char nextch)
		       (cons '$string (list->string (reverse cl)))))))
	      (else (loop (cons ch cl) (read-char)))))))

(define octave-read-comm
  (make-comm-reader '(("%" . "\n")
		      ("#!" . "!#") ("#lang" . "\n"))))

;; elipsis reader "..." whitespace "\n"
(define (elipsis? ch)
  (if (eqv? ch #\.)
      (let ((c1 (read-char)))
	(if (eqv? c1 #\.)
	    (let ((c2 (read-char)))
	      (if (eqv? c2 #\.)
		  (cons (string->symbol "...") "...")
		  (begin (unread-char c2) (unread-char c1) #f)))
	    (begin (unread-char c1) #f)))
      #f))

(define (skip-to-next-line)
  (let loop ((ch (read-char)))
    (cond
     ((eof-object? ch) ch)
     ((eqv? ch #\newline) (read-char))
     (else (loop (read-char))))))
  
(define-public (make-octave-lexer-generator match-table)
  (let* ((read-string octave-read-string)
	 (read-comm octave-read-comm)
	 (read-ident read-c$-ident)
	 (space-cs (string->char-set " \t\r\f"))
	 ;;
	 (strtab (filter-mt string? match-table)) ; strings in grammar
	 (kwstab (filter-mt like-c$-ident? strtab)) ; keyword strings =>
	 (keytab (map-mt string->symbol kwstab)) ; keywords in grammar
	 (chrseq (remove-mt like-c-ident? strtab)) ; character sequences
	 (symtab (filter-mt symbol? match-table)) ; symbols in grammar
	 (chrtab (filter-mt char? match-table))	; characters in grammar
	 (read-chseq (make-chseq-reader chrseq))
	 (newline-val (assoc-ref chrseq "\n"))
	 (assc-$ 
          (lambda (pair) (cons (assq-ref symtab (car pair)) (cdr pair)))))
    (if (not newline-val) (error "octave setup error"))
    (lambda ()
      (let ((qms #f) (bol #t))		; qms: quote means string
	(lambda ()
	  (let loop ((ch (read-char)))
	    (cond
	     ((eof-object? ch) (assc-$ (cons '$end ch)))
 	     ((elipsis? ch) (loop (skip-to-next-line)))
	     ((eqv? ch #\newline) (set! bol #t) (cons newline-val "\n"))
	     ((char-set-contains? space-cs ch) (set! qms #t) (loop (read-char)))
	     ((read-comm ch bol) => assc-$)
	     (bol (set! bol #f) (loop ch))
	     ((read-ident ch) =>	; returns string
	      (lambda (s)
		(set! qms #f)
		(or (and=> (assq-ref keytab (string->symbol s))
			   (lambda (tval) (cons tval s)))
		    (assc-$ (cons '$ident s)))))
	     ((read-c-num ch) => (lambda (p) (set! qms #f) (assc-$ p)))
	     ((eqv? ch #\') (if qms (assc-$ (read-string ch)) (read-chseq ch)))
	     ((read-chseq ch) =>
	      (lambda (p) (set! qms (and (memq ch '(#\= #\, #\()) #t)) p))
	     ((assq-ref chrtab ch) => (lambda (t) (cons t (string ch))))
	     (else (cons ch (string ch))))))))))

;;; --- last line ---