#!/bin/sh
# Exercise source navigation and the native x86-64 decoder without external tools.
set -eu
runtime=${1:-./forth}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export HOME="$work"
require_text() {
    case "$output" in
        *"$1"*) ;;
        *) printf 'Missing inspection output: %s\n%s\n' "$1" "$output" >&2; exit 1 ;;
    esac
}
reject_text() {
    case "$output" in
        *"$1"*) printf 'Unexpected inspection output: %s\n%s\n' "$1" "$output" >&2; exit 1 ;;
    esac
}

# LOCATE shows the selected source and both adjacent definitions.
output=$("$runtime" ': inspect.before 11 ; : inspect.focus 22 ; : inspect.after 33 ; : inspect.beyond 44 ; locate inspect.focus 42 .')
require_text ': inspect.before 11 ;'
require_text ': inspect.focus 22 ;'
require_text ': inspect.after 33 ;'
reject_text ': inspect.beyond 44 ;'
reject_text 'Disassembly'
reject_text 'forth.f:'
require_text 'source +0x'
require_text '42 '

# WHERE finds every occurrence, including repeated calls on the same line,
# without matching longer names or consuming existing data-stack contents.
output=$("$runtime" ': inspect.needle 1 ; : inspect.needle.long 2 ; : inspect.caller inspect.needle inspect.needle ; 42 where inspect.needle . cr')
[ "$(printf '%s\n' "$output" | grep -c 'source +0x')" -eq 3 ]
reject_text 'inspect.needle.long'
require_text ': inspect.needle 1 ;'
require_text ': inspect.caller inspect.needle inspect.needle ;'
require_text 'inspect.needle+0x'
require_text 'inspect.caller+0x'
reject_text 'forth.f:'
require_text '42 '
output=$("$runtime" 'where not.present.in.source')
[ "$output" = 'No source occurrences.' ]
output=$("$runtime" 'where contiguous')
require_text 'source.window.comments [documentation] -0x'
reject_text 'forth.f:'

# SEE reads the selected image's bytes and emits genuine Intel operands.
output=$("$runtime" 'see dup')
require_text 'Memory:'
require_text 'Disassembly (Intel):'
require_text '48 8B 45 F8'
require_text 'mov rax, qword ptr [rbp - 0x8]'
require_text 'add rbp, 0x8'
require_text 'ret'
require_text 'Source:'
require_text 'source +0x'
reject_text 'forth.f:'
require_text '\ Duplicate the top data-stack cell.'
require_text 'code dup'
require_text 'rax rbp -8 load,'
reject_text 'code drop'
reject_text '\ Discard the top data-stack cell.'
printf '%s\n' "$output" | awk '
  /^Memory:/ { memory = NR }
  /^Disassembly/ { assembly = NR }
  /^Source:/ { source = NR }
  END { exit !(memory > 0 && assembly > memory && source > assembly) }
'

# Consecutive documentation lines are included, but the next block is excluded.
output=$("$runtime" 'see source.window')
require_text '\ Select leading documentation and source through the first trailing blank line.'
require_text '\ This is a text display window; labels and returns do not imply definition ends.'
reject_text '\ Display the nearest entry'

output=$("$runtime" 'locate drop')
require_text '\ Duplicate the top data-stack cell.'
require_text '\ Discard the top data-stack cell.'
require_text '\ Exchange the top two data-stack cells.'
reject_text '\ Copy the second data-stack cell'

# Every constant has a focused documentation block, including assembler registers.
output=$("$runtime" 'see recovery.org.field')
require_text '\ R13-relative field storing the image origin to restore when recovering.'
require_text '32      constant recovery.org.field'
reject_text 'constant recovery.continuation.field'
reject_text 'constant recovery.r12.field'
output=$("$runtime" 'see rax')
require_text '\ Assembler register encoding for RAX.'
require_text '0 constant rax'
reject_text 'constant rcx'

# Source comes from the appended image and continues beyond an early return.
output=$("$runtime" ': inspect.source.example if 11 ; then 22 ; : inspect.source.next 33 ; see inspect.source.example verify? .')
require_text ': inspect.source.example if 11 ; then 22 ;'
reject_text ': inspect.source.next 33 ;'
require_text 'Disassembly (Intel):'
require_text '-1 '

# Encode each supported operand family in a never-executed CODE fixture.
output=$("$runtime" 'code inspect.encoding r15 $1122334455667788 mov64, r8 r9 mov.rr, r10 rsp -128 load, r11 r12 128 store, r15 r13 0 lea, rax 0 rip.lea, r15 push, r14 pop, r15 execute, r14 jump.reg, r8 -7 add#, r9 7 sub#, r10 -1 cmp#, r11 255 and#, r8 r9 add.rr, r8 r9 sub.rr, r8 r9 and.rr, r8 r9 or.rr, r8 r9 xor.rr, r8 r9 cmp.rr, r8 r9 imul.rr, r15 r12 1 load8, r15 r12 1 store8, r15 r12 1 load.s32, r15 r12 1 store32, r8 negate, r9 divide, r10 multiply, r11 3 shift.right#, r12 shl.cl, r13 shr.cl, r15 cc.equal setcc, syscall, ud2, int3, cld, movsb, stosb, ret, code.end see inspect.encoding verify? .')
require_text 'mov r15, 0x1122334455667788'
require_text 'mov r8, r9'
require_text 'mov r10, qword ptr [rsp - 0x80]'
require_text 'mov qword ptr [r12 + 0x80], r11'
require_text 'lea r15, [r13]'
require_text 'lea rax, [rip - 0x'
require_text 'push r15'
require_text 'pop r14'
require_text 'call r15'
require_text 'jmp r14'
require_text 'add r8, -0x7'
require_text 'sub r9, 0x7'
require_text 'cmp r10, -0x1'
require_text 'and r11, 0xFF'
for mnemonic in add sub and or xor cmp imul; do require_text "$mnemonic r8, r9"; done
require_text 'movzx r15, byte ptr [r12 + 0x1]'
require_text 'mov byte ptr [r12 + 0x1], r15b'
require_text 'movsxd r15, dword ptr [r12 + 0x1]'
require_text 'mov dword ptr [r12 + 0x1], r15d'
require_text 'neg r8'
require_text 'div r9'
require_text 'mul r10'
require_text 'shr r11, 0x3'
require_text 'shl r12, cl'
require_text 'shr r13, cl'
require_text 'sete r15b'
for mnemonic in syscall ud2 int3 cld 'rep movsb' 'rep stosb' ret; do require_text "$mnemonic"; done
reject_text 'db 0x'
require_text '-1 '

# Multiple returns remain visible; branch/call targets resolve in the new image.
output=$("$runtime" ': inspect.choose if 11 ; then 22 ; see inspect.choose')
[ "$(printf '%s\n' "$output" | grep -c ' ret$')" -eq 2 ]
require_text 'je 0x'
require_text '<inspect.choose+0x'
output=$("$runtime" ': inspect.callee 1 ; : inspect.caller inspect.callee ; see inspect.caller')
require_text '<inspect.callee>'
output=$("$runtime" ': inspect.alias : inspect.same 7 ; see inspect.alias verify? .')
require_text 'mov rax, 0x7'
require_text '-1 '

# A truncated prefix cannot borrow bytes from the next named code window.
output=$("$runtime" 'code inspect.short $48 c, code.end code inspect.next ret, code.end see inspect.short')
require_text 'db 0x48'
reject_text ' ret'
output=$("$runtime" 'code inspect.unknown $62 c, code.end see inspect.unknown')
require_text 'db 0x62'

# Decode the complete running code segment, including this audit definition.
output=$("$runtime" ': inspect.audit org dis.image ! code.start dis.cursor ! org header.code.limit + @ dis.limit ! begin dis.cursor @ dis.limit @ < while dis.decode dis.bad @ if dis.print then repeat ; inspect.audit depth . verify? .')
[ "$output" = '0 -1 ' ]
printf 'Distinct source inspection, code dumps, native disassembly and bounded decoding passed.\n'
