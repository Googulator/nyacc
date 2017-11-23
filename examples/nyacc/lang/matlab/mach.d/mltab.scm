;; mach.d/mltab.scm

;; Copyright 2016 Matthew R. Wette
;; 
;; This software is covered by the GNU GENERAL PUBLIC LICENCE, Version 3,
;; or any later version published by the Free Software Foundation.  See
;; the file COPYING included with the this distribution.

(define len-v
  #(1 1 1 2 1 2 1 2 4 3 2 0 2 2 1 1 2 10 9 8 7 6 5 1 3 1 2 1 1 1 5 4 8 9 8 6 
    9 8 6 9 6 2 3 1 3 1 1 1 2 4 5 0 5 1 1 3 3 1 3 1 3 1 3 1 3 3 1 3 3 3 3 1 3 
    3 1 3 3 3 3 3 3 3 3 1 2 2 2 1 1 2 2 1 4 3 1 1 3 2 3 2 3 1 3 1 1 1 3 1 2 2 
    3 1 1 1 1 1 1 1 1))

(define pat-v
  #((($ident shift . 1) ($:function shift . 2) ($lone-comm shift . 3) 
    ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7
    ) ($:clear shift . 8) ($:global shift . 9) (function-decl-line shift . 10)
    (lone-comment shift . 11) (command shift . 12) ($:return shift . 13) 
    ($:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (function-decl shift . 21) (function-defn shift . 22) (
    non-comment-statement shift . 23) (lone-comment-list shift . 24) (
    function-file shift . 25) (script-file shift . 26) (mfile shift . 27)) 
    ((#{$:\x28;}# reduce . 114) ($:= reduce . 114) ($:. reduce . 114) (
    #\newline reduce . 114) (#{$:;}# reduce . 114) ($:, reduce . 114) ($ident 
    reduce . 114) ($:: reduce . 114) ($:| reduce . 114) ($:& reduce . 114) 
    ($:== reduce . 114) ($:~= reduce . 114) ($:>= reduce . 114) ($:<= reduce 
    . 114) ($:> reduce . 114) ($:< reduce . 114) ($:+ reduce . 114) ($:- 
    reduce . 114) ($:.^ reduce . 114) ($:.\ reduce . 114) ($:./ reduce . 114) 
    ($:.* reduce . 114) ($:^ reduce . 114) ($:\ reduce . 114) ($:/ reduce . 
    114) ($:* reduce . 114) ($:.' reduce . 114) ($:' reduce . 114) (
    #{$:\x5d;}# reduce . 114) (#{$:\x29;}# reduce . 114) (#{$:\x7d;}# reduce 
    . 114)) ((#{$:\x5b;}# shift . 72) ($ident shift . 1) (ident shift . 73)) 
    ((#\newline reduce . 118) ($:end reduce . 118) ($lone-comm reduce . 118) 
    ($:, reduce . 118) (#{$:;}# reduce . 118) ($ident reduce . 118) ($:clear 
    reduce . 118) ($:global reduce . 118) ($:return reduce . 118) ($:switch 
    reduce . 118) ($:if reduce . 118) ($:while reduce . 118) ($:for reduce . 
    118) (#{$:\x5b;}# reduce . 118) ($:else reduce . 118) ($:elseif reduce . 
    118) ($end reduce . 118) ($:function reduce . 118) ($:case reduce . 118) 
    ($:otherwise reduce . 118)) (($lone-comm reduce . 113) ($:, reduce . 113) 
    (#{$:;}# reduce . 113) (#\newline reduce . 113) ($ident reduce . 113) 
    ($:clear reduce . 113) ($:global reduce . 113) ($:return reduce . 113) 
    ($:switch reduce . 113) ($:if reduce . 113) ($:while reduce . 113) 
    ($:for reduce . 113) (#{$:\x5b;}# reduce . 113) ($:end reduce . 113) 
    ($:otherwise reduce . 113) ($:case reduce . 113) ($:else reduce . 113) 
    ($:elseif reduce . 113) ($end reduce . 113) ($:function reduce . 113)) 
    (($lone-comm reduce . 112) ($:, reduce . 112) (#{$:;}# reduce . 112) 
    (#\newline reduce . 112) ($ident reduce . 112) ($:clear reduce . 112) 
    ($:global reduce . 112) ($:return reduce . 112) ($:switch reduce . 112) 
    ($:if reduce . 112) ($:while reduce . 112) ($:for reduce . 112) (
    #{$:\x5b;}# reduce . 112) ($:end reduce . 112) ($:otherwise reduce . 112) 
    ($:case reduce . 112) ($:else reduce . 112) ($:elseif reduce . 112) 
    ($end reduce . 112) ($:function reduce . 112)) (($lone-comm reduce . 111) 
    ($:, reduce . 111) (#{$:;}# reduce . 111) (#\newline reduce . 111) 
    ($ident reduce . 111) ($:clear reduce . 111) ($:global reduce . 111) 
    ($:return reduce . 111) ($:switch reduce . 111) ($:if reduce . 111) 
    ($:while reduce . 111) ($:for reduce . 111) (#{$:\x5b;}# reduce . 111) 
    ($:end reduce . 111) ($:otherwise reduce . 111) ($:case reduce . 111) 
    ($:else reduce . 111) ($:elseif reduce . 111) ($end reduce . 111) (
    $:function reduce . 111)) (($:= reduce . 91) (#{$:\x28;}# reduce . 91) 
    ($:. reduce . 91) (#\newline reduce . 91) (#{$:;}# reduce . 91) ($:, 
    reduce . 91) ($:' reduce . 91) ($:.' reduce . 91) ($:* reduce . 91) 
    ($:/ reduce . 91) ($:\ reduce . 91) ($:^ reduce . 91) ($:.* reduce . 91) 
    ($:./ reduce . 91) ($:.\ reduce . 91) ($:.^ reduce . 91) ($:- reduce . 91)
    ($:+ reduce . 91) ($:< reduce . 91) ($:> reduce . 91) ($:<= reduce . 91) 
    ($:>= reduce . 91) ($:~= reduce . 91) ($:== reduce . 91) ($:& reduce . 91)
    ($:| reduce . 91) ($:: reduce . 91) (#{$:\x5d;}# reduce . 91) (#{$:\x29;}#
    reduce . 91) (#{$:\x7d;}# reduce . 91)) (($ident reduce . 46)) (($ident 
    reduce . 45)) (($lone-comm shift . 3) (lone-comment shift . 11) (
    lone-comment-list shift . 71) ($:end reduce . 14) ($:, reduce . 14) 
    (#{$:;}# reduce . 14) (#\newline reduce . 14) ($ident reduce . 14) 
    ($:clear reduce . 14) ($:global reduce . 14) ($:return reduce . 14) 
    ($:switch reduce . 14) ($:if reduce . 14) ($:while reduce . 14) ($:for 
    reduce . 14) (#{$:\x5b;}# reduce . 14) ($:function reduce . 14) ($end 
    reduce . 14)) ((#\newline shift . 70)) (($ident shift . 1) (ident shift . 
    68) (arg-list shift . 69)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline
    shift . 6) (term shift . 67)) (($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) (expr shift . 66)) (($string 
    shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) 
    (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48)
    (string shift . 49) (number shift . 50) (ident shift . 7) (primary-expr 
    shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) 
    ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift . 57) 
    (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) (
    equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 63) 
    (expr shift . 65)) (($string shift . 43) ($float shift . 44) ($fixed shift
    . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47)
    (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) (ident 
    shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 
    53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (
    unary-expr shift . 57) (mul-expr shift . 58) (add-expr shift . 59) 
    (rel-expr shift . 60) (equality-expr shift . 61) (and-expr shift . 62) 
    (or-expr shift . 63) (expr shift . 64)) (($ident shift . 1) (ident shift 
    . 42)) (($ident shift . 1) (ident shift . 7) (lval-expr shift . 40) 
    (lval-expr-list shift . 41)) (($:= shift . 37) (#{$:\x28;}# shift . 38) 
    ($:. shift . 39)) ((#{$:\x5b;}# reduce . 29) ($:for reduce . 29) ($:while 
    reduce . 29) ($:if reduce . 29) ($:switch reduce . 29) ($:return reduce . 
    29) ($:global reduce . 29) ($:clear reduce . 29) ($ident reduce . 29) 
    (#\newline reduce . 29) (#{$:;}# reduce . 29) ($:, reduce . 29) (
    $lone-comm reduce . 29) ($:end reduce . 29) ($:else reduce . 29) ($:elseif
    reduce . 29) ($end reduce . 29) ($:function reduce . 29) ($:case reduce . 
    29) ($:otherwise reduce . 29)) (($ident shift . 1) ($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift
    . 8) ($:global shift . 9) (command shift . 12) ($:return shift . 13) 
    ($:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 34) ($:end shift . 35) (opt-end shift . 36)
    ($end reduce . 11) ($:function reduce . 11)) (($:function reduce . 6) 
    ($end reduce . 6)) (($lone-comm reduce . 4) ($:, reduce . 4) (#{$:;}# 
    reduce . 4) (#\newline reduce . 4) ($ident reduce . 4) ($:clear reduce . 4
    ) ($:global reduce . 4) ($:return reduce . 4) ($:switch reduce . 4) 
    ($:if reduce . 4) ($:while reduce . 4) ($:for reduce . 4) (#{$:\x5b;}# 
    reduce . 4) ($end reduce . 4)) (($ident shift . 1) ($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift
    . 8) ($:global shift . 9) (command shift . 12) ($:return shift . 13) 
    ($:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 32) ($lone-comm shift . 3) (lone-comment 
    shift . 33)) (($:function shift . 2) (function-decl-line shift . 10) 
    (function-decl shift . 21) (function-defn shift . 31) ($end reduce . 2)) 
    (($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift 
    . 6) (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) (
    $lone-comm shift . 3) (command shift . 12) ($:return shift . 13) ($:switch
    shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift . 17) 
    (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) (
    non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 30) ($end reduce . 1)) (($end accept . 0)) (($:end reduce . 28) 
    (#{$:\x5b;}# reduce . 28) ($:for reduce . 28) ($:while reduce . 28) 
    ($:if reduce . 28) ($:switch reduce . 28) ($:return reduce . 28) ($:global
    reduce . 28) ($:clear reduce . 28) ($ident reduce . 28) (#\newline reduce 
    . 28) (#{$:;}# reduce . 28) ($:, reduce . 28) ($lone-comm reduce . 28) 
    ($:else reduce . 28) ($:elseif reduce . 28) ($end reduce . 28) ($:function
    reduce . 28) ($:case reduce . 28) ($:otherwise reduce . 28)) (($:end 
    reduce . 27) (#{$:\x5b;}# reduce . 27) ($:for reduce . 27) ($:while reduce
    . 27) ($:if reduce . 27) ($:switch reduce . 27) ($:return reduce . 27) 
    ($:global reduce . 27) ($:clear reduce . 27) ($ident reduce . 27) (
    #\newline reduce . 27) (#{$:;}# reduce . 27) ($:, reduce . 27) ($lone-comm
    reduce . 27) ($:else reduce . 27) ($:elseif reduce . 27) ($end reduce . 27
    ) ($:function reduce . 27) ($:case reduce . 27) ($:otherwise reduce . 27))
    (($lone-comm reduce . 5) ($:, reduce . 5) (#{$:;}# reduce . 5) (#\newline 
    reduce . 5) ($ident reduce . 5) ($:clear reduce . 5) ($:global reduce . 5)
    ($:return reduce . 5) ($:switch reduce . 5) ($:if reduce . 5) ($:while 
    reduce . 5) ($:for reduce . 5) (#{$:\x5b;}# reduce . 5) ($end reduce . 5))
    (($:function reduce . 7) ($end reduce . 7)) (($lone-comm reduce . 3) 
    ($:, reduce . 3) (#{$:;}# reduce . 3) (#\newline reduce . 3) ($ident 
    reduce . 3) ($:clear reduce . 3) ($:global reduce . 3) ($:return reduce . 
    3) ($:switch reduce . 3) ($:if reduce . 3) ($:while reduce . 3) ($:for 
    reduce . 3) (#{$:\x5b;}# reduce . 3) ($end reduce . 3)) ((#\newline shift 
    . 128)) (($:end shift . 35) (opt-end shift . 125) ($ident shift . 1) 
    ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7
    ) ($:clear shift . 8) ($:global shift . 9) ($lone-comm shift . 3) (command
    shift . 12) ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) 
    ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (
    lval-expr shift . 19) (term shift . 20) (non-comment-statement shift . 28)
    (lone-comment shift . 29) (statement shift . 126) (statement-list shift . 
    127) ($end reduce . 11) ($:function reduce . 11)) (($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 123) (term-list 
    shift . 124)) (($:function reduce . 10) ($end reduce . 10)) (($string 
    shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) 
    (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48)
    (string shift . 49) (number shift . 50) (ident shift . 7) (primary-expr 
    shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) 
    ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift . 57) 
    (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) (
    equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 63) 
    (expr shift . 122)) (($string shift . 43) ($float shift . 44) ($fixed 
    shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift
    . 47) (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) 
    (ident shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) 
    ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 
    56) (unary-expr shift . 57) (mul-expr shift . 58) (add-expr shift . 59) 
    (rel-expr shift . 60) (equality-expr shift . 61) (and-expr shift . 62) 
    (or-expr shift . 63) ($:: shift . 119) (expr shift . 120) (expr-list shift
    . 121)) (($ident shift . 1) (ident shift . 118)) ((#{$:\x28;}# shift . 107
    ) ($:. shift . 39) (#{$:\x5d;}# reduce . 43) ($:, reduce . 43)) (($:, 
    shift . 116) (#{$:\x5d;}# shift . 117)) (($:= shift . 115)) (($:, reduce 
    . 117) (#{$:;}# reduce . 117) (#\newline reduce . 117) ($:: reduce . 117) 
    ($:| reduce . 117) ($:& reduce . 117) ($:== reduce . 117) ($:~= reduce . 
    117) ($:>= reduce . 117) ($:<= reduce . 117) ($:> reduce . 117) ($:< 
    reduce . 117) ($:+ reduce . 117) ($:- reduce . 117) ($:.^ reduce . 117) 
    ($:.\ reduce . 117) ($:./ reduce . 117) ($:.* reduce . 117) ($:^ reduce . 
    117) ($:\ reduce . 117) ($:/ reduce . 117) ($:* reduce . 117) ($:.' reduce
    . 117) ($:' reduce . 117) (#{$:\x29;}# reduce . 117) (#{$:\x7d;}# reduce 
    . 117) (#{$:\x5d;}# reduce . 117)) (($:, reduce . 116) (#{$:;}# reduce . 
    116) (#\newline reduce . 116) ($:: reduce . 116) ($:| reduce . 116) 
    ($:& reduce . 116) ($:== reduce . 116) ($:~= reduce . 116) ($:>= reduce . 
    116) ($:<= reduce . 116) ($:> reduce . 116) ($:< reduce . 116) ($:+ reduce
    . 116) ($:- reduce . 116) ($:.^ reduce . 116) ($:.\ reduce . 116) ($:./ 
    reduce . 116) ($:.* reduce . 116) ($:^ reduce . 116) ($:\ reduce . 116) 
    ($:/ reduce . 116) ($:* reduce . 116) ($:.' reduce . 116) ($:' reduce . 
    116) (#{$:\x29;}# reduce . 116) (#{$:\x7d;}# reduce . 116) (#{$:\x5d;}# 
    reduce . 116)) (($:, reduce . 115) (#{$:;}# reduce . 115) (#\newline 
    reduce . 115) ($:: reduce . 115) ($:| reduce . 115) ($:& reduce . 115) 
    ($:== reduce . 115) ($:~= reduce . 115) ($:>= reduce . 115) ($:<= reduce 
    . 115) ($:> reduce . 115) ($:< reduce . 115) ($:+ reduce . 115) ($:- 
    reduce . 115) ($:.^ reduce . 115) ($:.\ reduce . 115) ($:./ reduce . 115) 
    ($:.* reduce . 115) ($:^ reduce . 115) ($:\ reduce . 115) ($:/ reduce . 
    115) ($:* reduce . 115) ($:.' reduce . 115) ($:' reduce . 115) (
    #{$:\x29;}# reduce . 115) (#{$:\x7d;}# reduce . 115) (#{$:\x5d;}# reduce 
    . 115)) ((#{$:\x7d;}# shift . 113) ($string shift . 43) ($float shift . 44
    ) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) (expr shift . 110) (matrix-row 
    shift . 111) (matrix-row-list shift . 114)) ((#{$:\x5d;}# shift . 109) 
    ($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident shift
    . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift 
    . 48) (string shift . 49) (number shift . 50) (ident shift . 7) (
    primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) 
    (equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 63) 
    (expr shift . 110) (matrix-row shift . 111) (matrix-row-list shift . 112))
    (($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident 
    shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# 
    shift . 48) (string shift . 49) (number shift . 50) (ident shift . 7) 
    (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) 
    (equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 63) 
    (expr shift . 108)) ((#\newline reduce . 95) (#{$:;}# reduce . 95) 
    ($:, reduce . 95) ($:' reduce . 95) ($:.' reduce . 95) ($:* reduce . 95) 
    ($:/ reduce . 95) ($:\ reduce . 95) ($:^ reduce . 95) ($:.* reduce . 95) 
    ($:./ reduce . 95) ($:.\ reduce . 95) ($:.^ reduce . 95) ($:- reduce . 95)
    ($:+ reduce . 95) ($:< reduce . 95) ($:> reduce . 95) ($:<= reduce . 95) 
    ($:>= reduce . 95) ($:~= reduce . 95) ($:== reduce . 95) ($:& reduce . 95)
    ($:| reduce . 95) ($:: reduce . 95) (#{$:\x29;}# reduce . 95) (#{$:\x7d;}#
    reduce . 95) (#{$:\x5d;}# reduce . 95)) ((#\newline reduce . 94) (#{$:;}# 
    reduce . 94) ($:, reduce . 94) ($:' reduce . 94) ($:.' reduce . 94) 
    ($:* reduce . 94) ($:/ reduce . 94) ($:\ reduce . 94) ($:^ reduce . 94) 
    ($:.* reduce . 94) ($:./ reduce . 94) ($:.\ reduce . 94) ($:.^ reduce . 94
    ) ($:- reduce . 94) ($:+ reduce . 94) ($:< reduce . 94) ($:> reduce . 94) 
    ($:<= reduce . 94) ($:>= reduce . 94) ($:~= reduce . 94) ($:== reduce . 94
    ) ($:& reduce . 94) ($:| reduce . 94) ($:: reduce . 94) (#{$:\x29;}# 
    reduce . 94) (#{$:\x7d;}# reduce . 94) (#{$:\x5d;}# reduce . 94)) (
    ($:, reduce . 88) (#{$:;}# reduce . 88) (#\newline reduce . 88) ($:: 
    reduce . 88) ($:| reduce . 88) ($:& reduce . 88) ($:== reduce . 88) 
    ($:~= reduce . 88) ($:>= reduce . 88) ($:<= reduce . 88) ($:> reduce . 88)
    ($:< reduce . 88) ($:+ reduce . 88) ($:- reduce . 88) ($:.^ reduce . 88) 
    ($:.\ reduce . 88) ($:./ reduce . 88) ($:.* reduce . 88) ($:^ reduce . 88)
    ($:\ reduce . 88) ($:/ reduce . 88) ($:* reduce . 88) ($:.' reduce . 88) 
    ($:' reduce . 88) (#{$:\x29;}# reduce . 88) (#{$:\x7d;}# reduce . 88) 
    (#{$:\x5d;}# reduce . 88)) ((#{$:\x28;}# shift . 107) ($:. shift . 39) 
    ($:, reduce . 87) (#{$:;}# reduce . 87) (#\newline reduce . 87) ($:: 
    reduce . 87) ($:| reduce . 87) ($:& reduce . 87) ($:== reduce . 87) 
    ($:~= reduce . 87) ($:>= reduce . 87) ($:<= reduce . 87) ($:> reduce . 87)
    ($:< reduce . 87) ($:+ reduce . 87) ($:- reduce . 87) ($:.^ reduce . 87) 
    ($:.\ reduce . 87) ($:./ reduce . 87) ($:.* reduce . 87) ($:^ reduce . 87)
    ($:\ reduce . 87) ($:/ reduce . 87) ($:* reduce . 87) ($:.' reduce . 87) 
    ($:' reduce . 87) (#{$:\x29;}# reduce . 87) (#{$:\x7d;}# reduce . 87) 
    (#{$:\x5d;}# reduce . 87)) (($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) (postfix-expr shift . 106)) (($string shift . 43) ($float 
    shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46
    ) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) (postfix-expr shift . 105)) (($string shift . 43) ($float 
    shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46
    ) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) (postfix-expr shift . 104)) (($:' shift . 102) ($:.' shift . 
    103) (#\newline reduce . 83) (#{$:;}# reduce . 83) ($:, reduce . 83) 
    ($:* reduce . 83) ($:/ reduce . 83) ($:\ reduce . 83) ($:^ reduce . 83) 
    ($:.* reduce . 83) ($:./ reduce . 83) ($:.\ reduce . 83) ($:.^ reduce . 83
    ) ($:- reduce . 83) ($:+ reduce . 83) ($:< reduce . 83) ($:> reduce . 83) 
    ($:<= reduce . 83) ($:>= reduce . 83) ($:~= reduce . 83) ($:== reduce . 83
    ) ($:& reduce . 83) ($:| reduce . 83) ($:: reduce . 83) (#{$:\x29;}# 
    reduce . 83) (#{$:\x7d;}# reduce . 83) (#{$:\x5d;}# reduce . 83)) (
    ($:, reduce . 74) (#{$:;}# reduce . 74) (#\newline reduce . 74) ($:: 
    reduce . 74) ($:| reduce . 74) ($:& reduce . 74) ($:== reduce . 74) 
    ($:~= reduce . 74) ($:>= reduce . 74) ($:<= reduce . 74) ($:> reduce . 74)
    ($:< reduce . 74) ($:+ reduce . 74) ($:- reduce . 74) ($:.^ reduce . 74) 
    ($:.\ reduce . 74) ($:./ reduce . 74) ($:.* reduce . 74) ($:^ reduce . 74)
    ($:\ reduce . 74) ($:/ reduce . 74) ($:* reduce . 74) (#{$:\x29;}# reduce 
    . 74) (#{$:\x7d;}# reduce . 74) (#{$:\x5d;}# reduce . 74)) (($:* shift . 
    94) ($:/ shift . 95) ($:\ shift . 96) ($:^ shift . 97) ($:.* shift . 98) 
    ($:./ shift . 99) ($:.\ shift . 100) ($:.^ shift . 101) (#\newline reduce 
    . 71) (#{$:;}# reduce . 71) ($:, reduce . 71) ($:- reduce . 71) ($:+ 
    reduce . 71) ($:< reduce . 71) ($:> reduce . 71) ($:<= reduce . 71) 
    ($:>= reduce . 71) ($:~= reduce . 71) ($:== reduce . 71) ($:& reduce . 71)
    ($:| reduce . 71) ($:: reduce . 71) (#{$:\x29;}# reduce . 71) (#{$:\x7d;}#
    reduce . 71) (#{$:\x5d;}# reduce . 71)) (($:+ shift . 92) ($:- shift . 93)
    ($:, reduce . 66) (#{$:;}# reduce . 66) (#\newline reduce . 66) ($:: 
    reduce . 66) ($:| reduce . 66) ($:& reduce . 66) ($:== reduce . 66) 
    ($:~= reduce . 66) ($:>= reduce . 66) ($:<= reduce . 66) ($:> reduce . 66)
    ($:< reduce . 66) (#{$:\x29;}# reduce . 66) (#{$:\x7d;}# reduce . 66) 
    (#{$:\x5d;}# reduce . 66)) (($:< shift . 88) ($:> shift . 89) ($:<= shift 
    . 90) ($:>= shift . 91) (#\newline reduce . 63) (#{$:;}# reduce . 63) 
    ($:, reduce . 63) ($:~= reduce . 63) ($:== reduce . 63) ($:& reduce . 63) 
    ($:| reduce . 63) ($:: reduce . 63) (#{$:\x29;}# reduce . 63) (#{$:\x7d;}#
    reduce . 63) (#{$:\x5d;}# reduce . 63)) (($:== shift . 86) ($:~= shift . 
    87) ($:, reduce . 61) (#{$:;}# reduce . 61) (#\newline reduce . 61) 
    ($:: reduce . 61) ($:| reduce . 61) ($:& reduce . 61) (#{$:\x29;}# reduce 
    . 61) (#{$:\x7d;}# reduce . 61) (#{$:\x5d;}# reduce . 61)) (($:& shift . 
    85) (#\newline reduce . 59) (#{$:;}# reduce . 59) ($:, reduce . 59) 
    ($:| reduce . 59) ($:: reduce . 59) (#{$:\x29;}# reduce . 59) (#{$:\x7d;}#
    reduce . 59) (#{$:\x5d;}# reduce . 59)) (($:| shift . 84) ($:, reduce . 57
    ) (#{$:;}# reduce . 57) (#\newline reduce . 57) ($:: reduce . 57) (
    #{$:\x29;}# reduce . 57) (#{$:\x7d;}# reduce . 57) (#{$:\x5d;}# reduce . 
    57)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term 
    shift . 83) ($:: shift . 80)) (($:: shift . 80) ($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (term shift . 82)) (($:: shift . 80) 
    ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 81
    )) ((#{$:\x5b;}# reduce . 41) ($:for reduce . 41) ($:while reduce . 41) 
    ($:if reduce . 41) ($:switch reduce . 41) ($:return reduce . 41) ($:global
    reduce . 41) ($:clear reduce . 41) ($ident reduce . 41) (#\newline reduce 
    . 41) (#{$:;}# reduce . 41) ($:, reduce . 41) ($lone-comm reduce . 41) 
    ($:end reduce . 41) ($:else reduce . 41) ($:elseif reduce . 41) ($end 
    reduce . 41) ($:function reduce . 41) ($:case reduce . 41) ($:otherwise 
    reduce . 41)) (($:, reduce . 47) (#{$:;}# reduce . 47) (#\newline reduce 
    . 47) ($ident reduce . 47)) (($:, shift . 4) (#{$:;}# shift . 5) (
    #\newline shift . 6) (term shift . 78) ($ident shift . 1) (ident shift . 
    79)) (($:, reduce . 109) (#{$:;}# reduce . 109) (#\newline reduce . 109) 
    ($ident reduce . 109) ($:clear reduce . 109) ($:global reduce . 109) 
    ($:return reduce . 109) ($:switch reduce . 109) ($:if reduce . 109) 
    ($:while reduce . 109) ($:for reduce . 109) (#{$:\x5b;}# reduce . 109) 
    ($lone-comm reduce . 109) ($:end reduce . 109) ($:function reduce . 109) 
    ($end reduce . 109)) (($lone-comm shift . 3) (lone-comment shift . 33) 
    ($:end reduce . 13) ($:, reduce . 13) (#{$:;}# reduce . 13) (#\newline 
    reduce . 13) ($ident reduce . 13) ($:clear reduce . 13) ($:global reduce 
    . 13) ($:return reduce . 13) ($:switch reduce . 13) ($:if reduce . 13) 
    ($:while reduce . 13) ($:for reduce . 13) (#{$:\x5b;}# reduce . 13) 
    ($:function reduce . 13) ($end reduce . 13)) (($ident shift . 1) (ident 
    shift . 76) (ident-list shift . 77)) ((#{$:\x28;}# shift . 74) ($:= shift 
    . 75)) (($ident shift . 1) (ident shift . 76) (ident-list shift . 171) 
    (#{$:\x29;}# shift . 172)) (($ident shift . 1) (ident shift . 170)) 
    ((#{$:\x5d;}# reduce . 23) ($:, reduce . 23) (#{$:\x29;}# reduce . 23)) 
    (($:, shift . 168) (#{$:\x5d;}# shift . 169)) ((#{$:\x5b;}# reduce . 42) 
    ($:for reduce . 42) ($:while reduce . 42) ($:if reduce . 42) ($:switch 
    reduce . 42) ($:return reduce . 42) ($:global reduce . 42) ($:clear reduce
    . 42) ($ident reduce . 42) (#\newline reduce . 42) (#{$:;}# reduce . 42) 
    ($:, reduce . 42) ($lone-comm reduce . 42) ($:end reduce . 42) ($:else 
    reduce . 42) ($:elseif reduce . 42) ($end reduce . 42) ($:function reduce 
    . 42) ($:case reduce . 42) ($:otherwise reduce . 42)) (($:, reduce . 48) 
    (#{$:;}# reduce . 48) (#\newline reduce . 48) ($ident reduce . 48)) 
    (($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident 
    shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# 
    shift . 48) (string shift . 49) (number shift . 50) (ident shift . 7) 
    (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) 
    (equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 167)) 
    ((case-list shift . 166) ($:otherwise reduce . 51) ($:end reduce . 51) 
    ($:case reduce . 51)) (($ident shift . 1) ($:, shift . 4) (#{$:;}# shift 
    . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global
    shift . 9) ($lone-comm shift . 3) (command shift . 12) ($:return shift . 
    13) ($:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for 
    shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 
    20) (non-comment-statement shift . 28) (lone-comment shift . 29) (
    statement shift . 126) (statement-list shift . 165)) (($ident shift . 1) 
    ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7
    ) ($:clear shift . 8) ($:global shift . 9) ($lone-comm shift . 3) (command
    shift . 12) ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) 
    ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (
    lval-expr shift . 19) (term shift . 20) (non-comment-statement shift . 28)
    (lone-comment shift . 29) (statement shift . 126) (statement-list shift . 
    164)) (($string shift . 43) ($float shift . 44) ($fixed shift . 45) 
    ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) 
    (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) (ident 
    shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 
    53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (
    unary-expr shift . 57) (mul-expr shift . 58) (add-expr shift . 59) 
    (rel-expr shift . 60) (equality-expr shift . 61) (and-expr shift . 163)) 
    (($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident 
    shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# 
    shift . 48) (string shift . 49) (number shift . 50) (ident shift . 7) 
    (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) 
    (equality-expr shift . 162)) (($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 161)) (($string shift . 43) 
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 160)) (($string shift . 43) 
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 159)) (($string shift . 43) ($float shift . 44) ($fixed 
    shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift
    . 47) (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) 
    (ident shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) 
    ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 
    56) (unary-expr shift . 57) (mul-expr shift . 58) (add-expr shift . 158)) 
    (($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident 
    shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# 
    shift . 48) (string shift . 49) (number shift . 50) (ident shift . 7) 
    (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 157)) (($string shift . 43) 
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 156)) (($string shift . 43) ($float shift . 44) ($fixed 
    shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift
    . 47) (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) 
    (ident shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) 
    ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 
    56) (unary-expr shift . 57) (mul-expr shift . 155)) (($string shift . 43) 
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 154)
    ) (($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident 
    shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# 
    shift . 48) (string shift . 49) (number shift . 50) (ident shift . 7) 
    (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 153)) (($string shift . 43) ($float shift . 44) ($fixed shift . 45) 
    ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) 
    (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) (ident 
    shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 
    53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (
    unary-expr shift . 152)) (($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 151)) (($string shift . 43) 
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 150)) (($string shift . 43
    ) ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 149)) (($string shift . 43
    ) ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 148)) (($string shift . 43
    ) ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 147)) (($string shift . 43
    ) ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 146)) (($:, reduce . 89) 
    (#{$:;}# reduce . 89) (#\newline reduce . 89) ($:: reduce . 89) ($:| 
    reduce . 89) ($:& reduce . 89) ($:== reduce . 89) ($:~= reduce . 89) 
    ($:>= reduce . 89) ($:<= reduce . 89) ($:> reduce . 89) ($:< reduce . 89) 
    ($:+ reduce . 89) ($:- reduce . 89) ($:.^ reduce . 89) ($:.\ reduce . 89) 
    ($:./ reduce . 89) ($:.* reduce . 89) ($:^ reduce . 89) ($:\ reduce . 89) 
    ($:/ reduce . 89) ($:* reduce . 89) ($:.' reduce . 89) ($:' reduce . 89) 
    (#{$:\x29;}# reduce . 89) (#{$:\x7d;}# reduce . 89) (#{$:\x5d;}# reduce . 
    89)) (($:, reduce . 90) (#{$:;}# reduce . 90) (#\newline reduce . 90) 
    ($:: reduce . 90) ($:| reduce . 90) ($:& reduce . 90) ($:== reduce . 90) 
    ($:~= reduce . 90) ($:>= reduce . 90) ($:<= reduce . 90) ($:> reduce . 90)
    ($:< reduce . 90) ($:+ reduce . 90) ($:- reduce . 90) ($:.^ reduce . 90) 
    ($:.\ reduce . 90) ($:./ reduce . 90) ($:.* reduce . 90) ($:^ reduce . 90)
    ($:\ reduce . 90) ($:/ reduce . 90) ($:* reduce . 90) ($:.' reduce . 90) 
    ($:' reduce . 90) (#{$:\x29;}# reduce . 90) (#{$:\x7d;}# reduce . 90) 
    (#{$:\x5d;}# reduce . 90)) (($:' shift . 102) ($:.' shift . 103) (
    #\newline reduce . 84) (#{$:;}# reduce . 84) ($:, reduce . 84) ($:* reduce
    . 84) ($:/ reduce . 84) ($:\ reduce . 84) ($:^ reduce . 84) ($:.* reduce 
    . 84) ($:./ reduce . 84) ($:.\ reduce . 84) ($:.^ reduce . 84) ($:- reduce
    . 84) ($:+ reduce . 84) ($:< reduce . 84) ($:> reduce . 84) ($:<= reduce 
    . 84) ($:>= reduce . 84) ($:~= reduce . 84) ($:== reduce . 84) ($:& reduce
    . 84) ($:| reduce . 84) ($:: reduce . 84) (#{$:\x29;}# reduce . 84) 
    (#{$:\x7d;}# reduce . 84) (#{$:\x5d;}# reduce . 84)) (($:' shift . 102) 
    ($:.' shift . 103) (#\newline reduce . 85) (#{$:;}# reduce . 85) ($:, 
    reduce . 85) ($:* reduce . 85) ($:/ reduce . 85) ($:\ reduce . 85) 
    ($:^ reduce . 85) ($:.* reduce . 85) ($:./ reduce . 85) ($:.\ reduce . 85)
    ($:.^ reduce . 85) ($:- reduce . 85) ($:+ reduce . 85) ($:< reduce . 85) 
    ($:> reduce . 85) ($:<= reduce . 85) ($:>= reduce . 85) ($:~= reduce . 85)
    ($:== reduce . 85) ($:& reduce . 85) ($:| reduce . 85) ($:: reduce . 85) 
    (#{$:\x29;}# reduce . 85) (#{$:\x7d;}# reduce . 85) (#{$:\x5d;}# reduce . 
    85)) (($:' shift . 102) ($:.' shift . 103) (#\newline reduce . 86) 
    (#{$:;}# reduce . 86) ($:, reduce . 86) ($:* reduce . 86) ($:/ reduce . 86
    ) ($:\ reduce . 86) ($:^ reduce . 86) ($:.* reduce . 86) ($:./ reduce . 86
    ) ($:.\ reduce . 86) ($:.^ reduce . 86) ($:- reduce . 86) ($:+ reduce . 86
    ) ($:< reduce . 86) ($:> reduce . 86) ($:<= reduce . 86) ($:>= reduce . 86
    ) ($:~= reduce . 86) ($:== reduce . 86) ($:& reduce . 86) ($:| reduce . 86
    ) ($:: reduce . 86) (#{$:\x29;}# reduce . 86) (#{$:\x7d;}# reduce . 86) 
    (#{$:\x5d;}# reduce . 86)) (($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) ($:: shift . 119) (expr shift 
    . 120) (expr-list shift . 145)) ((#{$:\x29;}# shift . 144) ($:: shift . 80
    )) ((#\newline reduce . 97) (#{$:;}# reduce . 97) ($:, reduce . 97) 
    ($:' reduce . 97) ($:.' reduce . 97) ($:* reduce . 97) ($:/ reduce . 97) 
    ($:\ reduce . 97) ($:^ reduce . 97) ($:.* reduce . 97) ($:./ reduce . 97) 
    ($:.\ reduce . 97) ($:.^ reduce . 97) ($:- reduce . 97) ($:+ reduce . 97) 
    ($:< reduce . 97) ($:> reduce . 97) ($:<= reduce . 97) ($:>= reduce . 97) 
    ($:~= reduce . 97) ($:== reduce . 97) ($:& reduce . 97) ($:| reduce . 97) 
    ($:: reduce . 97) (#{$:\x29;}# reduce . 97) (#{$:\x7d;}# reduce . 97) 
    (#{$:\x5d;}# reduce . 97)) (($:: shift . 80) (#{$:\x7d;}# reduce . 105) 
    ($:, reduce . 105) (#{$:;}# reduce . 105) (#\newline reduce . 105) 
    (#{$:\x5d;}# reduce . 105)) (($:, shift . 143) (#{$:\x7d;}# reduce . 101) 
    (#\newline reduce . 101) (#{$:;}# reduce . 101) (#{$:\x5d;}# reduce . 101)
    ) ((#{$:\x5d;}# shift . 142) (#\newline shift . 139) (#{$:;}# shift . 140)
    (row-term shift . 141)) ((#\newline reduce . 99) (#{$:;}# reduce . 99) 
    ($:, reduce . 99) ($:' reduce . 99) ($:.' reduce . 99) ($:* reduce . 99) 
    ($:/ reduce . 99) ($:\ reduce . 99) ($:^ reduce . 99) ($:.* reduce . 99) 
    ($:./ reduce . 99) ($:.\ reduce . 99) ($:.^ reduce . 99) ($:- reduce . 99)
    ($:+ reduce . 99) ($:< reduce . 99) ($:> reduce . 99) ($:<= reduce . 99) 
    ($:>= reduce . 99) ($:~= reduce . 99) ($:== reduce . 99) ($:& reduce . 99)
    ($:| reduce . 99) ($:: reduce . 99) (#{$:\x29;}# reduce . 99) (#{$:\x7d;}#
    reduce . 99) (#{$:\x5d;}# reduce . 99)) ((#{$:\x7d;}# shift . 138) 
    (#\newline shift . 139) (#{$:;}# shift . 140) (row-term shift . 141)) 
    (($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident 
    shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# 
    shift . 48) (string shift . 49) (number shift . 50) (ident shift . 7) 
    (primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) 
    (equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 63) 
    (expr shift . 137)) (($ident shift . 1) (ident shift . 7) (lval-expr shift
    . 136)) (($:= shift . 135)) (($:= reduce . 93) (#{$:\x28;}# reduce . 93) 
    ($:. reduce . 93) (#{$:\x5d;}# reduce . 93) ($:, reduce . 93) (#\newline 
    reduce . 93) (#{$:;}# reduce . 93) ($:' reduce . 93) ($:.' reduce . 93) 
    ($:* reduce . 93) ($:/ reduce . 93) ($:\ reduce . 93) ($:^ reduce . 93) 
    ($:.* reduce . 93) ($:./ reduce . 93) ($:.\ reduce . 93) ($:.^ reduce . 93
    ) ($:- reduce . 93) ($:+ reduce . 93) ($:< reduce . 93) ($:> reduce . 93) 
    ($:<= reduce . 93) ($:>= reduce . 93) ($:~= reduce . 93) ($:== reduce . 93
    ) ($:& reduce . 93) ($:| reduce . 93) ($:: reduce . 93) (#{$:\x29;}# 
    reduce . 93) (#{$:\x7d;}# reduce . 93)) ((#{$:\x29;}# reduce . 54) 
    ($:, reduce . 54)) (($:: shift . 80) (#{$:\x29;}# reduce . 53) ($:, reduce
    . 53)) (($:, shift . 133) (#{$:\x29;}# shift . 134)) (($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 132) ($:: shift . 
    80)) (($:, reduce . 107) (#{$:;}# reduce . 107) (#\newline reduce . 107) 
    ($:function reduce . 107) ($end reduce . 107)) (($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (term shift . 131) ($:function reduce . 
    12) ($end reduce . 12)) (($:function reduce . 9) ($end reduce . 9)) 
    (($:end reduce . 25) ($lone-comm reduce . 25) ($:, reduce . 25) (#{$:;}# 
    reduce . 25) (#\newline reduce . 25) ($ident reduce . 25) ($:clear reduce 
    . 25) ($:global reduce . 25) ($:return reduce . 25) ($:switch reduce . 25)
    ($:if reduce . 25) ($:while reduce . 25) ($:for reduce . 25) (#{$:\x5b;}# 
    reduce . 25) ($:else reduce . 25) ($:elseif reduce . 25) ($:function 
    reduce . 25) ($end reduce . 25) ($:case reduce . 25) ($:otherwise reduce 
    . 25)) (($:end shift . 35) (opt-end shift . 129) ($ident shift . 1) 
    ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7
    ) ($:clear shift . 8) ($:global shift . 9) ($lone-comm shift . 3) (command
    shift . 12) ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) 
    ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (
    lval-expr shift . 19) (term shift . 20) (non-comment-statement shift . 28)
    (lone-comment shift . 29) (statement shift . 130) ($end reduce . 11) 
    ($:function reduce . 11)) (($:, reduce . 110) (#{$:;}# reduce . 110) 
    (#\newline reduce . 110) ($ident reduce . 110) ($:clear reduce . 110) 
    ($:global reduce . 110) ($:return reduce . 110) ($:switch reduce . 110) 
    ($:if reduce . 110) ($:while reduce . 110) ($:for reduce . 110) (
    #{$:\x5b;}# reduce . 110) ($lone-comm reduce . 110) ($:end reduce . 110) 
    ($:function reduce . 110) ($end reduce . 110)) (($:function reduce . 8) 
    ($end reduce . 8)) (($:end reduce . 26) ($lone-comm reduce . 26) ($:, 
    reduce . 26) (#{$:;}# reduce . 26) (#\newline reduce . 26) ($ident reduce 
    . 26) ($:clear reduce . 26) ($:global reduce . 26) ($:return reduce . 26) 
    ($:switch reduce . 26) ($:if reduce . 26) ($:while reduce . 26) ($:for 
    reduce . 26) (#{$:\x5b;}# reduce . 26) ($:function reduce . 26) ($end 
    reduce . 26) ($:else reduce . 26) ($:elseif reduce . 26) ($:case reduce . 
    26) ($:otherwise reduce . 26)) (($:, reduce . 108) (#{$:;}# reduce . 108) 
    (#\newline reduce . 108) ($:function reduce . 108) ($end reduce . 108)) 
    ((#{$:\x5b;}# reduce . 31) ($:for reduce . 31) ($:while reduce . 31) 
    ($:if reduce . 31) ($:switch reduce . 31) ($:return reduce . 31) ($:global
    reduce . 31) ($:clear reduce . 31) ($ident reduce . 31) (#\newline reduce 
    . 31) (#{$:;}# reduce . 31) ($:, reduce . 31) ($lone-comm reduce . 31) 
    ($:end reduce . 31) ($:else reduce . 31) ($:elseif reduce . 31) ($end 
    reduce . 31) ($:function reduce . 31) ($:case reduce . 31) ($:otherwise 
    reduce . 31)) (($:: shift . 192) ($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) (expr shift . 193)) (($:, shift
    . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 191) ($:= 
    reduce . 92) (#{$:\x28;}# reduce . 92) ($:. reduce . 92)) (($ident shift 
    . 1) (ident shift . 190)) ((#{$:\x28;}# shift . 107) ($:. shift . 39) 
    (#{$:\x5d;}# reduce . 44) ($:, reduce . 44)) (($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (term shift . 189) ($:: shift . 80)) 
    ((#\newline reduce . 100) (#{$:;}# reduce . 100) ($:, reduce . 100) 
    ($:' reduce . 100) ($:.' reduce . 100) ($:* reduce . 100) ($:/ reduce . 
    100) ($:\ reduce . 100) ($:^ reduce . 100) ($:.* reduce . 100) ($:./ 
    reduce . 100) ($:.\ reduce . 100) ($:.^ reduce . 100) ($:- reduce . 100) 
    ($:+ reduce . 100) ($:< reduce . 100) ($:> reduce . 100) ($:<= reduce . 
    100) ($:>= reduce . 100) ($:~= reduce . 100) ($:== reduce . 100) ($:& 
    reduce . 100) ($:| reduce . 100) ($:: reduce . 100) (#{$:\x29;}# reduce . 
    100) (#{$:\x7d;}# reduce . 100) (#{$:\x5d;}# reduce . 100)) (($ident 
    reduce . 104) ($float reduce . 104) ($fixed reduce . 104) ($string reduce 
    . 104) (#{$:\x7b;}# reduce . 104) (#{$:\x5b;}# reduce . 104) (#{$:\x28;}# 
    reduce . 104) ($:~ reduce . 104) ($:+ reduce . 104) ($:- reduce . 104)) 
    (($ident reduce . 103) ($float reduce . 103) ($fixed reduce . 103) 
    ($string reduce . 103) (#{$:\x7b;}# reduce . 103) (#{$:\x5b;}# reduce . 
    103) (#{$:\x28;}# reduce . 103) ($:~ reduce . 103) ($:+ reduce . 103) 
    ($:- reduce . 103)) (($string shift . 43) ($float shift . 44) ($fixed 
    shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift
    . 47) (#{$:\x28;}# shift . 48) (string shift . 49) (number shift . 50) 
    (ident shift . 7) (primary-expr shift . 51) (lval-expr shift . 52) 
    ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (postfix-expr shift . 
    56) (unary-expr shift . 57) (mul-expr shift . 58) (add-expr shift . 59) 
    (rel-expr shift . 60) (equality-expr shift . 61) (and-expr shift . 62) 
    (or-expr shift . 63) (expr shift . 110) (matrix-row shift . 188)) (
    (#\newline reduce . 98) (#{$:;}# reduce . 98) ($:, reduce . 98) ($:' 
    reduce . 98) ($:.' reduce . 98) ($:* reduce . 98) ($:/ reduce . 98) 
    ($:\ reduce . 98) ($:^ reduce . 98) ($:.* reduce . 98) ($:./ reduce . 98) 
    ($:.\ reduce . 98) ($:.^ reduce . 98) ($:- reduce . 98) ($:+ reduce . 98) 
    ($:< reduce . 98) ($:> reduce . 98) ($:<= reduce . 98) ($:>= reduce . 98) 
    ($:~= reduce . 98) ($:== reduce . 98) ($:& reduce . 98) ($:| reduce . 98) 
    ($:: reduce . 98) (#{$:\x29;}# reduce . 98) (#{$:\x7d;}# reduce . 98) 
    (#{$:\x5d;}# reduce . 98)) (($string shift . 43) ($float shift . 44) 
    ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46) (
    #{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) (expr shift . 187)) ((#\newline
    reduce . 96) (#{$:;}# reduce . 96) ($:, reduce . 96) ($:' reduce . 96) 
    ($:.' reduce . 96) ($:* reduce . 96) ($:/ reduce . 96) ($:\ reduce . 96) 
    ($:^ reduce . 96) ($:.* reduce . 96) ($:./ reduce . 96) ($:.\ reduce . 96)
    ($:.^ reduce . 96) ($:- reduce . 96) ($:+ reduce . 96) ($:< reduce . 96) 
    ($:> reduce . 96) ($:<= reduce . 96) ($:>= reduce . 96) ($:~= reduce . 96)
    ($:== reduce . 96) ($:& reduce . 96) ($:| reduce . 96) ($:: reduce . 96) 
    (#{$:\x29;}# reduce . 96) (#{$:\x7d;}# reduce . 96) (#{$:\x5d;}# reduce . 
    96)) ((#{$:\x29;}# shift . 186) ($:, shift . 133)) (($:, reduce . 82) 
    (#{$:;}# reduce . 82) (#\newline reduce . 82) ($:: reduce . 82) ($:| 
    reduce . 82) ($:& reduce . 82) ($:== reduce . 82) ($:~= reduce . 82) 
    ($:>= reduce . 82) ($:<= reduce . 82) ($:> reduce . 82) ($:< reduce . 82) 
    ($:+ reduce . 82) ($:- reduce . 82) ($:.^ reduce . 82) ($:.\ reduce . 82) 
    ($:./ reduce . 82) ($:.* reduce . 82) ($:^ reduce . 82) ($:\ reduce . 82) 
    ($:/ reduce . 82) ($:* reduce . 82) (#{$:\x29;}# reduce . 82) (#{$:\x7d;}#
    reduce . 82) (#{$:\x5d;}# reduce . 82)) (($:, reduce . 81) (#{$:;}# reduce
    . 81) (#\newline reduce . 81) ($:: reduce . 81) ($:| reduce . 81) ($:& 
    reduce . 81) ($:== reduce . 81) ($:~= reduce . 81) ($:>= reduce . 81) 
    ($:<= reduce . 81) ($:> reduce . 81) ($:< reduce . 81) ($:+ reduce . 81) 
    ($:- reduce . 81) ($:.^ reduce . 81) ($:.\ reduce . 81) ($:./ reduce . 81)
    ($:.* reduce . 81) ($:^ reduce . 81) ($:\ reduce . 81) ($:/ reduce . 81) 
    ($:* reduce . 81) (#{$:\x29;}# reduce . 81) (#{$:\x7d;}# reduce . 81) 
    (#{$:\x5d;}# reduce . 81)) (($:, reduce . 80) (#{$:;}# reduce . 80) 
    (#\newline reduce . 80) ($:: reduce . 80) ($:| reduce . 80) ($:& reduce . 
    80) ($:== reduce . 80) ($:~= reduce . 80) ($:>= reduce . 80) ($:<= reduce 
    . 80) ($:> reduce . 80) ($:< reduce . 80) ($:+ reduce . 80) ($:- reduce . 
    80) ($:.^ reduce . 80) ($:.\ reduce . 80) ($:./ reduce . 80) ($:.* reduce 
    . 80) ($:^ reduce . 80) ($:\ reduce . 80) ($:/ reduce . 80) ($:* reduce . 
    80) (#{$:\x29;}# reduce . 80) (#{$:\x7d;}# reduce . 80) (#{$:\x5d;}# 
    reduce . 80)) (($:, reduce . 79) (#{$:;}# reduce . 79) (#\newline reduce 
    . 79) ($:: reduce . 79) ($:| reduce . 79) ($:& reduce . 79) ($:== reduce 
    . 79) ($:~= reduce . 79) ($:>= reduce . 79) ($:<= reduce . 79) ($:> reduce
    . 79) ($:< reduce . 79) ($:+ reduce . 79) ($:- reduce . 79) ($:.^ reduce 
    . 79) ($:.\ reduce . 79) ($:./ reduce . 79) ($:.* reduce . 79) ($:^ reduce
    . 79) ($:\ reduce . 79) ($:/ reduce . 79) ($:* reduce . 79) (#{$:\x29;}# 
    reduce . 79) (#{$:\x7d;}# reduce . 79) (#{$:\x5d;}# reduce . 79)) (
    ($:, reduce . 78) (#{$:;}# reduce . 78) (#\newline reduce . 78) ($:: 
    reduce . 78) ($:| reduce . 78) ($:& reduce . 78) ($:== reduce . 78) 
    ($:~= reduce . 78) ($:>= reduce . 78) ($:<= reduce . 78) ($:> reduce . 78)
    ($:< reduce . 78) ($:+ reduce . 78) ($:- reduce . 78) ($:.^ reduce . 78) 
    ($:.\ reduce . 78) ($:./ reduce . 78) ($:.* reduce . 78) ($:^ reduce . 78)
    ($:\ reduce . 78) ($:/ reduce . 78) ($:* reduce . 78) (#{$:\x29;}# reduce 
    . 78) (#{$:\x7d;}# reduce . 78) (#{$:\x5d;}# reduce . 78)) (($:, reduce . 
    77) (#{$:;}# reduce . 77) (#\newline reduce . 77) ($:: reduce . 77) 
    ($:| reduce . 77) ($:& reduce . 77) ($:== reduce . 77) ($:~= reduce . 77) 
    ($:>= reduce . 77) ($:<= reduce . 77) ($:> reduce . 77) ($:< reduce . 77) 
    ($:+ reduce . 77) ($:- reduce . 77) ($:.^ reduce . 77) ($:.\ reduce . 77) 
    ($:./ reduce . 77) ($:.* reduce . 77) ($:^ reduce . 77) ($:\ reduce . 77) 
    ($:/ reduce . 77) ($:* reduce . 77) (#{$:\x29;}# reduce . 77) (#{$:\x7d;}#
    reduce . 77) (#{$:\x5d;}# reduce . 77)) (($:, reduce . 76) (#{$:;}# reduce
    . 76) (#\newline reduce . 76) ($:: reduce . 76) ($:| reduce . 76) ($:& 
    reduce . 76) ($:== reduce . 76) ($:~= reduce . 76) ($:>= reduce . 76) 
    ($:<= reduce . 76) ($:> reduce . 76) ($:< reduce . 76) ($:+ reduce . 76) 
    ($:- reduce . 76) ($:.^ reduce . 76) ($:.\ reduce . 76) ($:./ reduce . 76)
    ($:.* reduce . 76) ($:^ reduce . 76) ($:\ reduce . 76) ($:/ reduce . 76) 
    ($:* reduce . 76) (#{$:\x29;}# reduce . 76) (#{$:\x7d;}# reduce . 76) 
    (#{$:\x5d;}# reduce . 76)) (($:, reduce . 75) (#{$:;}# reduce . 75) 
    (#\newline reduce . 75) ($:: reduce . 75) ($:| reduce . 75) ($:& reduce . 
    75) ($:== reduce . 75) ($:~= reduce . 75) ($:>= reduce . 75) ($:<= reduce 
    . 75) ($:> reduce . 75) ($:< reduce . 75) ($:+ reduce . 75) ($:- reduce . 
    75) ($:.^ reduce . 75) ($:.\ reduce . 75) ($:./ reduce . 75) ($:.* reduce 
    . 75) ($:^ reduce . 75) ($:\ reduce . 75) ($:/ reduce . 75) ($:* reduce . 
    75) (#{$:\x29;}# reduce . 75) (#{$:\x7d;}# reduce . 75) (#{$:\x5d;}# 
    reduce . 75)) (($:* shift . 94) ($:/ shift . 95) ($:\ shift . 96) ($:^ 
    shift . 97) ($:.* shift . 98) ($:./ shift . 99) ($:.\ shift . 100) 
    ($:.^ shift . 101) (#\newline reduce . 73) (#{$:;}# reduce . 73) ($:, 
    reduce . 73) ($:- reduce . 73) ($:+ reduce . 73) ($:< reduce . 73) 
    ($:> reduce . 73) ($:<= reduce . 73) ($:>= reduce . 73) ($:~= reduce . 73)
    ($:== reduce . 73) ($:& reduce . 73) ($:| reduce . 73) ($:: reduce . 73) 
    (#{$:\x29;}# reduce . 73) (#{$:\x7d;}# reduce . 73) (#{$:\x5d;}# reduce . 
    73)) (($:* shift . 94) ($:/ shift . 95) ($:\ shift . 96) ($:^ shift . 97) 
    ($:.* shift . 98) ($:./ shift . 99) ($:.\ shift . 100) ($:.^ shift . 101) 
    (#\newline reduce . 72) (#{$:;}# reduce . 72) ($:, reduce . 72) ($:- 
    reduce . 72) ($:+ reduce . 72) ($:< reduce . 72) ($:> reduce . 72) 
    ($:<= reduce . 72) ($:>= reduce . 72) ($:~= reduce . 72) ($:== reduce . 72
    ) ($:& reduce . 72) ($:| reduce . 72) ($:: reduce . 72) (#{$:\x29;}# 
    reduce . 72) (#{$:\x7d;}# reduce . 72) (#{$:\x5d;}# reduce . 72)) (
    ($:+ shift . 92) ($:- shift . 93) ($:, reduce . 70) (#{$:;}# reduce . 70) 
    (#\newline reduce . 70) ($:: reduce . 70) ($:| reduce . 70) ($:& reduce . 
    70) ($:== reduce . 70) ($:~= reduce . 70) ($:>= reduce . 70) ($:<= reduce 
    . 70) ($:> reduce . 70) ($:< reduce . 70) (#{$:\x29;}# reduce . 70) 
    (#{$:\x7d;}# reduce . 70) (#{$:\x5d;}# reduce . 70)) (($:+ shift . 92) 
    ($:- shift . 93) ($:, reduce . 69) (#{$:;}# reduce . 69) (#\newline reduce
    . 69) ($:: reduce . 69) ($:| reduce . 69) ($:& reduce . 69) ($:== reduce 
    . 69) ($:~= reduce . 69) ($:>= reduce . 69) ($:<= reduce . 69) ($:> reduce
    . 69) ($:< reduce . 69) (#{$:\x29;}# reduce . 69) (#{$:\x7d;}# reduce . 69
    ) (#{$:\x5d;}# reduce . 69)) (($:+ shift . 92) ($:- shift . 93) ($:, 
    reduce . 68) (#{$:;}# reduce . 68) (#\newline reduce . 68) ($:: reduce . 
    68) ($:| reduce . 68) ($:& reduce . 68) ($:== reduce . 68) ($:~= reduce . 
    68) ($:>= reduce . 68) ($:<= reduce . 68) ($:> reduce . 68) ($:< reduce . 
    68) (#{$:\x29;}# reduce . 68) (#{$:\x7d;}# reduce . 68) (#{$:\x5d;}# 
    reduce . 68)) (($:+ shift . 92) ($:- shift . 93) ($:, reduce . 67) 
    (#{$:;}# reduce . 67) (#\newline reduce . 67) ($:: reduce . 67) ($:| 
    reduce . 67) ($:& reduce . 67) ($:== reduce . 67) ($:~= reduce . 67) 
    ($:>= reduce . 67) ($:<= reduce . 67) ($:> reduce . 67) ($:< reduce . 67) 
    (#{$:\x29;}# reduce . 67) (#{$:\x7d;}# reduce . 67) (#{$:\x5d;}# reduce . 
    67)) (($:< shift . 88) ($:> shift . 89) ($:<= shift . 90) ($:>= shift . 91
    ) (#\newline reduce . 65) (#{$:;}# reduce . 65) ($:, reduce . 65) ($:~= 
    reduce . 65) ($:== reduce . 65) ($:& reduce . 65) ($:| reduce . 65) 
    ($:: reduce . 65) (#{$:\x29;}# reduce . 65) (#{$:\x7d;}# reduce . 65) 
    (#{$:\x5d;}# reduce . 65)) (($:< shift . 88) ($:> shift . 89) ($:<= shift 
    . 90) ($:>= shift . 91) (#\newline reduce . 64) (#{$:;}# reduce . 64) 
    ($:, reduce . 64) ($:~= reduce . 64) ($:== reduce . 64) ($:& reduce . 64) 
    ($:| reduce . 64) ($:: reduce . 64) (#{$:\x29;}# reduce . 64) (#{$:\x7d;}#
    reduce . 64) (#{$:\x5d;}# reduce . 64)) (($:== shift . 86) ($:~= shift . 
    87) ($:, reduce . 62) (#{$:;}# reduce . 62) (#\newline reduce . 62) 
    ($:: reduce . 62) ($:| reduce . 62) ($:& reduce . 62) (#{$:\x29;}# reduce 
    . 62) (#{$:\x7d;}# reduce . 62) (#{$:\x5d;}# reduce . 62)) (($:& shift . 
    85) (#\newline reduce . 60) (#{$:;}# reduce . 60) ($:, reduce . 60) 
    ($:| reduce . 60) ($:: reduce . 60) (#{$:\x29;}# reduce . 60) (#{$:\x7d;}#
    reduce . 60) (#{$:\x5d;}# reduce . 60)) (($:end shift . 185) ($ident shift
    . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (ident 
    shift . 7) ($:clear shift . 8) ($:global shift . 9) ($lone-comm shift . 3)
    (command shift . 12) ($:return shift . 13) ($:switch shift . 14) ($:if 
    shift . 15) ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 
    18) (lval-expr shift . 19) (term shift . 20) (non-comment-statement shift 
    . 28) (lone-comment shift . 29) (statement shift . 130)) (($:end shift . 
    181) ($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline 
    shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) 
    ($lone-comm shift . 3) (command shift . 12) ($:return shift . 13) (
    $:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 130) ($:else shift . 182) ($:elseif shift . 183) (elseif-list 
    shift . 184)) (($:end shift . 178) ($:case shift . 179) ($:otherwise shift
    . 180)) (($:| shift . 84) ($:, reduce . 58) (#{$:;}# reduce . 58) (
    #\newline reduce . 58) ($:: reduce . 58) (#{$:\x29;}# reduce . 58) 
    (#{$:\x7d;}# reduce . 58) (#{$:\x5d;}# reduce . 58)) (($ident shift . 1) 
    (ident shift . 177)) (($:= shift . 176)) ((#{$:\x28;}# shift . 175)) 
    ((#{$:\x29;}# shift . 174) ($:, shift . 168)) (($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (term shift . 173)) ((#{$:\x5b;}# reduce 
    . 22) ($:for reduce . 22) ($:while reduce . 22) ($:if reduce . 22) 
    ($:switch reduce . 22) ($:return reduce . 22) ($:global reduce . 22) 
    ($:clear reduce . 22) ($ident reduce . 22) (#\newline reduce . 22) 
    (#{$:;}# reduce . 22) ($:, reduce . 22) ($:end reduce . 22) ($lone-comm 
    reduce . 22) ($:function reduce . 22) ($end reduce . 22)) (($:, shift . 4)
    (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 208)) (($ident 
    shift . 1) (ident shift . 76) (ident-list shift . 206) (#{$:\x29;}# shift 
    . 207)) (($ident shift . 1) (ident shift . 205)) ((#{$:\x5d;}# reduce . 24
    ) ($:, reduce . 24) (#{$:\x29;}# reduce . 24)) (($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (term shift . 204)) (($string shift . 43)
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) (expr shift . 203)) (($:, shift
    . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 202)) 
    (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 
    201)) (($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline 
    shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) 
    ($lone-comm shift . 3) (command shift . 12) ($:return shift . 13) (
    $:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 126) (statement-list shift . 200)) (($string shift . 43) ($float 
    shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# shift . 46
    ) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string shift . 49) 
    (number shift . 50) (ident shift . 7) (primary-expr shift . 51) (lval-expr
    shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55) (
    postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) (expr shift . 199)) (($:else 
    shift . 197) ($:elseif shift . 198)) (($:, shift . 4) (#{$:;}# shift . 5) 
    (#\newline shift . 6) (term shift . 196)) ((#{$:\x5d;}# reduce . 92) 
    ($:. reduce . 92) (#{$:\x28;}# reduce . 92) ($:, reduce . 92) (#\newline 
    reduce . 92) (#{$:;}# reduce . 92) ($:' reduce . 92) ($:.' reduce . 92) 
    ($:* reduce . 92) ($:/ reduce . 92) ($:\ reduce . 92) ($:^ reduce . 92) 
    ($:.* reduce . 92) ($:./ reduce . 92) ($:.\ reduce . 92) ($:.^ reduce . 92
    ) ($:- reduce . 92) ($:+ reduce . 92) ($:< reduce . 92) ($:> reduce . 92) 
    ($:<= reduce . 92) ($:>= reduce . 92) ($:~= reduce . 92) ($:== reduce . 92
    ) ($:& reduce . 92) ($:| reduce . 92) ($:: reduce . 92) (#{$:\x29;}# 
    reduce . 92) (#{$:\x7d;}# reduce . 92)) (($:: shift . 80) (#{$:\x7d;}# 
    reduce . 106) ($:, reduce . 106) (#{$:;}# reduce . 106) (#\newline reduce 
    . 106) (#{$:\x5d;}# reduce . 106)) (($:, shift . 143) (#{$:\x5d;}# reduce 
    . 102) (#\newline reduce . 102) (#{$:;}# reduce . 102) (#{$:\x7d;}# reduce
    . 102)) (($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline
    shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) 
    ($lone-comm shift . 3) (command shift . 12) ($:return shift . 13) (
    $:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 126) (statement-list shift . 195)) ((#{$:\x28;}# shift . 194)) 
    ((#{$:\x5b;}# reduce . 30) ($:for reduce . 30) ($:while reduce . 30) 
    ($:if reduce . 30) ($:switch reduce . 30) ($:return reduce . 30) ($:global
    reduce . 30) ($:clear reduce . 30) ($ident reduce . 30) (#\newline reduce 
    . 30) (#{$:;}# reduce . 30) ($:, reduce . 30) ($lone-comm reduce . 30) 
    ($:end reduce . 30) ($:else reduce . 30) ($:elseif reduce . 30) ($end 
    reduce . 30) ($:function reduce . 30) ($:case reduce . 30) ($:otherwise 
    reduce . 30)) ((#{$:\x29;}# reduce . 56) ($:, reduce . 56)) (($:: shift . 
    80) (#{$:\x29;}# reduce . 55) ($:, reduce . 55)) (($string shift . 43) 
    ($float shift . 44) ($fixed shift . 45) ($ident shift . 1) (#{$:\x7b;}# 
    shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift . 48) (string 
    shift . 49) (number shift . 50) (ident shift . 7) (primary-expr shift . 51
    ) (lval-expr shift . 52) ($:~ shift . 53) ($:+ shift . 54) ($:- shift . 55
    ) (postfix-expr shift . 56) (unary-expr shift . 57) (mul-expr shift . 58) 
    (add-expr shift . 59) (rel-expr shift . 60) (equality-expr shift . 61) 
    (and-expr shift . 62) (or-expr shift . 63) ($:: shift . 119) (expr shift 
    . 120) (expr-list shift . 219) (#{$:\x29;}# shift . 220)) (($:end shift . 
    218) ($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline 
    shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) 
    ($lone-comm shift . 3) (command shift . 12) ($:return shift . 13) (
    $:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 130)) ((#{$:\x5b;}# reduce . 35) ($:for reduce . 35) ($:while 
    reduce . 35) ($:if reduce . 35) ($:switch reduce . 35) ($:return reduce . 
    35) ($:global reduce . 35) ($:clear reduce . 35) ($ident reduce . 35) 
    (#\newline reduce . 35) (#{$:;}# reduce . 35) ($:, reduce . 35) (
    $lone-comm reduce . 35) ($:end reduce . 35) ($:else reduce . 35) ($:elseif
    reduce . 35) ($end reduce . 35) ($:function reduce . 35) ($:case reduce . 
    35) ($:otherwise reduce . 35)) (($ident shift . 1) ($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift
    . 8) ($:global shift . 9) ($lone-comm shift . 3) (command shift . 12) 
    ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) ($:while 
    shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift 
    . 19) (term shift . 20) (non-comment-statement shift . 28) (lone-comment 
    shift . 29) (statement shift . 126) (statement-list shift . 217)) (
    ($string shift . 43) ($float shift . 44) ($fixed shift . 45) ($ident shift
    . 1) (#{$:\x7b;}# shift . 46) (#{$:\x5b;}# shift . 47) (#{$:\x28;}# shift 
    . 48) (string shift . 49) (number shift . 50) (ident shift . 7) (
    primary-expr shift . 51) (lval-expr shift . 52) ($:~ shift . 53) ($:+ 
    shift . 54) ($:- shift . 55) (postfix-expr shift . 56) (unary-expr shift 
    . 57) (mul-expr shift . 58) (add-expr shift . 59) (rel-expr shift . 60) 
    (equality-expr shift . 61) (and-expr shift . 62) (or-expr shift . 63) 
    (expr shift . 216)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift 
    . 6) (term shift . 215) ($:: shift . 80)) (($:end shift . 214) ($ident 
    shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) 
    (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) ($lone-comm 
    shift . 3) (command shift . 12) ($:return shift . 13) ($:switch shift . 14
    ) ($:if shift . 15) ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# 
    shift . 18) (lval-expr shift . 19) (term shift . 20) (
    non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 130)) ((#{$:\x5b;}# reduce . 38) ($:for reduce . 38) ($:while 
    reduce . 38) ($:if reduce . 38) ($:switch reduce . 38) ($:return reduce . 
    38) ($:global reduce . 38) ($:clear reduce . 38) ($ident reduce . 38) 
    (#\newline reduce . 38) (#{$:;}# reduce . 38) ($:, reduce . 38) (
    $lone-comm reduce . 38) ($:end reduce . 38) ($:else reduce . 38) ($:elseif
    reduce . 38) ($end reduce . 38) ($:function reduce . 38) ($:case reduce . 
    38) ($:otherwise reduce . 38)) (($ident shift . 1) ($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift
    . 8) ($:global shift . 9) ($lone-comm shift . 3) (command shift . 12) 
    ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) ($:while 
    shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift 
    . 19) (term shift . 20) (non-comment-statement shift . 28) (lone-comment 
    shift . 29) (statement shift . 126) (statement-list shift . 213)) (
    ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 
    212) ($:: shift . 80)) ((#{$:\x5b;}# reduce . 40) ($:for reduce . 40) 
    ($:while reduce . 40) ($:if reduce . 40) ($:switch reduce . 40) ($:return 
    reduce . 40) ($:global reduce . 40) ($:clear reduce . 40) ($ident reduce 
    . 40) (#\newline reduce . 40) (#{$:;}# reduce . 40) ($:, reduce . 40) 
    ($lone-comm reduce . 40) ($:end reduce . 40) ($:else reduce . 40) (
    $:elseif reduce . 40) ($end reduce . 40) ($:function reduce . 40) ($:case 
    reduce . 40) ($:otherwise reduce . 40)) ((#{$:\x28;}# shift . 211)) 
    ((#{$:\x29;}# shift . 210) ($:, shift . 168)) (($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (term shift . 209)) ((#{$:\x5b;}# reduce 
    . 21) ($:for reduce . 21) ($:while reduce . 21) ($:if reduce . 21) 
    ($:switch reduce . 21) ($:return reduce . 21) ($:global reduce . 21) 
    ($:clear reduce . 21) ($ident reduce . 21) (#\newline reduce . 21) 
    (#{$:;}# reduce . 21) ($:, reduce . 21) ($:end reduce . 21) ($lone-comm 
    reduce . 21) ($:function reduce . 21) ($end reduce . 21)) ((#{$:\x5b;}# 
    reduce . 20) ($:for reduce . 20) ($:while reduce . 20) ($:if reduce . 20) 
    ($:switch reduce . 20) ($:return reduce . 20) ($:global reduce . 20) 
    ($:clear reduce . 20) ($ident reduce . 20) (#\newline reduce . 20) 
    (#{$:;}# reduce . 20) ($:, reduce . 20) ($:end reduce . 20) ($lone-comm 
    reduce . 20) ($:function reduce . 20) ($end reduce . 20)) (($:, shift . 4)
    (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 232)) (($ident 
    shift . 1) (ident shift . 76) (ident-list shift . 230) (#{$:\x29;}# shift 
    . 231)) (($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline
    shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) 
    ($lone-comm shift . 3) (command shift . 12) ($:return shift . 13) (
    $:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for shift 
    . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 20) 
    (non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 126) (statement-list shift . 229)) (($:end shift . 228) ($ident 
    shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) 
    (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) ($lone-comm 
    shift . 3) (command shift . 12) ($:return shift . 13) ($:switch shift . 14
    ) ($:if shift . 15) ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# 
    shift . 18) (lval-expr shift . 19) (term shift . 20) (
    non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 130)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) 
    (term shift . 227)) (($ident shift . 1) ($:, shift . 4) (#{$:;}# shift . 5
    ) (#\newline shift . 6) (ident shift . 7) ($:clear shift . 8) ($:global 
    shift . 9) ($lone-comm shift . 3) (command shift . 12) ($:return shift . 
    13) ($:switch shift . 14) ($:if shift . 15) ($:while shift . 16) ($:for 
    shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) (term shift . 
    20) (non-comment-statement shift . 28) (lone-comment shift . 29) (
    statement shift . 126) (statement-list shift . 226)) (($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 225) ($:: shift . 
    80)) (($:end shift . 224) ($ident shift . 1) ($:, shift . 4) (#{$:;}# 
    shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift . 8) 
    ($:global shift . 9) ($lone-comm shift . 3) (command shift . 12) ($:return
    shift . 13) ($:switch shift . 14) ($:if shift . 15) ($:while shift . 16) 
    ($:for shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift . 19) 
    (term shift . 20) (non-comment-statement shift . 28) (lone-comment shift 
    . 29) (statement shift . 130)) (($:, shift . 4) (#{$:;}# shift . 5) 
    (#\newline shift . 6) (term shift . 223)) ((#{$:\x29;}# shift . 222) 
    ($:, shift . 133)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift 
    . 6) (term shift . 221)) ((#{$:\x5b;}# reduce . 32) ($:for reduce . 32) 
    ($:while reduce . 32) ($:if reduce . 32) ($:switch reduce . 32) ($:return 
    reduce . 32) ($:global reduce . 32) ($:clear reduce . 32) ($ident reduce 
    . 32) (#\newline reduce . 32) (#{$:;}# reduce . 32) ($:, reduce . 32) 
    ($lone-comm reduce . 32) ($:end reduce . 32) ($:else reduce . 32) (
    $:elseif reduce . 32) ($end reduce . 32) ($:function reduce . 32) ($:case 
    reduce . 32) ($:otherwise reduce . 32)) (($:, shift . 4) (#{$:;}# shift . 
    5) (#\newline shift . 6) (term shift . 238)) ((#{$:\x5b;}# reduce . 34) 
    ($:for reduce . 34) ($:while reduce . 34) ($:if reduce . 34) ($:switch 
    reduce . 34) ($:return reduce . 34) ($:global reduce . 34) ($:clear reduce
    . 34) ($ident reduce . 34) (#\newline reduce . 34) (#{$:;}# reduce . 34) 
    ($:, reduce . 34) ($lone-comm reduce . 34) ($:end reduce . 34) ($:else 
    reduce . 34) ($:elseif reduce . 34) ($end reduce . 34) ($:function reduce 
    . 34) ($:case reduce . 34) ($:otherwise reduce . 34)) (($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (term shift . 237)) (($ident 
    shift . 1) ($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) 
    (ident shift . 7) ($:clear shift . 8) ($:global shift . 9) ($lone-comm 
    shift . 3) (command shift . 12) ($:return shift . 13) ($:switch shift . 14
    ) ($:if shift . 15) ($:while shift . 16) ($:for shift . 17) (#{$:\x5b;}# 
    shift . 18) (lval-expr shift . 19) (term shift . 20) (
    non-comment-statement shift . 28) (lone-comment shift . 29) (statement 
    shift . 126) (statement-list shift . 236)) (($ident shift . 1) ($:, shift 
    . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear 
    shift . 8) ($:global shift . 9) ($lone-comm shift . 3) (command shift . 12
    ) ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) ($:while 
    shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift 
    . 19) (term shift . 20) (non-comment-statement shift . 28) (lone-comment 
    shift . 29) (statement shift . 130) ($:else reduce . 49) ($:elseif reduce 
    . 49)) ((#{$:\x5b;}# reduce . 37) ($:for reduce . 37) ($:while reduce . 37
    ) ($:if reduce . 37) ($:switch reduce . 37) ($:return reduce . 37) 
    ($:global reduce . 37) ($:clear reduce . 37) ($ident reduce . 37) (
    #\newline reduce . 37) (#{$:;}# reduce . 37) ($:, reduce . 37) ($lone-comm
    reduce . 37) ($:end reduce . 37) ($:else reduce . 37) ($:elseif reduce . 
    37) ($end reduce . 37) ($:function reduce . 37) ($:case reduce . 37) 
    ($:otherwise reduce . 37)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline
    shift . 6) (term shift . 235)) (($ident shift . 1) ($:, shift . 4) 
    (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear shift
    . 8) ($:global shift . 9) ($lone-comm shift . 3) (command shift . 12) 
    ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) ($:while 
    shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift 
    . 19) (term shift . 20) (non-comment-statement shift . 28) (lone-comment 
    shift . 29) (statement shift . 130) ($:end reduce . 52) ($:case reduce . 
    52) ($:otherwise reduce . 52)) ((#{$:\x29;}# shift . 234) ($:, shift . 168
    )) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) (term shift 
    . 233)) ((#{$:\x5b;}# reduce . 19) ($:for reduce . 19) ($:while reduce . 
    19) ($:if reduce . 19) ($:switch reduce . 19) ($:return reduce . 19) 
    ($:global reduce . 19) ($:clear reduce . 19) ($ident reduce . 19) (
    #\newline reduce . 19) (#{$:;}# reduce . 19) ($:, reduce . 19) ($:end 
    reduce . 19) ($lone-comm reduce . 19) ($:function reduce . 19) ($end 
    reduce . 19)) ((#{$:\x5b;}# reduce . 18) ($:for reduce . 18) ($:while 
    reduce . 18) ($:if reduce . 18) ($:switch reduce . 18) ($:return reduce . 
    18) ($:global reduce . 18) ($:clear reduce . 18) ($ident reduce . 18) 
    (#\newline reduce . 18) (#{$:;}# reduce . 18) ($:, reduce . 18) ($:end 
    reduce . 18) ($lone-comm reduce . 18) ($:function reduce . 18) ($end 
    reduce . 18)) (($:, shift . 4) (#{$:;}# shift . 5) (#\newline shift . 6) 
    (term shift . 239)) ((#{$:\x5b;}# reduce . 39) ($:for reduce . 39) 
    ($:while reduce . 39) ($:if reduce . 39) ($:switch reduce . 39) ($:return 
    reduce . 39) ($:global reduce . 39) ($:clear reduce . 39) ($ident reduce 
    . 39) (#\newline reduce . 39) (#{$:;}# reduce . 39) ($:, reduce . 39) 
    ($lone-comm reduce . 39) ($:end reduce . 39) ($:else reduce . 39) (
    $:elseif reduce . 39) ($end reduce . 39) ($:function reduce . 39) ($:case 
    reduce . 39) ($:otherwise reduce . 39)) (($ident shift . 1) ($:, shift . 4
    ) (#{$:;}# shift . 5) (#\newline shift . 6) (ident shift . 7) ($:clear 
    shift . 8) ($:global shift . 9) ($lone-comm shift . 3) (command shift . 12
    ) ($:return shift . 13) ($:switch shift . 14) ($:if shift . 15) ($:while 
    shift . 16) ($:for shift . 17) (#{$:\x5b;}# shift . 18) (lval-expr shift 
    . 19) (term shift . 20) (non-comment-statement shift . 28) (lone-comment 
    shift . 29) (statement shift . 130) ($:else reduce . 50) ($:elseif reduce 
    . 50)) ((#{$:\x5b;}# reduce . 36) ($:for reduce . 36) ($:while reduce . 36
    ) ($:if reduce . 36) ($:switch reduce . 36) ($:return reduce . 36) 
    ($:global reduce . 36) ($:clear reduce . 36) ($ident reduce . 36) (
    #\newline reduce . 36) (#{$:;}# reduce . 36) ($:, reduce . 36) ($lone-comm
    reduce . 36) ($:end reduce . 36) ($:else reduce . 36) ($:elseif reduce . 
    36) ($end reduce . 36) ($:function reduce . 36) ($:case reduce . 36) 
    ($:otherwise reduce . 36)) ((#{$:\x5b;}# reduce . 33) ($:for reduce . 33) 
    ($:while reduce . 33) ($:if reduce . 33) ($:switch reduce . 33) ($:return 
    reduce . 33) ($:global reduce . 33) ($:clear reduce . 33) ($ident reduce 
    . 33) (#\newline reduce . 33) (#{$:;}# reduce . 33) ($:, reduce . 33) 
    ($lone-comm reduce . 33) ($:end reduce . 33) ($:else reduce . 33) (
    $:elseif reduce . 33) ($end reduce . 33) ($:function reduce . 33) ($:case 
    reduce . 33) ($:otherwise reduce . 33)) ((#{$:\x5b;}# reduce . 17) 
    ($:for reduce . 17) ($:while reduce . 17) ($:if reduce . 17) ($:switch 
    reduce . 17) ($:return reduce . 17) ($:global reduce . 17) ($:clear reduce
    . 17) ($ident reduce . 17) (#\newline reduce . 17) (#{$:;}# reduce . 17) 
    ($:, reduce . 17) ($:end reduce . 17) ($lone-comm reduce . 17) ($:function
    reduce . 17) ($end reduce . 17))))

(define rto-v
  #($start mfile mfile script-file script-file script-file function-file 
    function-file function-defn function-defn function-defn opt-end opt-end 
    function-decl function-decl nl-list nl-list function-decl-line 
    function-decl-line function-decl-line function-decl-line 
    function-decl-line function-decl-line ident-list ident-list statement-list
    statement-list statement statement non-comment-statement 
    non-comment-statement non-comment-statement non-comment-statement 
    non-comment-statement non-comment-statement non-comment-statement 
    non-comment-statement non-comment-statement non-comment-statement 
    non-comment-statement non-comment-statement non-comment-statement 
    non-comment-statement lval-expr-list lval-expr-list command command 
    arg-list arg-list elseif-list elseif-list case-list case-list expr-list 
    expr-list expr-list expr-list expr expr or-expr or-expr and-expr and-expr 
    equality-expr equality-expr equality-expr rel-expr rel-expr rel-expr 
    rel-expr rel-expr add-expr add-expr add-expr mul-expr mul-expr mul-expr 
    mul-expr mul-expr mul-expr mul-expr mul-expr mul-expr unary-expr 
    unary-expr unary-expr unary-expr postfix-expr postfix-expr postfix-expr 
    postfix-expr lval-expr lval-expr lval-expr primary-expr primary-expr 
    primary-expr primary-expr primary-expr primary-expr primary-expr 
    matrix-row-list matrix-row-list row-term row-term matrix-row matrix-row 
    term-list term-list lone-comment-list lone-comment-list term term term 
    ident number number string lone-comment))

(define mtab
  '(($string . $string) ($float . $float) ($fixed . $fixed) ($ident . $ident) 
    (";" . #{$:;}#) ("}" . #{$:\x7d;}#) ("{" . #{$:\x7b;}#) ("." . $:.) 
    (".'" . $:.') ("'" . $:') ("~" . $:~) (".^" . $:.^) (".\\" . $:.\) 
    ("./" . $:./) (".*" . $:.*) ("^" . $:^) ("\\" . $:\) ("/" . $:/) ("*" . 
    $:*) ("-" . $:-) ("+" . $:+) (">=" . $:>=) ("<=" . $:<=) (">" . $:>) 
    ("<" . $:<) ("~=" . $:~=) ("==" . $:==) ("&" . $:&) ("|" . $:|) (":" . $::
    ) ("case" . $:case) ("elseif" . $:elseif) ("clear" . $:clear) ("global" . 
    $:global) ("return" . $:return) ("otherwise" . $:otherwise) ("switch" . 
    $:switch) ("else" . $:else) ("if" . $:if) ("while" . $:while) ("for" . 
    $:for) ("," . $:,) (")" . #{$:\x29;}#) ("(" . #{$:\x28;}#) ("=" . $:=) 
    ("]" . #{$:\x5d;}#) ("[" . #{$:\x5b;}#) ("function" . $:function) (
    #\newline . #\newline) ("end" . $:end) ($code-comm . $code-comm) (
    $lone-comm . $lone-comm) ($error . $error) ($end . $end)))

;;; end tables
