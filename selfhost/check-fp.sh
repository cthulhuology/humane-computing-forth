#!/bin/sh
# Exercise the separate guarded FP stack, memory formats, parser and checkpoints.
set -eu
runtime=$(realpath "${1:-./forth}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"
cd "$work"
cat > "$work/fp.f" <<'FORTH'
fvariable saved.float
2.5 fconstant two.half
: fp.mutate 9e0 f+ trap ;
: fp.check
  1.5 2e0 f* 3e0 f= require
  7e0 2e0 f- 5e0 f= require
  9e0 2e0 f/ 4.5 f= require
  -7 s>f 2e0 f/ f>s -3 = require
  two.half fdup saved.float f! saved.float f@ f= require
  1e0 2e0 fover 1e0 f= require fswap 1e0 f= require 2e0 f= require
  0e0 fnegate 0e0 f= require
  s" nan" >float require fdup f= 0= require
  s" nan" >float require 1e0 f< 0= require
  s" 1.25e2" >float require 125e0 f= require
  s" 1.2bad" >float 0= require fdepth 0= require
  0 page.size 2 * protection.read.write 34 -1 0 9 syscall6 dup 0 > require >r
  r@ page.size + page.size protection.none image.protect
  3.5 r@ page.size + 4 - sf! r@ page.size + 4 - sf@ 3.5 f= require
  r> page.size 2 * 0 0 0 0 11 syscall6 0= require
  fdepth 0= require depth 0= require ;
fp.check
verify? require
1.25 f. cr
bye
FORTH
"$runtime" < "$work/fp.f" > "$work/output"
printf '1.25 \n' > "$work/expected"
cmp "$work/output" "$work/expected" || { cat "$work/output"; exit 1; }
for command in 'fdrop' ': fp.fill begin 1e0 again ; fp.fill'; do
  printf 'fdepth . depth . bye\n' | "$runtime" "$command" > "$work/fault"
  grep -q 'signal 11' "$work/fault"
  grep -q '0 0 ' "$work/fault"
done
"$runtime" 'see ffi.native see s>f see f+ see f< see ffi.promote' > "$work/dis"
grep -q 'movsd xmm7' "$work/dis"
grep -q 'cvtsi2sd xmm0' "$work/dis"
grep -q 'addsd xmm0' "$work/dis"
grep -q 'ucomisd xmm0' "$work/dis"
grep -q 'cvtss2sd xmm0' "$work/dis"
if grep -q ' db ' "$work/dis"; then cat "$work/dis"; exit 1; fi
printf 'FP stack arithmetic, formats, parsing, recovery, guards and SSE inspection passed.\n'
