;; mach.d/octia-tab.scm

;; Copyright 2015-2018 Matthew R. Wette
;; 
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; See the file COPYING.LESSER included with the this distribution.

(define octia-len-v
  #(1 3 3 2 2 1 0 2 1 1 4 3 2 2 2 1 10 9 8 7 6 5 1 3 1 2 1 1 2 1 1 1 1 2 1 2 
    1 3 7 5 8 6 7 5 8 5 1 2 1 1 1 2 4 5 0 5 1 1 3 3 1 2 1 2 1 3 1 3 5 3 5 1 3 
    1 3 1 3 3 1 3 3 3 3 1 3 3 3 3 1 3 3 3 3 3 3 3 3 1 2 2 2 1 2 2 4 3 3 1 1 1 
    3 2 3 2 3 1 3 1 1 1 3 1 2 1 1 1 1 2 3 1 1 1 1 1 1 1 1))

(define octia-pat-v
  #(((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) (48 . 29) 
    (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) (45 . 36) 
    (46 . 37) (85 . 38) (54 . 39) (86 . 40) (94 . 41) (87 . 42) (93 . 43) 
    (104 . 44) (88 . 45) (98 . 46) (99 . 47) (102 . 48) (100 . 49)) ((1 . -131
    )) ((1 . -130)) ((1 . -134)) ((1 . -133)) ((1 . -132)) ((1 . -129)) 
    ((34 . 102) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (74 . 25) (85 . 99) (63 . 100) (64 . 103)) ((52 . 98) 
    (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (74 . 25) (85 . 99) (63 . 100) (64 . 101)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) 
    (85 . 97)) ((1 . -109)) ((1 . -108)) ((1 . -107)) ((1 . -101)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (67 . 96)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (67 . 95)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4)
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (67 . 94)) ((11 . 90) (10 . 91) (50 . 92) (9 . 93) (1 . -97)) 
    ((1 . -88)) ((20 . 82) (19 . 83) (18 . 84) (17 . 85) (16 . 86) (15 . 87) 
    (14 . 88) (13 . 89) (1 . -83)) ((24 . 78) (23 . 79) (22 . 80) (21 . 81) 
    (1 . -78)) ((28 . 74) (27 . 75) (26 . 76) (25 . 77) (1 . -75)) ((30 . 72) 
    (29 . 73) (1 . -73)) ((31 . 71) (1 . -71)) ((1 . -136)) ((33 . 69) 
    (32 . 70) (1 . -66)) ((1 . -49)) ((1 . -48)) ((1 . -135)) ((1 . -125)) 
    ((1 . -124)) ((1 . -123)) ((7 . 6) (90 . 67) (81 . 68)) ((1 . -46)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (74 . 25) (85 . 66)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (74 . 25) (85 . 65)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) 
    (85 . 64)) ((7 . 6) (90 . 63)) ((51 . 62) (1 . -36)) ((53 . 60) (7 . 6) 
    (90 . 61)) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 59)) ((1 . -34)) 
    ((47 . 58)) ((3 . 28) (87 . 55) (59 . 56) (92 . 57) (1 . -15)) ((1 . -30))
    ((1 . -29)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (74 . 25) (38 . 26) (39 . 27) (47 . 24) (82 . 32) 
    (40 . 33) (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (48 . 29) 
    (8 . 30) (61 . 31) (86 . 40) (104 . 50) (94 . 51) (97 . 52) (55 . 53) 
    (95 . 54)) ((1 . -9)) ((1 . -8)) ((57 . 0)) ((1 . -32)) ((1 . -31)) 
    ((55 . 53) (95 . 150) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) 
    (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) 
    (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) 
    (104 . 44) (88 . 45) (99 . 151) (96 . 152)) ((47 . 24) (48 . 29) (8 . 30) 
    (61 . 31) (94 . 149)) ((1 . -12)) ((47 . 24) (61 . 148)) ((3 . 28) 
    (87 . 147) (1 . -126)) ((1 . -14)) ((1 . -33)) ((1 . -35)) ((7 . 6) 
    (90 . 145) (91 . 146)) ((50 . 143) (51 . 144)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) (85 . 142)) 
    ((51 . 141)) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 140)) ((47 . 24
    ) (48 . 29) (8 . 30) (61 . 31) (94 . 139)) ((47 . 24) (48 . 29) (8 . 30) 
    (61 . 31) (94 . 138)) ((1 . -50)) ((7 . 6) (90 . 137) (1 . -47)) ((55 . 
    135) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (74 . 136)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 134)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 133)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 132)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 131)) 
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
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 127)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 126)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 125)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 124)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 123)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 122)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 121)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 120)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 119)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 118)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 117)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 116)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 115)) ((1 . -102)) ((1 . -103)) ((49 . 112) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) (85 . 113) 
    (75 . 114)) ((7 . 6) (90 . 111)) ((11 . 90) (10 . 91) (50 . 92) (9 . 93) 
    (1 . -98)) ((11 . 90) (10 . 91) (50 . 92) (9 . 93) (1 . -99)) ((11 . 90) 
    (10 . 91) (50 . 92) (9 . 93) (1 . -100)) ((49 . 110)) ((1 . -111)) 
    ((1 . -119)) ((48 . 109) (1 . -115)) ((52 . 108) (47 . 24) (61 . 105) 
    (8 . 106) (62 . 107)) ((1 . -113)) ((34 . 104) (47 . 24) (61 . 105) 
    (8 . 106) (62 . 107)) ((1 . -114)) ((1 . -118)) ((1 . -117)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) 
    (74 . 25) (85 . 99) (63 . 169)) ((1 . -112)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) (85 . 168)) 
    ((1 . -110)) ((1 . -106)) ((1 . -105)) ((1 . -64)) ((49 . 166) (48 . 167))
    ((1 . -96)) ((1 . -95)) ((1 . -94)) ((1 . -93)) ((1 . -92)) ((1 . -91)) 
    ((1 . -90)) ((1 . -89)) ((20 . 82) (19 . 83) (18 . 84) (17 . 85) (16 . 86)
    (15 . 87) (14 . 88) (13 . 89) (1 . -87)) ((20 . 82) (19 . 83) (18 . 84) 
    (17 . 85) (16 . 86) (15 . 87) (14 . 88) (13 . 89) (1 . -86)) ((20 . 82) 
    (19 . 83) (18 . 84) (17 . 85) (16 . 86) (15 . 87) (14 . 88) (13 . 89) 
    (1 . -85)) ((20 . 82) (19 . 83) (18 . 84) (17 . 85) (16 . 86) (15 . 87) 
    (14 . 88) (13 . 89) (1 . -84)) ((24 . 78) (23 . 79) (22 . 80) (21 . 81) 
    (1 . -82)) ((24 . 78) (23 . 79) (22 . 80) (21 . 81) (1 . -81)) ((24 . 78) 
    (23 . 79) (22 . 80) (21 . 81) (1 . -80)) ((24 . 78) (23 . 79) (22 . 80) 
    (21 . 81) (1 . -79)) ((28 . 74) (27 . 75) (26 . 76) (25 . 77) (1 . -77)) 
    ((28 . 74) (27 . 75) (26 . 76) (25 . 77) (1 . -76)) ((30 . 72) (29 . 73) 
    (1 . -74)) ((31 . 71) (1 . -72)) ((1 . -69)) ((32 . 70) (33 . 165) 
    (1 . -67)) ((1 . -51)) ((83 . 164) (1 . -54)) ((5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) 
    (38 . 26) (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) 
    (40 . 33) (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) 
    (94 . 41) (87 . 42) (104 . 44) (88 . 45) (99 . 151) (96 . 163)) ((5 . 1) 
    (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) 
    (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) 
    (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) 
    (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) (48 . 29) (8 . 30) 
    (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) (45 . 36) (46 . 37) 
    (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) (88 . 45) (99 . 151) 
    (96 . 162)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (74 . 25) (85 . 161)) ((1 . -37)) ((7 . 6) (90 . 145) 
    (91 . 159) (49 . 160)) ((7 . 6) (90 . 158)) ((1 . -22)) ((48 . 156) 
    (52 . 157)) ((47 . 24) (61 . 155)) ((1 . -127)) ((1 . -13)) ((1 . -11)) 
    ((1 . -24)) ((55 . 53) (95 . 153) (5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) 
    (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) 
    (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) 
    (87 . 42) (104 . 44) (88 . 45) (99 . 154)) ((1 . -10)) ((1 . -25)) 
    ((1 . -128)) ((7 . 6) (90 . 186)) ((51 . 185)) ((50 . 184)) ((49 . 183) 
    (48 . 156)) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 182)) ((47 . 24)
    (48 . 29) (8 . 30) (61 . 31) (94 . 181)) ((55 . 180) (5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) 
    (74 . 25) (38 . 26) (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) 
    (82 . 32) (40 . 33) (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) 
    (86 . 40) (94 . 41) (87 . 42) (104 . 44) (88 . 45) (99 . 154)) ((55 . 176)
    (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) (48 . 29) 
    (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) (45 . 36) 
    (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) (88 . 45) 
    (99 . 154) (43 . 177) (37 . 178) (84 . 179)) ((55 . 173) (36 . 174) 
    (41 . 175)) ((55 . 171) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (74 . 172)) ((1 . -104)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) 
    (85 . 170)) ((1 . -120)) ((48 . 109) (1 . -116)) ((1 . -65)) ((1 . -70)) 
    ((32 . 70) (1 . -68)) ((1 . -45)) ((4 . 3) (6 . 2) (35 . 198) (78 . 199) 
    (79 . 200) (80 . 201)) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 197))
    ((1 . -43)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) 
    (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) 
    (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) 
    (88 . 45) (99 . 151) (96 . 196)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) (85 . 195)) ((43 . 192) 
    (37 . 193) (55 . 194)) ((1 . -39)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) 
    (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) 
    (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) 
    (87 . 42) (104 . 44) (88 . 45) (99 . 151) (96 . 191)) ((1 . -21)) (
    (47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 190)) ((7 . 6) (90 . 145) 
    (91 . 188) (49 . 189)) ((7 . 6) (90 . 187)) ((1 . -23)) ((50 . 215)) 
    ((49 . 214) (48 . 156)) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 213)
    ) ((1 . -20)) ((55 . 212) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) 
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) 
    (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) 
    (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) 
    (104 . 44) (88 . 45) (99 . 154)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) 
    (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) 
    (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) 
    (87 . 42) (104 . 44) (88 . 45) (99 . 151) (96 . 211)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (74 . 25) 
    (85 . 210)) ((1 . -41)) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 209)
    ) ((55 . 208) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) 
    (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) 
    (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) 
    (88 . 45) (99 . 154)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) 
    (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) 
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) 
    (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) 
    (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) 
    (104 . 44) (88 . 45) (99 . 151) (96 . 207)) ((6 . 2) (79 . 203) (77 . 204)
    (4 . 3) (78 . 205) (76 . 206)) ((1 . -57)) ((1 . -56)) ((47 . 24) (48 . 29
    ) (8 . 30) (61 . 31) (94 . 202)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) 
    (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) 
    (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) 
    (87 . 42) (104 . 44) (88 . 45) (99 . 151) (96 . 227)) ((1 . -60)) (
    (34 . 225) (6 . 2) (79 . 226)) ((1 . -62)) ((34 . 223) (4 . 3) (78 . 224))
    ((55 . 222) (5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) 
    (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) 
    (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) 
    (88 . 45) (99 . 154)) ((1 . -42)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) 
    (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) 
    (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) 
    (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) 
    (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) 
    (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) 
    (87 . 42) (104 . 44) (88 . 45) (99 . 151) (96 . 221)) ((47 . 24) (48 . 29)
    (8 . 30) (61 . 31) (94 . 220)) ((55 . 219) (5 . 1) (6 . 2) (4 . 3) 
    (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) 
    (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) 
    (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) 
    (38 . 26) (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) 
    (40 . 33) (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) 
    (94 . 41) (87 . 42) (104 . 44) (88 . 45) (99 . 154)) ((1 . -38)) ((1 . -19
    )) ((47 . 24) (48 . 29) (8 . 30) (61 . 31) (94 . 218)) ((7 . 6) (90 . 145)
    (91 . 216) (49 . 217)) ((49 . 230) (48 . 156)) ((47 . 24) (48 . 29) 
    (8 . 30) (61 . 31) (94 . 229)) ((1 . -18)) ((1 . -40)) ((5 . 1) (6 . 2) 
    (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) 
    (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) (23 . 16) (67 . 17) 
    (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) (73 . 23) (47 . 24) 
    (74 . 25) (38 . 26) (39 . 27) (3 . 28) (48 . 29) (8 . 30) (61 . 31) 
    (82 . 32) (40 . 33) (42 . 34) (44 . 35) (45 . 36) (46 . 37) (85 . 38) 
    (86 . 40) (94 . 41) (87 . 42) (104 . 44) (88 . 45) (99 . 151) (96 . 228)) 
    ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) (53 . 8) 
    (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) (24 . 15) 
    (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) (72 . 22) 
    (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) (48 . 29) 
    (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) (45 . 36) 
    (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) (88 . 45) 
    (99 . 154) (1 . -52)) ((1 . -44)) ((1 . -59)) ((1 . -63)) ((1 . -58)) 
    ((1 . -61)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5) (7 . 6) (35 . 7) 
    (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13) (12 . 14) 
    (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) (71 . 21) 
    (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) (3 . 28) 
    (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) (44 . 35) 
    (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) (104 . 44) 
    (88 . 45) (99 . 154) (1 . -55)) ((5 . 1) (6 . 2) (4 . 3) (58 . 4) (79 . 5)
    (7 . 6) (35 . 7) (53 . 8) (50 . 9) (78 . 10) (65 . 11) (90 . 12) (66 . 13)
    (12 . 14) (24 . 15) (23 . 16) (67 . 17) (68 . 18) (69 . 19) (70 . 20) 
    (71 . 21) (72 . 22) (73 . 23) (47 . 24) (74 . 25) (38 . 26) (39 . 27) 
    (3 . 28) (48 . 29) (8 . 30) (61 . 31) (82 . 32) (40 . 33) (42 . 34) 
    (44 . 35) (45 . 36) (46 . 37) (85 . 38) (86 . 40) (94 . 41) (87 . 42) 
    (104 . 44) (88 . 45) (99 . 154) (1 . -53)) ((1 . -17)) ((47 . 24) (48 . 29
    ) (8 . 30) (61 . 31) (94 . 231)) ((1 . -16))))

(define octia-rto-v
  #(#f 106 106 106 106 103 101 101 100 100 102 102 102 95 98 98 93 93 93 93 
    93 93 91 91 96 96 105 89 89 99 99 97 97 88 88 104 86 86 86 86 86 86 86 86 
    86 86 86 86 82 82 81 81 84 84 83 83 80 80 80 80 77 77 76 76 75 75 85 85 85
    85 85 74 74 73 73 72 72 72 71 71 71 71 71 70 70 70 70 70 69 69 69 69 69 69
    69 69 69 68 68 68 68 67 67 67 67 67 67 66 66 66 66 66 66 66 66 64 64 62 62
    63 63 60 60 94 94 94 92 59 59 90 79 58 65 65 78 87 61))

(define octia-mtab
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

(define octia-tables
  (list
   (cons 'len-v octia-len-v)
   (cons 'pat-v octia-pat-v)
   (cons 'rto-v octia-rto-v)
   (cons 'mtab octia-mtab)))

;;; end tables
