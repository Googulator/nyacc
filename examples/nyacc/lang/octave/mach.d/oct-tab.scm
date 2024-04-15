;; mach.d/oct-tab.scm

;; Copyright 2015-2018 Matthew R. Wette
;; 
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; See the file COPYING.LESSER included with the this distribution.

(define oct-len-v
  #(1 3 3 2 2 1 0 2 1 1 4 3 2 2 2 1 10 9 8 7 6 5 1 3 1 2 1 1 2 1 1 1 1 2 1 2 
    1 3 7 5 8 6 7 5 8 5 1 2 1 1 1 2 4 5 0 5 1 1 3 3 1 2 1 2 1 3 1 3 5 3 5 1 3 
    1 3 1 3 3 1 3 3 3 3 1 3 3 3 3 1 3 3 3 3 3 3 3 3 1 2 2 2 1 2 2 4 3 3 1 1 1 
    3 2 3 2 3 1 3 1 1 1 3 1 2 1 1 1 1 2 3 1 1 1 1 1 1 1 1))

(define oct-pat-v
  #(((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (47 . 22) 
    (72 . 23) (3 . 24) (48 . 25) (8 . 26) (61 . 27) (73 . 28) (74 . 29) 
    (38 . 30) (39 . 31) (94 . 32) (87 . 33) (54 . 34) (82 . 35) (40 . 36) 
    (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) (88 . 42) (93 . 43) 
    (86 . 44) (89 . 45) (98 . 46) (102 . 47) (104 . 48) (105 . 49) (106 . 50))
    ((1 . -131)) ((1 . -130)) ((1 . -134)) ((1 . -133)) ((1 . -132)) ((1 . 
    -129)) ((34 . 109) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 106) (63 . 107) (64 . 110)) 
    ((52 . 105) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 23) (73 . 28) (74 . 29) (85 . 106) (63 . 107) (64 . 108)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) 
    (74 . 29) (85 . 104)) ((1 . -109)) ((1 . -108)) ((1 . -107)) ((1 . -101)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (67 . 103)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (67 . 102)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (67 . 101)) ((11 . 97) (10 . 98) (50 . 99) 
    (9 . 100) (1 . -97)) ((1 . -88)) ((20 . 89) (19 . 90) (18 . 91) (17 . 92) 
    (16 . 93) (15 . 94) (14 . 95) (13 . 96) (1 . -83)) ((24 . 85) (23 . 86) 
    (22 . 87) (21 . 88) (1 . -78)) ((28 . 81) (27 . 82) (26 . 83) (25 . 84) 
    (1 . -75)) ((1 . -136)) ((30 . 79) (29 . 80) (1 . -73)) ((1 . -135)) 
    ((1 . -125)) ((1 . -124)) ((1 . -123)) ((31 . 78) (1 . -71)) ((33 . 76) 
    (32 . 77) (1 . -66)) ((1 . -49)) ((1 . -48)) ((1 . -34)) ((47 . 75)) 
    ((53 . 73) (7 . 6) (90 . 74)) ((7 . 6) (90 . 71) (81 . 72)) ((1 . -46)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (74 . 29) (85 . 70)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 69)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) 
    (85 . 68)) ((7 . 6) (90 . 67)) ((51 . 66) (1 . -36)) ((1 . -27)) ((3 . 24)
    (87 . 63) (59 . 64) (92 . 65) (1 . -15)) ((47 . 22) (48 . 25) (8 . 26) 
    (61 . 27) (94 . 62)) ((47 . 22) (3 . 24) (48 . 25) (8 . 26) (61 . 27) 
    (94 . 32) (87 . 33) (88 . 61) (1 . -26)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4)
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (38 . 30) (39 . 31) 
    (47 . 22) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) 
    (85 . 41) (48 . 25) (8 . 26) (61 . 27) (86 . 44) (104 . 56) (94 . 57) 
    (97 . 58) (55 . 59) (95 . 60)) ((101 . 53) (103 . 55) (1 . -6)) ((101 . 53
    ) (103 . 54) (1 . -6)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (74 . 29) (38 . 30) (39 . 31) (82 . 35) 
    (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) 
    (104 . 51) (54 . 34) (93 . 43) (98 . 46) (102 . 52)) ((57 . 0)) ((101 . 53
    ) (103 . 166) (1 . -6)) ((101 . 53) (103 . 165) (1 . -6)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) 
    (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) (8 . 26) 
    (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) 
    (85 . 41) (54 . 34) (86 . 44) (94 . 32) (87 . 33) (93 . 43) (104 . 158) 
    (88 . 159) (98 . 46) (99 . 162) (102 . 163) (100 . 164) (1 . -5)) (
    (1 . -3)) ((1 . -4)) ((1 . -32)) ((1 . -31)) ((55 . 59) (95 . 157) 
    (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) 
    (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) 
    (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) 
    (99 . 160) (96 . 161)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 156))
    ((1 . -12)) ((1 . -28)) ((1 . -35)) ((47 . 22) (61 . 155)) ((3 . 24) 
    (87 . 154) (1 . -126)) ((1 . -14)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 153)) ((51 . 152))
    ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 151)) ((47 . 22) (48 . 25) 
    (8 . 26) (61 . 27) (94 . 150)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) 
    (94 . 149)) ((1 . -50)) ((7 . 6) (90 . 148) (1 . -47)) ((7 . 6) (90 . 146)
    (91 . 147)) ((50 . 144) (51 . 145)) ((1 . -33)) ((55 . 142) (5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) 
    (74 . 143)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 23) (73 . 141)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 140)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 139)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 138)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 137)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 136)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 135)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 134)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 133)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 132)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 131)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 130)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 129)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 128)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 127)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 126)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 125)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 124)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 123)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 122)) ((1 . -102)) ((1 . -103)) ((49 . 119) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 120) 
    (75 . 121)) ((7 . 6) (90 . 118)) ((11 . 97) (10 . 98) (50 . 99) (9 . 100) 
    (1 . -98)) ((11 . 97) (10 . 98) (50 . 99) (9 . 100) (1 . -99)) ((11 . 97) 
    (10 . 98) (50 . 99) (9 . 100) (1 . -100)) ((49 . 117)) ((1 . -111)) 
    ((1 . -119)) ((48 . 116) (1 . -115)) ((52 . 115) (47 . 22) (61 . 112) 
    (8 . 113) (62 . 114)) ((1 . -113)) ((34 . 111) (47 . 22) (61 . 112) 
    (8 . 113) (62 . 114)) ((1 . -114)) ((1 . -118)) ((1 . -117)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) 
    (74 . 29) (85 . 106) (63 . 183)) ((1 . -112)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 182)) 
    ((1 . -110)) ((1 . -106)) ((1 . -105)) ((1 . -64)) ((49 . 180) (48 . 181))
    ((1 . -96)) ((1 . -95)) ((1 . -94)) ((1 . -93)) ((1 . -92)) ((1 . -91)) 
    ((1 . -90)) ((1 . -89)) ((20 . 89) (19 . 90) (18 . 91) (17 . 92) (16 . 93)
    (15 . 94) (14 . 95) (13 . 96) (1 . -87)) ((20 . 89) (19 . 90) (18 . 91) 
    (17 . 92) (16 . 93) (15 . 94) (14 . 95) (13 . 96) (1 . -86)) ((20 . 89) 
    (19 . 90) (18 . 91) (17 . 92) (16 . 93) (15 . 94) (14 . 95) (13 . 96) 
    (1 . -85)) ((20 . 89) (19 . 90) (18 . 91) (17 . 92) (16 . 93) (15 . 94) 
    (14 . 95) (13 . 96) (1 . -84)) ((24 . 85) (23 . 86) (22 . 87) (21 . 88) 
    (1 . -82)) ((24 . 85) (23 . 86) (22 . 87) (21 . 88) (1 . -81)) ((24 . 85) 
    (23 . 86) (22 . 87) (21 . 88) (1 . -80)) ((24 . 85) (23 . 86) (22 . 87) 
    (21 . 88) (1 . -79)) ((28 . 81) (27 . 82) (26 . 83) (25 . 84) (1 . -77)) 
    ((28 . 81) (27 . 82) (26 . 83) (25 . 84) (1 . -76)) ((30 . 79) (29 . 80) 
    (1 . -74)) ((31 . 78) (1 . -72)) ((1 . -69)) ((32 . 77) (33 . 179) 
    (1 . -67)) ((7 . 6) (90 . 146) (91 . 177) (49 . 178)) ((7 . 6) (90 . 176))
    ((1 . -22)) ((48 . 174) (52 . 175)) ((1 . -51)) ((83 . 173) (1 . -54)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) 
    (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) 
    (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) 
    (99 . 160) (96 . 172)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) 
    (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) 
    (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) 
    (104 . 158) (88 . 159) (99 . 160) (96 . 171)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 170)) 
    ((1 . -37)) ((47 . 22) (61 . 169)) ((1 . -127)) ((1 . -13)) ((1 . -11)) 
    ((1 . -30)) ((1 . -29)) ((1 . -24)) ((55 . 59) (95 . 167) (5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (47 . 22) 
    (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) (8 . 26) (61 . 27) 
    (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) 
    (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) (99 . 168)) ((1 . -9)
    ) ((1 . -8)) ((1 . -7)) ((1 . -2)) ((1 . -1)) ((1 . -10)) ((1 . -25)) 
    ((1 . -128)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 200)) ((55 . 
    199) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) 
    (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) 
    (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) 
    (99 . 168)) ((55 . 195) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) 
    (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) 
    (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) 
    (104 . 158) (88 . 159) (99 . 168) (43 . 196) (37 . 197) (84 . 198)) 
    ((55 . 192) (36 . 193) (41 . 194)) ((7 . 6) (90 . 191)) ((51 . 190)) 
    ((50 . 189)) ((49 . 188) (48 . 174)) ((47 . 22) (48 . 25) (8 . 26) 
    (61 . 27) (94 . 187)) ((55 . 185) (5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 186)) ((1 . -104)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) 
    (74 . 29) (85 . 184)) ((1 . -120)) ((48 . 116) (1 . -116)) ((1 . -65)) 
    ((1 . -70)) ((32 . 77) (1 . -68)) ((1 . -21)) ((47 . 22) (48 . 25) 
    (8 . 26) (61 . 27) (94 . 215)) ((7 . 6) (90 . 146) (91 . 213) (49 . 214)) 
    ((7 . 6) (90 . 212)) ((1 . -23)) ((1 . -45)) ((4 . 3) (6 . 2) (35 . 208) 
    (78 . 209) (79 . 210) (80 . 211)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) 
    (94 . 207)) ((1 . -43)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) 
    (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) 
    (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) 
    (104 . 158) (88 . 159) (99 . 160) (96 . 206)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 205)) 
    ((43 . 202) (37 . 203) (55 . 204)) ((1 . -39)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) 
    (38 . 30) (39 . 31) (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) 
    (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) 
    (94 . 32) (87 . 33) (104 . 158) (88 . 159) (99 . 160) (96 . 201)) (
    (55 . 229) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) 
    (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) 
    (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) 
    (88 . 159) (99 . 168)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) 
    (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) 
    (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) 
    (104 . 158) (88 . 159) (99 . 160) (96 . 228)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (74 . 29) (85 . 227)) 
    ((1 . -41)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 226)) ((55 . 225
    ) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) 
    (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) 
    (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) 
    (99 . 168)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) 
    (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) 
    (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) 
    (88 . 159) (99 . 160) (96 . 224)) ((6 . 2) (79 . 220) (77 . 221) (4 . 3) 
    (78 . 222) (76 . 223)) ((1 . -57)) ((1 . -56)) ((47 . 22) (48 . 25) 
    (8 . 26) (61 . 27) (94 . 219)) ((50 . 218)) ((49 . 217) (48 . 174)) 
    ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 216)) ((1 . -20)) ((1 . -19)
    ) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 241)) ((7 . 6) (90 . 146) 
    (91 . 239) (49 . 240)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) 
    (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) 
    (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) 
    (104 . 158) (88 . 159) (99 . 160) (96 . 238)) ((1 . -60)) ((34 . 236) 
    (6 . 2) (79 . 237)) ((1 . -62)) ((34 . 234) (4 . 3) (78 . 235)) ((55 . 233
    ) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) 
    (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) 
    (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) 
    (99 . 168)) ((1 . -42)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) 
    (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) 
    (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) 
    (104 . 158) (88 . 159) (99 . 160) (96 . 232)) ((47 . 22) (48 . 25) 
    (8 . 26) (61 . 27) (94 . 231)) ((55 . 230) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) 
    (38 . 30) (39 . 31) (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) 
    (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) 
    (94 . 32) (87 . 33) (104 . 158) (88 . 159) (99 . 168)) ((1 . -38)) 
    ((1 . -40)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) 
    (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) 
    (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) 
    (88 . 159) (99 . 160) (96 . 244)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) (38 . 30) 
    (39 . 31) (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) (40 . 36) 
    (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) (94 . 32) 
    (87 . 33) (104 . 158) (88 . 159) (99 . 168) (1 . -52)) ((1 . -44)) 
    ((1 . -59)) ((1 . -63)) ((1 . -58)) ((1 . -61)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 23) (73 . 28) (47 . 22) (74 . 29) 
    (38 . 30) (39 . 31) (3 . 24) (48 . 25) (8 . 26) (61 . 27) (82 . 35) 
    (40 . 36) (42 . 37) (44 . 38) (45 . 39) (46 . 40) (85 . 41) (86 . 44) 
    (94 . 32) (87 . 33) (104 . 158) (88 . 159) (99 . 168) (1 . -55)) ((49 . 
    243) (48 . 174)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 242)) 
    ((1 . -18)) ((1 . -17)) ((47 . 22) (48 . 25) (8 . 26) (61 . 27) (94 . 245)
    ) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 23) 
    (73 . 28) (47 . 22) (74 . 29) (38 . 30) (39 . 31) (3 . 24) (48 . 25) 
    (8 . 26) (61 . 27) (82 . 35) (40 . 36) (42 . 37) (44 . 38) (45 . 39) 
    (46 . 40) (85 . 41) (86 . 44) (94 . 32) (87 . 33) (104 . 158) (88 . 159) 
    (99 . 168) (1 . -53)) ((1 . -16))))

(define oct-rto-v
  #(#f 106 106 106 106 103 101 101 100 100 102 102 102 95 98 98 93 93 93 93 
    93 93 91 91 96 96 105 89 89 99 99 97 97 88 88 104 86 86 86 86 86 86 86 86 
    86 86 86 86 82 82 81 81 84 84 83 83 80 80 80 80 77 77 76 76 75 75 85 85 85
    85 85 74 74 73 73 72 72 72 71 71 71 71 71 70 70 70 70 70 69 69 69 69 69 69
    69 69 69 68 68 68 68 67 67 67 67 67 67 66 66 66 66 66 66 66 66 64 64 62 62
    63 63 60 60 94 94 94 92 59 59 90 79 58 65 65 78 87 61))

(define oct-mtab
  '(($start . 106) ($lone-comm . 3) ($string . 4) ($float . 5) ($fixed . 6) 
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

(define oct-tables
  (list
   (cons 'len-v oct-len-v)
   (cons 'pat-v oct-pat-v)
   (cons 'rto-v oct-rto-v)
   (cons 'mtab oct-mtab)))

;;; end tables