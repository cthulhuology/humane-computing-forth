#!/bin/sh
# Check native history persistence using an isolated home directory.
set -eu
runtime=${1:-./forth}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"

printf ': hello ." hello world" ;\nhello cr\nverify? . cr\nbye\n' > "$work/commands"
output=$("$runtime" < "$work/commands")
[ "$output" = 'hello world
-1 ' ]
cmp "$work/commands" "$work/.forth"
[ "$(stat -c %a "$work/.forth")" = 600 ]

# A new process appends without truncating the previous session.
printf '42 . cr\nbye\n' > "$work/next"
"$runtime" < "$work/next" > /dev/null
cat "$work/next" >> "$work/commands"
cmp "$work/commands" "$work/.forth"

# Failed commands, blank lines and an EOF-terminated partial line are retained.
printf 'unknown.history.word\n\n17 . cr' > "$work/next"
"$runtime" < "$work/next" > /dev/null
cat "$work/next" >> "$work/commands"
printf '\n' >> "$work/commands"
cmp "$work/commands" "$work/.forth"

# A command sees itself already present in the history buffer when it executes.
printf 'history.length @ .\n' > "$work/next"
cat "$work/next" >> "$work/commands"
expected=$(wc -c < "$work/commands" | tr -d ' ')
[ "$("$runtime" < "$work/next")" = "$expected " ]
cmp "$work/commands" "$work/.forth"

# Existing long files grow the recall buffer; missing final newlines are repaired.
printf '\\ ' > "$work/.forth"
head -c 18000 /dev/zero | tr '\000' x >> "$work/.forth"
cp "$work/.forth" "$work/commands"
printf '\nbye\n' >> "$work/commands"
printf 'bye\n' | "$runtime"
cmp "$work/commands" "$work/.forth"

# An unavailable history path must prevent execution of an unrecorded command.
mkdir "$work/unavailable"
mkdir "$work/unavailable/.forth"
if output=$(printf '999 .\n' | HOME="$work/unavailable" "$runtime"); then exit 1; else status=$?; fi
[ "$status" -eq 2 ]
[ "$output" = 'Cannot save command history in ~/.forth.' ]
printf 'History persistence, ordering, growth, final lines and write failure passed.\n'
