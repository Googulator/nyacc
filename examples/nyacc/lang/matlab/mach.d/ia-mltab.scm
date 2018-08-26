;; mach.d/ia-mltab.scm

;; Copyright 2015-2018 Matthew R. Wette
;; 
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; See the file COPYING.LESSER included with the this distribution.

(define ia-ml-len-v
  #(1 1 1 2 1 2 1 2 4 3 2 0 2 2 1 10 9 8 7 6 5 1 3 1 2 1 1 2 0 1 3 7 5 8 6 7 
    5 8 5 1 2 1 1 1 2 4 5 0 5 1 1 3 3 1 2 1 2 1 3 1 3 5 3 5 1 3 1 3 1 3 3 1 3 
    3 3 3 1 3 3 3 3 1 3 3 3 3 3 3 3 3 1 2 2 2 1 2 2 4 3 3 1 1 1 3 2 3 2 3 1 3 
    1 1 1 3 1 2 1 1 1 2 3 1 1 1 1 1 1 1 1))

(define ia-ml-pat-v
  #(((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) 
    (45 . 30) (46 . 31) (47 . 32) (83 . 33) (84 . 34) (96 . 35) (1 . -28)) 
    ((1 . -123)) ((1 . -122)) ((1 . -126)) ((1 . -125)) ((1 . -124)) ((1 . 
    -121)) ((35 . 81) (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 78) (61 . 79) (62 . 82)) 
    ((52 . 77) (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) 
    (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) 
    (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) 
    (70 . 22) (71 . 23) (72 . 24) (83 . 78) (61 . 79) (62 . 80)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) 
    (72 . 24) (83 . 76)) ((1 . -102)) ((1 . -101)) ((1 . -100)) ((1 . -94)) 
    ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (65 . 75)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (65 . 74)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (65 . 73)) ((12 . 69) (11 . 70) (50 . 71) 
    (10 . 72) (1 . -90)) ((1 . -81)) ((21 . 61) (20 . 62) (19 . 63) (18 . 64) 
    (17 . 65) (16 . 66) (15 . 67) (14 . 68) (1 . -76)) ((25 . 57) (24 . 58) 
    (23 . 59) (22 . 60) (1 . -71)) ((29 . 53) (28 . 54) (27 . 55) (26 . 56) 
    (1 . -68)) ((31 . 51) (30 . 52) (1 . -66)) ((32 . 50) (1 . -64)) ((34 . 48
    ) (33 . 49) (1 . -59)) ((1 . -42)) ((1 . -41)) ((8 . 6) (87 . 46) (79 . 47
    )) ((1 . -39)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7)
    (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) 
    (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) 
    (70 . 22) (71 . 23) (72 . 24) (83 . 45)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4)
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 44)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) 
    (72 . 24) (83 . 43)) ((8 . 6) (87 . 42)) ((51 . 41) (1 . -29)) ((3 . 36) 
    (48 . 37) (9 . 38) (59 . 39) (86 . 40)) ((57 . 0)) ((1 . -128)) ((1 . -118
    )) ((1 . -117)) ((1 . -116)) ((1 . -27)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4)
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 121)) ((51 . 120))
    ((3 . 36) (48 . 37) (9 . 38) (59 . 39) (86 . 119)) ((3 . 36) (48 . 37) 
    (9 . 38) (59 . 39) (86 . 118)) ((3 . 36) (48 . 37) (9 . 38) (59 . 39) 
    (86 . 117)) ((1 . -43)) ((8 . 6) (87 . 116) (1 . -40)) ((55 . 114) 
    (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 115)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 113)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5)
    (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13)
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 112)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 111)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) 
    (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) 
    (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 110)) 
    ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 109)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) 
    (66 . 18) (67 . 19) (68 . 108)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5)
    (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13)
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 107)) 
    ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 106)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) 
    (66 . 18) (67 . 105)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 104)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 18) (67 . 103)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5)
    (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13)
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 102)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 101)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 100)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) 
    (66 . 99)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) 
    (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) 
    (25 . 15) (24 . 16) (65 . 17) (66 . 98)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4)
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 97)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 96)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 95)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) 
    (66 . 94)) ((1 . -95)) ((1 . -96)) ((49 . 91) (6 . 1) (7 . 2) (5 . 3) 
    (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) 
    (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) 
    (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 92) 
    (73 . 93)) ((8 . 6) (87 . 90)) ((12 . 69) (11 . 70) (50 . 71) (10 . 72) 
    (1 . -91)) ((12 . 69) (11 . 70) (50 . 71) (10 . 72) (1 . -92)) ((12 . 69) 
    (11 . 70) (50 . 71) (10 . 72) (1 . -93)) ((49 . 89)) ((1 . -104)) (
    (1 . -112)) ((48 . 88) (1 . -108)) ((52 . 87) (3 . 36) (59 . 84) (9 . 85) 
    (60 . 86)) ((1 . -106)) ((35 . 83) (3 . 36) (59 . 84) (9 . 85) (60 . 86)) 
    ((1 . -107)) ((1 . -111)) ((1 . -110)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 78) (61 . 134)) 
    ((1 . -105)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) 
    (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) 
    (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) 
    (70 . 22) (71 . 23) (72 . 24) (83 . 133)) ((1 . -103)) ((1 . -99)) 
    ((1 . -98)) ((1 . -57)) ((49 . 131) (48 . 132)) ((1 . -89)) ((1 . -88)) 
    ((1 . -87)) ((1 . -86)) ((1 . -85)) ((1 . -84)) ((1 . -83)) ((1 . -82)) 
    ((21 . 61) (20 . 62) (19 . 63) (18 . 64) (17 . 65) (16 . 66) (15 . 67) 
    (14 . 68) (1 . -80)) ((21 . 61) (20 . 62) (19 . 63) (18 . 64) (17 . 65) 
    (16 . 66) (15 . 67) (14 . 68) (1 . -79)) ((21 . 61) (20 . 62) (19 . 63) 
    (18 . 64) (17 . 65) (16 . 66) (15 . 67) (14 . 68) (1 . -78)) ((21 . 61) 
    (20 . 62) (19 . 63) (18 . 64) (17 . 65) (16 . 66) (15 . 67) (14 . 68) 
    (1 . -77)) ((25 . 57) (24 . 58) (23 . 59) (22 . 60) (1 . -75)) ((25 . 57) 
    (24 . 58) (23 . 59) (22 . 60) (1 . -74)) ((25 . 57) (24 . 58) (23 . 59) 
    (22 . 60) (1 . -73)) ((25 . 57) (24 . 58) (23 . 59) (22 . 60) (1 . -72)) 
    ((29 . 53) (28 . 54) (27 . 55) (26 . 56) (1 . -70)) ((29 . 53) (28 . 54) 
    (27 . 55) (26 . 56) (1 . -69)) ((31 . 51) (30 . 52) (1 . -67)) ((32 . 50) 
    (1 . -65)) ((1 . -62)) ((33 . 49) (34 . 130) (1 . -60)) ((1 . -44)) 
    ((81 . 129) (1 . -47)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) 
    (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) 
    (84 . 34) (96 . 124) (85 . 125) (95 . 126) (92 . 128) (1 . -28)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) 
    (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) (45 . 30) 
    (46 . 31) (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) (85 . 125) 
    (95 . 126) (92 . 127) (1 . -28)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 122)) ((1 . -30)) 
    ((3 . 36) (48 . 37) (9 . 38) (59 . 39) (86 . 147)) ((1 . -127)) ((1 . -26)
    ) ((1 . -25)) ((1 . -23)) ((55 . 146) (6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) 
    (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) 
    (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 142) (1 . -28)) ((55 . 141
    ) (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) 
    (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) 
    (85 . 125) (95 . 142) (44 . 143) (38 . 144) (82 . 145) (1 . -28)) (
    (55 . 138) (37 . 139) (42 . 140)) ((55 . 136) (6 . 1) (7 . 2) (5 . 3) 
    (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) 
    (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) 
    (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 137)) ((1 . -97)) 
    ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 24) (83 . 135)) ((1 . -113)) ((48 . 88) (1 . -109)) 
    ((1 . -58)) ((1 . -63)) ((33 . 49) (1 . -61)) ((1 . -38)) ((5 . 3) 
    (7 . 2) (36 . 155) (76 . 156) (77 . 157) (78 . 158)) ((3 . 36) (48 . 37) 
    (9 . 38) (59 . 39) (86 . 154)) ((1 . -36)) ((1 . -24)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) 
    (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) 
    (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) 
    (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 126) 
    (92 . 153) (1 . -28)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (83 . 152)) ((44 . 149) (38 . 150)
    (55 . 151)) ((1 . -32)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) 
    (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13)
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) 
    (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) 
    (84 . 34) (96 . 124) (85 . 125) (95 . 126) (92 . 148) (1 . -28)) ((55 . 
    169) (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) 
    (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) 
    (85 . 125) (95 . 142) (1 . -28)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) 
    (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) 
    (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 126) (92 . 168) (1 . -28))
    ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 24) (83 . 167)) ((1 . -34)) ((3 . 36) (48 . 37) (9 . 38) 
    (59 . 39) (86 . 166)) ((55 . 165) (6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) 
    (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) 
    (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 142) (1 . -28)) ((6 . 1) 
    (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) 
    (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) 
    (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) 
    (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) (45 . 30) 
    (46 . 31) (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) (85 . 125) 
    (95 . 126) (92 . 164) (1 . -28)) ((7 . 2) (77 . 160) (75 . 161) (5 . 3) 
    (76 . 162) (74 . 163)) ((1 . -50)) ((1 . -49)) ((3 . 36) (48 . 37) 
    (9 . 38) (59 . 39) (86 . 159)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) 
    (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13)
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) 
    (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) 
    (84 . 34) (96 . 124) (85 . 125) (95 . 126) (92 . 178) (1 . -28)) ((1 . -53
    )) ((35 . 176) (7 . 2) (77 . 177)) ((1 . -55)) ((35 . 174) (5 . 3) 
    (76 . 175)) ((55 . 173) (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) 
    (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) 
    (84 . 34) (96 . 124) (85 . 125) (95 . 142) (1 . -28)) ((1 . -35)) (
    (6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) 
    (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) 
    (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) 
    (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) 
    (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) 
    (85 . 125) (95 . 126) (92 . 172) (1 . -28)) ((3 . 36) (48 . 37) (9 . 38) 
    (59 . 39) (86 . 171)) ((55 . 170) (6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) 
    (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) 
    (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 142) (1 . -28)) ((1 . -31)
    ) ((1 . -33)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) 
    (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) (13 . 14) 
    (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) (69 . 21) 
    (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) (41 . 28) 
    (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) (84 . 34) 
    (96 . 124) (85 . 125) (95 . 126) (92 . 179) (1 . -28)) ((6 . 1) (7 . 2) 
    (5 . 3) (58 . 4) (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) 
    (63 . 11) (87 . 12) (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) 
    (66 . 18) (67 . 19) (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) 
    (39 . 25) (40 . 26) (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) 
    (47 . 32) (83 . 33) (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 142) 
    (44 . -45) (38 . -45) (55 . -45) (1 . -28)) ((1 . -37)) ((1 . -52)) 
    ((1 . -56)) ((1 . -51)) ((1 . -54)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) 
    (77 . 5) (8 . 6) (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) 
    (64 . 13) (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) 
    (68 . 20) (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) 
    (80 . 27) (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) 
    (4 . 123) (84 . 34) (96 . 124) (85 . 125) (95 . 142) (55 . -48) (37 . -48)
    (42 . -48) (1 . -28)) ((6 . 1) (7 . 2) (5 . 3) (58 . 4) (77 . 5) (8 . 6) 
    (36 . 7) (53 . 8) (50 . 9) (76 . 10) (63 . 11) (87 . 12) (64 . 13) 
    (13 . 14) (25 . 15) (24 . 16) (65 . 17) (66 . 18) (67 . 19) (68 . 20) 
    (69 . 21) (70 . 22) (71 . 23) (72 . 24) (39 . 25) (40 . 26) (80 . 27) 
    (41 . 28) (43 . 29) (45 . 30) (46 . 31) (47 . 32) (83 . 33) (4 . 123) 
    (84 . 34) (96 . 124) (85 . 125) (95 . 142) (44 . -46) (38 . -46) (55 . -46
    ) (1 . -28))))

(define ia-ml-rto-v
  #(#f 100 100 99 99 99 98 98 94 94 94 91 91 93 93 89 89 89 89 89 89 88 88 92
    92 95 95 96 84 84 84 84 84 84 84 84 84 84 84 84 84 80 80 79 79 82 82 81 81
    78 78 78 78 75 75 74 74 73 73 83 83 83 83 83 72 72 71 71 70 70 70 69 69 69
    69 69 68 68 68 68 68 67 67 67 67 67 67 67 67 67 66 66 66 66 65 65 65 65 65
    65 64 64 64 64 64 64 64 64 62 62 60 60 61 61 90 90 86 86 86 97 97 87 77 58
    63 63 76 85 59))

(define ia-ml-mtab
  '(($start . 96) ("\n" . 3) ($lone-comm . 4) ($string . 5) ($float . 6) 
    ($fixed . 7) ($ident . 8) (";" . 9) ("." . 10) (".'" . 11) ("'" . 12) 
    ("~" . 13) (".^" . 14) (".\\" . 15) ("./" . 16) (".*" . 17) ("^" . 18) 
    ("\\" . 19) ("/" . 20) ("*" . 21) (".-" . 22) (".+" . 23) ("-" . 24) 
    ("+" . 25) (">=" . 26) ("<=" . 27) (">" . 28) ("<" . 29) ("~=" . 30) 
    ("==" . 31) ("&" . 32) ("|" . 33) (":" . 34) ("}" . 35) ("{" . 36) 
    ("case" . 37) ("elseif" . 38) ("clear" . 39) ("global" . 40) ("return" . 
    41) ("otherwise" . 42) ("switch" . 43) ("else" . 44) ("if" . 45) ("while" 
    . 46) ("for" . 47) ("," . 48) (")" . 49) ("(" . 50) ("=" . 51) ("]" . 52) 
    ("[" . 53) ("function" . 54) ("end" . 55) ($error . 2) ($end . 57)))

(define ia-ml-tables
  (list
   (cons 'len-v ia-ml-len-v)
   (cons 'pat-v ia-ml-pat-v)
   (cons 'rto-v ia-ml-rto-v)
   (cons 'mtab ia-ml-mtab)))

;;; end tables
