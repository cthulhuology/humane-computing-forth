#!/bin/sh
# Debugger hooks execute as native Forth in an isolated context after sigreturn.
set -eu
runtime=$(realpath "${1:-./forth}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"
cd "$work"

require_text() {
    case "$output" in
        *"$1"*) ;;
        *) printf 'Missing debugger output: %s\n%s\n' "$1" "$output" >&2; exit 1 ;;
    esac
}

output=$(printf 'depth . rdepth . 7 . cr\n' | "$runtime" trap 999 .)
require_text 'signal 5 '
require_text '0 0 7 '
case "$output" in *'Register (hex)'*) exit 1 ;; esac

output=$(printf 'depth . rdepth . 7 . cr\n' |
    "$runtime" "'" test.debug.clean DEBUG ! 10 20 test.debug.fault)
require_text debug-clean
require_text '0 0 7 '

output=$(printf 'depth . rdepth . 7 . cr\n' |
    "$runtime" "'" debug.dump DEBUG ! 10 20 test.debug.fault)
require_text 'RAX 0000000012345678 | 0000000000000014 |'
require_text '| 000000000000000A |'
require_text 'Source: test.debug.fault+0x'
require_text 'image.call+0x'
require_text 'code test.debug.fault'
require_text '0 0 7 '

# Translate calls across a relocated faulting image and the original caller image.
output=$(printf 'depth . rdepth . 7 . cr\n' |
    "$runtime" "'" debug.dump DEBUG ! rebuild dup image.seal '>r' 10 20 'r>' "'" test.debug.fault image.call)
require_text 'Source: test.debug.fault+0x'
require_text 'image.call+0x'
require_text '0 0 7 '

output=$(printf 'depth . rdepth . 7 . cr\n' |
    "$runtime" "'" trap DEBUG ! trap)
require_text 'Debug hook fault: signal 5 '
require_text '0 0 7 '

output=$(printf 'depth . rdepth . fault.number . 7 . cr\n' |
    "$runtime" "'" test.fault.native DEBUG ! trap)
require_text 'Debug hook fault: signal 11 '
require_text '0 0 5 7 '

output=$(printf 'depth . rdepth . 7 . cr\n' |
    "$runtime" "'" quit DEBUG ! trap)
require_text '0 0 7 '

output=$(printf 'depth . rdepth . 7 . cr\n' | "$runtime" 99 quit 999 .)
[ "$output" = '0 0 7 ' ]

output=$(printf 'depth . rdepth . 7 . cr\n' |
    "$runtime" rebuild dup image.seal "'" test.debug.foreign debug.install 10 20 test.debug.fault)
require_text debug-clean
require_text '0 0 7 '

# Retain ordinary stacks between lines, reset both after a later line faults,
# keep the hook installed, and handle a final input line without a newline.
output=$(printf "' debug.dump DEBUG !\n11 22 >r\ntrap\ndepth . rdepth . 7 ." | "$runtime")
require_text '| 000000000000000B |'
require_text 'Forth return stack (R12, top first): 0000000000000016 '
require_text 'Data stack (top) | FP stack (top)   | Return stack (RSP)'
require_text '0 0 7 '

# Captured FP values sit between the data and native return columns, top first.
output=$(printf "' debug.dump DEBUG !\n1.5 2.25 trap\nfdepth . depth . 7 .\n" | "$runtime")
require_text ' |                  |             2.25 |'
require_text ' |                  |              1.5 |'
require_text '0 0 7 '

output=$(printf "' debug.dump DEBUG !\n0 DEBUG ! trap\n42 .\n" | "$runtime")
require_text '42 '
case "$output" in *'Register (hex)'*) exit 1 ;; esac

output=$(printf 'depth . rdepth . 42 .\n' | "$runtime" 99 missing.command)
require_text 'Unknown command word: missing.command'
require_text '0 0 42 '

printf 'Debug hook isolation, captured state, source display and QUIT recovery passed.\n'
