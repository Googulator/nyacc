;; tsh-ia-tab.scm

;; Copyright (C) 2021-2023 Matthew R. Wette
;; 
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; See the file COPYING included with the this distribution.

(define tsh-ia-mtab
  '(($start . 103) ("\n" . 3) (";" . 4) ($keyword . 5) ($keychar . 6) ($float 
    . 7) ($fixed . 8) ("::" . 9) (no-ws . 10) ($string . 11) ($ident . 12) 
    ("," . 13) ("]" . 14) ("[" . 15) ($deref . 16) ("~" . 17) ("!" . 18) 
    ("%" . 19) ("/" . 20) ("*" . 21) ("-" . 22) ("+" . 23) (">>" . 24) 
    ("<<" . 25) (">=" . 26) (">" . 27) ("<=" . 28) ("<" . 29) ("!=" . 30) 
    ("==" . 31) ("&" . 32) ("^" . 33) ("|" . 34) ("&&" . 35) ("||" . 36) 
    ("default" . 37) ("elseif" . 38) ("else" . 39) ("if" . 40) ("incr" . 41) 
    ("return" . 42) ("format" . 43) ("for" . 44) ("while" . 45) ("switch" . 46
    ) (")" . 47) ("(" . 48) ($deref/ix . 49) ("set" . 50) ("use" . 51) 
    ($lone-comm . 52) ("args" . 53) ("}" . 54) ("{" . 55) ("proc" . 56) 
    ("source" . 57) ($error . 2) ($end . 59)))

(define tsh-ia-ntab
  '((60 . path-1) (61 . expr-seq-1) (62 . expression) (63 . expr-list-1) 
    (64 . keyword) (65 . keychar) (66 . float) (67 . fixed) (68 . 
    unary-expression) (69 . multiplicative-expression) (70 . 
    additive-expression) (71 . shift-expression) (72 . relational-expression) 
    (73 . equality-expression) (74 . bitwise-and-expression) (75 . 
    bitwise-xor-expression) (76 . bitwise-or-expression) (77 . 
    logical-and-expression) (78 . logical-or-expression) (79 . 
    primary-expression) (80 . case-expr) (81 . default-case-expr) (82 . 
    case-list-1) (83 . elseif-list-1) (84 . elseif-list) (85 . case-list) 
    (86 . if-stmt) (87 . expr-seq) (88 . expr-list) (89 . path) (90 . 
    exec-stmt) (91 . decl-stmt) (92 . stmt-list-1) (93 . unit-expr) (94 . 
    arg-list-1) (95 . symbol) (96 . stmt-list) (97 . arg-list) (98 . ident) 
    (99 . string) (100 . stmt) (101 . term) (102 . topl-decl) (103 . item) 
    (104 . script-1) (105 . script) (106 . top)))

(define tsh-ia-len-v
  #(1 1 1 1 2 2 2 2 8 6 1 0 2 5 2 1 1 3 1 1 0 1 2 3 6 2 3 3 1 5 5 13 2 1 2 2 
    3 5 9 6 10 1 5 6 1 2 1 1 2 2 2 4 2 1 1 1 3 1 3 1 3 1 3 1 3 1 3 3 1 3 3 3 3
    1 3 3 1 3 3 1 3 3 3 1 2 2 2 2 1 4 1 1 1 1 1 1 3 3 1 1 3 1 0 2 1 1 1 5 5 1 
    1 1 1 1 1 1 1 1))

(define tsh-ia-rto-v
  #(#f 106 105 104 104 103 103 102 102 102 97 94 94 94 94 96 92 92 100 100 
    100 100 91 90 90 90 90 90 90 90 90 90 90 90 90 90 90 86 86 86 86 84 83 83 
    85 85 82 82 82 82 80 80 81 93 62 78 78 77 77 76 76 75 75 74 74 73 73 73 72
    72 72 72 72 71 71 71 70 70 70 69 69 69 69 68 68 68 68 68 79 79 79 79 79 79
    79 79 79 79 88 63 63 87 61 61 89 60 60 60 60 98 67 66 99 95 65 64 101 101))

(define tsh-ia-pat-v
  #(((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) (44 . 6) (45 . 7) (46 . 8) 
    (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13) (51 . 14) (52 . 15) 
    (90 . 16) (91 . 17) (56 . 18) (57 . 19) (100 . 20) (102 . 21) (103 . 22) 
    (1 . -20)) ((1 . -109)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) 
    (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) 
    (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) (93 . 82)) 
    ((12 . 1) (98 . 81)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) 
    (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) 
    (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) (93 . 80) 
    (1 . -33)) ((61 . 36) (87 . 79) (1 . -102)) ((55 . 78)) ((12 . 1) (5 . 38)
    (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) 
    (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (79 . 75) (93 . 77)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) 
    (93 . 76)) ((1 . -28)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) 
    (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13
    ) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 74) 
    (1 . -20)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 61) (72 . 62) 
    (73 . 63) (74 . 64) (75 . 65) (76 . 66) (77 . 67) (78 . 68) (62 . 69) 
    (63 . 70) (88 . 71)) ((61 . 36) (87 . 37) (1 . -102)) ((12 . 1) (98 . 34) 
    (49 . 35)) ((11 . 30) (12 . 31) (60 . 32) (89 . 33)) ((1 . -21)) ((1 . -19
    )) ((1 . -18)) ((12 . 1) (98 . 29)) ((11 . 27) (99 . 28)) ((3 . 23) 
    (4 . 24) (101 . 26)) ((3 . 23) (4 . 24) (101 . 25)) ((59 . 0)) ((1 . -117)
    ) ((1 . -116)) ((1 . -5)) ((1 . -6)) ((1 . -112)) ((1 . -7)) ((12 . 1) 
    (98 . 40) (95 . 121) (55 . 122)) ((10 . -106) (1 . -106)) ((10 . -105) 
    (1 . -105)) ((10 . 120) (1 . -104)) ((1 . -22)) ((12 . 1) (5 . 38) 
    (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) 
    (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (79 . 75) (93 . 119)) ((48 . 118)) ((12 . 1) (5 . 38) (6 . 39) 
    (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) 
    (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) 
    (79 . 117) (1 . -101)) ((1 . -25)) ((1 . -115)) ((1 . -114)) ((1 . -113)) 
    ((1 . -111)) ((1 . -110)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) 
    (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13
    ) (90 . 116)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 61) (72 . 62) 
    (73 . 63) (74 . 64) (75 . 65) (76 . 66) (77 . 67) (78 . 68) (62 . 69) 
    (63 . 70) (88 . 115)) ((1 . -95)) ((1 . -94)) ((1 . -93)) ((1 . -92)) 
    ((1 . -91)) ((1 . -90)) ((48 . 114)) ((1 . -88)) ((12 . 1) (5 . 38) 
    (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) 
    (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 113)) 
    ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43
    ) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) 
    (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) 
    (68 . 112)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 111)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) 
    (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 110)) ((1 . -83)) ((1 . -79)
    ) ((21 . 107) (20 . 108) (19 . 109) (1 . -76)) ((23 . 105) (22 . 106) 
    (1 . -73)) ((25 . 103) (24 . 104) (1 . -68)) ((29 . 99) (28 . 100) 
    (27 . 101) (26 . 102) (1 . -65)) ((31 . 97) (30 . 98) (1 . -63)) ((32 . 96
    ) (1 . -61)) ((33 . 95) (1 . -59)) ((34 . 94) (1 . -57)) ((35 . 93) 
    (1 . -55)) ((36 . 92) (1 . -54)) ((1 . -99)) ((13 . 91) (1 . -98)) 
    ((47 . 90)) ((3 . 23) (4 . 24) (101 . 89) (1 . -16)) ((1 . -15)) ((54 . 88
    )) ((1 . -53)) ((55 . 87)) ((55 . 86)) ((12 . 1) (40 . 2) (41 . 3) 
    (42 . 4) (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) 
    (98 . 12) (50 . 13) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) 
    (92 . 73) (96 . 85) (1 . -20)) ((1 . -32)) ((1 . -34)) ((12 . 1) (5 . 38) 
    (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) 
    (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (79 . 75) (93 . 84) (1 . -35)) ((55 . 83)) ((12 . 1) (40 . 2) 
    (41 . 3) (42 . 4) (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) 
    (48 . 11) (98 . 12) (50 . 13) (51 . 14) (52 . 15) (90 . 16) (91 . 17) 
    (100 . 72) (92 . 73) (96 . 158) (1 . -20)) ((1 . -36)) ((54 . 157)) 
    ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) (44 . 6) (45 . 7) (46 . 8) 
    (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13) (51 . 14) (52 . 15) 
    (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 156) (1 . -20)) ((12 . 1) 
    (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44
    ) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (79 . 75) (3 . 23) (4 . 24) (93 . 151) (101 . 152) (80 . 153) 
    (82 . 154) (85 . 155)) ((1 . -27)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) 
    (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12)
    (50 . 13) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 150) 
    (1 . -20)) ((1 . -26)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) 
    (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) 
    (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) 
    (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 61) 
    (72 . 62) (73 . 63) (74 . 64) (75 . 65) (76 . 66) (77 . 67) (78 . 68) 
    (62 . 149)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 61) (72 . 62) 
    (73 . 63) (74 . 64) (75 . 65) (76 . 66) (77 . 148)) ((12 . 1) (5 . 38) 
    (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) 
    (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) 
    (69 . 59) (70 . 60) (71 . 61) (72 . 62) (73 . 63) (74 . 64) (75 . 65) 
    (76 . 147)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 61) (72 . 62) 
    (73 . 63) (74 . 64) (75 . 146)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) 
    (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) 
    (71 . 61) (72 . 62) (73 . 63) (74 . 145)) ((12 . 1) (5 . 38) (6 . 39) 
    (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) 
    (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) 
    (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) 
    (70 . 60) (71 . 61) (72 . 62) (73 . 144)) ((12 . 1) (5 . 38) (6 . 39) 
    (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) 
    (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) 
    (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) 
    (70 . 60) (71 . 61) (72 . 143)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) 
    (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) 
    (71 . 61) (72 . 142)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) 
    (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) 
    (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) 
    (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 141)) 
    ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43
    ) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) 
    (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) 
    (68 . 58) (69 . 59) (70 . 60) (71 . 140)) ((12 . 1) (5 . 38) (6 . 39) 
    (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) 
    (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) 
    (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) 
    (70 . 60) (71 . 139)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) 
    (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) 
    (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) 
    (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 138)) 
    ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43
    ) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) 
    (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) 
    (68 . 58) (69 . 59) (70 . 137)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) 
    (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 136)) 
    ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43
    ) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) 
    (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) 
    (68 . 58) (69 . 135)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) 
    (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) 
    (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) 
    (23 . 55) (22 . 56) (79 . 57) (68 . 58) (69 . 134)) ((12 . 1) (5 . 38) 
    (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) 
    (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 133)) 
    ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43
    ) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) 
    (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) 
    (68 . 132)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 131)) ((1 . -84)) ((1 . -85)) ((1 . -86)) 
    ((1 . -87)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (17 . 53) (18 . 54) (23 . 55) 
    (22 . 56) (79 . 57) (68 . 58) (69 . 59) (70 . 60) (71 . 61) (72 . 62) 
    (73 . 63) (74 . 64) (75 . 65) (76 . 66) (77 . 67) (78 . 68) (62 . 69) 
    (63 . 70) (88 . 130)) ((47 . 129)) ((14 . 128)) ((1 . -103)) ((12 . 1) 
    (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44
    ) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (17 . 53) (18 . 54) (23 . 55) (22 . 56) (79 . 57) (68 . 58) 
    (69 . 59) (70 . 60) (71 . 61) (72 . 62) (73 . 63) (74 . 64) (75 . 65) 
    (76 . 66) (77 . 67) (78 . 68) (62 . 69) (63 . 70) (88 . 127)) ((1 . -23)) 
    ((9 . 126)) ((55 . 125)) ((94 . 123) (97 . 124) (1 . -11)) ((12 . 1) 
    (98 . 174) (55 . 175) (53 . 176) (1 . -10)) ((54 . 173)) ((12 . 1) 
    (40 . 2) (41 . 3) (42 . 4) (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) 
    (55 . 10) (48 . 11) (98 . 12) (50 . 13) (51 . 14) (52 . 15) (90 . 16) 
    (91 . 17) (100 . 72) (92 . 73) (96 . 172) (1 . -20)) ((10 . 171)) (
    (47 . 170)) ((1 . -97)) ((1 . -96)) ((47 . 169)) ((1 . -82)) ((1 . -81)) 
    ((1 . -80)) ((21 . 107) (20 . 108) (19 . 109) (1 . -78)) ((21 . 107) 
    (20 . 108) (19 . 109) (1 . -77)) ((23 . 105) (22 . 106) (1 . -75)) 
    ((23 . 105) (22 . 106) (1 . -74)) ((25 . 103) (24 . 104) (1 . -72)) 
    ((25 . 103) (24 . 104) (1 . -71)) ((25 . 103) (24 . 104) (1 . -70)) 
    ((25 . 103) (24 . 104) (1 . -69)) ((29 . 99) (28 . 100) (27 . 101) 
    (26 . 102) (1 . -67)) ((29 . 99) (28 . 100) (27 . 101) (26 . 102) (1 . -66
    )) ((31 . 97) (30 . 98) (1 . -64)) ((32 . 96) (1 . -62)) ((33 . 95) 
    (1 . -60)) ((34 . 94) (1 . -58)) ((35 . 93) (1 . -56)) ((1 . -100)) 
    ((1 . -17)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) 
    (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) 
    (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) (93 . 167) (55 . 168)) 
    ((1 . -47)) ((1 . -46)) ((37 . 163) (81 . 164) (12 . 1) (5 . 38) (6 . 39) 
    (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) 
    (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) 
    (79 . 75) (93 . 151) (80 . 165) (3 . 23) (4 . 24) (101 . 166) (1 . -44)) 
    ((54 . 162)) ((54 . 161)) ((55 . 160)) ((54 . 159)) ((39 . 186) (38 . 187)
    (83 . 188) (84 . 189) (1 . -37)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) 
    (93 . 185)) ((1 . -30)) ((1 . -29)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) 
    (93 . 184)) ((1 . -45)) ((1 . -48)) ((1 . -49)) ((1 . -50)) ((12 . 1) 
    (40 . 2) (41 . 3) (42 . 4) (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) 
    (55 . 10) (48 . 11) (98 . 12) (50 . 13) (51 . 14) (52 . 15) (90 . 16) 
    (91 . 17) (100 . 72) (92 . 73) (96 . 183) (1 . -20)) ((1 . -89)) ((12 . 1)
    (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44
    ) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (79 . 75) (93 . 182)) ((11 . 180) (12 . 181)) ((54 . 179)) 
    ((55 . 178)) ((1 . -12)) ((12 . 1) (98 . 177)) ((1 . -14)) ((12 . 1) 
    (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44
    ) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) 
    (16 . 52) (79 . 75) (93 . 197)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) 
    (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12)
    (50 . 13) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) 
    (96 . 196) (1 . -20)) ((1 . -9)) ((10 . -108) (1 . -108)) ((10 . -107) 
    (1 . -107)) ((1 . -24)) ((54 . 195)) ((1 . -52)) ((54 . 194)) ((55 . 193))
    ((12 . 1) (5 . 38) (6 . 39) (98 . 40) (11 . 27) (7 . 41) (8 . 42) (15 . 43
    ) (48 . 44) (64 . 45) (65 . 46) (95 . 47) (99 . 48) (66 . 49) (67 . 50) 
    (49 . 51) (16 . 52) (79 . 75) (93 . 192)) ((38 . 191) (1 . -41)) ((39 . 
    190) (1 . -39)) ((55 . 204)) ((12 . 1) (5 . 38) (6 . 39) (98 . 40) 
    (11 . 27) (7 . 41) (8 . 42) (15 . 43) (48 . 44) (64 . 45) (65 . 46) 
    (95 . 47) (99 . 48) (66 . 49) (67 . 50) (49 . 51) (16 . 52) (79 . 75) 
    (93 . 203)) ((55 . 202)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) 
    (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13
    ) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 201) 
    (1 . -20)) ((55 . 200)) ((1 . -51)) ((54 . 199)) ((54 . 198)) ((1 . -13)) 
    ((1 . -8)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) (44 . 6) (45 . 7)
    (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13) (51 . 14) 
    (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 209) (1 . -20)) 
    ((54 . 208)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) (44 . 6) 
    (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13) 
    (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 207) 
    (1 . -20)) ((55 . 206)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) 
    (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13
    ) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 205) 
    (1 . -20)) ((54 . 213)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) (43 . 5) 
    (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12) (50 . 13
    ) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) (96 . 212) 
    (1 . -20)) ((54 . 211)) ((1 . -38)) ((54 . 210)) ((55 . 215)) ((1 . -42)) 
    ((54 . 214)) ((1 . -40)) ((1 . -43)) ((12 . 1) (40 . 2) (41 . 3) (42 . 4) 
    (43 . 5) (44 . 6) (45 . 7) (46 . 8) (86 . 9) (55 . 10) (48 . 11) (98 . 12)
    (50 . 13) (51 . 14) (52 . 15) (90 . 16) (91 . 17) (100 . 72) (92 . 73) 
    (96 . 216) (1 . -20)) ((54 . 217)) ((1 . -31))))

(define tsh-ia-tables
  (list
   (cons 'mtab tsh-ia-mtab)
   (cons 'ntab tsh-ia-ntab)
   (cons 'len-v tsh-ia-len-v)
   (cons 'rto-v tsh-ia-rto-v)
   (cons 'pat-v tsh-ia-pat-v)
   ))

;;; end tables
