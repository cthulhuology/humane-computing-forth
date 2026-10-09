#!/bin/sh
# Build only a test DSO; all loader, ABI and verification work runs in native Forth.
set -eu
runtime=$(realpath "${1:-./forth}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"
${CC:-cc} -shared -fPIC -O2 -Wall -Wextra -o "$work/fixture.so" selfhost/fixture-ffi.c
cd "$work"
cat > "$work/check.f" <<FORTH
variable library.handle
variable library.again
variable foreign.cell
: symbol library.handle @ -rot dlsym dup 0<> require ;
: ffi.check
  dlerror 2drop
  s" $work/fixture.so" rtld.now dlopen dup 0<> require library.handle !
  s" ffi_zero" symbol c.call0 100 = require
  -101 s" ffi_one" symbol c.call1 -1 = require
  1 2 s" ffi_two" symbol c.call2 21 = require
  1 2 3 s" ffi_three" symbol c.call3 321 = require
  1 2 3 4 s" ffi_four" symbol c.call4 4321 = require
  1 2 3 4 5 s" ffi_five" symbol c.call5 54321 = require
  1 2 3 4 5 6 s" ffi_six" symbol c.call6 654321 = require
  s" ffi_alignment" symbol c.call0 8 = require
  s" ffi_tls" symbol c.call0 37 = require
  s" ffi_tls" symbol c.call0 38 = require
  41 foreign.cell ! foreign.cell s" ffi_pointer" symbol c.call1 42 = require
  foreign.cell @ 42 = require
  library.handle @ s" nonexistent_ffi_symbol" dlsym 0= require
  dlerror nip 0 > require dlerror nip 0= require
  s" $work/fixture.so" rtld.now dlopen dup 0<> require library.again !
  library.handle @ dlclose 0= require
  library.again @ s" ffi_zero" dlsym c.call0 100 = require
  s" reference retained" type cr
  library.again @ dlclose 0= require
  s" $work/no-library.so" rtld.now dlopen 0= require
  dlerror nip 0 > require dlerror nip 0= require
  0 0 rtld.now dlopen dup 0<> require library.handle !
  library.handle @ s" strlen" dlsym dup 0<> require
  s" native forth" c.string dup >r swap c.call1 12 = require r> c.string.free
  library.handle @ dlclose 0= require
  depth 0= require fdepth 0= require ;
ffi.check
verify? require
: ffi.relocated rebuild dup image.seal >r r@ s" ffi.check" image.find entry.xt + @ r@ swap image.call r> image.free ;
ffi.relocated
: libc.output s" flushed libc output" c.string dup >r rtld.default s" puts" dlsym c.call1 drop r> c.string.free ;
libc.output
bye
FORTH
"$runtime" < "$work/check.f" > "$work/output"
cat > "$work/expected" <<'EXPECTED'
reference retained
library closed
reference retained
library closed
flushed libc output
EXPECTED
cmp "$work/output" "$work/expected" || { cat "$work/output"; exit 1; }
# C destructors also run on normal Forth process exit with an open handle.
"$runtime" ": exit.check s\" $work/fixture.so\" rtld.now dlopen 0<> require ; exit.check bye" > "$work/exit"
printf 'library closed\n' > "$work/exit.expected"
cmp "$work/exit" "$work/exit.expected"
cat > "$work/typed.f" <<FORTH
LIBRARY $work/fixture.so
FUNCTION: ffi_seven ( a b c d e f g -- long )
function: ffi_pair ( {ll} -- {ll} )
function: ffi_mixed ( {dl} -- {dl} )
function: ffi_vector3 ( {%12} -- {fff} )
function: ffi_large ( {24} -- {lll} )
function: ffi_rollback ( a b c d e {16} f -- long )
function: ffi_sse_rollback ( %%a %%b %%c %%d %%e %%f %%g {%%16} %%h -- %%result )
function: ffi_nine ( %%a %%b %%c %%d %%e %%f %%g %%h %%i -- %%result )
function: ffi_var ( n %%fixed ... %v i -- %%result )
function: ffi_odd ( {3} -- {ccc} )
function: ffi_float ( %f -- %result )
function: ffi_negative ( -- int )
function: ffi_void ( pointer -- )
variable ffi.buffer
: typed.check
  93e0
  0 page.size protection.read.write 34 -1 0 9 syscall6 dup 0 > require ffi.buffer !
  1 2 3 4 5 6 7 ffi_seven 7654321 = require
  1 ffi.buffer @ ! 2 ffi.buffer @ 8 + !
  ffi.buffer @ 64 + ffi.buffer @ ffi_pair ffi.buffer @ 64 + = require
  ffi.buffer @ 64 + @ 11 = require ffi.buffer @ 72 + @ 22 = require
  \$3ff0000000000000 ffi.buffer @ ! 3 ffi.buffer @ 8 + !
  ffi.buffer @ 64 + ffi.buffer @ ffi_mixed drop
  ffi.buffer @ 64 + @ \$4000000000000000 = require ffi.buffer @ 72 + @ 5 = require
  \$3f800000 ffi.buffer @ u32! \$40000000 ffi.buffer @ 4 + u32! \$40400000 ffi.buffer @ 8 + u32!
  ffi.buffer @ 64 + ffi.buffer @ ffi_vector3 drop
  ffi.buffer @ 64 + @ \$4080000040000000 = require
  ffi.buffer @ 72 + @ \$ffffffff and \$40c00000 = require
  1 ffi.buffer @ ! 2 ffi.buffer @ 8 + ! 3 ffi.buffer @ 16 + !
  ffi.buffer @ 64 + ffi.buffer @ ffi_large drop
  ffi.buffer @ 64 + @ 2 = require ffi.buffer @ 72 + @ 4 = require ffi.buffer @ 80 + @ 6 = require
  1 2 3 4 5 ffi.buffer @ 6 ffi_rollback 24 = require
  \$3ff0000000000000 ffi.buffer @ ! \$3ff0000000000000 ffi.buffer @ 8 + !
  1e0 fdup fdup fdup fdup fdup fdup ffi.buffer @ 1e0 ffi_sse_rollback 10e0 f= require
  1e0 fdup fdup fdup fdup fdup fdup fdup fdup ffi_nine 9e0 f= require
  1 2e0 3e0 4 ffi_var 10e0 f= require
  \$030201 ffi.buffer @ !
  ffi.buffer @ 64 + ffi.buffer @ ffi_odd drop
  ffi.buffer @ 64 + @ \$ffffff and \$040302 = require
  1e0 ffi_float 2e0 f= require
  ffi_negative -23 = require ffi.buffer @ ffi_void ffi.buffer @ @ 99 = require
  ffi.buffer @ page.size 0 0 0 0 11 syscall6 0= require
  93e0 f= require
  depth 0= require fdepth 0= require ;
typed.check
verify? require
: typed.relocated rebuild dup image.seal >r r@ s" typed.check" image.find entry.xt + @ r@ swap image.call r> image.free ;
typed.relocated
bye
FORTH
"$runtime" < "$work/typed.f" > "$work/typed.output"
printf 'library closed\n' > "$work/typed.expected"
cmp "$work/typed.output" "$work/typed.expected" || { cat "$work/typed.output"; exit 1; }
printf 'Native dynamic loading, C arities/alignment/TLS, errors, close/exit destructors and relocated calls passed.\n'
