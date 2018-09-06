;; nyacc/lang/octave/Umach.scm - update octave machines
;;
;; Copyright (C) 2015-2018 Matthew R. Wette
;; 
;; Copying and distribution of this file, with or without modification,
;; are permitted in any medium without royalty provided the copyright
;; notice and this notice are preserved.  This file is offered as-is,
;; without any warranty.

(use-modules (nyacc lang octave mach))
(use-modules (nyacc lang util))
(use-modules (nyacc lalr))
(use-modules (nyacc util))
(use-modules (nyacc export))
(use-modules (ice-9 pretty-print))

(gen-octave-files)

(compile-file "parser.scm")

(with-output-to-file ",file.txt"
  (lambda ()
    (pp-lalr-notice octave-spec)
    (pp-lalr-grammar octave-spec)
    (pp-lalr-machine octave-mach)))

(with-output-to-file ",stmt.txt"
  (lambda ()
    (pp-lalr-notice octave-ia-spec)
    (pp-lalr-grammar octave-ia-spec)
    (pp-lalr-machine octave-ia-mach)))

;; --- last line ---
