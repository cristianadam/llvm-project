// RUN: env CINDEXTEST_EDITING=1 CINDEXTEST_PREAMBLE_FILE=%t-preamble.pch \
// RUN:   not c-index-test -test-load-source-reparse 1 local \
// RUN:   -remap-file="%s,%S/Inputs/crash-recovery-reparse-remap.c" \
// RUN:   %s 2> %t.err
// RUN: FileCheck < %t.err -check-prefix=CHECK-REPARSE-SOURCE-CRASH %s
// RUN: test ! -e $t-preamble.pch
// CHECK-REPARSE-SOURCE-CRASH: Unable to reparse translation unit
//
// REQUIRES: crash-recovery
// FIXME: See wy "terminating with uncaught exception of type std::__1::system_error: mutex lock failed: Invalid argument" is happening on darwin
// UNSUPPORTED: libstdcxx-safe-mode, darwin, system-windows

#warning parsing original file
