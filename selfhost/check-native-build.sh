#!/bin/sh
# Native replacement builds must regenerate ELF and survive moved entry/context offsets.
set -eu
runtime=$(realpath "${1:-./forth}")
project=$(dirname "$runtime")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/first" "$work/second"
env -i PATH=/nonexistent HOME="$work" "$runtime" build.file "$project/forth.f" "$work/first" > "$work/log"
env -i PATH=/nonexistent HOME="$work" "$work/first/forth" build.file "$project/forth.f" "$work/second" >> "$work/log"
for artifact in forth image.bin code.bin dictionary.bin source.bin; do
  cmp "$project/selfhost/build/$artifact" "$work/first/$artifact"
  cmp "$work/first/$artifact" "$work/second/$artifact"
done
cmp "$project/forth.f" "$work/first/source.bin"
# Shift kernel.start, shift compiler context variables, and change the ELF generator.
# The final executable must use the NEW generator, not its parent's wrapper bytes.
awk '
  /^code kernel.start$/ {
    print "\\ Move the process entry point for the native rebuild test."
    print "code build.test.padding ret, code.end\n"
  }
  /^variable compiler.failure$/ {
    print "variable build.test.context\n"
  }
  /^  elf.link elf.startup$/ { print "  12345 2560 elf!" }
  { print }
' "$project/forth.f" > "$work/changed.f"
mkdir "$work/changed"
env -i PATH=/nonexistent HOME="$work" "$runtime" build.file "$work/changed.f" "$work/changed" >> "$work/log"
[ "$(od -An -tu8 -j2560 -N8 "$work/changed/forth" | tr -d ' ')" = 12345 ]
[ "$(od -An -tu8 -j80 -N8 "$work/changed/image.bin" | tr -d ' ')" -gt 4096 ]
env -i PATH=/nonexistent "$work/changed/forth" '9 square . verify? . depth .' > "$work/changed-result"
[ "$(cat "$work/changed-result")" = '81 -1 0 ' ]
# clean keeps a native seed; neither rebuilding nor failure recovery consults SF.
mkdir -p "$work/project/selfhost/seed"
cp "$project/Makefile" "$project/forth.f" "$project/shim.f" "$work/project/"
cp "$project/selfhost/check.f" "$project/selfhost/check-docs.awk" "$work/project/selfhost/"
cp "$runtime" "$work/project/selfhost/seed/forth"
(cd "$work/project" && make -s clean && test -x selfhost/seed/forth && make -s SF=/nonexistent) >> "$work/log"
cmp "$runtime" "$work/project/forth"
printf '\ninvalid.build.token\n' >> "$work/project/forth.f"
if (cd "$work/project" && make -s SF=/nonexistent) >> "$work/log" 2>&1; then
  printf 'Malformed replacement source unexpectedly built.\n' >&2; exit 1
fi
cmp "$runtime" "$work/project/forth"
cmp "$runtime" "$work/project/selfhost/build/forth"
for artifact in image.bin code.bin dictionary.bin source.bin; do
  cmp "$project/selfhost/build/$artifact" "$work/project/selfhost/build/$artifact"
done
printf 'Native file builds, complete ELF regeneration, compiler/context relocation, clean seed and failed-build preservation passed.\n'
