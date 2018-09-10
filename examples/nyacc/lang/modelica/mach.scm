;;; nyacc/lang/modelica/mach.scm

;; Copyright (C) 2015-2018 Matthew R. Wette
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

;;; Notes:

;; The desire to generate a Modelica parser in Scheme is what 
;; started my effort to generate NYACC.  - Matt

;;; Code:

(define-module (nyacc lang modelica mach)
  #:export (modelica-spec
	    modelica-mach
	    modelica-parser
	    gen-mod-lexer
	    parse-mo)
  #:use-module (nyacc lalr)
  #:use-module (nyacc lex)
  #:use-module (nyacc parse)
  #:use-module (nyacc lang util)
  #:use-module (ice-9 pretty-print)
  )

(define (check-ids st nd)
  (if (not (string=? (cadr st) (cadr nd)))
      (throw 'mo-error "end name does not match")))

;; based on version 3.4, I believe
(define modelica-spec
  (lalr-spec
   (notice (string-append "Copyright 2016-2017 Matthew R. Wette" lang-crn-lic))
   (start stored-definition)
   (grammar
    
    ;; B.2.1
    (stored-definition
     ($empty ($$ `(stored-defn)))
     (stored-definition-1 stored-definition-2 ($$ `(stored-defn ,$1 ,$2)))
     (stored-definition-2 ($$ (tl->list $1)))
     )
    (stored-definition-1
     ("within" name ";" ($$ `(within ,$2)))
     ("within" ";" ($$ '(within)))
     )
    (stored-definition-2
     ("final" class-definition ";"
      ($$ (make-tl 'class-defn-list (sx+attr* $2 'final "yes"))))
     (class-definition ";" ($$ (make-tl 'class-defn-list $1)))
     (stored-definition-2 "final" class-definition ";"
			  ($$ (tl-append $3 (sx+attr* $3 'final "yes"))))
     (stored-definition-2 class-definition ";" ($$ (tl-append $1 $2)))
     )

    ;; B.2.2 Class Definition
    (class-definition
     ("encapsulated" class-prefixes class-specifier
      ($$ (append (tl->list (tl+attr $2 'encapsulated "yes")) $3)))
     (class-prefixes class-specifier ($$ (append (tl->list $1) $2)))
     )
    (class-prefixes
     ("partial" class-prefixes-1 ($$ (tl+attr (make-tl $2) 'partial "yes")))
     (class-prefixes-1 ($$ (make-tl $1)))
     )
    (class-prefixes-1
     ("class" ($$ 'class))
     ("model" ($$ 'model))
     ("operator" "record" ($$ 'operator-record))
     ("record" ($$ 'record))
     ("block" ($$ 'block))
     ("expandable" "connector" ($$ 'expandable-connector))
     ("connector" ($$ 'connector))
     ("type" ($$ 'type))
     ("package" ($$ 'package))
     ("impure" "operator" "function" ($$ 'impure-operator-function))
     ("pure" "operator" "function" ($$ 'pure-operator-function))
     ("impure" "function" ($$ 'impure-function))
     ("pure" "function" ($$ 'pure-function))
     ("operator" "function" ($$ 'operator-function))
     ("function" ($$ 'function))
     ("operator" ($$ 'operator))
     )

    (class-specifier
     (long-class-specifier)
     (short-class-specifier)
     (der-class-specifier)
     )

    (long-class-specifier
     (ident string-comment composition "end" ident
	    ($$ (check-ids $1 $5) (if (pair? $2) (list $1 $2 $3) (list $1 $3))))
     ("extends" ident class-modification string-comment composition "end" ident
      ($$ (check-ids $2 $7) (list '(@ extends . "yes") $2 $3 $4 $5)))
     ("extends" ident string-comment composition "end" ident
      ($$ (check-ids $2 $6) (list '(@ extends . "yes") $2 $3 $4)))
     )

    (short-class-specifier
     (ident "=" base-prefix type-specifier array-subscripts
	    class-modification comment
	    ($$ (list $1 `(is ,$3 ,$4 ,$5 ,$6 ,$7))))
     (ident "=" base-prefix type-specifier array-subscripts comment)
     
     (ident "=" base-prefix type-specifier class-modification comment)
     (ident "=" base-prefix type-specifier comment)
     (ident "=" "enumeration" "(" enum-list ")" comment)
     (ident "=" "enumeration" "(" ":" ")" comment)
     )

    (der-class-specifier
     (ident "=" "der" "(" type-specifier "," der-class-specifier-1 ")" comment
	    ($$ `(der-class-specifier ... (tl->list $7))))
     )
    (der-class-specifier-1 ;; or ident-colon-list
     (ident ($$ (make-tl 'ident-list $1)))
     (der-class-specifier-1 ";" ident ($$ (tl-append $1 $3)))
     )

    (base-prefix ("input") ("output"))

    (enum-list
     (enumeration-literal ($$ (make-tl 'enum-list $1)))
     (enum-list "," enumeration-literal ($$ (tl-append $1 $3))))

    (enumeration-literal
     (ident comment)
     )

    ;; ===================== update to v3.4 stopped here ======================

    (composition
     (element-list composition-1-list external-part opt-annotation
		   ($$ (if (pair? $4)
			   `(composition ,$1 ,$2 ,$3 ,$4)
			   `(composition ,$1 ,$2 ,$3))))
     (element-list composition-1-list opt-annotation
		   ($$ (if (pair? $3)
			   `(composition ,$1 ,$2 ,$3)
			   `(composition ,$1 ,$2))))
     (element-list external-part opt-annotation
		   ($$ (if (pair? $3)
			   `(composition ,$1 ,$2 ,$3)
			   `(composition ,$1 ,$2))))
     (element-list opt-annotation
		   ($$ (if (pair? $2)
			   `(composition ,$1 ,$2)
			   `(composition ,$1))))
     )
    (composition-1-list
     (composition-1-list-1 ($$ (tl->list $1))))
    (composition-1-list-1
     (composition-1 ($$ (make-tl 'composition-list $1)))
     (composition-1-list composition-1 ($$ (tl-append $1 $2)))
     )
    (composition-1
     ("public")
     ("public" element-list)
     ("protected")
     ("protected" element-list)
     (equation-section)
     (algorithm-section)
     )
    (external-part
     ("external" language-specification external-function-call annotation ";")
     ("external" language-specification external-function-call ";")
     ("external" language-specification annotation ";")
     ("external" external-function-call annotation ";")
     ("external" language-specification ";")
     ("external" external-function-call ";")
     ("external" annotation ";")
     ("external" ";")
     )
    (language-specification (string))

    (external-function-call
     (component-reference "=" ident "(" expression-list ")")
     (component-reference "=" ident "(" ")")
     (ident "(" expression-list ")")
     (ident "(" ")")
     )

    (element-list
     (element-list-1 ($$ (tl->list $1))))
    (element-list-1
     (element ";" ($$ (make-tl 'element-list $1)))
     (element-list-1 element ";" ($$ (tl-append $1 $2))))

    (element
     (import-clause)
     (extends-clause)
     ("redeclare" ($? "final") ($? "inner") ($? "outer") element-1)
     ("final" ($? "inner") ($? "outer") element-1)
     ("inner" ($? "outer") element-1)
     ("outer" element-1)
     (element-1)
      )
    (element-1
     (class-definition)
     (component-clause)
     ("replaceable" element-2 constraining-clause comment)
     ("replaceable" element-2)
     )
    (element-2
     (class-definition)
     (component-clause)
     )

    (import-clause
     ("import" import-clause-1 comment)
     )
    (import-clause-1
     (ident "=" name)
     (name "." import-clause-2)
     (name)
     )
    (import-clause-2
     ("*")
     ("{" "}")
     ("{" import-list "}")
     )
    (import-list
     (ident)
     (import-list "," ident))

    ;; B.2.3 Extends
    (extends-clause
     ("extends" name class-modification annotation)
     ("extends" name class-modification)
     ("extends" name annotation)
     ("extends" name)
     )

    (constraining-clause
     ("constrainedby" name class-modification)
     ("constrainedby" name)
     )

    ;; B.2.4 Component Clause
    (component-clause
     (type-prefix type-specifier array-subscripts component-list
		  ($$ `(component-clause ,$1 ,$2 ,$3 ,$4)))
     (type-prefix type-specifier component-list
		  ($$ `(component-clause ,$1 ,$2 ,$3)))
     (type-specifier array-subscripts component-list
		     ($$ `(component-clause ,$1 ,$2 ,$3)))
     (type-specifier component-list
		     ($$ `(component-clause ,$1 ,$2)))
     )

    (type-prefix
     (type-prefix-1 type-prefix-2 type-prefix-3
		    ($$ `(type-prefix ,$1 ,$2 ,$3)))
     (type-prefix-1 type-prefix-2
		    ($$ `(type-prefix ,$1 ,$2)))
     (type-prefix-1 type-prefix-3
		    ($$ `(type-prefix ,$1 ,$2)))
     (type-prefix-2 type-prefix-3
		    ($$ `(type-prefix ,$1 ,$2)))
     (type-prefix-1 ($$ `(type-prefix ,$1)))
     (type-prefix-2 ($$ `(type-prefix ,$1)))
     (type-prefix-3 ($$ `(type-prefix ,$1)))
     ;;() ;; causes conflicts so fix component-clause and base-prefix p-rules
     )
    (type-prefix-1 ("flow") ("stream"))
    (type-prefix-2 ("discrete") ("parameter") ("constant"))
    (type-prefix-3 ("input") ("output"))

    (type-specifier (name))

    (component-list
     (component-declaration)
     (component-list "," component-declaration)
     )

    (component-declaration
     (declaration condition-attribute comment)
     (declaration comment)
     )

    (condition-attribute
     ("if" expression)
     )

    (declaration
     (ident ($? array-subscripts) ($? modification))
     )

    ;; B.2.5 Modification
    (modification
     (class-modification "=" expression)
     (class-modification)
     ("=" expression)
     (":=" expression)
     )

    (class-modification
     ("(" argument-list ")")
     ("(" ")")
     )

    (argument-list
     (argument)
     (argument-list "," argument)
     )

    (argument (element-modification-or-replaceable) (element-redeclaration))

    (element-modification-or-replaceable
     ("each" "final" elt-mod-or-repl-1)
     ("each" elt-mod-or-repl-1)
     ("final" elt-mod-or-repl-1)
     (elt-mod-or-repl-1)
     )
    (elt-mod-or-repl-1 (element-modification) (element-replaceable))

    (element-modification (name ($? modification) string-comment))

    ;; This looks wierd in the 3.3r1 spec. Like maybe typo.
    (element-redeclaration
     ("redeclare" ($? "each") ($? "final") elt-redecl-1)
     )
    (elt-redecl-1
     (short-class-definition)
     (component-clause1)
     (element-replaceable)
     )

    (element-replaceable
     ("replaceable"
      short-class-definition component-clause1 constraining-clause)
     ("replaceable"
      short-class-definition component-clause1)
     )

    (component-clause1
     (type-prefix type-specifier declaration comment
		  ($$ (list $1 $2 (append $3 (list $4))))))

    (short-class-definition
     (class-prefixes
      short-class-specifier
      ($$ `(short-class-def ,(append $1 (list $2))))))

    ;; B.2.6 Equations
    (equation-section
     ("initial" "equation" equation-list
      ($$ `(init-eqn-section ,$3)))
     ("equation" equation-list
      ($$ `(eqn-section ,$2)))
     ("initial" "equation"
      ($$ `(init-eqn-section (eqn-list))))
     ("equation"
      ($$ `(eqn-section (eqn-list))))
     )

    ;; I think they messed this up tool
    (algorithm-section
     ("initial" "algorithm" statement-list
      ($$ `(init-alg-section ,$3)))
     ("algorithm" statement-list
      ($$ `(alg-section ,$2)))
     ("initial" "algorithm"
      ($$ `(init-alg-section (stmt-list))))
     ("algorithm"
      ($$ `(alg-section (stmt-list))))
     )

    ;; my addition:
    (equation-list
     (equation-list-1 ($$ (tl->list $1))))
    (equation-list-1
     (equation ";" ($$ (make-tl 'eqn-list $1)))
     (equation-list-1 equation ";" ($$ (tl-append $1 $2)))
     )

    (equation (equation-1 comment ($$ (append $1 (list $2)))))
    (equation-1
     (simple-expression "=" expression ($$ `(equate ,$1 ,$3)))
     (if-equation)
     (for-equation)
     (connect-clause)
     (when-equation)
     (name function-call-args ($$ `(fctn ,$1 ,$2))))

    ;; my addition:
    (statement-list
     (statement ";" ($$ (make-tl 'stmt-list $1)))
     (statement-list statement ";" ($$ (tl-append $1 $2))))

    (statement (statement-1 comment ($$ (append $1 (list $2)))))
    (statement-1
     (component-reference ":=" expression ($$ `(assign ,$1 ,$3)))
     (component-reference function-call-args ($$ `(call ,$1 ,$2)))
     ("(" output-expression-list ")" ":="
      component-reference function-call-args
      ($$ `(multi-assign ,$2 ,$5 ,$6)))
     ("break" ($$ '(break-stmt)))
     ("return" ($$ '(return-stmt)))
     (if-statement)
     (for-statement)
     (while-statement)
     (when-statement)
     )

    (if-equation
     ("if" expression then-eq-part elseif-eq-list else-eq-part "end" "if"
      ($$ `(if-eq ,$2 ,$3 ,@(cdr (tl->list $4)) ,$5)))
     ("if" expression then-eq-part elseif-eq-list "end" "if"
      ($$ `(if-eq ,$2 ,$3 ,@(cdr (tl->list $4)))))
     ("if" expression then-eq-part else-eq-part "end" "if"
      ($$ `(if-eq ,$2 ,$3 ,$4)))
     ("if" expression then-eq-part "end" "if"
      ($$ `(if-eq ,$2 ,$3)))
     )
    (then-eq-part
     ("then" equation-list ($$ $2))
     ("then" ($$ '(eqn-list))))
    (elseif-eq-list
     (elseif-eq-part ($$ (make-tl 'l $1)))
     (elseif-eq-list elseif-eq-part ($$ (tl-append $1 $2))))
    (elseif-eq-part
     ("elseif" equation-list ($$ `(elseif-eq ,$2)))
     ("elseif" ($$ `(else-eq (eqn-list)))))
    (else-eq-part
     ("else" equation-list ($$ `(else-eq ,$2)))
     ("else" ($$ `(else-st (eqn-list)))))

    (if-statement
     ("if" expression then-st-part elseif-st-list else-st-part "end" "if"
      ($$ `(if-st ,$2 ,$3 ,@(cdr (tl->list $4)) ,$5)))
     ("if" expression then-st-part elseif-st-list "end" "if"
      ($$ `(if-st ,$2 ,$3 ,@(cdr (tl->list $4)))))
     ("if" expression then-st-part else-st-part "end" "if"
      ($$ `(if-st ,$2 ,$3 ,$4)))
     ("if" expression then-st-part "end" "if"
      ($$ `(if-st ,$2 ,$3)))
     )
    (then-st-part
     ("then" statement-list ($$ $2))
     ("then" ($$ '(stmt-list))))
    (elseif-st-list
     (elseif-st-part ($$ (make-tl 'l $1)))
     (elseif-st-list elseif-st-part ($$ (tl-append $1 $2))))
    (elseif-st-part
     ("elseif" statement-list ($$ `(elseif-st ,$2)))
     ("elseif" ($$ `(else-st (stmt-list)))))
    (else-st-part
     ("else" statement-list ($$ `(else-st ,$2)))
     ("else" ($$ `(else-st (stmt-list)))))

    (for-equation
     ("for" for-indices "loop" equation-list "end" "for"
      ($$ `(for-eq ,$2 ,$4)))
     ("for" for-indices "loop" "end" "for"
      ($$ `(for-eq ,$2 (eqn-list))))
     )

    (for-statement
     ("for" for-indices "loop" statement-list "end" "for"
      ($$ `(for-st ,$2 ,$4)))
     ("for" for-indices "loop" "end" "for"
      ($$ `(for-st ,$2 (stmt-list))))
     )

    (for-indices
     (for-index ($$ (make-tl 'for-indices $1)))
     (for-indices "," for-index ($$ (tl-append $1 $3)))
     )

    (for-index
     (ident "in" expression ($$ `(for-index ,$1 ,$3)))
     (ident ($$ `(for-index ,$1)))
     )

    (while-statement
     ("while" expression "loop" statement-list "end" "while"
      ($$ `(while-st ,$2 ,(tl->list $4))))
     ("while" expression "loop" "end" "while"
      ($$ `(while-st ,$2 (stmt-list))))
     )

    (when-equation
     ("when" expression then-eq-part elsewhen-eq-list "end" "when"
      ($$ `(when-eq ,$2 ,$3 ,@(cdr (tl->list $4))))))
    (elsewhen-eq-list
     (elsewhen-eq-part ($$ (make-tl 'l $1)))
     (elsewhen-eq-list elsewhen-eq-part ($$ (tl->append $1 $2))))
    (elsewhen-eq-part
     ("elsewhen" expression "then" ($$ `(elsewhen ,$2 (expr-list))))
     ("elsewhen" expression "then" expression-list ($$ `(elsewhen ,$2 ,$4))))
    
    (when-statement
     ("when" expression then-st-part elsewhen-st-list "end" "when"
      ($$ `(when-st ,$2 ,$3 ,@(cdr (tl->list $4))))))
    (elsewhen-st-list
     (elsewhen-st-part ($$ (make-tl 'l $1)))
     (elsewhen-st-list elsewhen-st-part ($$ (tl->append $1 $2))))
    (elsewhen-st-part
     ("elsewhen" expression "then" ($$ `(elsewhen ,$2 (stmt-list))))
     ("elsewhen" expression "then" statement-list ($$ `(elsewhen ,$2 ,$4))))

    (connect-clause
     ("connect" "(" component-reference "," component-reference ")"
      ($$ `(connect ,$3 ,$5))))

    ;; B.2.7 Expressions
    (expression
     (simple-expression)
     ("if" expression "then" expression elseif-ex-list "else" expression
      ($$ `(if ,$2 ,$4 ,@(cdr (tl->list $5)) (else ,$7))))
     ("if" expression "then" expression "else" expression
      ($$ `(if ,$2 ,$4 (else ,$6))))
     )
    (elseif-ex-list
     ("elseif" expression "then" expression
      ($$ (make-tl 'l `(elseif ,$2 ,$4))))
     (elseif-ex-list "elseif" expression "then" expression
		     ($$ (tl-append $1 `(elseif ,$2 ,$4)))))

    (simple-expression
     (logical-expression)
     (logical-expression ":" logical-expression ":" logical-expression
			 ($$ `(colon ,$1 ,$5 ,$3)))
     (logical-expression ":" logical-expression
			 ($$ `(colon ,$1 ,$3)))
     )

    ;; the following rules modified from spec
    (logical-expression
     (logical-term)
     (logical-expression "or" logical-term ($$ `(or ,$1 ,$3)))
     )

    (logical-term
     (logical-factor)
     (logical-term "and" logical-factor ($$ `(and ,$1 ,$3)))
     )

    (logical-factor
     (relation)
     ("not" relation ($$ `(not ,$2)))
     )

    (relation
     (arithmetic-expression)
     (relation rel-op arithmetic-expression ($$ (list $2 $1 $3)))
     )
    (rel-op ("<" ($$ 'lt)) ("<=" ($$ 'le))
	    (">" ($$ 'gt)) (">=" ($$ 'ge))
	    ("==" ($$ 'eq)) ("<>" ($$ 'ne)))
    
    (arithmetic-expression
     (term)
     (arithmetic-expression add-op term ($$ (list $2 $1 $3)))
     )
    (add-op ("+" ($$ 'add)) ("-" ($$ 'sub))
	    (".+" ($$ 'dot-add)) (".-" ($$ 'dot-sub)))

    (term
     (factor)
     (term mul-op factor)
     )
    (mul-op ("*" ($$ 'mul)) ("/" ($$ 'div))
	    (".*" ($$ 'dot-mul)) ("./" ($$ 'dot-div)))

    (factor
     (primary)
     (factor "^" primary ($$ `(pow ,$1 ,$2)))
     (factor ".^" primary ($$ `(dot-pow ,$1 ,$2)))
     )

    (primary
     (unsigned-number ($$ `(p-expr ,$1)))
     (string ($$ `(p-expr ,$1)))
     ("false" ($$ `(p-expr '(false))))
     ("true" ($$ `(p-expr '(true))))
     (name function-call-args ($$ `(fctn-call ,$1 ,(tl->list $2))))
     ("der" function-call-args ($$ `(der ,$2)))
     ;;("initial" function-call-args)  ; 4 srconf, OK to shift?
     
     ;; from component reference:
     (name)
     (name array-subscripts ($$ `(array-elt ,$1 ,$2)))
     
     ("(" output-expression-list ")")
     ("[" expression-list-list  "]"
      ($$ `(matrix ,(map (lambda (row) (cons 'row (cdr row)))
			 (cdr (tl->list $2))))))
     ("{" function-arguments "}")
     ;;("end")			     ; 2 srconf, and WTF is this for?
     )
    (expression-list-list
     (expression-list ($$ (make-tl 'rows $1)))
     (expression-list-list ";" expression-list ($$ (tl-append $1 $3)))
     )

    (name
     (ident ($$ $1))
     ("." ident ($$ `(sel ,$2)))
     (name "." ident ($$ `(sel ,$3 ,$1)))
     )

    ;; changed to deal with rr-conf
    ;; (comp-ref (array-ref 3 (sel xxx 
    (component-reference
     (component-reference-1 ($$ `(comp-ref ,$1))))
    (component-reference-1
     (component-reference-2)
     ("." component-reference-2 ($$ `(sel ,$2)))
     (component-reference-1 "." component-reference-2 ($$ `(sel ,$3 ,$1))))
    (component-reference-2
     (ident ($$ $1))
     (ident array-subscripts ($$ `(ary-ref ,$2 ,$1)))
     )

    (function-call-args
     ("(" function-arguments ")" ($$ $2))
     ("(" ")" ($$ '(ftn-args)))
     )

    ;; production in Appendix B is hosed up wrt what is in S 12.4.2
    (function-arguments
     (function-arguments-1 ($$ (tl->list $1)))
     (named-only-arguments-1 ($$ (tl->list $1))))
    (function-arguments-1
     (function-argument ($$ (make-tl 'ftn-args $1)))
     (function-arguments-1 "," function-argument ($$ (tl-append $1 $2))))
    (named-arguments
     (named-only-arguments-1 ($$ (tl->list $1))))
    (named-only-arguments-1
     (named-argument ($$ (make-tl 'ftn-args $1)))
     (named-only-arguments-1 "," named-argument ($$ (tl-append $1 $3)))
     (function-arguments-1 "," named-argument ($$ (tl-append $1 $3)))
     )
    ;;(function-argument-1 ("," function-arguments) ("for" for-indices))
    ;;(named-arguments (named-argument) (named-arguments "," named-argument))

    (named-argument (ident "=" function-argument))

    (function-argument
     ("function" name "(" named-arguments ")")
     ("function" name "(" ")")
     (expression)
     )

    (output-expression-list
     (",")
     (expression)
     (output-expression-list "," expression)
     )

    (expression-list
     (expression)
     (expression-list "," expression)
     )

    (array-subscripts
     ("[" array-subscript-list "]" ($$ (tl->list $2))))
    (array-subscript-list
     (subscript ($$ (make-tl 'array-subscripts $1)))
     (array-subscript-list "," subscript ($$ (tl-append $1 $3)))
     )

    (subscript
     (":")
     (expression)
     )

    (comment
     (string-comment annotation
		     ($$ (if (pair? $1) `(comment ,$1 ,$2) `(comment ,$2))))
     (string-comment ($$ (if (pair? $1) `(comment ,$1) '(comment))))
     )

    (string-comment
     ($empty)
     (string-cat))
    (string-cat
     (string ($$ (make-tl 'string-comment $1)))
     (string-cat "+" string ($$ (tl-append $1 $3))))
    
    (opt-annotation () (annotation ";"))
    (annotation
     ("annotation" class-modification)
     )

    ;; end of grammar
    (unsigned-number
     ($fixed ($$ `(unsigned-number ,$1)))
     ($float ($$ `(unsigned-number ,$1))))
    (ident ($ident ($$ `(ident ,$1))))
    (string ($string ($$ `(string ,$1))))
    )))

(define modelica-mach
  (identity ;; hashify-machine
   (identity ;; compact-machine
    (make-lalr-machine modelica-spec))))

;; does not support Q-ident (single quoted identifier)
(define gen-mod-lexer
  (make-lexer-generator (lalr-match-table modelica-mach)
			#:comm-skipper read-c-comm
			))

(define modelica-parser (make-lalr-parser modelica-mach))

(define (parse-mo) (modelica-parser (gen-mod-lexer)))

;; === automaton file generator =========

(define (gen-modelica-files . rest)
  (define (lang-dir path)
    (if (pair? rest) (string-append (car rest) "/" path) path))
  (define (xtra-dir path)
    (lang-dir (string-append "mach.d/" path)))

  (write-lalr-actions modelica-mach (xtra-dir "moact.scm.new"))
  (write-lalr-tables modelica-mach (xtra-dir "motab.scm.new"))
  (let ((a (move-if-changed (xtra-dir "moact.scm.new")
			    (xtra-dir "moact.scm")))
	(b (move-if-changed (xtra-dir "motab.scm.new")
			    (xtra-dir "motab.scm"))))
    (when #f ;;(or a b) 
      (system (string-append "touch " (lang-dir "parser.scm"))))
    (or a b)))

;; --- last line ---
