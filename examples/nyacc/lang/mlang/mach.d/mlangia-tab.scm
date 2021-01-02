;; mlangia-tab.scm

;; Copyright 2015-2018 Matthew R. Wette
;; 
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; See the file COPYING included with the this distribution.

(define mlangia-mtab
  '(($start . 100) ($lone-comm . 3) ($string . 4) ($float . 5) ($fixed . 6) 
    ($ident . 7) (";" . 8) ("." . 9) (".'" . 10) ("'" . 11) ("~" . 12) 
    (".^" . 13) (".\\" . 14) ("./" . 15) (".*" . 16) ("^" . 17) ("\\" . 18) 
    ("/" . 19) ("*" . 20) (".-" . 21) (".+" . 22) ("-" . 23) ("+" . 24) 
    (">=" . 25) ("<=" . 26) (">" . 27) ("<" . 28) ("~=" . 29) ("==" . 30) 
    ("&" . 31) ("|" . 32) (":" . 33) ("}" . 34) ("{" . 35) ("case" . 36) 
    ("elseif" . 37) ("clear" . 38) ("global" . 39) ("return" . 40) (
    "otherwise" . 41) ("switch" . 42) ("else" . 43) ("if" . 44) ("while" . 45)
    ("for" . 46) ("\n" . 47) ("," . 48) (")" . 49) ("(" . 50) ("=" . 51) 
    ("]" . 52) ("[" . 53) ("function" . 54) ("end" . 55) ($error . 2) ($end . 
    57)))

(define mlangia-ntab
  '((58 . float) (59 . lone-comment-list-1) (60 . term-list) (61 . nl) 
    (62 . row-term) (63 . matrix-row) (64 . matrix-row-list) (65 . number) 
    (66 . primary-expr) (67 . postfix-expr) (68 . unary-expr) (69 . mul-expr) 
    (70 . add-expr) (71 . rel-expr) (72 . equality-expr) (73 . and-expr) 
    (74 . or-expr) (75 . expr-list) (76 . string-list) (77 . fixed-list) 
    (78 . string) (79 . fixed) (80 . case-expr) (81 . arg-list) (82 . command)
    (83 . case-list) (84 . elseif-list) (85 . expr) (86 . 
    nontrivial-statement-1) (87 . lone-comment) (88 . trivial-statement) 
    (89 . triv-stmt-list-1) (90 . ident) (91 . ident-list) (92 . 
    lone-comment-list) (93 . function-decl-line) (94 . term) (95 . the-end) 
    (96 . stmt-list) (97 . non-comment-statement) (98 . function-decl) 
    (99 . statement) (100 . mlang-item) (101 . mlang-item-list-1) (102 . 
    function-defn) (103 . mlang-item-list) (104 . nontrivial-statement) 
    (105 . triv-stmt-list) (106 . translation-unit)))

(define mlangia-len-v
  #(1 3 3 2 2 1 0 2 1 1 4 3 2 2 2 1 10 9 8 7 6 5 1 3 1 2 1 1 2 1 1 1 1 2 1 2 
    1 3 7 5 8 6 7 5 8 5 1 2 1 1 1 2 4 5 0 5 1 1 3 3 1 2 1 2 1 3 1 1 3 5 3 5 1 
    3 1 3 1 3 3 1 3 3 3 3 1 3 3 3 3 1 3 3 3 3 3 3 3 3 1 2 2 2 1 2 2 4 3 3 1 1 
    1 3 2 3 2 3 1 3 1 1 1 3 1 2 1 1 1 1 2 3 1 1 1 1 1 1 1 1))

(define mlangia-rto-v
  #(#f 106 106 106 106 103 101 101 100 100 102 102 102 95 98 98 93 93 93 93 
    93 93 91 91 96 96 105 89 89 99 99 97 97 88 88 104 86 86 86 86 86 86 86 86 
    86 86 86 86 82 82 81 81 84 84 83 83 80 80 80 80 77 77 76 76 75 75 85 85 85
    85 85 85 74 74 73 73 72 72 72 71 71 71 71 71 70 70 70 70 70 69 69 69 69 69
    69 69 69 69 68 68 68 68 67 67 67 67 67 67 66 66 66 66 66 66 66 66 64 64 62
    62 63 63 60 60 94 94 94 92 59 59 90 79 58 65 65 78 87 61))

(define mlangia-pat-v
  #(((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) 
    (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) 
    (45 . 37) (46 . 38) (85 . 39) (54 . 40) (86 . 41) (94 . 42) (87 . 43) 
    (93 . 44) (104 . 45) (88 . 46) (98 . 47) (99 . 48) (102 . 49) (100 . 50)) 
    ((1 . -132)) ((1 . -131)) ((1 . -135)) ((1 . -134)) ((1 . -133)) ((1 . 
    -130)) ((34 . 103) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 100) (63 . 101) 
    (64 . 104)) ((52 . 99) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 100) (63 . 101) 
    (64 . 102)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 98)) ((1 . -110)) ((1 . -109
    )) ((1 . -108)) ((1 . -102)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (67 . 97)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (67 . 96)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (67 . 95)) ((11 . 91) 
    (10 . 92) (50 . 93) (9 . 94) (1 . -98)) ((1 . -89)) ((20 . 83) (19 . 84) 
    (18 . 85) (17 . 86) (16 . 87) (15 . 88) (14 . 89) (13 . 90) (1 . -84)) 
    ((24 . 79) (23 . 80) (22 . 81) (21 . 82) (1 . -79)) ((28 . 75) (27 . 76) 
    (26 . 77) (25 . 78) (1 . -76)) ((30 . 73) (29 . 74) (1 . -74)) ((31 . 72) 
    (1 . -72)) ((1 . -137)) ((1 . -67)) ((33 . 70) (32 . 71) (1 . -66)) 
    ((1 . -49)) ((1 . -48)) ((1 . -136)) ((1 . -126)) ((1 . -125)) ((1 . -124)
    ) ((7 . 6) (90 . 68) (81 . 69)) ((1 . -46)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) 
    (85 . 67)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 66)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (33 . 25) 
    (74 . 26) (85 . 65)) ((7 . 6) (90 . 64)) ((51 . 63) (1 . -36)) ((53 . 61) 
    (7 . 6) (90 . 62)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 60)) 
    ((1 . -34)) ((47 . 59)) ((3 . 29) (87 . 56) (59 . 57) (92 . 58) (1 . -15))
    ((1 . -30)) ((1 . -29)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) (38 . 27) (39 . 28) 
    (47 . 24) (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) 
    (85 . 39) (48 . 30) (8 . 31) (61 . 32) (86 . 41) (104 . 51) (94 . 52) 
    (97 . 53) (55 . 54) (95 . 55)) ((1 . -9)) ((1 . -8)) ((57 . 0)) ((1 . -32)
    ) ((1 . -31)) ((55 . 54) (95 . 151) (5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) 
    (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) 
    (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) 
    (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 152) (96 . 153)) ((47 . 24)
    (48 . 30) (8 . 31) (61 . 32) (94 . 150)) ((1 . -12)) ((47 . 24) (61 . 149)
    ) ((3 . 29) (87 . 148) (1 . -127)) ((1 . -14)) ((1 . -33)) ((1 . -35)) 
    ((7 . 6) (90 . 146) (91 . 147)) ((50 . 144) (51 . 145)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (33 . 25) 
    (74 . 26) (85 . 143)) ((51 . 142)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32)
    (94 . 141)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 140)) ((47 . 24)
    (48 . 30) (8 . 31) (61 . 32) (94 . 139)) ((1 . -50)) ((7 . 6) (90 . 138) 
    (1 . -47)) ((55 . 136) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (74 . 137)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 135)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 134)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 133)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 132)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 131)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 130)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 129)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 128)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 127)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 126)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 125)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 124)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 123)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 122)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 121)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 120)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 119)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 118)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 117)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 116)) ((1 . -103)) ((1 . -104)) 
    ((49 . 113) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 114) (75 . 115)) ((7 . 6) 
    (90 . 112)) ((11 . 91) (10 . 92) (50 . 93) (9 . 94) (1 . -99)) ((11 . 91) 
    (10 . 92) (50 . 93) (9 . 94) (1 . -100)) ((11 . 91) (10 . 92) (50 . 93) 
    (9 . 94) (1 . -101)) ((49 . 111)) ((1 . -112)) ((1 . -120)) ((48 . 110) 
    (1 . -116)) ((52 . 109) (47 . 24) (61 . 106) (8 . 107) (62 . 108)) 
    ((1 . -114)) ((34 . 105) (47 . 24) (61 . 106) (8 . 107) (62 . 108)) 
    ((1 . -115)) ((1 . -119)) ((1 . -118)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 100) 
    (63 . 170)) ((1 . -113)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 169)) ((1 . -111))
    ((1 . -107)) ((1 . -106)) ((1 . -64)) ((49 . 167) (48 . 168)) ((1 . -97)) 
    ((1 . -96)) ((1 . -95)) ((1 . -94)) ((1 . -93)) ((1 . -92)) ((1 . -91)) 
    ((1 . -90)) ((20 . 83) (19 . 84) (18 . 85) (17 . 86) (16 . 87) (15 . 88) 
    (14 . 89) (13 . 90) (1 . -88)) ((20 . 83) (19 . 84) (18 . 85) (17 . 86) 
    (16 . 87) (15 . 88) (14 . 89) (13 . 90) (1 . -87)) ((20 . 83) (19 . 84) 
    (18 . 85) (17 . 86) (16 . 87) (15 . 88) (14 . 89) (13 . 90) (1 . -86)) 
    ((20 . 83) (19 . 84) (18 . 85) (17 . 86) (16 . 87) (15 . 88) (14 . 89) 
    (13 . 90) (1 . -85)) ((24 . 79) (23 . 80) (22 . 81) (21 . 82) (1 . -83)) 
    ((24 . 79) (23 . 80) (22 . 81) (21 . 82) (1 . -82)) ((24 . 79) (23 . 80) 
    (22 . 81) (21 . 82) (1 . -81)) ((24 . 79) (23 . 80) (22 . 81) (21 . 82) 
    (1 . -80)) ((28 . 75) (27 . 76) (26 . 77) (25 . 78) (1 . -78)) ((28 . 75) 
    (27 . 76) (26 . 77) (25 . 78) (1 . -77)) ((30 . 73) (29 . 74) (1 . -75)) 
    ((31 . 72) (1 . -73)) ((1 . -70)) ((32 . 71) (33 . 166) (1 . -68)) 
    ((1 . -51)) ((83 . 165) (1 . -54)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) 
    (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) 
    (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) 
    (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 152) (96 . 164)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) 
    (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) 
    (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) 
    (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) 
    (99 . 152) (96 . 163)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 162)) ((1 . -37)) 
    ((7 . 6) (90 . 146) (91 . 160) (49 . 161)) ((7 . 6) (90 . 159)) ((1 . -22)
    ) ((48 . 157) (52 . 158)) ((47 . 24) (61 . 156)) ((1 . -128)) ((1 . -13)) 
    ((1 . -11)) ((1 . -24)) ((55 . 54) (95 . 154) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) 
    (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) 
    (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) 
    (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 155)) ((1 . -10))
    ((1 . -25)) ((1 . -129)) ((7 . 6) (90 . 187)) ((51 . 186)) ((50 . 185)) 
    ((49 . 184) (48 . 157)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 183)
    ) ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 182)) ((55 . 181) (5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) 
    (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) 
    (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) 
    (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) 
    (99 . 155)) ((55 . 177) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) 
    (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) 
    (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) 
    (87 . 43) (104 . 45) (88 . 46) (99 . 155) (43 . 178) (37 . 179) (84 . 180)
    ) ((55 . 174) (36 . 175) (41 . 176)) ((55 . 172) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 173)) ((1 . -105))
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (33 . 25) (74 . 26) (85 . 171)) ((1 . -121)) ((48 . 110) 
    (1 . -117)) ((1 . -65)) ((1 . -71)) ((32 . 71) (1 . -69)) ((1 . -45)) 
    ((4 . 3) (6 . 2) (35 . 199) (78 . 200) (79 . 201) (80 . 202)) ((47 . 24) 
    (48 . 30) (8 . 31) (61 . 32) (94 . 198)) ((1 . -43)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) 
    (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) 
    (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) 
    (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 152) 
    (96 . 197)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (33 . 25) (74 . 26) (85 . 196)) ((43 . 193) (37 . 194)
    (55 . 195)) ((1 . -39)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) 
    (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) 
    (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) 
    (87 . 43) (104 . 45) (88 . 46) (99 . 152) (96 . 192)) ((1 . -21)) (
    (47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 191)) ((7 . 6) (90 . 146) 
    (91 . 189) (49 . 190)) ((7 . 6) (90 . 188)) ((1 . -23)) ((50 . 216)) 
    ((49 . 215) (48 . 157)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 214)
    ) ((1 . -20)) ((55 . 213) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) 
    (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) 
    (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) 
    (87 . 43) (104 . 45) (88 . 46) (99 . 155)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) 
    (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) 
    (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) 
    (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 152) (96 . 212)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (33 . 25) (74 . 26) (85 . 211)) ((1 . -41)) ((47 . 24) (48 . 30)
    (8 . 31) (61 . 32) (94 . 210)) ((55 . 209) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) 
    (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) 
    (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) 
    (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 155)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) 
    (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) 
    (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) 
    (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) 
    (99 . 152) (96 . 208)) ((6 . 2) (79 . 204) (77 . 205) (4 . 3) (78 . 206) 
    (76 . 207)) ((1 . -57)) ((1 . -56)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32
    ) (94 . 203)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) 
    (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) 
    (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) 
    (104 . 45) (88 . 46) (99 . 152) (96 . 228)) ((1 . -60)) ((34 . 226) 
    (6 . 2) (79 . 227)) ((1 . -62)) ((34 . 224) (4 . 3) (78 . 225)) ((55 . 223
    ) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) 
    (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) 
    (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) 
    (88 . 46) (99 . 155)) ((1 . -42)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) 
    (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) 
    (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) 
    (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 152) (96 . 222)) ((47 . 24)
    (48 . 30) (8 . 31) (61 . 32) (94 . 221)) ((55 . 220) (5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) 
    (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) 
    (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) 
    (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 155)) 
    ((1 . -38)) ((1 . -19)) ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 219)
    ) ((7 . 6) (90 . 146) (91 . 217) (49 . 218)) ((49 . 231) (48 . 157)) 
    ((47 . 24) (48 . 30) (8 . 31) (61 . 32) (94 . 230)) ((1 . -18)) ((1 . -40)
    ) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) 
    (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) 
    (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) 
    (88 . 46) (99 . 152) (96 . 229)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) (74 . 26) 
    (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) (82 . 33) 
    (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) (86 . 41) 
    (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 155) (1 . -52)) ((1 . -44))
    ((1 . -59)) ((1 . -63)) ((1 . -58)) ((1 . -61)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (33 . 25) 
    (74 . 26) (38 . 27) (39 . 28) (3 . 29) (48 . 30) (8 . 31) (61 . 32) 
    (82 . 33) (40 . 34) (42 . 35) (44 . 36) (45 . 37) (46 . 38) (85 . 39) 
    (86 . 41) (94 . 42) (87 . 43) (104 . 45) (88 . 46) (99 . 155) (1 . -55)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (33 . 25) (74 . 26) (38 . 27) (39 . 28) (3 . 29) 
    (48 . 30) (8 . 31) (61 . 32) (82 . 33) (40 . 34) (42 . 35) (44 . 36) 
    (45 . 37) (46 . 38) (85 . 39) (86 . 41) (94 . 42) (87 . 43) (104 . 45) 
    (88 . 46) (99 . 155) (1 . -53)) ((1 . -17)) ((47 . 24) (48 . 30) (8 . 31) 
    (61 . 32) (94 . 232)) ((1 . -16))))

(define mlangia-tables
  (list
   (cons 'mtab mlangia-mtab)
   (cons 'ntab mlangia-ntab)
   (cons 'len-v mlangia-len-v)
   (cons 'rto-v mlangia-rto-v)
   (cons 'pat-v mlangia-pat-v)
   ))

;;; end tables
