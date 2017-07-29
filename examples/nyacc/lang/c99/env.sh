#!/bin/sh
# source this file: $ . env.sh
topdir=`(cd ../../../..; pwd)`
if [ "X$GUILE_LOAD_PATH" = "X" ]; then
 GUILE_LOAD_PATH=$topdir/module:$topdir/examples
else
 GUILE_LOAD_PATH=$topdir/module:$topdir/examples:$GUILE_LOAD_PATH
fi;
GUILE_LOAD_PATH=$topdir/examples/nyacc/lang/c99/ffi.d:$GUILE_LOAD_PATH
export GUILE_LOAD_PATH
