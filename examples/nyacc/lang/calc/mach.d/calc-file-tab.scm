;; calc-file-tab.scm

(define calc-file-mtab
  '(($start . 20) ("=" . 3) (")" . 4) ("(" . 5) ($ident . 6) ($float . 7) 
    ($fixed . 8) ("/" . 9) ("*" . 10) ("-" . 11) ("+" . 12) ("\n" . 13) 
    ($error . 2) ($end . 15)))

(define calc-file-ntab
  '((16 . assn) (17 . expr) (18 . stmt) (19 . stmt-list) (20 . prog)))

(define calc-file-len-v
  #(1 1 1 2 1 2 2 3 3 3 3 1 1 1 3 3))

(define calc-file-rto-v
  #(#f 20 19 19 18 18 18 17 17 17 17 17 17 17 17 16))

(define calc-file-pat-v
  #(((5 . 1) (6 . 2) (7 . 3) (8 . 4) (16 . 5) (17 . 6) (13 . 7) (18 . 8) 
    (19 . 9) (20 . 10)) ((5 . 1) (6 . 19) (7 . 3) (8 . 4) (17 . 20)) ((3 . 18)
    (1 . -13)) ((1 . -12)) ((1 . -11)) ((13 . 17)) ((13 . 12) (12 . 13) 
    (11 . 14) (10 . 15) (9 . 16)) ((1 . -4)) ((1 . -2)) ((5 . 1) (6 . 2) 
    (7 . 3) (8 . 4) (16 . 5) (17 . 6) (13 . 7) (18 . 11) (1 . -1)) ((15 . 0)) 
    ((1 . -3)) ((1 . -5)) ((5 . 1) (6 . 19) (7 . 3) (8 . 4) (17 . 26)) 
    ((5 . 1) (6 . 19) (7 . 3) (8 . 4) (17 . 25)) ((5 . 1) (6 . 19) (7 . 3) 
    (8 . 4) (17 . 24)) ((5 . 1) (6 . 19) (7 . 3) (8 . 4) (17 . 23)) ((1 . -6))
    ((5 . 1) (6 . 19) (7 . 3) (8 . 4) (17 . 22)) ((1 . -13)) ((4 . 21) 
    (12 . 13) (11 . 14) (10 . 15) (9 . 16)) ((1 . -14)) ((12 . 13) (11 . 14) 
    (10 . 15) (9 . 16) (1 . -15)) ((1 . -10)) ((1 . -9)) ((10 . 15) (9 . 16) 
    (1 . -8)) ((10 . 15) (9 . 16) (1 . -7))))

(define calc-file-tables
  (list
   (cons 'mtab calc-file-mtab)
   (cons 'ntab calc-file-ntab)
   (cons 'len-v calc-file-len-v)
   (cons 'rto-v calc-file-rto-v)
   (cons 'pat-v calc-file-pat-v)
   ))

;;; end tables