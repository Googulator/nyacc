(define-library (bytestructures r7 struct)
  (import
   (scheme base)
   (scheme case-lambda)
   (srfi 1)
   (srfi 28)
   (bytestructures r7 utils)
   (bytestructures r7 base)
   (bytestructures r7 bitfields))
  (include-library-declarations "struct.exports.sld")
  (include "body/struct.scm"))
