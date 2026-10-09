#!/bin/sh
# Native transactional file compilation and libc shell/filesystem services.
set -eu
runtime=$(realpath "${1:-./forth}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"
project=$(dirname "$runtime")
cd "$work"
cat > "$work/import file.f" <<'FORTH'
\ Imported words retain their documentation in the mapped source image.
: imported 41 ;

\ Compile a reference into an earlier imported definition.
: doubled imported 2 * ;
unit.end

\ Allocate an ordinary runtime variable as part of the import.
variable imported.cell

\ Add a compile-time constant from the file's interpreting reader.
123 constant imported.constant
FORTH
output=$(printf '88\nsource.load %s\n. imported . doubled . imported.constant . imported.cell @ . verify? . depth . cr\nsnapshot Imported source\nsource.save %s\ncheckpoints\nbye\n' "$work/import file.f" "$work/export.f" | "$runtime")
case "$output" in *'88 41 82 123 0 -1 0 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
last=$(printf '%s\n' "$output" | tail -n 1)
ruby "$project/selfhost/reconstruct-snapshot.rb" "$last" "$work/restored.bin" "$work/restored.f"
cmp "$work/export.f" "$work/restored.f"
"$runtime" snapshot.verify "$last" </dev/null
# One explicit save creates exactly one revision after the entire import.
test "$(find "$work/$(basename "$work").snapshots" -name complete | wc -l)" -eq 1
grep -q 'Imported words retain their documentation' "$work/export.f"
cat > "$work/broken.f" <<'FORTH'
: unpublished 99 ;
: broken missing.import.word ;
FORTH
output=$(printf 'source.load %s\nunpublished\nsource.load /nonexistent\nsource.load.buffer @ . editor.stage @ . snapshot.fd @ . 42 . cr\nbye\n' "$work/broken.f" | "$runtime")
case "$output" in *'Compilation error: missing.import.word'*'Unknown command word: unpublished'*'Checkpoint I/O failed:'*'0 0 -1 42 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Compiler stack imbalance cannot consume an existing runtime value and publish.
printf ': unbalanced 1 ;\n123 constant misplaced\n' > "$work/unbalanced.f"
output=$(printf '88\nsource.load %s\nunbalanced\nsource.load.buffer @ . editor.stage @ . 43 . cr\nbye\n' "$work/unbalanced.f" | "$runtime")
case "$output" in *'Compilation error:'*'Unknown command word: unbalanced'*'0 0 43 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Source import does not depend on a writable snapshot destination.
mkdir "$work/failure"
printf blocked > "$work/failure/failure.snapshots"
output=$(cd "$work/failure"; printf 'source.load %s\nimported . cr\nsource.load.buffer @ . editor.stage @ . 44 . cr\nbye\n' "$work/import file.f" | HOME="$work/failure" "$runtime")
case "$output" in *'41 '*'0 0 44 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# The counted reader is callable from ordinary Forth definitions too.
output=$("$runtime" ": import.test s\" $work/import file.f\" source.read ; import.test imported . verify? . depth ." </dev/null)
case "$output" in *'41 -1 0 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# libc results retain signed int semantics; SYSTEM exposes the encoded wait status.
output=$(printf ': os.check s" %s/new directory" 448 mkdir . s" %s/new directory" 448 mkdir . s" %s/new directory" chdir . s" /no-such-directory" chdir . s" exit 7" system . cr ;\nos.check\n$ printf "%%s" "shell ; text" > shell-output\n$\ndepth . verify? . cr\nbye\n' "$work" "$work" "$work" | "$runtime")
case "$output" in *'0 -1 0 -1 1792 '*'0 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
test "$(cat "$work/new directory/shell-output")" = 'shell ; text'
# The bootstrap compiler must reproduce the imported checkpoint, including source.
if [ "${VALIDATE_SF:-0}" = 1 ]; then
  mkdir -p "$work/seed/selfhost/build"
  cp "$work/export.f" "$work/seed/forth.f"
  cp "$(dirname "$runtime")/shim.f" "$work/seed/shim.f"
  (cd "$work/seed" && "${SF:-sf}" shim.f)
  cmp "$work/restored.bin" "$work/seed/selfhost/build/image.bin"
fi
printf 'Native source imports, atomic failure, checkpoints, libc wrappers and shell lines passed.\n'
