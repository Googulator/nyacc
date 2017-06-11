;; Tmach.scm - modelica dev
;;
;; Copyright (C) 2015,2017 Matthew R. Wette
;; 
;; Copying and distribution of this file, with or without modification,
;; are permitted in any medium without royalty provided the copyright
;; notice and this notice are preserved.  This file is offered as-is,
;; without any warranty.

(add-to-load-path (string-append (getcwd) "/../../../../module"))
(add-to-load-path (string-append (getcwd) "/../../../../examples"))

(use-modules (nyacc lang modelica mach))
(use-modules (nyacc lalr))
(use-modules (nyacc export))
(use-modules (ice-9 pretty-print))

(when #t
  (with-output-to-file "lang.txt.new"
    (lambda ()
      (pp-lalr-grammar modelica-spec)
      (pp-lalr-machine modelica-mach)))
  (write-lalr-tables modelica-mach "mach.d/motab.scm.new")
  (write-lalr-actions modelica-mach "mach.d/moact.scm.new")
  )
		
(when #f
  (with-output-to-file "gram.y.new"
    (lambda () (lalr->bison modelica-spec))))

(when #f
  (let ((res (with-input-from-file "exam.d/ex1.mo"
               (lambda ()
                  (modelica-parser (gen-mod-lexer) #:debug #f)))))
    (pretty-print res)))

;; --- last line ---
