
(define gram
  (make-lalr-grammar
   (start file-input)
   ;;(start single-input)
   ;;(start eval-input)

   (grammar
    (file-input
     ("\n")
     (stmt)
     (file-input "\n")
     (file-input stmt)
     )
    (single-input
     ("\n")
     (simple-stmt)
     (compound-stmt "\n")
     )
    (eval-input
     (testlist)
     (eval-input "\n"))

    (decorator
     ("@" dotted-name opt-arg-list "\n"))
    (opt-arg-list
     ($empty)
     ("(" ")")
     ("(" arg-list ")"))
    (decorators
     (decorator)
     (decorators decorator))
    (decorated
     (decorators classdef)
     (decorators funcdef))

    (funcdef
     ("def" name parameters opt-test ":" suite))
    (opt-test ($empty) ("->" text))

    (parameters
     ("(" typedargslist ")")
     ("(" ")"))
    (typeargslist

;;  typedargslist: ((tfpdef ['=' test] ',')*
;;                  ('*' [tname] (',' tname ['=' test])* [',' '**' tname] | '**';;  ;;  ;;  ;;   tname)
;;                  | tfpdef ['=' test] (',' tfpdef ['=' test])* [','])
;;  tname: NAME [':' test]
;;  tfpdef: tname | '(' tfplist ')'
;;  tfplist: tfpdef (',' tfpdef)* [',']
;;  varargslist: ((vfpdef ['=' test] ',')*
;;                ('*' [vname] (',' vname ['=' test])*  [',' '**' vname] | '**' ;;  ;;  ;;  ;;  vname)
;;                | vfpdef ['=' test] (',' vfpdef ['=' test])* [','])
;;  vname: NAME
;;  vfpdef: vname | '(' vfplist ')'
;;  vfplist: vfpdef (',' vfpdef)* [',']
;;  
;;  stmt: simple_stmt | compound_stmt
;;  simple_stmt: small_stmt (';' small_stmt)* [';'] NEWLINE
;;  small_stmt: (expr_stmt | print_stmt  | del_stmt | pass_stmt | flow_stmt |
;;               import_stmt | global_stmt | exec_stmt | assert_stmt)
;;  expr_stmt: testlist_star_expr (augassign (yield_expr|testlist) |
;;                       ('=' (yield_expr|testlist_star_expr))*)
;;  testlist_star_expr: (test|star_expr) (',' (test|star_expr))* [',']
;;  augassign: ('+=' | '-=' | '*=' | '@=' | '/=' | '%=' | '&=' | '|=' | '^=' |
;;              '<<=' | '>>=' | '**=' | '//=')
;;  # For normal assignments, additional restrictions enforced by the interprete;;  ;;  ;;  ;;  ;;  ;;  r
;;  print_stmt: 'print' ( [ test (',' test)* [','] ] |
;;                        '>>' test [ (',' test)+ [','] ] )
;;  del_stmt: 'del' exprlist
;;  pass_stmt: 'pass'
;;  flow_stmt: break_stmt | continue_stmt | return_stmt | raise_stmt | yield_stm;;  ;;  ;;  ;;  ;;  t
;;  break_stmt: 'break'
;;  continue_stmt: 'continue'
;;  return_stmt: 'return' [testlist]
;;  yield_stmt: yield_expr
;;  raise_stmt: 'raise' [test ['from' test | ',' test [',' test]]]
;;  import_stmt: import_name | import_from
;;  import_name: 'import' dotted_as_names
;;  import_from: ('from' ('.'* dotted_name | '.'+)
;;                'import' ('*' | '(' import_as_names ')' | import_as_names))
;;  import_as_name: NAME ['as' NAME]
;;  dotted_as_name: dotted_name ['as' NAME]
;;  import_as_names: import_as_name (',' import_as_name)* [',']
;;  dotted_as_names: dotted_as_name (',' dotted_as_name)*
;;  dotted_name: NAME ('.' NAME)*
;;  global_stmt: ('global' | 'nonlocal') NAME (',' NAME)*
;;  exec_stmt: 'exec' expr ['in' test [',' test]]
;;  assert_stmt: 'assert' test [',' test]
;;  
;;  compound_stmt: if_stmt | while_stmt | for_stmt | try_stmt | with_stmt | func;;  def | classdef | decorated
;;  if_stmt: 'if' test ':' suite ('elif' test ':' suite)* ['else' ':' suite]
;;  while_stmt: 'while' test ':' suite ['else' ':' suite]
;;  for_stmt: 'for' exprlist 'in' testlist ':' suite ['else' ':' suite]
;;  try_stmt: ('try' ':' suite
;;             ((except_clause ':' suite)+
;;          ['else' ':' suite]
;;          ['finally' ':' suite] |
;;         'finally' ':' suite))
;;  with_stmt: 'with' with_item (',' with_item)*  ':' suite
;;  with_item: test ['as' expr]
;;  with_var: 'as' expr
;;   NB compile.c makes sure that the default except clause is last
;;  except_clause: 'except' [test [(',' | 'as') test]]
;;  suite: simple_stmt | NEWLINE INDENT stmt+ DEDENT
;;  
;;  # Backward compatibility cruft to support:
;;  # [ x for x in lambda: True, lambda: False if x() ]
;;  # even while also allowing:
;;  # lambda x: 5 if x else 2
;;  # (But not a mix of the two)
;;  testlist_safe: old_test [(',' old_test)+ [',']]
;;  old_test: or_test | old_lambdef
;;  old_lambdef: 'lambda' [varargslist] ':' old_test
;;  
;;  test: or_test ['if' or_test 'else' test] | lambdef
;;  or_test: and_test ('or' and_test)*
;;  and_test: not_test ('and' not_test)*
;;  not_test: 'not' not_test | comparison
;;  comparison: expr (comp_op expr)*
;;  comp_op: '<'|'>'|'=='|'>='|'<='|'<>'|'!='|'in'|'not' 'in'|'is'|'is' 'not'
;;  star_expr: '*' expr
;;  expr: xor_expr ('|' xor_expr)*
;;  xor_expr: and_expr ('^' and_expr)*
;;  and_expr: shift_expr ('&' shift_expr)*
;;  shift_expr: arith_expr (('<<'|'>>') arith_expr)*
;;  arith_expr: term (('+'|'-') term)*
;;  term: factor (('*'|'@'|'/'|'%'|'//') factor)*
;;  factor: ('+'|'-'|'~') factor | power
;;  power: atom trailer* ['**' factor]
;;  atom: ('(' [yield_expr|testlist_gexp] ')' |
;;         '[' [listmaker] ']' |
;;         '{' [dictsetmaker] '}' |
;;         '`' testlist1 '`' |
;;         NAME | NUMBER | STRING+ | '.' '.' '.')
;;  listmaker: (test|star_expr) ( comp_for | (',' (test|star_expr))* [','] )
;;  testlist_gexp: (test|star_expr) ( comp_for | (',' (test|star_expr))* [','] )
;;  lambdef: 'lambda' [varargslist] ':' test
;;  trailer: '(' [arglist] ')' | '[' subscriptlist ']' | '.' NAME
;;  subscriptlist: subscript (',' subscript)* [',']
;;  subscript: test | [test] ':' [test] [sliceop]
;;  sliceop: ':' [test]
;;  exprlist: (expr|star_expr) (',' (expr|star_expr))* [',']
;;  testlist: test (',' test)* [',']
;;  dictsetmaker: ( (test ':' test (comp_for | (',' test ':' test)* [','])) |
;;                  (test (comp_for | (',' test)* [','])) )
;;  
;;  classdef: 'class' NAME ['(' [arglist] ')'] ':' suite
;;  
;;  arglist: (argument ',')* (argument [',']
;;                           |'*' test (',' argument)* [',' '**' test] 
;;                           |'**' test)
;;  argument: test [comp_for] | test '=' test  # Really [keyword '='] test
;;  
;;  comp_iter: comp_for | comp_if
;;  comp_for: 'for' exprlist 'in' testlist_safe [comp_iter]
;;  comp_if: 'if' old_test [comp_iter]
;;  
;;  testlist1: test (',' test)*
;;  
;;  # not used in grammar, but may appear in "node" passed from Parser to Compil;;  ;;  ;;  ;;  ;;  er
;;  encoding_decl: NAME
;;
;;  yield_expr: 'yield' [yield_arg];;  
;;  yield_arg: 'from' test | testlist
