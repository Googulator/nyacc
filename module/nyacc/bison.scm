;;; nyacc/bison.scm - export bison

;; Copyright (C) 2016,2018,2020,2021 Matthew R. Wette
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
;; You should have received a copy of the licence with this software.
;; If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(define-module (nyacc bison)
  #:export (make-lalr-machine/bison)
  #:use-module (sxml simple)
  #:use-module (sxml match)
  #:use-module (sxml xpath)
  #:use-module (ice-9 pretty-print)
  #:use-module ((srfi srfi-1) #:select (fold))
  #:use-module (nyacc export)
  #:use-module (nyacc lalr)             ; gen-match-table
  #:use-module (nyacc util))

;; @deffn chew-on-grammar tree lhs-v rhs-v terms => a-list
;; Generate a-list that maps bison rule index to NYACC rule index.
(define (chew-on-grammar tree lhs-v rhs-v terms) ;; bison-rule => nyacc-rule map

  ;; match rule index, if no match return @code{-1}
  ;; could be improved by starting with last rule number and wrapping
  (define (match-rule lhs rhs)
    (let loop ((ix 0))
      (if (eqv? ix (vector-length lhs-v)) -1
          (if (and (equal? lhs (elt->bison (vector-ref lhs-v ix) terms))
                   (equal? rhs (vector->list
                                (vector-map
                                 (lambda (ix val) (elt->bison val terms))
                                 (vector-ref rhs-v ix)))))
              ix
              (loop (1+ ix))))))

  ;; this is a fold
  (define (rule->index-al tree seed)
    (sxml-match tree
      ;; Skip first bison rule: always $accept.
      ((rule (@ (number "0")) (lhs "$accept") . ,rest)
       (acons 0 0 seed))
      ;; This matches all others.
      ((rule (@ (number ,n)) (lhs ,lhs) (rhs (symbol ,rhs) ...))
       (acons (string->number n) (match-rule lhs rhs) seed))
      (,otherwise seed)))

  (fold rule->index-al '() ((sxpath '(// rule)) tree)))

;; @deffn chew-on-automaton tree gx-al bs->ns => a-list
;; This digests the automaton and generated the @code{pat-v} and @code{kis-v}
;; vectors for the NYACC automaton.
(define (chew-on-automaton tree gx-al bs->ns)

  (define st-numb
    (let ((xsnum (sxpath '(@ number *text*))))
      (lambda (state)
        (string->number (car (xsnum state))))))

  (define (do-state state)
    (let* ((b-items ((sxpath '(// item)) state))
           (n-items (fold
                     (lambda (tree seed)
                       (sxml-match tree
                         ((item (@ (rule-number ,rns) (point ,pts)) . ,rest)
                          (let ((rn (string->number rns))
                                (pt (string->number pts)))
                            (if (and (positive? rn) (zero? pt)) seed
                                (acons (assq-ref gx-al rn) pt seed))))
                         (,otherwise (error "broken item")))) '() b-items))
           (b-trans ((sxpath '(// transition)) state))
           (n-trans (map
                     (lambda (tree)
                       (sxml-match tree
                         ((transition (@ (symbol ,symb) (state ,dest)))
                          (cons* (bs->ns symb) 'shift (string->number dest)))
                         (,otherwise (error "broken tran")))) b-trans))
           (b-redxs ((sxpath '(// reduction)) state))
           (n-redxs (map
                     (lambda (tree)
                       (sxml-match tree
                         ((reduction (@ (symbol ,symb) (rule "accept")))
                          (cons* (bs->ns symb) 'accept 0))
                         ((reduction (@ (symbol ,symb) (rule ,rule)))
                          (cons* (bs->ns symb) 'reduce
                                 (assq-ref gx-al (string->number rule))))
                         (,otherwise (error "broken redx" tree)))) b-redxs)))
      (list
       (st-numb state)
       (cons 'kis n-items)
       (cons 'pat (append n-trans n-redxs)))))

  (let ((xsf (sxpath '(itemset item (@ (rule-number (equal? "0"))
                                       (point (equal? "2")))))))
    (let loop ((data '()) (xtra #f) (states (cdr tree)))
      (cond
       ((null? states) (cons xtra data))
       ((pair? (xsf (car states)))
        (loop data (st-numb (car states)) (cdr states)))
       (else
        (loop (cons (do-state (car states)) data) xtra (cdr states)))))))

;; @deffn atomize symbol => string
;; This is copied from the module @code{(nyacc lalr)}.
(define (atomize terminal)              ; from lalr.scm
  (if (string? terminal)
      (string->symbol (string-append "$:" terminal))
      terminal))

;; @deffn make-bison->nyacc-symbol-mapper terminals non-terminals => proc
;; This generates a procedure to map bison symbol names, generated by the
;; NYACC @code{lalr->bison} procedure, (back) to nyacc symbols names.
(define (make-bison->nyacc-symbol-mapper terms non-ts)
  (let ((bs->ns-al
         (cons*
          '("$default" . $default)
          '("$end" . $end)
          (map (lambda (symb) (cons (elt->bison symb terms) symb))
               (append (map atomize terms) non-ts)))))
    (lambda (name) (assoc-ref bs->ns-al name))))

;; fix-pa
;; fix parse action
(define (fix-pa pa xs)
  (cond
   ((and (eqv? 'shift (cadr pa))
         (> (cddr pa) xs))
    (cons* (car pa) (cadr pa) (1- (cddr pa))))
   ((and (eqv? 'shift (cadr pa))
         (= (cddr pa) xs))
    (cons* (car pa) 'accept 0))
   (else pa)))

;; @deffn fix-is is xs rhs-v
;; Convert xxx
(define (fix-is is xs rhs-v)
  (let* ((gx (car is))
         (rx (cdr is))
         (gl (vector-length (vector-ref rhs-v gx))))
    (if (= rx gl) (cons gx -1) is)))

;; @deffn spec->mac-sxml spec
;; Write bison-converted @var{spec} to file, run bison on it, and load
;; the bison-generated automaton as a SXML tree using the @code{-x} option.
(define (spec->mach-sxml spec)
  (let* ((bisname (mkstemp! (string-copy "/tmp/nyacc-XXXXXX.y")))
         (xmlname (mkstemp! (string-copy "/tmp/nyacc-XXXXXX.xml")))
         (tabname (mkstemp! (string-copy "/tmp/nyacc-XXXXXX.tab.c"))))
    (with-output-to-file bisname
      (lambda () (lalr->bison spec)))
    (system (string-append "bison" " --xml=" xmlname " --output=" tabname
                           " " bisname))
    (let ((sx (call-with-input-file xmlname
                (lambda (p) (xml->sxml p #:trim-whitespace? #t)))))
      (delete-file bisname)
      (delete-file xmlname)
      (delete-file tabname)
      sx)))

;; @deffn make-lalr-machine/bison spec => mach
;; Make a LALR automaton, consistent with that from @code{make-lalr-machine}
;; using external @code{bison} program.
(define (make-lalr-machine/bison spec)
  (let* ((terminals (assq-ref spec 'terminals))
         (non-terms (assq-ref spec 'non-terms))
         (lhs-v (assq-ref spec 'lhs-v))
         (rhs-v (assq-ref spec 'rhs-v))
         (s0 (spec->mach-sxml spec))
         (sG ((sxpath '(bison-xml-report grammar)) s0))
         (sG (if (pair? sG) (car sG) sG))
         (sA ((sxpath '(bison-xml-report automaton)) s0))
         (sA (if (pair? sA) (car sA) sA))
         (pG (chew-on-grammar sG lhs-v rhs-v terminals))
         (bsym->nsym (make-bison->nyacc-symbol-mapper terminals non-terms))
         (pA (chew-on-automaton sA pG bsym->nsym))
         (xs (car pA))
         (ns (caadr pA))
         (pat-v (make-vector ns #f))
         (kis-v (make-vector ns #f)))
    ;;(pretty-print sA)
    (for-each
     (lambda (state)
       (let* ((sx (car state))
              (sx (if (>= sx xs) (1- sx) sx))
              (pat (assq-ref (cdr state) 'pat))
              (pat (map (lambda (pa) (fix-pa pa xs)) pat))
              (kis (assq-ref (cdr state) 'kis))
              (kis (map (lambda (is) (fix-is is xs rhs-v)) kis)))
         (vector-set! pat-v sx pat)
         (vector-set! kis-v sx kis)))
     (cdr pA))
    (gen-match-table
     (cons*
      (cons 'pat-v pat-v)
      (cons 'kis-v kis-v)
      (cons 'len-v (vector-map (lambda (i v) (vector-length v)) rhs-v))
      (cons 'rto-v (vector-copy lhs-v))
      spec))))


;; --- last line ---
 
