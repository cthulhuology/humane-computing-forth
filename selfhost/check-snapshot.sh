#!/bin/sh
# Check native checkpoint transactions, fresh restores, branching and pruning.
set -eu
runtime=$(realpath "${1:-./forth}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work/home with spaces"
mkdir -p "$HOME"
output=$(printf 'variable counter\n99 counter !\n: value 11 ;\n: value 22 ;\nundo\ncounter @ . value . fdepth . depth . cr\n: value 33 ;\nvalue . verify? . cr\nsource.save %s\ncheckpoints\nbye\n' "$work/export.f" | "$runtime")
case "$output" in *'0 11 0 0 '*'33 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
root="$HOME/.forth.d/checkpoints/00000000"
a="$root/00000000/00000000"
b="$a/00000000"
c="$a/00000001"
for node in "$root" "$root/00000000" "$a" "$b" "$c"; do
  test -x "$node/forth"
  test "$(wc -c < "$node/complete")" -eq 8
  "$node/forth" snapshot.validate
done
cmp "$work/export.f" "$c/forth.f"
cat "$a/forth.f" "$b/change.f" > "$work/reconstructed.f"
cmp "$work/reconstructed.f" "$b/forth.f"
cat "$a/forth.f" "$c/change.f" > "$work/reconstructed.f"
cmp "$work/reconstructed.f" "$c/forth.f"
output=$(printf 'restore %s\nvalue . counter @ . verify? . cr\nbye\n' "$b" | "$runtime")
case "$output" in *'22 0 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# A corrupted or incomplete candidate must leave the caller and its input intact.
printf x >> "$b/image.bin"
output=$(printf 'restore %s\n42 . cr\nrestore /nonexistent\n43 . cr\nbye\n' "$b" | "$runtime")
case "$output" in *'Checkpoint validation failed:'*'42 '*'Checkpoint validation failed:'*'43 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
mkdir "$work/incomplete"
cp "$runtime" "$work/incomplete/forth"
output=$(printf 'restore %s\n44 . cr\nbye\n' "$work/incomplete" | "$runtime")
case "$output" in *'Checkpoint validation failed:'*'44 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Source export must not replace a user's existing file.
output=$(printf 'source.save %s\n45 . cr\nbye\n' "$work/export.f" | "$runtime")
case "$output" in *'Checkpoint I/O failed:'*'45 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
cmp "$work/export.f" "$c/forth.f"
# A failed automatic save must not publish the definition.
mkdir "$work/failure"
printf blocked > "$work/failure/.forth.d"
output=$(printf ': unpublished 19 ;\n46 . cr\nunpublished\nbye\n' | HOME="$work/failure" "$runtime")
case "$output" in *'Checkpoint I/O failed:'*'46 '*'Unknown command word: unpublished'*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Pruning removes an unused old name, retains direct references and replays exactly.
mkdir "$work/prune"
output=$(printf ': unused 11 ;\n: unused 22 ;\nprune\n: used 31 ;\n: caller used ;\n: used 32 ;\nprune\nunused . caller . used . verify? . cr\nsource.save %s\ncheckpoints\nbye\n' "$work/pruned.f" | HOME="$work/prune" "$runtime")
case "$output" in *'1 superseded dictionary entries pruned.'*'0 superseded dictionary entries pruned.'*'22 31 32 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
grep -q ' entry.hide$' "$work/pruned.f"
last=$(printf '%s\n' "$output" | tail -n 1)
"$last/forth" snapshot.validate
# A saved execution token remains a reference even without a compiled direct call.
mkdir "$work/pointer"
output=$(printf "variable held\n: saved 17 ;\n' saved held !\n: saved 18 ;\nprune\nheld @ execute . saved . verify? . cr\nbye\n" | HOME="$work/pointer" "$runtime")
case "$output" in *'0 superseded dictionary entries pruned.'*'17 18 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Seed the same pruned source with SwiftForth: no target-only pruning decisions.

if [ "${VALIDATE_SF:-0}" = 1 ]; then
  mkdir -p "$work/seed/selfhost/build"
  cp "$work/pruned.f" "$work/seed/forth.f"
  cp "$(dirname "$runtime")/shim.f" "$work/seed/shim.f"
  (cd "$work/seed" && "${SF:-sf}" shim.f)
  cmp "$last/image.bin" "$work/seed/selfhost/build/image.bin"
fi
printf 'Native checkpoints, branching, source export, restore rejection and pruning passed.\n'
