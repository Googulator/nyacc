;; ./mach.d/cpptab.scm

;; Copyright (C) 2016,2017 Matthew R. Wette
;; 
;; This software is covered by the GNU GENERAL PUBLIC LICENCE, Version 3,
;; or any later version published by the Free Software Foundation.  See
;; the file COPYING included with the this distribution.

(define len-v
  #(1 1 5 1 3 1 3 1 3 1 3 1 3 1 3 3 1 3 3 3 3 1 3 3 1 3 3 1 3 3 3 1 2 2 2 2 
    2 2 1 2 2 1 1 1 4 3 1 3))

(define pat-v
  #(((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 
    9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (
    42 . 17) (43 . 18) (44 . 19) (45 . 20) (46 . 21) (47 . 22) (48 . 23) (49 
    . 24) (50 . 25)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7)
    (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 
    15) (41 . 16) (42 . 17) (43 . 18) (44 . 19) (45 . 20) (46 . 21) (47 . 22) 
    (48 . 23) (49 . 24) (50 . 54) (36 . 55)) ((3 . 53)) ((-1 . -43)) ((-1 . 
    -42)) ((-1 . -41)) ((-1 . -38)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (
    37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (
    39 . 52)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8
    ) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 51)) ((3 . 1) (4 
    . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (
    16 . 11) (15 . 12) (38 . 13) (39 . 50)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (
    7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38
    . 13) (39 . 49)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7
    ) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 48)) ((3 
    . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11
    . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 47)) ((9 . 45) (8 . 46) (-1 . 
    -31)) ((-1 . -27)) ((14 . 42) (13 . 43) (12 . 44) (-1 . -24)) ((16 . 40) (
    15 . 41) (-1 . -21)) ((18 . 38) (17 . 39) (-1 . -16)) ((22 . 34) (21 . 35)
    (20 . 36) (19 . 37) (-1 . -13)) ((24 . 32) (23 . 33) (-1 . -11)) ((25 . 
    31) (-1 . -9)) ((26 . 30) (-1 . -7)) ((27 . 29) (-1 . -5)) ((28 . 28) (-1 
    . -3)) ((31 . 26) (29 . 27) (2 . -1) (1 . -1) (35 . -1)) ((35 . 0)) ((3 . 
    1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 
    . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 17
    ) (43 . 18) (44 . 19) (45 . 20) (46 . 21) (47 . 22) (48 . 23) (49 . 77)) (
    (3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) 
    (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 
    . 17) (43 . 18) (44 . 19) (45 . 20) (46 . 21) (47 . 22) (48 . 76)) ((3 . 1
    ) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 
    10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 17) 
    (43 . 18) (44 . 19) (45 . 20) (46 . 21) (47 . 75)) ((3 . 1) (4 . 2) (5 . 3
    ) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (
    15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 17) (43 . 18) (44 
    . 19) (45 . 20) (46 . 74)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 
    6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 
    14) (40 . 15) (41 . 16) (42 . 17) (43 . 18) (44 . 19) (45 . 73)) ((3 . 1) 
    (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10
    ) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 17) (
    43 . 18) (44 . 72)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 
    . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (
    40 . 15) (41 . 16) (42 . 17) (43 . 71)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (
    7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38
    . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 17) (43 . 70)) ((3 . 1) (4 . 2)
    (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 
    . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 69)) ((3 . 1
    ) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 
    10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 68))
    ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9
    ) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41 . 16) (
    42 . 67)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8
    ) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 15) (41
    . 16) (42 . 66)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7
    ) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 
    . 15) (41 . 65)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7)
    (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 
    15) (41 . 64)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (
    9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 63
    )) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 
    . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 14) (40 . 62)) ((3 . 1)
    (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 
    10) (16 . 11) (15 . 12) (38 . 13) (39 . 61)) ((3 . 1) (4 . 2) (5 . 3) (6 
    . 4) (7 . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 
    12) (38 . 13) (39 . 60)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 6)
    (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 59
    )) ((-1 . -39)) ((-1 . -40)) ((-1 . -32)) ((-1 . -33)) ((-1 . -34)) ((-1 
    . -35)) ((-1 . -36)) ((-1 . -37)) ((7 . 58)) ((2 . -46) (1 . -46)) ((2 . 
    56) (1 . 57)) ((-1 . -45)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 . 5) (37 . 
    6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 . 13) (39 . 
    14) (40 . 15) (41 . 16) (42 . 17) (43 . 18) (44 . 19) (45 . 20) (46 . 21) 
    (47 . 22) (48 . 23) (49 . 24) (50 . 80)) ((2 . 79)) ((-1 . -30)) ((-1 . 
    -29)) ((-1 . -28)) ((14 . 42) (13 . 43) (12 . 44) (-1 . -26)) ((14 . 42) (
    13 . 43) (12 . 44) (-1 . -25)) ((16 . 40) (15 . 41) (-1 . -23)) ((16 . 40)
    (15 . 41) (-1 . -22)) ((18 . 38) (17 . 39) (-1 . -20)) ((18 . 38) (17 . 
    39) (-1 . -19)) ((18 . 38) (17 . 39) (-1 . -18)) ((18 . 38) (17 . 39) (-1 
    . -17)) ((22 . 34) (21 . 35) (20 . 36) (19 . 37) (-1 . -15)) ((22 . 34) (
    21 . 35) (20 . 36) (19 . 37) (-1 . -14)) ((24 . 32) (23 . 33) (-1 . -12)) 
    ((25 . 31) (-1 . -10)) ((26 . 30) (-1 . -8)) ((27 . 29) (-1 . -6)) ((28 . 
    28) (-1 . -4)) ((30 . 78) (29 . 27)) ((3 . 1) (4 . 2) (5 . 3) (6 . 4) (7 
    . 5) (37 . 6) (8 . 7) (9 . 8) (10 . 9) (11 . 10) (16 . 11) (15 . 12) (38 
    . 13) (39 . 14) (40 . 15) (41 . 16) (42 . 17) (43 . 18) (44 . 19) (45 . 20
    ) (46 . 21) (47 . 22) (48 . 23) (49 . 24) (50 . 81)) ((-1 . -44)) ((2 . 
    -47) (1 . -47)) ((2 . -2) (1 . -2) (35 . -2))))

(define rto-v
  #(#f 50 50 49 49 48 48 47 47 46 46 45 45 44 44 44 43 43 43 43 43 42 42 42 
    41 41 41 40 40 40 40 39 39 39 39 39 39 39 38 38 38 37 37 37 37 37 36 36))

(define mtab
  '(("," . 1) (")" . 2) ("(" . 3) ("defined" . 4) ($chlit . 5) ($fixed . 6) 
    ($ident . 7) ("--" . 8) ("++" . 9) ("~" . 10) ("!" . 11) ("%" . 12) ("/" 
    . 13) ("*" . 14) ("-" . 15) ("+" . 16) (">>" . 17) ("<<" . 18) (">=" . 19)
    (">" . 20) ("<=" . 21) ("<" . 22) ("!=" . 23) ("==" . 24) ("&" . 25) ("^"
    . 26) ("|" . 27) ("&&" . 28) ("||" . 29) (":" . 30) ("?" . 31) (
    $code-comm . 32) ($lone-comm . 33) ($error . 34) ($end . 35)))

;;; end tables
