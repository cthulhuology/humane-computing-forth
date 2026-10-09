#!/bin/sh
# Exercise the native argument reader; no host Forth is used for these checks.
set -eu
runtime=${1:-./selfhost/build/forth}

check_output() {
    expected=$1
    shift
    actual=$("$runtime" "$@" < /dev/null)
    if [ "$actual" != "$expected" ]; then
        printf 'Unexpected command output: <%s>, expected <%s>\n' "$actual" "$expected" >&2
        exit 1
    fi
}

check_failure() {
    expected_status=$1
    expected_text=$2
    shift 2
    if actual=$("$runtime" "$@" < /dev/null); then
        printf 'Expected command failure: %s\n' "$*" >&2
        exit 1
    else
        status=$?
    fi
    [ "$status" -eq "$expected_status" ]
    case "$actual" in
        *"$expected_text"*) ;;
        *) printf 'Unexpected diagnostic: %s\n' "$actual" >&2; exit 1 ;;
    esac
}

check_output '3 ' 1 2 + .
check_output '81 ' '9 square .'
check_output '123 ' 123 '>r' 'r>' .
check_output '32 ' '$20' .
check_output '-1 7 ' verify? . 7 .
check_output 'Verification passed: rebuilt image is identical.
-1 ' verify .
check_output 'Verification FAILED: rebuilt image differs.
0 ' 'org page.size protection.read.write image.protect 1 org header.rebuild.xt + cell+ c! verify .'

check_output '' ''
check_output '' '   '
check_output 'input.address @ input.length @ type' input.address @ input.length @ type
check_output ' input.address @ input.length @ type ' '' input.address @ input.length @ type ''

# More than one page, and thousands of individual argv entries.
set --
count=0
while [ "$count" -lt 1500 ]; do
    set -- "$@" 0 drop
    count=$((count + 1))
done
check_output '42 ' "$@" 42 .

check_failure 2 'Unknown command word: missing.command' missing.command
check_output '1 ' : example 1 ';' example .
check_failure 133 'signal 5 ' trap 999 .
check_failure 136 'signal 8 ' 1 0 u/mod
check_failure 139 'signal 11 ' 0 @
check_failure 7 '' 7 process.exit
printf 'Command-line input, execution, compiler reuse and fault recovery passed.\n'
