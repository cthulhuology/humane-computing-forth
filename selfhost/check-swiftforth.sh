#!/bin/sh
# Independent SwiftForth oracle: never modifies the native build or seed.
set -eu
runtime=$(realpath "${1:-./forth}")
project=$(dirname "$runtime")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/selfhost/build"
cp "$project/forth.f" "$project/shim.f" "$work/"
(cd "$work" && "${SF:-sf}" shim.f)
for artifact in forth image.bin code.bin dictionary.bin source.bin; do
  cmp "$project/selfhost/build/$artifact" "$work/selfhost/build/$artifact"
done
(cd "$project" && "${SF:-sf}" selfhost/check.f)
printf 'SwiftForth independently reproduced every native artifact, including the ELF wrapper.\n'
