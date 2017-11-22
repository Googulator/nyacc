;;; cairo-demo.scm

;; Copyright (C) 2017 Matthew R. Wette

;; Copying and distribution of this file, with or without modification,
;; are permitted in any medium without royalty provided the copyright
;; notice and this notice are preserved.  This file is offered as-is,
;; without any warranty.

(use-modules (ffi cairo))

;;(define srf (cairo_svg_surface_create "abc.svg" 200.0 200.0))
(define srf (cairo_image_surface_create 'CAIRO_FORMAT_ARGB32 200 200))
(define cr (cairo_create srf))

(cairo_move_to cr 10.0 10.0)
(cairo_line_to cr 190.0 10.0)
(cairo_line_to cr 190.0 190.0)
(cairo_line_to cr 10.0 190.0)
(cairo_line_to cr 10.0 10.0)
(cairo_stroke cr)

(cairo_surface_write_to_png srf "cairo-demo.png")
(cairo_destroy cr)
(cairo_surface_destroy srf)

;;; --- last line ---