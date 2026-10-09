#!/bin/sh
# Exercise native editor compilation and inspection without a host compiler.
set -eu
runtime=${1:-./forth}

check_output() {
    expected=$1
    shift
    actual=$("$runtime" "$@" < /dev/null)
    [ "$actual" = "$expected" ] || {
        printf 'Unexpected editor output: <%s>, expected <%s>\n' "$actual" "$expected" >&2
        exit 1
    }
}

require_text() {
    case "$output" in
        *"$1"*) ;;
        *) printf 'Missing editor output: %s\n%s\n' "$1" "$output" >&2; exit 1 ;;
    esac
}

check_output '81 -1 ' ': sq dup * ; 9 sq . verify? .'
check_output 'hello world-1 ' ': hello ." hello world" ; hello verify? .'
check_output 'left  right-1 ' ': strings ." " ." left  right" ; strings verify? .'
check_output '2 -1 ' ': a 1 ; : b a 1+ ; b . verify? .'
check_output '2 -1 ' ': a 1 ; : a 2 ; a . verify? .'
check_output '720 -1 ' ': fact dup 1 > if dup 1- fact * else drop 1 then ; 6 fact . verify? .'
check_output '42 -1 ' '42 constant answer answer . verify? .'
check_output '42 -1 ' 'variable total 42 total ! total @ . verify? .'
check_output '17 -1 ' ': emit17 17 asm.literal ; immediate : answer emit17 ; answer . verify? .'
check_output '4 3 -1 ' ': prefix 3 : suffix 4 ; prefix . . verify? .'
check_output '7 -1 ' 'code seven rax 7 mov64, rax rbp 0 store, rbp 8 add#, ret, code.end seven . verify? .'
check_output '-1 0 ' 'debug.on DEBUG @ 0<> . debug.off DEBUG @ . bye 999 .'

output=$(printf ': choose\n if 11 ; then 22 ;\n0 choose . 1 choose . verify? .\n' | "$runtime")
[ "$output" = '22 11 -1 ' ]

output=$(printf ': good 7 ; : broken missing\ngood . verify? .\n' | "$runtime")
require_text 'Compilation error: missing'
require_text '7 -1 '

output=$(printf ': if 17 ;\n42 .\n' | "$runtime")
require_text 'Cannot redefine installed compiler syntax: if'
require_text '42 '

if output=$("$runtime" ': unfinished if 1 ;' < /dev/null); then exit 1; else status=$?; fi
[ "$status" -eq 2 ]
require_text 'Unfinished compilation at end of input.'

output=$("$runtime" ': inspected 123 ; see inspected locate inspected where inspected words' < /dev/null)
require_text ': inspected 123 ;'
require_text 'inspected  image 0x'
require_text 'source +0x'
require_text 'debug.on'
require_text 'bye'

output=$("$runtime" ': inspected 123 ; 42 where inspected . cr' < /dev/null)
require_text 'inspected+0x'
require_text ': inspected 123 ;'
require_text '42 '

output=$("$runtime" 'org 16 dump' < /dev/null)
require_text ': 46 54 46 53 45 4C 46 31 '
require_text '|FTFSELF1'

output=$(printf 'depth . rdepth . 42 .\n' | "$runtime" '0 1 dump')
require_text 'signal 11 '
require_text '0 0 42 '

output=$(printf 'locate broken depth . rdepth . 7 .\n' | "$runtime" 'debug.on : broken trap ; broken')
require_text 'Source: trap+0x'
require_text 'broken+0x'
require_text ': broken trap ;'
require_text '0 0 7 '

printf 'Editor append, extended self-compilation, recovery and inspection passed.\n'
