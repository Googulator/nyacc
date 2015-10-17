;;; lang/c/pgen.scm
;;;
;;; Copyright (C) 2015 Matthew R. Wette
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

;; C parser generator: based on ISO-C99; with comments and CPP statements

(define-module (nyacc lang c99 pgen)
  #:export (clang-spec clang-mach dev-parse-c)
  #:use-module (nyacc lang c99 cpp)
  #:use-module (nyacc lalr)
  #:use-module (nyacc parse)
  #:use-module (nyacc lex)
  #:use-module (nyacc lang util)
  #:use-module ((srfi srfi-9) #:select (define-record-type))
  #:use-module ((srfi srfi-43) #:select (vector-map))
  #:use-module ((sxml xpath)
		#:renamer (lambda (s) (if (eq? s 'filter) 'xp-filter s)))
  )

;; Objective is to generate a sxml tree.
;; Strategy for building the tree:
;; @itemize
;; @item add decoration for RHS items, not LHS items
;; @example
;; Written to the grammar specified for ISO-C99 in the following URL:
;; http://slps.github.io/zoo/c/iso-9899-tc3.html
;; but modified to handle comments and CPP statements.
(define clang-spec
  (lalr-spec
   (notice lang-crn-lic)
   (prec< "then" "else")	    ; then/else SR-shift resolution
   (prec< "imp"			    ; implied type SR-shift resolution
	  "char" "short" "int" "long"
	  "float" "double" "_Complex")
   ;;(expect 25)			; 25 SR-conf fixed with above prec
   (start translation-unit-proxy)
   (grammar
 
    (translation-unit-proxy (translation-unit ($$/ref 's0-1 (tl->list $1))))

    ;; 4.1, p 74
    (declaration
     (declaration-specifiers
      initialized-declarator-list
      ($$/ref 's4.1-01 (save-typenames `(decl ,(tl->list $1) ,(tl->list $2))))
      ";" opt-code-comment
      ($$/ref 's4.1-02 (if (pair? $5) (append $3 (list $5)) $3)))
     ;; The grammar productions listed in the book do not seem to allow 
     ;; forward declarations, so we add these: -- M.Wette 04Oct15
     (structure-type-reference ";")
     (union-type-reference ";") 
     )

    ;; At most one storage class specifier and one type specifier may appear.
    (declaration-specifiers
     ;; storage-class-specifier declaration-specifiers_opt
     (storage-class-specifier
      ($$/ref 's4.1-03 (make-tl 'decl-spec-list $1)))
     (storage-class-specifier declaration-specifiers
			      ($$/ref 's4.1-04 (tl-insert $2 $1)))
     ;; type-specifier declaration-specifiers_opt
     (type-specifier
      ($$/ref 's4.1-04 (make-tl 'decl-spec-list $1)))
     (type-specifier declaration-specifiers
		     ($$/ref 's4.1-05 (tl-insert $2 $1)))
     ;; type-qualifier declaration-specifiers_opt
     (type-qualifier
      ($$/ref 's4.1-06 (make-tl 'decl-spec-list $1)))
     (type-qualifier declaration-specifiers
		     ($$/ref 's4.1-07 (tl-insert $2 $1)))
     ;; function-specifier declaration-specifiers_opt
     (function-specifier
      ($$/ref 's4.1-08 (make-tl 'decl-spec-list `(fctn-spec ,$1))))
     (function-specifier declaration-specifiers
			 ($$/ref 's4.1-09 (tl-insert $2 `(fctn-spec ,$1))))
     )
    
    (initialized-declarator-list
     (initialized-declarator ($$/ref 's4.1-09 (make-tl 'init-declr-list $1)))
     (initialized-declarator-list "," initialized-declarator
				  ($$/ref 's4.1-10 (tl-append $1 $3)))
     )

    (initialized-declarator
     (declarator ($$/ref 's4.1-11 `(init-declr ,$1)))
     (declarator "=" initializer ($$/ref 's4.1-12 `(init-declr ,$1 ,$3)))
     )

    ;; 4.3, p 83
    (storage-class-specifier
     ("auto" ($$/ref 's4.3-01 '(stor-spec (auto))))
     ("extern" ($$/ref 's4.3-02 '(stor-spec (extern))))
     ("register" ($$/ref 's4.3-03 '(stor-spec (register))))
     ("static" ($$/ref 's4.3-04 '(stor-spec (static))))
     ("typedef" ($$/ref 's4.3-05 '(stor-spec (typedef))))
     )

    ;; 4.3.3, p 86
    (function-specifier ("inline" ($$-ref 's4.3.3-01)))

    ;; 4.4, p 86
    (type-specifier
     (enumeration-type-specifier ($$/ref 's4.4-01 `(type-spec ,$1)))
     (floating-point-type-specifier ($$/ref 's4.4-02 `(type-spec ,$1)))
     (integer-type-specifier ($$/ref 's4.4-03 `(type-spec ,$1)))
     (structure-type-specifier ($$/ref 's4.4-04 `(type-spec ,$1)))
     (typedef-name ($$/ref 's4.4-05 `(type-spec ,$1)))
     (union-type-specifier ($$/ref 's4.4-06 `(type-spec ,$1)))
     (void-type-specifier ($$/ref 's4.4-07 `(type-spec ,$1)))
     )

    (type-qualifier
     ("const" ($$/ref 's4.4-08 '(type-qual (const))))
     ("volatile" ($$/ref 's4.4-09 '(type-qual (volatile))))
     ("restrict" ($$/ref 's4.4-10 '(type-qual (restrict))))
     )

    ;; 4.5, p 95
    (declarator
     (pointer-declarator ($$/ref 's4.5-01 $1))
     (direct-declarator ($$/ref 's4.5-02 $1))
     )

    (direct-declarator
     (simple-declarator ($$/ref 's4.5-03 $1))
     ("(" declarator ")" ($$/ref 's4.5-04 `(scope ,$2)))
     (function-declarator ($$/ref 's4.5-05 $1))
     (array-declarator ($$/ref 's4.5-06 $1))
     )

    ;; 4.5.1, p 96
    (simple-declarator
     (identifier ($$/ref 's4.5.1-01 $1))
     )

    ;; 4.5.2, p 96
    (pointer-declarator
     (pointer direct-declarator ($$/ref 's4.5.2-01 `(ptr-declr ,$1 ,$2)))
     )

    (pointer
     ("*" type-qualifier-list ($$/ref 's4.5.2-02 `(pointer ,$2)))
     ("*" ($$/ref 's4.5.2-03 '(pointer)))
     ("*" type-qualifier-list pointer
      ($$/ref 's4.5.2-04 `(pointer ,(tl->list $2) ,$3)))
     ("*" pointer ($$/ref 's4.5.2-05 `(pointer ,$2)))
     )

    (type-qualifier-list ; (C89)
     (type-qualifier ($$/ref 's4.5.2-06 (make-tl 'type-qual-list $1)))
     (type-qualifier-list type-qualifier ($$/ref 's4.5.2-07 (tl-append $1 $2)))
     )

    ;; 4.5.3, p 97
    ;; The expansion here is very WAGgy.
    (array-declarator
     ;; direct-declarator "[" constant-expression_opt "]" <= pre-C99
     (direct-declarator
      "[" array-qualifier-list array-size-expression "]"
      ($$/ref 's4.5.3-01 `(array-of ,$1 ,$2 ,$3)))
     (direct-declarator
      "[" array-qualifier-list "]"
      ($$/ref 's4.5.3-02 `(array-of ,$1 ,$3)))
     (direct-declarator
      "[" array-size-expression "]"
      ($$/ref 's4.5.3-03 `(array-of ,$1 ,$3)))
     (direct-declarator
      "[" "]"
      ($$/ref 's4.5.3-04 `(array-of ,$1)))
     (direct-declarator
      "[" array-qualifier-list "*" "]"
      ($$/ref 's4.5.3-05 `(array-of ,$1 ,$3 "*???")))
     (direct-declarator
      "[" "*" "]"
      ($$/ref 's4.5.3-06 `(array-of ,$1 "*???")))
     )

    (array-qualifier-list
     (array-qualifier
      ($$/ref 's4.5.3-07 (make-tl 'array-qual-list $1)))
     (array-qualifier-list array-qualifier
			   ($$/ref 's4.5.3-08 (tl-append $1 $2)))
     )

    (array-qualifier
     ("static" ($$/ref 's4.5.3-09 '(static)))
     ("restrict" ($$/ref 's4.5.3-10 '(restrict)))
     ("const" ($$/ref 's4.5.3-11 '(const)))
     ("volatile" ($$/ref 's4.5.3-12 '(volatile)))
     )

    (array-size-expression
     ;; I don't know how to handle 'constant-expression here.  It generates
     ;; a conflict with (to be documented).
     ;;(constant-expression) =>
     (assignment-expression ($$/ref 's2.5.3-13 $1))
     ;; I don't know how to deal with "*" here.  It seems to be handled
     ;; by 'array-declarator.
     ;;("*")
     )

    ;; 4.5.4, p 100
    (function-declarator
     (direct-declarator
      "(" parameter-type-list ")"
      ($$/ref 's4.5.4-01 `(ftn-declr ,$1 ,(tl->list $3))))
     (direct-declarator
      "(" identifier-list ")"
      ($$/ref 's4.5.4-02 `(ftn-declr ,$1 ,(tl->list $3))))
     (direct-declarator
      "(" ")"
      ($$/ref 's4.5.4-03 `(ftn-declr ,$1)))
     )

    (parameter-type-list
     (parameter-list ($$/ref 's4.5.4-04 $1))
     (parameter-list "," "..." ($$/ref 's4.5.4-05 $1))
     )

    (parameter-list
     (parameter-declaration ($$/ref 's4.5.4-06 (make-tl 'param-list $1)))
     (parameter-list "," parameter-declaration
		     ($$/ref 's4.5.4-07 (tl-append $1 $3)))
     )

    (parameter-declaration
     (declaration-specifiers
      declarator
      ($$/ref 's4.5.4-08 `(param-decln ,(tl->list $1) ,$2)))
     (declaration-specifiers
      abstract-declarator
      ($$/ref 's4.5.4-09 `(param-decln ,(tl->list $1) ,$2)))
     (declaration-specifiers
      ($$/ref 's4.5.4-10 `(param-decln ,(tl->list $1))))
     )

    (identifier-list
     (identifier ($$/ref 's4.5.4-11 (make-tl 'ident-list $1)))
     (identifier-list "," identifier ($$/ref 's4.5.4-12 (tl-append $1 $3)))
     )

    ;; 4.6, p 103
    (initializer
     (assignment-expression ($$/ref 's4.6-01 `(initzer ,$1)))
     ("{" initializer-list "," "}" ($$/ref 's4.6-02 `(initzer ,(tl->list $2))))
     ("{" initializer-list "}" ($$/ref 's4.6-03 `(initzer ,(tl->list $2))))
     )

    ;; The designation productions are from C99.
    (initializer-list
     (initializer ($$/ref 's4.6-04 (make-tl 'initzer-list $1)))
     (initializer-list "," initializer ($$/ref 's4.6-05 (tl-append $1 $3)))
     (designation initializer ($$/ref 's4.6-06 (make-tl 'initzer-list $1 $2)))
     (initializer-list "," designation initializer
		       ($$/ref 's4.6-07 (tl-append $1 $3 $4)))
     )

    (designation
     (designator-list "=" ($$/ref 's4.6-08 `(desig ,$1)))
     )

    (designator-list
     (designator ($$/ref 's4.6-09 (make-tl 'desgr-list $1)))
     (designator-list designator ($$/ref 's4.6-10 (tl-append $1 $2)))
     )

    (designator
     ("[" constant-expression "]" ($$/ref 's4.6-11 (list 'array-dsgr $2)))
     ("." identifier ($$/ref 's4.6-12 (list 'sel-dsgr $2)))
     )

    ;; 5.1, p 125
    (integer-type-specifier
     (signed-type-specifier)
     (unsigned-type-specifier)
     (character-type-specifier)
     (bool-type-specifier)
     )

    ;; 5.1.1, p 125
    ;; The productions shown in the book are not LALR1 so we will need to use
    ;; static semantics.
    (signed-type-specifier ;; Enforce with static semantics.
     ("short" ($prec "imp")
      ($$/ref 's5.1.1-01 '(fixed-type "short")))
     ("short" "int"
      ($$/ref 's5.1.1-02 '(fixed-type "short int")))
     ("signed" "short" ($prec "imp")
      ($$/ref 's5.1.1-03 '(fixed-type "signed short")))
     ("signed" "short" "int"
      ($$/ref 's5.1.1-04 '(fixed-type "signed short int")))
     ("int" ($$/ref 's5.1.1-01 '(fixed-type "int")))
     ("signed" ($prec "imp")
      ($$/ref 's5.1.1-05 '(fixed-type "signed")))
     ("signed" "int"
      ($$/ref 's5.1.1-06 '(fixed-type "signed int")))
     ("long" ($prec "imp")
      ($$/ref 's5.1.1-07 '(fixed-type "long")))
     ("long" "int"
      ($$/ref 's5.1.1-08 '(fixed-type "long int")))
     ("signed" "long" ($prec "imp")
      ($$/ref 's5.1.1-09 '(fixed-type "signed long")))
     ("signed" "long" "int"
      ($$/ref 's5.1.1-10 '(fixed-type "signed long int")))
     ("long" "long" ($prec "imp")
      ($$/ref 's5.1.1-11 '(fixed-type "long long")))
     ("long" "long" "int"
      ($$/ref 's5.1.1-12 '(fixed-type "long long int")))
     ("signed" "long" "long" ($prec "imp")
      ($$/ref 's5.1.1-13 '(fixed-type "signed long long")))
     ("signed" "long" "long" "int"
      ($$/ref 's5.1.1-14 '(fixed-type "signed long long int")))
     )

    ;; 5.1.2, p 128
    (unsigned-type-specifier
     ("unsigned" "short" "int"
      ($$/ref 's5.1.2-01 '(fixed-type "unsigned short int")))
     ("unsigned" "short" ($prec "imp")
      ($$/ref 's5.1.2-02 '(fixed-type "unsigned short")))
     ("unsigned" "int"
      ($$/ref 's5.1.2-03 '(fixed-type "unsigned int")))
     ("unsigned" ($prec "imp")
      ($$/ref 's5.1.2-04 '(fixed-type "unsigned")))
     ("unsigned" "long" "int"
      ($$/ref 's5.1.2-05 '(fixed-type "unsigned long")))
     ("unsigned" "long" ($prec "imp")
      ($$/ref 's5.1.2-06 '(fixed-type "unsigned long")))
     ("unsigned" "long" "long" "int"
      ($$/ref 's5.1.2-07 '(fixed-type "unsigned long long int")))
     ("unsigned" "long" "long" ($prec "imp")
      ($$/ref 's5.1.2-08 '(fixed-type "unsigned long long")))
     )

    ;; 5.1.3, p 129
    (character-type-specifier ;; Enforce with static semantics.
     ("char" ($$/ref 's5.1.3-01 '(fixed-type "char")))
     ("signed" "char" ($$/ref 's5.1.3-02 '(fixed-type "signed char")))
     ("unsigned" "char" ($$/ref 's5.1.3-03 '(fixed-type "unsigned char")))
     )

    ;; 5.1.5, p 132, discussed but not defined
    (bool-type-specifier
     ("_Bool" ($$/ref 's5.1.5-01 '(fixed-type "_Bool")))
     )

    ;; 5.2, p 132
    (floating-point-type-specifier
     ("float" ($prec "imp") ($$/ref 's5.2-01 '(float-type "float")))
     ("double" ($prec "imp") ($$/ref 's5.2-02 '(float-type "double")))
     ("long" "double" ($$/ref 's5.2-03 '(float-type "long double")))
     (complex-type-specifier)
     )

    ;; 5.2.1, p 136
    (complex-type-specifier
     ("_Complex"
      ($$/ref 's5.2.1-01 '(complex-type "_Complex")))
     ("float" "_Complex"
      ($$/ref 's5.2.1-02 '(complex-type "float _Complex")))
     ("double" "_Complex"
      ($$/ref 's5.2.1-03 '(complex-type "double _Complex")))
     ("long" "double" "_Complex"
      ($$/ref 's5.2.1-04 '(complex-type "long double _Complex")))
     )

    ;; 5.5, p 145
    (enumeration-type-specifier
     (enumeration-type-definition)
     (enumeration-type-reference)
     )

    (enumeration-type-definition
     ("enum" enumeration-tag "{" enumeration-definition-list "}"
      ($$/ref 's5.5-01 `(enum-def ,$1 ,(tl->list $4))))
     ("enum" "{" enumeration-definition-list "}"
      ($$/ref 's5.5-02 `(enum-def ,(tl->list $3))))
     ("enum" enumeration-tag "{" enumeration-definition-list "," "}"
      ($$/ref 's5.5-03 `(enum-def ,$1 ,(tl->list $4))))
     ("enum" "{" enumeration-definition-list "," "}"
      ($$/ref 's5.5-04 `(enum-def ,(tl->list $3))))
     )
    
    (enumeration-type-reference
     ("enum" enumeration-tag ($$/ref 's5.5-05 `(enum-ref ,$2)))
     )

    (enumeration-tag (identifier))

    (enumeration-definition-list
     (enumeration-constant-definition
      ($$/ref 's5.5-06 (make-tl 'enum-def-list $1)))
     (enumeration-definition-list "," enumeration-constant-definition
				  ($$/ref 's5.5-07 (tl-append $1 $3)))
     )

    (enumeration-constant-definition
     (enumeration-constant ($$/ref 's5.5-08 `(enum-defn ,$1)))
     ;; I'm not not sure how to get this working. With 'expression, then
     ;; comma-expressions are allowed but enum uses commas in list of
     ;; enumerations.  So I'm using 'constant-expression instead for now.
     ;; (enumeration-constant "=" expression)  ;;  --[change to]--> 
     (enumeration-constant "=" constant-expression
			   ($$/ref 's5.5-08 `(enum-defn ,$1 ,$3)))
     )
    (enumeration-constant (identifier))

    ;; 5.6, p 148
    (structure-type-specifier
     (structure-type-definition)
     (structure-type-reference)
     )

    (structure-type-definition
     ("struct" structure-tag "{" field-list "}"
      ($$/ref 's5.6-01 `(struct-def ,$1 ,(tl->list $4))))
     ("struct" "{" field-list "}"
      ($$/ref 's5.6-02 `(struct-def ,(tl->list $3))))
     )

    (structure-type-reference
     ("struct" structure-tag ($$/ref 's5.6-03 `(struct-ref ,$2)))
     )

    (structure-tag (identifier))

    (field-list
     (component-declaration ($$/ref 's5.6-04 (make-tl 'field-list $1)))
     (lone-comment ($$/ref 's5.6-04 (make-tl 'field-list $1)))
     (field-list component-declaration ($$/ref 's5.6-05 (tl-append $1 $2)))
     (field-list lone-comment ($$/ref 's5.6-06 (tl-append $1 $2)))
     )

    (component-declaration
     (type-specifier
      component-declarator-list ";" opt-code-comment
      ($$/ref 's5.6-07 (if (pair? $4)
	      `(comp-decln ,$1 ,(tl->list $2) ,$4)
	      `(comp-decln ,$1 ,(tl->list $2)))))
     )

    (component-declarator-list
     (component-declarator ($$/ref 's5.6-08 (make-tl 'comp-declr-list $1)))
     (component-declarator-list "," component-declarator
				($$/ref 's5.6-09 (tl-append $1 $3)))
     )

    (component-declarator
     (simple-component)
     (bit-field)
     )

    (simple-component (declarator))

    ;; TEST
    (bit-field
     (declarator ":" width ($$/ref 's5.6-10 `(bit-field ,$1 ,$3)))
     (":" width ($$/ref 's5.6-11 `(bit-field ,$2)))
     )

    (width (constant-expression))

    ;; 5.8, p 161
    (union-type-specifier
     (union-type-definition)
     (union-type-reference)
     )

    (union-type-definition
     ("union" union-tag "{" field-list "}"
      ($$/ref 's5.8-01 `(union-def ,$1 ,(tl->list $4))))
     ("union" "{" field-list "}"
      ($$/ref 's5.8-02 `(union-def ,(tl->list $3))))
     )

    (union-type-reference
     ("union" union-tag ($$/ref 's5.8-03 `(union-ref ,$1)))
     )
    (union-tag (identifier))

    ;; 5.9, p 168
    (void-type-specifier ("void" ($$/ref 's5.9-01 '(void))))

    ;; 5.10, p 168
    ;;(typedef-name (identifier)) must be hacked w/ the lexical analyzer
    (typedef-name ('typename ($$/ref 's5.10-01 `(typename ,$1))))

    ;; 5.12, p 176
    (type-name
     (declaration-specifiers
      abstract-declarator
      ($$/ref 's5.12-01 `(type-name ,(tl->list $1) ,$2))) ;; ???
     (declaration-specifiers
      ($$/ref 's5.12-02 `(type-name ,(tl->list $1)))) ;; ???
     )

    (abstract-declarator
     (pointer ($$/ref 's5.12-01 `(abs-declr ,$1)))
     (pointer direct-abstract-declarator
	      ($$/ref 's5.12-02 `(abs-declr ,$1 ,$2)))
     (direct-abstract-declarator ($$/ref 's5.12-03 `(abs-declr ,$1)))
     )

    ;; The following in 4.5.2
    ;; pointer =>
    ;; type-qualifier-list => 

    ;; I have removed 'constant-expression productions below because
    ;; these conflict with expression which expands to constant-expression.
    (direct-abstract-declarator
     ("(" abstract-declarator ")" ($$/ref 's5.12-01 `(declr-scope ,$2)))
     ;;(direct-abstract-declarator "[" constant-expression "]") 
     (direct-abstract-declarator "[" "]" ($$/ref 's5.12-03 `(declr-array ,$1)))
     ;;("[" constant-expression "]")
     ("[" "]")
     ;;
     (direct-abstract-declarator
      "[" expression "]"
      ($$/ref 's5.12-05 `(declr-arry ,$1 ,$3)))
     ("[" expression "]" ($$/ref 's5.12-06 `(declr-anon-arry ,$2))) ;; ?????
     ;;
     (direct-abstract-declarator
      "[" "*" "]"
      ($$/ref 's5.12-07 `(declr-STAR ,$1)))
     ("[" "*" "]" ($$/ref 's5.12-08 '(declr-STAR)))
     ;;
     (direct-abstract-declarator
      "(" parameter-type-list ")"
      ($$/ref 's5.12-09 `(declr-fctn ,$1 ,(tl->list $3))))
     (direct-abstract-declarator "(" ")" ($$/ref 's5.12-01 `(declr-fctn ,$1)))
     ("(" parameter-type-list ")"
      ($$/ref 's5.12-10 `(declr-anon-fctn ,(tl->list $2))))
     ("(" ")" ($$/ref 's5.12-11 '(declr-anon-fctn)))
     )

    ;; 7.3, p 207
    (primary-expression
     (identifier ($$/ref 's7.3-01 `(p-expr ,$1)))
     (constant ($$/ref 's7.3-02 `(p-expr ,$1)))
     (parenthesized-expression)
     )

    ;; 7.3.3, p 209
    (parenthesized-expression
     ("(" expression ")" ($$/ref 's7.3.3-01 `(p-expr ,$2))))

    ;; 7.4, p 210
    (postfix-expression
     (primary-expression)
     (subscript-expression)
     (component-selection-expression)
     (function-call)
     (postincrement-expression)
     (postdecrement-expression)
     (compound-literal)
     )

    ;; 7.4.1, p 210
    (subscript-expression
     (postfix-expression "[" expression "]" ($$/ref 's7.4.1-01 '(FIX)))
     )

    ;; 7.4.2, p 212
    (component-selection-expression
     (direct-component-selection)
     (indirect-component-selection)
     )

    (direct-component-selection
     (postfix-expression "." identifier ($$/ref 's7.4.2-01 `(d-sel ,$3 ,$1)))
     )
    
    (indirect-component-selection
     (postfix-expression "->" identifier ($$/ref 's7.4.2-02 `(i-sel ,$3 ,$1)))
     )

    ;; 7.4.3, p 214
    (function-call
     (postfix-expression "(" expression-list ")"
			 ($$/ref 's7.4.3-01 `(fctn-call ,$1 ,$2)))
     (postfix-expression "(" ")" ($$/ref 's7.4.3-02 `(fctn-call ,$1)))
     )

    (expression-list
     (assignment-expression ($$/ref 's7.4.3-03 (make-tl 'expr-list $1)))
     (expression-list "," assignment-expression
		      ($$/ref 's7.4.3-04 (tl-append $1 $3)))
     )

    ;; 7.4.4, p 216
    (postincrement-expression
     (postfix-expression "++" ($$/ref 's7.4.4-01 `(post-inc ,$1)))
     )
    
    (postdecrement-expression
     (postfix-expression "--" ($$/ref 's7.4.4-02 `(post-dec ,$1)))
     )

    ;; 7.4.5, p 217
    (compound-literal
     ("(" type-name ")" "{" initializer-list "}"
      ($$/ref 's7.4.5-01 `(comp-literal ,$2 ,(tl->list $5))))
     ("(" type-name ")" "{" initializer-list "," "}"
      ($$/ref 's7.4.5-02 `(comp-literal ,$2 ,(tl->list $5))))
     )

    ;; 7.5, p 219
    (cast-expression
     (unary-expression)
     ("(" type-name ")" cast-expression ($$/ref 's7.5-01 `(cast ,$2 ,$4)))
     )

    (unary-expression
     (postfix-expression)
     (sizeof-expression)
     (unary-minus-expression)
     (unary-plus-expression)
     (logical-negation-expression)
     (bitwise-negation-expression)
     (address-expression)
     (indirection-expression)
     (preincrement-expression)
     (predecrement-expression)
     )
    
    ;; 7.5.2, p 220
    (sizeof-expression
     ("sizeof" "(" type-name ")" ($$/ref 's7.5.2-01 `(sizeof-type ,$3)))
     ("sizeof" unary-expression ($$/ref 's7.5.2-02 `(sizeof-expr ,$2)))
     )

    ;; 7.5.3, p 222
    (unary-minus-expression
     ("-" cast-expression ($$/ref 's7.5.3-01 `(neg ,$2)))
     )

    ;; (C89)
    (unary-plus-expression
     ("+" cast-expression ($$/ref 's7.5.3-02 `(pos ,$2)))
     )

    ;; 7.5.4, p 223
    (logical-negation-expression
     ("!" cast-expression)
     )
    
    ;; 7.5.5, p 223
    (bitwise-negation-expression
     ("~" cast-expression)
     )

    ;; 7.5.6, p 224
    (address-expression
     ("&" cast-expression)
     )

    ;; 7.5.7, p 225
    (indirection-expression
     ("*" cast-expression)
     )

    ;; 7.5.8, p 226
    (preincrement-expression
     ("++" unary-expression ($$/ref 's7.5.8-01 `(pre-inc ,$2)))
     )

    (predecrement-expression
     ("--" unary-expression ($$/ref 's7.5.8-02 `(pre-dec ,$2)))
     )

    ;; 7.6.1, p 227
    (multiplicative-expression
     (cast-expression)
     (multiplicative-expression mult-op cast-expression
				($$/ref 's7.6.1-01 (list $2 $1 $3)))
     )
    (mult-op ("*" ($$/ref 's7.6.1-02 'mul))
	     ("/" ($$/ref 's7.6.1-03 'div))
	     ("%" ($$/ref 's7.6.1-04 'mod)))

    ;; 7.6.2, p 229
    (additive-expression
     (multiplicative-expression)
     (additive-expression add-op multiplicative-expression
			  ($$/ref 's7.6.2-01 (list $2 $1 $3)))
     )
    (add-op ("+" ($$/ref 's7.6.2-02 'add))
	    ("-" ($$/ref 's7.6.2-03 'sub)))

    ;; 7.6.3, p 231
    (shift-expression
     (additive-expression)
     (shift-expression shift-op additive-expression
		       ($$/ref 's7.6.3-01 (list $2 $1 $3)))
     )
    (shift-op ("<<" ($$/ref 's7.6.3-02 'lshift))
	      (">>" ($$/ref 's7.6.3-03 'rshift)))

    ;; 7.6.4, p 233
    (relational-expression
     (shift-expression)
     (relational-expression relational-op shift-expression
			    ($$/ref 's7.6.4-01 (list $2 $1 $3)))
     )
    (relational-op ("<" ($$/ref 's7.6.4-02 'lt))
		   ("<=" ($$/ref 's7.6.4-03 'le))
		   (">" ($$/ref 's7.6.4-04 'gt))
		   (">=" ($$/ref 's7.6.4-05 'ge)))

    ;; 7.6.5, p 234
    (equality-expression
     (relational-expression)
     (equality-expression equality-op relational-expression
			  ($$/ref 's7.6.5-01 (list $2 $1 $3)))
     )
    (equality-op ("==" ($$/ref 's7.6.5-02 'eq))
		 ("!=" ($$/ref 's7.6.5-03 'ne)))

    ;; 7.6.6, p 236
    (bitwise-or-expression
     (bitwise-xor-expression)
     (bitwise-or-expression "|" bitwise-xor-expression
			    ($$/ref 's7.6.6-01 `(bitwise-or ,$1 ,$3)))
     )
    
    (bitwise-xor-expression
     (bitwise-and-expression)
     (bitwise-xor-expression "^" bitwise-and-expression
			     ($$/ref 's7.6.6-02 `(bitwise-xor ,$1 ,$3)))
     )
    
    (bitwise-and-expression
     (equality-expression)
     (bitwise-and-expression "&" equality-expression
			     ($$/ref 's7.6.6-03 `(bitwise-and ,$1 ,$3)))
     )

    ;; 7.7, p 242
    (logical-or-expression
     (logical-and-expression)
     (logical-or-expression "||" logical-and-expression
			    ($$/ref 's7.7-01 `(or ,$1 ,$3)))
     )
    
    (logical-and-expression
     (bitwise-or-expression)
     (logical-and-expression "&&" bitwise-or-expression
			     ($$/ref 's7.7-02 `(and ,$1 ,$3)))
     )

    ;; 7.8, p 244
    (conditional-expression
     (logical-or-expression)
     (logical-or-expression "?" expression ":" conditional-expression
			    ($$/ref 's7.8-01 `(cond-expr $1 $2 $3)))
     )

    ;; 7.9, p 246
    (assignment-expression
     (conditional-expression)
     (unary-expression assignment-op assignment-expression
		       ($$/ref 's7.9-01 (list $2 $1 $3)))
     )
    (assignment-op ("=" ($$ 'assign))
		   ("+=" ($$ 'add-assign))
		   ("-=" ($$ 'sub-assign))
		   ("*=" ($$ 'mul-assign))
		   ("/=" ($$ 'div-assign))
		   ("%=" ($$ 'mod-assign))
		   ("<<=" ($$ 'lshift-assign))
		   (">>=" ($$ 'rshift-assign))
		   ("&=" ($$ 'and-assign))
		   ("^=" ($$ 'xor-assign))
		   ("|=" ($$ 'or-assign)))

    ;; 7.10, p 249
    (comma-expression
     (assignment-expression)
     (comma-expression "," assignment-expression)
     )

    (expression
     (comma-expression))

    ;; 7.11, constant-expression explained, provided in appendix
    (constant-expression
     (conditional-expression)
     ;;('$hack)
     )
    
    ;; 8, p 259
    (statement
     (expression-statement)
     (labeled-statement)
     (compound-statement)
     (conditional-statement)
     (iterative-statement)
     (switch-statement)
     (break-statement)
     (continue-statement)
     (return-statement)
     (goto-statement)
     (null-statement)
     )

    ;; See the following productions below, in 8.5 and 8.6
    ;; conditional-statement =>
    ;; iterative-statement => 

    ;; 8.2, p 260
    (expression-statement
     (expression ";")
     )

    ;; 8.3, p 261
    (labeled-statement
     (label ":" statement)
     )
    (label (named-label) (case-label) (default-label))

    ;; 8.4, p 262
    (compound-statement
     ("{" declaration-or-statement-list "}")
     ("{" "}")
     )

    (declaration-or-statement-list
     (declaration-or-statement)
     (declaration-or-statement-list declaration-or-statement)
     )

    (declaration-or-statement
     (declaration)
     (statement)
     )

    ;; 8.5, p 264
    (conditional-statement
     (if-statement)
     (if-else-statement)
     )

    (if-statement
     ("if" "(" expression ")" statement ($prec "then")
      ($$ `(if ,$3 ,$5)))
     )

    (if-else-statement
     ("if" "(" expression ")" statement "else" statement
      ($$ `(if ,$3 ,$5 ,7)))
     )

    ;; 8.6, p 266
    (iterative-statement
     (while-statement)
     (do-statement)
     (for-statement)
     )

    ;; 8.6.1, p 267
    (while-statement
     ("while" "(" expression ")" statement ($$ `(while ,$3 ,$5)))
     )

    ;; 8.6.2, p 268
    (do-statement
     ("do" statement "while" "(" expression ")" ";" ($$ `(do-while ,$2 ,$5)))
     )

    ;; 8.6.3, p 269
    (for-statement
     ("for" for-expressions statement ($$ `(for ,@$2 $3)))
     )

    (for-expressions
     ("(" initial-clause expression ";" expression ")" ($$ (list $2 $3 $5)))
     ("(" initial-clause expression ";" ")" ($$ (list $2 $3 '(expr))))
     ("(" initial-clause ";" expression ")" ($$ (list $2 '(expr) $4)))
     ("(" initial-clause ";" ")" ($$ (list $2 '(expr) '(expr))))
     )
    
    (initial-clause
     (expression ";")
     (";" ($$ '(expr)))
     (declaration)
     )

    ;; 8.7, p 274
    (switch-statement
     ("switch" "(" expression ")" statement)
     )

    (case-label
     ("case" constant-expression)
     )

    (default-label
      ("default")
      )

    ;; 8.8, p 277
    (break-statement ("break" ";" ($$ '(break))))

    (continue-statement ("continue" ";" ($$ '(continue))))

    ;; 8.9, p 279
    (return-statement
     ("return" expression ";" ($$ `(return $2)))
     ("return" ";" ($$ `(return (expr))))
     )

    ;; 8.10, p 280
    (goto-statement
     ("goto" named-label ";" ($$ `(goto $2)))
     )
    (named-label (identifier))

    ;; 8.11, p 281
    (null-statement
     (";" ($$ '(null-stmt))))

    ;; 9.1, p 286
    (translation-unit
     (top-level-declaration ($$ (make-tl 'trans-unit $1)))
     (translation-unit
      top-level-declaration
      ($$ (cond
	   ((eqv? 'trans-unit (car $2))
	    (let* ((t1 (tl-append $1 '(extern-C-begin)))
		   (t2 (tl-extend t1 (cdr $2)))
		   (t3 (tl-append t2 '(extern-C-end))))
	      t3))
	   (else
	    (tl-append $1 $2)))))
     )

    (top-level-declaration
     (declaration)
     (function-definition)
     (lone-comment)
     (cpp-statement)
     ;; The following is a kludge to deal with @code{extern "C" @{}.
     ("extern" '$string "{" translation-unit "}" ($$ (tl->list $4)))
     )

    (function-definition
     (function-def-specifier compound-statement)
     )

    (function-def-specifier
     ;; declaration-specifiers_opt declarator declaration-list_opt
     (declaration-specifiers
      declarator declaration-list
      ($$ `(fctn-defn1a ,(tl->list $1) ,$2 ,(tl->list $3))))
     (declaration-specifiers
      declarator
      ($$ `(fctn-defn1b ,(tl->list $1) ,$2)))
     (declarator
      ($$ `(fctn-defn1c ,$1)))
     )

    (declaration-list
     (declaration ($$ (make-tl $1)))
     (declaration-list declaration ($$ (tl-append $1 $2)))
     )

    ;; 9.1, p 287
    ;; These productions are repeated in the book.  See 4.5.4 above.
    ;; function-declarator =>
    ;; parameter-type-list =>
    ;; parameter-list =>
    ;; parameter-declaration =>
    ;; identifier-list =>

    (opt-code-comment () (code-comment))
    ;;(opt-lone-comment () (lone-comment))

    ;; non-terminal leaves
    (identifier
     ('$ident ($$ `(ident ,$1)))
     ('cpp-ident ($$ `(ident ,$1)))
     )
    (constant
     ('$fixed ($$ `(fixed ,$1)))	; integer-constant
     ('$float ($$ `(float ,$1)))	; floating-constant
     ('$chlit ($$ `(char ,$1)))		; char-constant
     ('$string ($$ `(string ,$1)))	; string-constant
     )
    (code-comment ('$code-comm ($$ `(comment ,$1))))
    (lone-comment ('$lone-comm ($$ `(comment ,$1))))
    (cpp-statement ('cpp-stmt ($$ `(cpp-stmt ,$1))))
    )))

(define clang-mach
  (compact-machine
   ;;(identity
   (hashify-machine
    ;;(identity
    (make-lalr-machine clang-spec))))

(define len-v (assq-ref clang-mach 'len-v))
(define pat-v (assq-ref clang-mach 'pat-v))
(define rto-v (assq-ref clang-mach 'rto-v))
(define mtab (assq-ref clang-mach 'mtab))
(define sya-v (vector-map (lambda (ix actn) (wrap-action actn))
			  (assq-ref clang-mach 'act-v)))
(define act-v (vector-map (lambda (ix f) (eval f (current-module))) sya-v))

;;(include "pbody.scm")
(include-from-path "nyacc/lang/c99/pbody.scm")

(define raw-parser (make-lalr-parser clang-mach))

(define (run-parse) (raw-parser (gen-c-lexer)))

(define* (dev-parse-c
	  #:key (cpp-defs '()) (inc-dirs '()) (td-dict '()) (mode 'file) debug)
  (catch
   'parse-error
   (lambda ()
     (let ((info (make-cpi cpp-defs (cons "." inc-dirs) td-dict)))
       (with-fluid* *info* info
		    (lambda ()
		      (raw-parser (gen-c-lexer #:mode mode) #:debug debug)))))
   (lambda (key fmt . rest)
     (apply simple-format (current-error-port) (string-append fmt "\n") rest)
     #f)))

;; --- last line