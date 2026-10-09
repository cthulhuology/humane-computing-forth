#!/bin/sh
# Native parent patches, project storage, self-verification, restore and pruning.
set -eu
runtime=$(realpath "${1:-./forth}")
project=$(dirname "$runtime")
decoder="$project/selfhost/reconstruct-snapshot.rb"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work/home with spaces"
mkdir -p "$HOME" "$work/project with spaces"
cd "$work/project with spaces"
# Editing, importing and pruning must never create snapshots on their own.
mkdir "$work/unsaved"
printf ': loaded 7 ;\nunit.end\n' > "$work/import.f"
output=$(cd "$work/unsaved"; printf ': draft 1 ;\n: draft 2 ;\nsource.load %s\nprune\ndraft . loaded . verify? . cr\nbye\n' "$work/import.f" | "$runtime")
case "$output" in *'1 superseded dictionary entries pruned.'*'2 7 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
test ! -e "$work/unsaved/unsaved.snapshots"
# The first explicit save contains all current edits and creates only one root.
output=$(cd "$work/unsaved"; printf ': draft 9 ;\nsource.load %s\nsnapshot All edits\n: later 10 ;\nbye\n' "$work/import.f" | "$runtime")
test "$(find "$work/unsaved" -name complete | wc -l)" -eq 1
test "$(cat "$work/unsaved/unsaved.snapshots/00000000/comment")" = 'All edits'
output=$(printf 'restore %s\ndraft . loaded . cr\nlater\nbye\n' "$work/unsaved/unsaved.snapshots/00000000" | "$runtime")
case "$output" in *'9 7 '*'Unknown command word: later'*) ;; *) printf '%s\n' "$output"; exit 1;; esac

collection="$PWD/project with spaces.snapshots"
output=$(printf 'snapshot\nvariable counter\nsnapshot\n99 counter !\n: value 11 ;\nsnapshot\n: value 22 ;\nsnapshot\nundo\ncounter @ . value . fdepth . depth . cr\n: value 33 ;\nsnapshot\nvalue . verify? . cr\nsource.save %s\ncheckpoints\nbye\n' "$work/export.f" | "$runtime")
case "$output" in *'0 11 0 0 '*'33 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
root="$collection/00000000"
a="$collection/00000002"
b="$collection/00000003"
c="$collection/00000004"
for node in "$root" "$collection/00000001" "$a" "$b" "$c"; do
  test "$(find "$node" -type f | wc -l)" -eq 2
  test "$(wc -c < "$node/complete")" -eq 8
  "$runtime" snapshot.verify "$node" </dev/null | grep -q 'Snapshot verification passed.'
  ruby "$decoder" "$node" "$work/image.bin" "$work/source.f"
done
cmp "$work/export.f" "$work/source.f"
test "$(wc -c < "$c/image.patch")" -lt 4096
ruby -e 'ARGV.each { |p| abort "wrong parent" unless File.binread(p)[8,8].unpack1("Q<") == 2 }' "$b/image.patch" "$c/image.patch"
output=$(printf 'restore %s\nvalue . counter @ . verify? . cr\nbye\n' "$b" | "$runtime")
case "$output" in *'22 0 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Relative paths work too; undo at a root stays in its editor.
output=$(printf 'restore project with spaces.snapshots/00000000\nundo\n42 . cr\nbye\n' | "$runtime")
case "$output" in *'No parent snapshot:'*'42 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
cp "$b/image.patch" "$work/good.patch"
# Well-formed code/source disagreement must fail the image's own compiler check.
ruby -e 'p=ARGV[0];s=File.binread(p);abort "fixture source absent" unless s.include?(": value 22 ;");File.binwrite(p,s.sub(": value 22 ;",": value 23 ;"))' "$b/image.patch"
output=$(printf 'restore %s\n43 . cr\nbye\n' "$b" | "$runtime")
case "$output" in *'Snapshot source verification failed:'*'43 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# A failed explicit save retains unsaved definitions and releases its buffers.
output=$(printf 'restore %s\n: verify? 0 ;\nsnapshot invalid verifier\nverify? . snapshot.result @ . snapshot.patch @ . depth . cr\nbye\n' "$c" | "$runtime")
case "$output" in *'Snapshot source verification failed:'*'0 0 0 0 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Structural corruption, forward parents, truncation and absent markers all fail safely.
for damage in trailing parent offset length truncate marker; do
  cp "$work/good.patch" "$b/image.patch"
  ruby -e 'p,kind=ARGV;s=File.binread(p);case kind;when "trailing";s << "x";when "parent";s[8,8]=[3].pack("Q<");when "offset";s[40,8]=[1048576].pack("Q<");when "length";s[48,8]=[0xffffffffffffffff].pack("Q<");when "truncate";s=s[0,39];when "marker";File.unlink(File.join(File.dirname(p),"complete"));end;File.binwrite(p,s)' "$b/image.patch" "$damage"
  output=$(printf 'restore %s\n44 . cr\nsnapshot.result @ . snapshot.patch @ . snapshot.memfd @ . depth . cr\nbye\n' "$b" | "$runtime")
  case "$output" in *'44 '*'0 0 0 0 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
  case "$output" in *'Invalid snapshot:'*|*'Checkpoint I/O failed:'*) ;; *) exit 1;; esac
done
# Source export never replaces an existing file.
output=$(printf 'source.save %s\n45 . cr\nbye\n' "$work/export.f" | "$runtime")
case "$output" in *'Checkpoint I/O failed:'*'45 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Saving follows chdir and names each collection after the new working directory.
mkdir "$work/other project"
output=$(printf 'restore %s\n: switch s" %s/other project" chdir drop ;\nswitch\n: elsewhere 51 ;\nsnapshot New project\ncheckpoint.path\nvalue . elsewhere . cr\nbye\n' "$c" "$work" | "$runtime")
case "$output" in *"$work/other project/other project.snapshots/00000000"*'33 51 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Definitions remain usable even when the snapshot destination cannot be written.
mkdir "$work/failure"
printf blocked > "$work/failure/failure.snapshots"
output=$(cd "$work/failure"; printf ': unpublished 19 ;\n46 . cr\nunpublished . cr\nbye\n' | "$runtime")
case "$output" in *'46 '*'19 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Pruning retains references and replays its decisions through patch reconstruction.
mkdir "$work/prune"
output=$(cd "$work/prune"; printf ': unused 11 ;\n: unused 22 ;\nprune\n: used 31 ;\n: caller used ;\n: used 32 ;\nprune\nunused . caller . used . verify? . cr\nsource.save %s\nsnapshot Pruned system\ncheckpoints\nbye\n' "$work/pruned.f" | "$runtime")
case "$output" in *'1 superseded dictionary entries pruned.'*'0 superseded dictionary entries pruned.'*'22 31 32 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
grep -q ' entry.hide$' "$work/pruned.f"
last=$(printf '%s\n' "$output" | tail -n 1)
"$runtime" snapshot.verify "$last" </dev/null
ruby "$decoder" "$last" "$work/pruned.bin" "$work/replayed.f"
cmp "$work/pruned.f" "$work/replayed.f"
mkdir "$work/pointer"
output=$(cd "$work/pointer"; printf "variable held\n: saved 17 ;\n' saved held !\n: saved 18 ;\nprune\nheld @ execute . saved . verify? . cr\nbye\n" | "$runtime")
case "$output" in *'0 superseded dictionary entries pruned.'*'17 18 -1 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac
# Unchanged revisions store no spans; growth and shrink reproduce exact images.
mkdir "$work/extents"
ruby -e 'File.write(ARGV[0], 92.chr + " retained source padding " + "x" * 8192 + "\n")' "$work/padding.f"
output=$(cd "$work/extents"; printf 'checkpoint\ncheckpoint\norg\nsource.load %s\nsnapshot Grown source\nsnapshot.publish\ncheckpoint.path\nbye\n' "$work/padding.f" | "$runtime")
base="$work/extents/extents.snapshots"
test "$(wc -c < "$base/00000001/image.patch")" -eq 40
ruby "$decoder" "$base/00000000" "$work/base.bin"
ruby "$decoder" "$base/00000002" "$work/grown.bin"
ruby "$decoder" "$base/00000003" "$work/shrunk.bin"
test "$(wc -c < "$work/grown.bin")" -gt "$(wc -c < "$work/base.bin")"
cmp "$work/base.bin" "$work/shrunk.bin"
"$runtime" snapshot.verify "$base/00000003" </dev/null
# Copying a complete project collection preserves its parent references.
cp -r "$base" "$work/moved.snapshots"
"$runtime" snapshot.verify "$work/moved.snapshots/00000003" </dev/null

# Explicit descriptions consume the rest of the line and are committed with the patch.
mkdir "$work/descriptions"
output=$(cd "$work/descriptions"; printf '42\nsnapshot release one ; bye\n. cr\nsnapshot release two\nsnapshots\nbye\n' | "$runtime")
case "$output" in *'42 '*'00000001  release two'*'00000000  release one ; bye'*) ;; *) printf '%s\n' "$output"; exit 1;; esac
test "$(cat "$work/descriptions/descriptions.snapshots/00000000/comment")" = 'release one ; bye'
"$runtime" snapshot.verify "$work/descriptions/descriptions.snapshots/00000000" </dev/null
# A failed save releases the captured comment and keeps the input loop usable.
output=$(cd "$work/failure"; printf 'snapshot cannot save\nsnapshot.comment.address @ . snapshot.comment.length @ . 47 . cr\nbye\n' | "$runtime")
case "$output" in *'Checkpoint I/O failed:'*'0 0 47 '*) ;; *) printf '%s\n' "$output"; exit 1;; esac

if [ "${VALIDATE_SF:-0}" = 1 ]; then
  mkdir -p "$work/seed/selfhost/build"
  cp "$work/pruned.f" "$work/seed/forth.f"
  cp "$project/shim.f" "$work/seed/shim.f"
  (cd "$work/seed" && "${SF:-sf}" shim.f)
  cmp "$work/pruned.bin" "$work/seed/selfhost/build/image.bin"
fi
printf 'Native project snapshots, compact patches, self-verification, branching and rejection passed.\n'
