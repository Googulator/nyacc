;;; lang/javascript/mach.scm

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

(define-module (nyacc lang javascript mach)
  #:export (js-spec
	    js-mach
	    dev-parse-js
	    gen-js-files gen-se-files)
  #:use-module (nyacc lang util)
  #:use-module (nyacc lalr)
  #:use-module (nyacc parse)
  #:use-module (nyacc lex)
  #:use-module (nyacc util)
  #:use-module ((srfi srfi-43) #:select (vector-map)))

;; This parses EcmaScript v3 1999.  Some v5 2011 items are added as comments.

;; The 'NoIn' variants are needed to avoid confusing the in operator 
;; in a relational expression with the in operator in a for statement.
;; Exclusion of ObjectLiteral and FunctionExpression at statement scope
;; is implemented using precedence for reduction.

;; NSI = "no semi-colon insertion"

(define js-spec
  (lalr-spec
   (notice (string-append "Copyright 2015-2018 Matthew R. Wette"
			  lang-crn-lgpl3+))
   (reserve "abstract" "boolean" "byte" "char" "class" "const" "debugger"
	    "double" "enum" "export" "extends" "final" "float" "goto"
	    "implements" "import" "int" "interface" "long" "native" 
	    "package" "private" "protected" "public" "short" "static"
	    "super" "synchronized" "throws" "transient" "volatile")
   (prec< 'then "else")
   (prec< 'expr 'stmt)
   (expect 1)				; shift-reduce on ":"
   (start Program)
   (grammar

    (Literal
     (NullLiteral)
     (BooleanLiteral)
     (NumericLiteral)
     (StringLiteral))

    (NullLiteral ("null" ($$ '(NullLiteral))))
    (BooleanLiteral
     ("true" ($$ `(BooleanLiteral ,$1)))
     ("false" ($$ `(BooleanLiteral ,$1))))
    (NumericLiteral
     ($fixed ($$ `(NumericLiteral ,$1)))
     ($float ($$ `(NumericLiteral ,$1))))
    (StringLiteral
     ($string ($$ `(StringLiteral ,$1))))
    
    ;;(DoubleStringCharacters ($string))
    ;;(SingleStringCharacters ($string))

    (Identifier ($ident ($$ `(Identifier ,$1))))

    ;; A.3
    (PrimaryExpression
     ("this" ($$ `(PrimaryExpression (this))))
     (Identifier ($$ `(PrimaryExpression ,$1)))
     (Literal ($$ `(PrimaryExpression ,$1)))
     (ArrayLiteral ($$ `(PrimaryExpression ,$1)))
     (ObjectLiteral ($$ `(PrimaryExpression ,$1)))
     ("(" Expression ")" ($$ $2))
     )

    (ArrayLiteral
     ("[" Elision "]" ($$ `(ArrayLiteral (Elision ,(number->string $2)))))
     ("[" "]" ($$ `(ArrayLiteral)))
     ("[" ElementList "]" ($$ `(ArrayLiteral ,(tl->list $2))))
     ("[" ElementList "," Elision "]"
      ($$ `(ArrayLiteral (Elision ,(number->string $2)))))
     ("[" ElementList "," "]" ($$ `(ArrayLiteral ,(tl->list $2))))
     )

    (ElementList
     (Elision AssignmentExpression
	      ($$ (make-tl 'ElementList `(Elision ,(number->string $2)))))
     (AssignmentExpression ($$ (make-tl 'ElementList $1)))
     (ElementList "," Elision AssignmentExpression
		  ($$ (tl-append $1 `(Elision ,(number->string $3)) $4)))
     (ElementList "," AssignmentExpression ($$ (tl-append $1 $3)))
     )

    (Elision
     ("," ($$ 1))
     (Elision "," ($$ (1+ $1)))
     )

    (ObjectLiteral
     ("{" "}" ($prec 'expr) ($$ `(ObjectLiteral)))
     ("{" PropertyNameAndValueList "}" ($prec 'expr)
      ($$ `(ObjectLiteral ,(tl->list $2))))
     ("{" PropertyNameAndValueList "," "}" ($prec 'expr)
      ($$ `(ObjectLiteral ,(tl->list $2))))
     )

    (PropertyNameAndValueList
     (PropertyName ":" AssignmentExpression
		   ($$ (make-tl `PropertyNameAndValueList
				`(PropertyNameAndValue ,$1 ,$3))))
     (PropertyNameAndValueList
      "," PropertyName ":" AssignmentExpression
      ($$ (tl-append $1 `(PropertyNameAndValue ,$3 ,$5))))
     )

    ;; from v5.1
    #|
    (PropertyAssignment
     (PropertyName ":" AssignmentExpression)
     ("get" PropertyName "(" ")" "{" FunctionBody "}")
     ("set" PropertyName "(" PropertySetParametersList ")"
      "{" FunctionBody "}")
     )
    |#

    (PropertyName
     (Identifier)
     (StringLiteral)
     (NumericLiteral)
     )

    (MemberExpression
     (PrimaryExpression)
     (FunctionExpression)
     (MemberExpression "[" Expression "]" ($$ `(ooa-ref ,$1 ,$3)))
     (MemberExpression "." Identifier ($$ `(obj-ref ,$1 ,$3)))
     ("new" MemberExpression Arguments ($$ `(new ,$2 ,$3)))
     )

    (NewExpression
     (MemberExpression)
     ("new" NewExpression ($$ `(new ,$2)))
     )

    (CallExpression
     (MemberExpression Arguments ($$ `(CallExpression ,$1 ,$2)))
     (CallExpression Arguments ($$ `(CallExpression ,$1 ,$2)))
     (CallExpression "[" Expression "]" ($$ `(ooa-ref ,$1 ,$3)))
     (CallExpression "." Identifier ($$ `(obj-ref ,$1 ,$3)))
     )

    (Arguments
     ("(" ")" ($$ '(ArgumentList)))
     ("(" ArgumentList ")" ($$ (tl->list $2)))
     )
    (ArgumentList
     (AssignmentExpression ($$ (make-tl 'ArgumentList $1)))
     (ArgumentList "," AssignmentExpression ($$ (tl-append $1 $3)))
     )

    (LeftHandSideExpression
     (NewExpression)
     (CallExpression)
     )

    (PostfixExpression
     (LeftHandSideExpression)
     (LeftHandSideExpression ($$ (NSI)) "++" ($$ `(post-inc ,$1)))
     (LeftHandSideExpression ($$ (NSI)) "--" ($$ `(post-dec ,$1)))
     )

    (UnaryExpression
     (PostfixExpression)
     ("delete" UnaryExpression ($$ `(delete ,$2)))
     ("void" UnaryExpression ($$ `(void ,$2)))
     ("typeof" UnaryExpression ($$ `(typeof ,$2)))
     ("++" UnaryExpression ($$ `(pre-inc ,$2)))
     ("--" UnaryExpression ($$ `(pre-dec ,$2)))
     ("+" UnaryExpression ($$ `(pos ,$2)))
     ("-" UnaryExpression ($$ `(neg ,$2)))
     ("~" UnaryExpression ($$ `(bitwise-not?? ,$2)))
     ("!" UnaryExpression ($$ `(not ,$2)))
     )

    (MultiplicativeExpression
     (UnaryExpression)
     (MultiplicativeExpression "*" UnaryExpression
			       ($$ `(mul ,$1 ,$3)))
     (MultiplicativeExpression "/" UnaryExpression
			       ($$ `(div ,$1 ,$3)))
     (MultiplicativeExpression "%" UnaryExpression
			       ($$ `(mod ,$1 ,$3)))
     )

    (AdditiveExpression
     (MultiplicativeExpression)
     (AdditiveExpression "+" MultiplicativeExpression
			 ($$ `(add ,$1 ,$3)))
     (AdditiveExpression "-" MultiplicativeExpression
			 ($$ `(sub ,$1 ,$3)))
     )

    (ShiftExpression
     (AdditiveExpression)
     (ShiftExpression "<<" AdditiveExpression
		      ($$ `(lshift ,$1 ,$3)))
     (ShiftExpression ">>" AdditiveExpression
		      ($$ `(rshift ,$1 ,$3)))
     (ShiftExpression ">>>" AdditiveExpression
		      ($$ `(rrshift ,$1 ,$3)))
     )

    (RelationalExpression
     (ShiftExpression)
     (RelationalExpression "<" ShiftExpression
			   ($$ `(lt ,$1 ,$3)))
     (RelationalExpression ">" ShiftExpression
			   ($$ `(gt ,$1 ,$3)))
     (RelationalExpression "<=" ShiftExpression
			   ($$ `(le ,$1 ,$3)))
     (RelationalExpression ">=" ShiftExpression
			   ($$ `(ge ,$1 ,$3)))
     (RelationalExpression "instanceof" ShiftExpression
			   ($$ `(instanceof ,$1 ,$3)))
     (RelationalExpression "in" ShiftExpression
			   ($$ `(in ,$1 ,$3)))
     )
    (RelationalExpressionNoIn
     (ShiftExpression)
     (RelationalExpressionNoIn "<" ShiftExpression
			       ($$ `(lt ,$1 ,$3)))
     (RelationalExpressionNoIn ">" ShiftExpression
			       ($$ `(gt ,$1 ,$3)))
     (RelationalExpressionNoIn "<=" ShiftExpression
			       ($$ `(le ,$1 ,$3)))
     (RelationalExpressionNoIn ">=" ShiftExpression
			       ($$ `(ge ,$1 ,$3)))
     (RelationalExpressionNoIn "instanceof" ShiftExpression
			       ($$ `(instanceof ,$1 ,$3)))
     )
    
    (EqualityExpression
     (RelationalExpression)
     (EqualityExpression "==" RelationalExpression
			 ($$ `(eq ,$1 ,$3)))
     (EqualityExpression "!=" RelationalExpression
			 ($$ `(neq ,$1 ,$3)))
     (EqualityExpression "===" RelationalExpression
			 ($$ `(eq-eq ,$1 ,$3)))
     (EqualityExpression "!==" RelationalExpression
			 ($$ `(neq-eq ,$1 ,$3)))
     )
    (EqualityExpressionNoIn
     (RelationalExpressionNoIn)
     (EqualityExpressionNoIn "==" RelationalExpressionNoIn
			     ($$ `(eq ,$1 ,$3)))
     (EqualityExpressionNoIn "!=" RelationalExpressionNoIn
			     ($$ `(neq ,$1 ,$3)))
     (EqualityExpressionNoIn "===" RelationalExpressionNoIn
			     ($$ `(eq-eq ,$1 ,$3)))
     (EqualityExpressionNoIn "!==" RelationalExpressionNoIn
			     ($$ `(neq-eq ,$1 ,$3)))
     )

    (BitwiseANDExpression
     (EqualityExpression)
     (BitwiseANDExpression "&" EqualityExpression
			   ($$ `(bit-and ,$1 ,$3)))
     )
    (BitwiseANDExpressionNoIn
     (EqualityExpressionNoIn)
     (BitwiseANDExpressionNoIn "&" EqualityExpressionNoIn
			   ($$ `(bit-and ,$1 ,$3)))
     )

    (BitwiseXORExpression
     (BitwiseANDExpression)
     (BitwiseXORExpression "^" BitwiseANDExpression
			   ($$ `(bit-xor ,$1 ,$3)))
     )
    (BitwiseXORExpressionNoIn
     (BitwiseANDExpressionNoIn)
     (BitwiseXORExpressionNoIn "^" BitwiseANDExpressionNoIn
			       ($$ `(bit-xor ,$1 ,$3)))
     )

    (BitwiseORExpression
     (BitwiseXORExpression)
     (BitwiseORExpression "|" BitwiseXORExpression
			  ($$ `(bit-or ,$1 ,$3)))
     )
    (BitwiseORExpressionNoIn
     (BitwiseXORExpressionNoIn)
     (BitwiseORExpressionNoIn "|" BitwiseXORExpressionNoIn
			      ($$ `(bit-or ,$1 ,$3)))
     )

    (LogicalANDExpression
     (BitwiseORExpression)
     (LogicalANDExpression "&&" BitwiseORExpression
			   ($$ `(and ,$1 ,$3)))
     )
    (LogicalANDExpressionNoIn
     (BitwiseORExpressionNoIn)
     (LogicalANDExpressionNoIn "&&" BitwiseORExpressionNoIn
			       ($$ `(and ,$1 ,$3)))
     )

    (LogicalORExpression
     (LogicalANDExpression)
     (LogicalORExpression "||" LogicalANDExpression
			  ($$ `(or ,$1 ,$3)))
     )
    (LogicalORExpressionNoIn
     (LogicalANDExpressionNoIn)
     (LogicalORExpressionNoIn "||" LogicalANDExpressionNoIn
			  ($$ `(or ,$1 ,$3)))
     )

    (ConditionalExpression
     (LogicalORExpression)
     (LogicalORExpression "?" AssignmentExpression ":" AssignmentExpression
			  ($$ `(ConditionalExpression ,$1 ,$3 ,$5)))
     )
    (ConditionalExpressionNoIn
     (LogicalORExpressionNoIn)
     (LogicalORExpressionNoIn "?" AssignmentExpression
			      ":" AssignmentExpressionNoIn
			  ($$ `(ConditionalExpression ,$1 ,$3 ,$5)))
     )
    
    (AssignmentExpression
     (ConditionalExpression)
     (LeftHandSideExpression AssignmentOperator AssignmentExpression
			     ($$ `(AssignmentExpression ,$1 ,$2 ,$3)))
     )
    (AssignmentExpressionNoIn
     (ConditionalExpressionNoIn)
     (LeftHandSideExpression AssignmentOperator AssignmentExpressionNoIn
			     ($$ `(AssignmentExpression ,$1 ,$2 ,$3)))
     )

    (AssignmentOperator
     ("=" ($$ `(assign ,$1)))
     ("*=" ($$ `(mul-assign ,$1)))
     ("/=" ($$ `(div-assign ,$1)))
     ("%=" ($$ `(mod-assign ,$1)))
     ("+=" ($$ `(add-assign ,$1)))
     ("-=" ($$ `(sub-assign ,$1)))
     ("<<=" ($$ `(lshift-assign ,$1)))
     (">>=" ($$ `(rshift-assign ,$1)))
     (">>>=" ($$ `(rrshift-assign ,$1)))
     ("&=" ($$ `(and-assign ,$1)))
     ("^=" ($$ `(xor-assign ,$1)))
     ("|=" ($$ `(or-assign ,$1))))

    (Expression
     (AssignmentExpression)
     (Expression
      "," AssignmentExpression
      ($$ (if (and (pair? (car $1)) (eqv? 'expr-list (caar $1)))
	      (tl-append $1 $3)
	      (make-tl 'expr-list $1 $3))))
     )
    (ExpressionNoIn
     (AssignmentExpressionNoIn)
     (ExpressionNoIn
      "," AssignmentExpressionNoIn
      ($$ (if (and (pair? (car $1)) (eqv? 'expr-list (caar $1)))
	      (tl-append $1 $3)
	      (make-tl 'expr-list $1 $3))))
     )
	    
    ;; A.4
    (Statement
     (Block)
     (VariableStatement)
     (EmptyStatement)
     (ExpressionStatement)
     (IfStatement)
     (IterationStatement)
     (ContinueStatement)
     (BreakStatement)
     (ReturnStatement)
     (WithStatement)
     (LabelledStatement)
     (SwitchStatement)
     (ThrowStatement)
     (TryStatement)
     ;;(DebuggerStatement) v5.1
     )

    (Block
     ("{" StatementList "}" ($prec 'stmt) ($$ `(Block . ,(cdr (tl->list $2)))))
     ("{" "}" ($prec 'stmt) ($$ '(Block)))
     )

    (StatementList
     (Statement ($$ (make-tl 'StatementList $1)))
     (StatementList Statement ($$ (tl-append $1 $2)))
     )

    (VariableStatement
     ("var" VariableDeclarationList ";"
      ($$ `(VariableStatement ,(tl->list $2))))
     )

    (VariableDeclarationList
     (VariableDeclaration ($$ (make-tl 'VariableDeclarationList $1)))
     (VariableDeclarationList "," VariableDeclaration ($$ (tl-append $1 $3)))
     )
    (VariableDeclarationListNoIn
     (VariableDeclarationNoIn ($$ (make-tl 'VariableDeclarationList $1)))
     (VariableDeclarationListNoIn "," VariableDeclarationNoIn
				  ($$ (tl-append $1 $3)))
     )

    (VariableDeclaration
     (Identifier Initializer ($$ `(VariableDeclaration ,$1 ,$2)))
     (Identifier ($$ `(VariableDeclaration ,$1)))
     )
    (VariableDeclarationNoIn
     (Identifier InitializerNoIn ($$ `(VariableDeclaration ,$1 ,$2)))
     (Identifier ($$ `(VariableDeclaration ,$1)))
     )

    (Initializer
     ("=" AssignmentExpression ($$ `(Initializer ,$2)))
     )
    (InitializerNoIn
     ("=" AssignmentExpressionNoIn ($$ `(Initializer ,$2)))
     )

    (EmptyStatement
     (";" ($$ '(EmptyStatement)))
     )

    (ExpressionStatement
     (Expression ";" ($$ `(ExpressionStatement ,$1)))
     )

    (IfStatement
     ("if" "(" Expression ")" Statement "else" Statement
      ($$ `(IfStatement ,$3 ,$5 ,$7)))
     ("if" "(" Expression ")" Statement ($prec 'then)
      ($$ `(IfStatement ,$3 ,$5)))
     )

    (IterationStatement
     ("do" Statement "while" "(" Expression ")" ";" ;; <= spec has ';' here
      ($$ `(do ,$2 ,$5)))
     ("while" "(" Expression ")" Statement
      ($$ `(while ,$3 ,$5)))
     ("for" "(" OptExprStmtNoIn OptExprStmt OptExprClose Statement
      ($$ `(for $3 $4 $5 $6)))
     ("for" "(" "var" VariableDeclarationListNoIn ";" OptExprStmt
      OptExprClose Statement
      ($$ `(for $4 $6 $7 $8)))		; ???
     ("for" "(" LeftHandSideExpression "in" Expression ")" Statement
      ($$ `(for-in $3 $5 $7)))		; ???
     ("for" "(" "var" VariableDeclarationNoIn "in" Expression ")" Statement
      ($$ `(for-in $4 $6 $8)))		; ???
     )
    (OptExprStmtNoIn
     (":" ($$ '(NoExpression)))
     (ExpressionNoIn ";")
     )
    (OptExprStmt
     (";" ($$ '(NoExpression)))
     (Expression ";")
     )
    (OptExprClose
     (";" ($$ '(NoExpression)))
     (Expression ")")
     )

    (ContinueStatement
     ("continue" ($$ (NSI)) Identifier ";"
      ($$ `(ContinueStatement ,$3)))
     ("continue" ";" ($$ '(ContinueStatement)))
     )

    (BreakStatement
     ("break" ($$ (NSI)) Identifier ";"
      ($$ `(BreakStatement ,$3)))
     ("break" ";" ($$ '(BreakStatement)))
     )

    (ReturnStatement
     ("return" ($$ (NSI)) Expression ";"
      ($$ `(ReturnStatement ,$3)))
     ("return" ";" ($$ '(ReturnStatement)))
     )

    (WithStatement
     ("with" "(" Expression ")" Statement
      ($$ `(WithStatement ,$3 ,$5))))

    (SwitchStatement
     ("switch" "(" Expression ")" ($$ (NSI)) CaseBlock
      ($$ `(SwitchStatement ,$3 ,$6))))
    (CaseBlock
     ("{" CaseBlockTail ($$ $2))
     ("{" seq-of-semis CaseBlockTail ($$ $3)))
    (seq-of-semis (";") (seq-of-semis ";"))
    (CaseBlockTail
     ("}" ($$ '(CaseBlock)))
     (CaseClauses "}" ($$ `(CaseBlock ,(tl->list $1))))
     (CaseClauses DefaultClause "}" ($$ `(CaseBlock ,(tl->list $1) ,$2)))
     (CaseClauses DefaultClause CaseClauses "}"
      ($$ `(CaseBlock ,(tl->list $1) ,$2 ,(tl->list $3))))
     (DefaultClause CaseClauses "}" ($$ `(CaseBlock ,$1 ,(tl->list $2))))
     (DefaultClause "}" ($$ `(CaseBlock ,$1)))
     )
    (CaseClauses
     (CaseClause ($$ (make-tl 'CaseClauses $1)))
     (CaseClauses CaseClause ($$ (tl-append $1 $2)))
     )
    (CaseClause
     ("case" Expression ":" StatementList
      ($$ `(CaseClause ,$2 ,(tl->list $4))))
     ("case" Expression ":"
      ($$ `(CaseClause ,$2)))
     )
    (DefaultClause
      ("default" ":" StatementList
       ($$ `(DefaultClause ,(tl->list $3))))
      ("default" ":"
       ($$ `(DefaultClause)))
      )

    (LabelledStatement
     (Identifier ":" Statement
		 ($$ `(LabelledStatement ,$1 ,$3)))
     )

    (ThrowStatement
     ("throw" ($$ (NSI)) Expression ";"
      ($$ `(ThrowStatement ,$3)))
     )

    (TryStatement
     ("try" Block Catch
      ($$ `(TryStatement ,$2 ,$3)))
     ("try" Block Finally
      ($$ `(TryStatement ,$2 ,$3)))
     ("try" Block Catch Finally
      ($$ `(TryStatement ,$2 ,$3 ,$4)))
     )

    (Catch
     ("catch" "(" Identifier ")" Block
      ($$ `(Catch ,$3 ,$5)))
     )

    (Finally
     ("finally" Block
      ($$ `(Finally ,$2)))
     )

    ;;(DebuggerStatement ("debugger" ";"))

    ;; A.5
    (FunctionDeclaration
     ("function" Identifier "(" FormalParameterList ")" "{" FunctionBody "}"
      ($prec 'stmt)
      ($$ `(FunctionDeclaration ,$2 ,(tl->list $4) ,$7)))
     ("function" Identifier "(" ")" "{" FunctionBody "}"
      ($prec 'stmt)
      ($$ `(FunctionDeclaration ,$2 (FormalParameterList) ,$6)))
     )

    (FunctionExpression
     ("function" Identifier "(" FormalParameterList ")" "{" FunctionBody "}"
      ($prec 'expr)
      ($$ `(FunctionExpression ,$2 ,(tl->list $4) ,$7)))
     ("function" "(" FormalParameterList ")" "{" FunctionBody "}"
      ($prec 'expr)
      ($$ `(FunctionExpression ,(tl->list $3) ,$6)))
     ("function" Identifier "(" ")" "{" FunctionBody "}"
      ($prec 'expr)
      ($$ `(FunctionExpression ,$2 (FormalParameterList) ,$6)))
     ("function" "(" ")" "{" FunctionBody "}"
      ($prec 'expr)
      ($$ `(FunctionExpression (FormalParameterList) ,$5)))
     )

    (FormalParameterList
     (Identifier ($$ (make-tl 'FormalParameterList $1)))
     (FormalParameterList "," Identifier ($$ (tl-append $1 $3)))
     )

    (FunctionBody
     (SourceElements))

    (Program
     (SourceElements ($$ `(Program ,$1))))

    (SourceElements
     (SourceElements-1 ($$ (tl->list $1))))
    (SourceElements-1
     (SourceElement ($$ (make-tl 'SourceElements $1)))
     (SourceElements-1 SourceElement ($$ (tl-append $1 $2))))

    (SourceElement
     (Statement)
     (FunctionDeclaration))
    
    )))

(define js-mach
  (hashify-machine
   (compact-machine
    (make-lalr-machine js-spec))))

(define len-v (assq-ref js-mach 'len-v))
(define pat-v (assq-ref js-mach 'pat-v))
(define rto-v (assq-ref js-mach 'rto-v))
(define mtab (assq-ref js-mach 'mtab))
(define sya-v (vector-map (lambda (ix actn) (wrap-action actn))
			  (assq-ref js-mach 'act-v)))
(define act-v (vector-map (lambda (ix f) (eval f (current-module))) sya-v))

(include-from-path "nyacc/lang/javascript/body.scm")

(define raw-parser (make-lalr-parser js-mach))

(define* (dev-parse-js #:key debug)
  (catch
   'nyacc-error
   (lambda ()
     (with-fluid*
	 *insert-semi* #t
	 (lambda () (raw-parser (gen-js-lexer) #:debug debug))))
   (lambda (key fmt . args)
     (report-error fmt args)
     #f)))

;; ======= gen files

(define (gen-js-files . rest)
  (define (lang-dir path)
    (if (pair? rest) (string-append (car rest) "/" path) path))
  (define (xtra-dir path)
    (lang-dir (string-append "mach.d/" path)))

  (write-lalr-actions js-mach (xtra-dir "jsact.scm.new"))
  (write-lalr-tables js-mach (xtra-dir "jstab.scm.new"))
  (let ((a (move-if-changed (xtra-dir "jsact.scm.new")
			    (xtra-dir "jsact.scm")))
	(b (move-if-changed (xtra-dir "jstab.scm.new")
			    (xtra-dir "jstab.scm"))))
    ;;(when (or a b) (system (string-append "touch " (lang-dir "parser.scm"))))
    (or a b)))

(define (gen-se-files . rest)
  (define (lang-dir path)
    (if (pair? rest) (string-append (car rest) "/" path) path))
  (define (xtra-dir path)
    (lang-dir (string-append "mach.d/" path)))

  (let* ((se-spec (restart-spec js-spec 'SourceElements))
	 (se-mach (make-lalr-machine se-spec))
	 (se-mach (compact-machine se-mach))
	 (se-mach (hashify-machine se-mach)))
    (write-lalr-actions se-mach (xtra-dir "seact.scm.new"))
    (write-lalr-tables se-mach (xtra-dir "setab.scm.new")))
  
  (let ((a (move-if-changed (xtra-dir "seact.scm.new")
			    (xtra-dir "seact.scm")))
	(b (move-if-changed (xtra-dir "setab.scm.new")
			    (xtra-dir "setab.scm"))))
    ;;(when (or a b) (system (string-append "touch " (lang-dir "separser.scm"))))
    (or a b)))


;;; --- last line ---
