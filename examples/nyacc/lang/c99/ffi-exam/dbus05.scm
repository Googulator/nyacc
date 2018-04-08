;; dbus05.scm - dbus04 applied to example

(use-modules (dbus00))
(use-modules (dbus04))
(use-modules (ffi dbus))
(use-modules (system ffi-help-rt))
(use-modules ((system foreign) #:prefix ffi:))
(use-modules (ice-9 pretty-print))

(define (sf fmt . args) (apply simple-format #t fmt args))
(define pp pretty-print)

(define msg (dbus_message_new_method_call
	     "org.freedesktop.DBus"		; bus name (was NULL)
	     "/org/freedesktop/DBus"		; object path
	     "org.freedesktop.DBus.Debug.Stats"	; interface name
	     "GetStats"))			; method

(define (send-msg conn msg)
  (let ((pending (make-DBusPendingCall*)))
    (or (dbus_connection_send_with_reply conn msg (pointer-to pending) -1)
	(error "*** send_with_reply FAILED\n"))
    ;;(dbus_message_unref msg)
    pending))

(define (handle-it pending)
  (dbus_pending_call_block pending)
  (let ((msg (dbus_pending_call_steal_reply pending))
	(msg-iter (make-DBusMessageIter))
	)
    (if (zero? (fh-object-ref msg)) (error "*** reply message NULL\n"))
    (dbus_pending_call_unref pending)
    (dbus_message_iter_init msg (pointer-to msg-iter))
    (sf "result:\n")
    (pretty-print (read-dbus-val (pointer-to msg-iter)) #:per-line-prefix "  ")
    (dbus_message_unref msg)))

;; (define conn (start-dbus-session-loop))
;; --- last line ---
