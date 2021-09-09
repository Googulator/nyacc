;; tsh-tab.scm

;; Copyright (C) 2021 Matthew R. Wette
;; 
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; See the file COPYING included with the this distribution.

(define tsh-mtab
  '(($start . 75) ("\n" . 3) (";" . 4) ($float . 5) ($fixed . 6) ($ident . 7) 
    ("," . 8) ("]" . 9) ("[" . 10) (")" . 11) ("(" . 12) ("--" . 13) ("++" . 
    14) ("~" . 15) ("!" . 16) ("%" . 17) ("/" . 18) ("*" . 19) ("-" . 20) 
    ("+" . 21) (">>" . 22) ("<<" . 23) (">=" . 24) (">" . 25) ("<=" . 26) 
    ("<" . 27) ("!=" . 28) ("==" . 29) ("&" . 30) ("^" . 31) ("|" . 32) 
    ("&&" . 33) ("||" . 34) ("if" . 35) ("set" . 36) ($lone-comm . 37) 
    ("}" . 38) ("{" . 39) ("proc" . 40) ($error . 2) ($end . 42)))

(define tsh-ntab
  '((43 . expr-seq-1) (44 . expression) (45 . expression-list-1) (46 . 
    expr-seq) (47 . expression-list) (48 . float) (49 . fixed) (50 . 
    postfix-expression) (51 . unary-expression) (52 . 
    multiplicative-expression) (53 . additive-expression) (54 . 
    shift-expression) (55 . relational-expression) (56 . equality-expression) 
    (57 . bitwise-and-expression) (58 . bitwise-xor-expression) (59 . 
    bitwise-or-expression) (60 . logical-and-expression) (61 . 
    logical-or-expression) (62 . primary-expression) (63 . if-stmt) (64 . 
    stmt-list-1) (65 . expr) (66 . arg-list-1) (67 . stmt) (68 . stmt-list) 
    (69 . arg-list) (70 . ident) (71 . item) (72 . term) (73 . item-list-1) 
    (74 . item-list) (75 . top)))

(define tsh-len-v
  #(1 1 1 0 3 8 1 1 0 2 5 1 0 3 1 3 3 1 5 1 1 1 3 1 3 1 3 1 3 1 3 1 3 3 1 3 3
    3 3 1 3 3 1 3 3 1 3 3 3 1 2 2 2 2 2 2 1 2 2 1 1 1 3 4 1 1 3 1 0 2 1 1 1 1 
    1))

(define tsh-rto-v
  #(#f 75 74 73 73 71 71 69 66 66 66 68 64 64 67 67 67 67 63 65 44 61 61 60 
    60 59 59 58 58 57 57 56 56 56 55 55 55 55 55 54 54 54 53 53 53 52 52 52 52
    51 51 51 51 51 51 51 50 50 50 62 62 62 62 62 47 45 45 46 43 43 70 49 48 72
    72))

(define tsh-pat-v
  #(((73 . 1) (74 . 2) (75 . 3) (1 . -3)) ((3 . 4) (4 . 5) (72 . 6) (1 . -2))
    ((1 . -1)) ((42 . 0)) ((1 . -74)) ((1 . -73)) ((35 . 7) (63 . 8) (36 . 9) 
    (39 . 10) (37 . 11) (67 . 12) (40 . 13) (71 . 14)) ((5 . 20) (6 . 21) 
    (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 27) 
    (65 . 28)) ((1 . -17)) ((7 . 15) (70 . 19)) ((64 . 17) (68 . 18) (1 . -12)
    ) ((1 . -14)) ((1 . -6)) ((7 . 15) (70 . 16)) ((1 . -4)) ((1 . -70)) 
    ((39 . 56)) ((3 . 4) (4 . 5) (72 . 55) (1 . -11)) ((38 . 54)) ((5 . 20) 
    (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) 
    (62 . 27) (65 . 53)) ((1 . -72)) ((1 . -71)) ((7 . 15) (70 . 52)) (
    (5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) 
    (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) 
    (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 41) (55 . 42) 
    (56 . 43) (57 . 44) (58 . 45) (59 . 46) (60 . 47) (61 . 48) (44 . 49) 
    (45 . 50) (47 . 51)) ((1 . -61)) ((1 . -60)) ((1 . -59)) ((1 . -19)) 
    ((39 . 29)) ((64 . 17) (68 . 90) (1 . -12)) ((1 . -56)) ((5 . 20) (6 . 21)
    (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) 
    (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) 
    (51 . 89)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 88)) ((5 . 20) (6 . 21) (7 . 15) 
    (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) 
    (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 87)) 
    ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) 
    (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) 
    (20 . 36) (50 . 37) (51 . 86)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) 
    (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) 
    (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 85)) ((5 . 20) 
    (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) 
    (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) 
    (50 . 37) (51 . 84)) ((14 . 82) (13 . 83) (1 . -49)) ((1 . -45)) ((19 . 79
    ) (18 . 80) (17 . 81) (1 . -42)) ((21 . 77) (20 . 78) (1 . -39)) ((23 . 75
    ) (22 . 76) (1 . -34)) ((27 . 71) (26 . 72) (25 . 73) (24 . 74) (1 . -31))
    ((29 . 69) (28 . 70) (1 . -29)) ((30 . 68) (1 . -27)) ((31 . 67) (1 . -25)
    ) ((32 . 66) (1 . -23)) ((33 . 65) (1 . -21)) ((34 . 64) (1 . -20)) 
    ((1 . -65)) ((8 . 63) (1 . -64)) ((11 . 62)) ((43 . 60) (46 . 61) (1 . -68
    )) ((1 . -16)) ((1 . -15)) ((35 . 7) (63 . 8) (36 . 9) (39 . 10) (37 . 11)
    (67 . 59)) ((66 . 57) (69 . 58) (1 . -8)) ((7 . 15) (70 . 114) (39 . 115) 
    (1 . -7)) ((38 . 113)) ((1 . -13)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) 
    (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 112) (1 . -67)) ((9 . 111)) 
    ((1 . -62)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 41) 
    (55 . 42) (56 . 43) (57 . 44) (58 . 45) (59 . 46) (60 . 47) (61 . 48) 
    (44 . 110)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 41) 
    (55 . 42) (56 . 43) (57 . 44) (58 . 45) (59 . 46) (60 . 109)) ((5 . 20) 
    (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) 
    (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) 
    (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 41) (55 . 42) (56 . 43) 
    (57 . 44) (58 . 45) (59 . 108)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) 
    (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) 
    (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) 
    (53 . 40) (54 . 41) (55 . 42) (56 . 43) (57 . 44) (58 . 107)) ((5 . 20) 
    (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) 
    (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) 
    (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 41) (55 . 42) (56 . 43) 
    (57 . 106)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 41) 
    (55 . 42) (56 . 105)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) 
    (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) 
    (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) 
    (54 . 41) (55 . 104)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) 
    (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) 
    (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) 
    (54 . 41) (55 . 103)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) 
    (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) 
    (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) 
    (54 . 102)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 101)) 
    ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) 
    (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) 
    (20 . 36) (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 100)) ((5 . 20) 
    (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) 
    (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) 
    (50 . 37) (51 . 38) (52 . 39) (53 . 40) (54 . 99)) ((5 . 20) (6 . 21) 
    (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) 
    (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) 
    (51 . 38) (52 . 39) (53 . 98)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) 
    (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) 
    (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 39) 
    (53 . 97)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 38) (52 . 96)) ((5 . 20) (6 . 21) 
    (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) 
    (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) 
    (51 . 38) (52 . 95)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) 
    (48 . 24) (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) 
    (16 . 34) (21 . 35) (20 . 36) (50 . 37) (51 . 94)) ((5 . 20) (6 . 21) 
    (7 . 15) (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 30) 
    (13 . 31) (14 . 32) (15 . 33) (16 . 34) (21 . 35) (20 . 36) (50 . 37) 
    (51 . 93)) ((5 . 20) (6 . 21) (7 . 15) (10 . 22) (12 . 23) (48 . 24) 
    (49 . 25) (70 . 26) (62 . 30) (13 . 31) (14 . 32) (15 . 33) (16 . 34) 
    (21 . 35) (20 . 36) (50 . 37) (51 . 92)) ((1 . -57)) ((1 . -58)) ((1 . -50
    )) ((1 . -51)) ((1 . -52)) ((1 . -53)) ((1 . -54)) ((1 . -55)) ((38 . 91))
    ((1 . -18)) ((1 . -48)) ((1 . -47)) ((1 . -46)) ((19 . 79) (18 . 80) 
    (17 . 81) (1 . -44)) ((19 . 79) (18 . 80) (17 . 81) (1 . -43)) ((21 . 77) 
    (20 . 78) (1 . -41)) ((21 . 77) (20 . 78) (1 . -40)) ((23 . 75) (22 . 76) 
    (1 . -38)) ((23 . 75) (22 . 76) (1 . -37)) ((23 . 75) (22 . 76) (1 . -36))
    ((23 . 75) (22 . 76) (1 . -35)) ((27 . 71) (26 . 72) (25 . 73) (24 . 74) 
    (1 . -33)) ((27 . 71) (26 . 72) (25 . 73) (24 . 74) (1 . -32)) ((29 . 69) 
    (28 . 70) (1 . -30)) ((30 . 68) (1 . -28)) ((31 . 67) (1 . -26)) ((32 . 66
    ) (1 . -24)) ((33 . 65) (1 . -22)) ((1 . -66)) ((1 . -63)) ((1 . -69)) 
    ((39 . 117)) ((1 . -9)) ((7 . 15) (70 . 116)) ((5 . 20) (6 . 21) (7 . 15) 
    (10 . 22) (12 . 23) (48 . 24) (49 . 25) (70 . 26) (62 . 27) (65 . 119)) 
    ((64 . 17) (68 . 118) (1 . -12)) ((38 . 121)) ((38 . 120)) ((1 . -10)) 
    ((1 . -5))))

(define tsh-tables
  (list
   (cons 'mtab tsh-mtab)
   (cons 'ntab tsh-ntab)
   (cons 'len-v tsh-len-v)
   (cons 'rto-v tsh-rto-v)
   (cons 'pat-v tsh-pat-v)
   ))

;;; end tables