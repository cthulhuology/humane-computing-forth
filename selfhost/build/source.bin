\ forth.f -- canonical, executable source for the native self-compiling image.
\ Linux x86-64, 64-bit cells. RBX = image origin; RBP = next data-stack slot;
\ R12 = next Forth return-stack slot; R13 = private compiler context.
\ RSP contains native return addresses only. Image fields contain offsets.
\ CODE executes the shared assembler through an invocation-private output vector.
\ Code is packed. : names an entry point; ; emits RET without ending a body.
\ Labels may share code and control flow. Names support ordinary recursion.
\ The complete file is retained verbatim in the image's read-only source part.
\ Inline assembly comments use Intel destination, source order; semicolons
\ separate instructions. Symbolic immediates and branch targets are fixups.

\ Establish the image origin, allocate stacks and context, and invoke main.
code kernel.start
  \ Compute ORG using the selected image's code cursor, not a fixed displacement.
  rbx 0 rip.lea,
  rdi 0 mov64,
  rsi context.mapping.size mov64,
  rdx protection.read.write mov64,
  r10 34 mov64,
  r8 -1 mov64,
  r9 0 mov64,
  rax 9 mov64,
  syscall,
  rax 0 cmp#,
  cc.not.sign jcc.hole,
  rdi 2 mov64,
  rax 60 mov64,
  syscall,
  resolve,
  r13 rax mov.rr,
  rbp r13 data.stack.offset lea,
  r12 r13 return.stack.offset lea,
  rax rbx header.main.xt load,
  rax rbx add.rr,
  rax execute,
  rdi 0 mov64,
  rax 60 mov64,
  syscall,
code.end

\ Duplicate the top data-stack cell.
code dup
  rax rbp -8 load,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Discard the top data-stack cell.
code drop
  rbp 8 sub#,
  ret,
code.end

\ Exchange the top two data-stack cells.
code swap
  rax rbp -8 load,
  rdx rbp -16 load,
  rax rbp -16 store,
  rdx rbp -8 store,
  ret,
code.end

\ Copy the second data-stack cell to the top.
code over
  rax rbp -16 load,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Add the top two cells.
code +
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax add.rr,
  rdx rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Subtract the top cell from the cell below it.
code -
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax sub.rr,
  rdx rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Multiply the top two cells.
code *
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax imul.rr,
  rdx rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Compute the bitwise AND of the top two cells.
code and
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax and.rr,
  rdx rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Compute the bitwise OR of the top two cells.
code or
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax or.rr,
  rdx rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Compute the bitwise exclusive OR of the top two cells.
code xor
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax xor.rr,
  rdx rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Return a Forth flag indicating whether two cells are equal.
code =
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax cmp.rr,
  rax 0 mov64,
  rax cc.equal setcc,
  rax negate,
  rax rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Compare two signed cells and return whether the first is smaller.
code <
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax cmp.rr,
  rax 0 mov64,
  rax cc.less setcc,
  rax negate,
  rax rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Compare two unsigned cells and return whether the first is smaller.
code u<
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax cmp.rr,
  rax 0 mov64,
  rax cc.below setcc,
  rax negate,
  rax rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Shift a cell left by the supplied bit count.
code lshift
  rcx rbp -8 load,
  rax rbp -16 load,
  rax shl.cl,
  rax rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Shift a cell right logically by the supplied bit count.
code rshift
  rcx rbp -8 load,
  rax rbp -16 load,
  rax shr.cl,
  rax rbp -16 store,
  rbp 8 sub#,
  ret,
code.end

\ Divide unsigned cells and return the remainder followed by the quotient.
code u/mod
  rcx rbp -8 load,
  rax rbp -16 load,
  rdx rdx xor.rr,
  rcx divide,
  rdx rbp -16 store,
  rax rbp -8 store,
  ret,
code.end

\ Fetch a cell from a native address.
code @
  rax rbp -8 load,
  rax rax 0 load,
  rax rbp -8 store,
  ret,
code.end

\ Store a cell at a native address.
code !
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax 0 store,
  rbp 16 sub#,
  ret,
code.end

\ Fetch an unsigned byte from a native address.
code c@
  rax rbp -8 load,
  rax rax 0 load8,
  rax rbp -8 store,
  ret,
code.end

\ Store the low byte of a cell at a native address.
code c!
  rax rbp -8 load,
  rdx rbp -16 load,
  rdx rax 0 store8,
  rbp 16 sub#,
  ret,
code.end

\ Move the top data-stack cell to the Forth return stack.
code >r
  rax rbp -8 load,
  rax r12 0 store,
  r12 8 add#,
  rbp 8 sub#,
  ret,
code.end

\ Move the top Forth return-stack cell to the data stack.
code r>
  r12 8 sub#,
  rax r12 0 load,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Copy the top Forth return-stack cell to the data stack.
code r@
  rax r12 -8 load,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Copy bytes forward from a source address to a destination address.
code move
  rcx rbp -8 load,
  rdi rbp -16 load,
  rsi rbp -24 load,
  cld,
  movsb,
  rbp 24 sub#,
  ret,
code.end

\ Fill a native memory range with the low byte of a supplied value.
code fill
  rax rbp -8 load,
  rcx rbp -16 load,
  rdi rbp -24 load,
  cld,
  stosb,
  rbp 24 sub#,
  ret,
code.end

\ Push the native base address of the executing image.
code org
  rbx rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Push the native base address of this invocation's mutable context.
code context
  r13 rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Invoke a Linux system call with six arguments and return its result.
code syscall6
  rax rbp -8 load,
  r9 rbp -16 load,
  r8 rbp -24 load,
  r10 rbp -32 load,
  rdx rbp -40 load,
  rsi rbp -48 load,
  rdi rbp -56 load,
  syscall,
  rax rbp -56 store,
  rbp 48 sub#,
  ret,
code.end

\ Call an image-relative XT with that image's origin, then restore the caller's origin.
code image.call
  rbx push,
  rbx rbp -16 load,
  rax rbp -8 load,
  rax rbx add.rr,
  rbp 16 sub#,
  rax execute,
  rbx pop,
  ret,
code.end

\ HOST-LAYOUT-BEGIN
4096    constant page.size
8       constant header.version
16      constant header.image.size
24      constant header.code.limit
32      constant header.dictionary.limit
40      constant header.dictionary.root
48      constant header.source.offset
56      constant header.source.length
64      constant header.main.xt
72      constant header.context.limit
80      constant header.start.xt
96      constant header.rebuild.xt

\ Linux x86-64 mapping and private R13-relative stack layout (all byte counts).
\ [context][guard][data stack][guard][return stack][guard][unused reserve]
327680  constant context.mapping.size
65536   constant context.guard.offset

\ data stack allocation and depth check
69632   constant data.stack.offset
135168  constant data.guard.offset

\ return stack allocation, recursion depth echeck
139264  constant return.stack.offset
204800  constant return.guard.offset

\ default stack allocation 
65536   constant stack.size

\ memory protection flags
0 constant protection.none
1 constant protection.read
3 constant protection.read.write
5 constant protection.read.execute

\ image memory format
0                 constant header.magic

$31464c4553465446 constant image.magic
2                 constant image.version
1048576           constant image.capacity

4096              constant code.start
131072            constant dictionary.start
262144            constant source.start

\ dictionary entry size
64      constant /entry

\ Dictionary field offsets are bytes, independent of host cell numbering.
0       constant entry.previous
8       constant entry.xt
16      constant entry.name.length
24      constant entry.source.start
32      constant entry.kind
40      constant entry.value
48      constant entry.name.offset
56      constant entry.flags

\ compiler word flag
1       constant flag.immediate

\ editable regions
1024    constant context.variables
4096    constant context.control
8192    constant context.scratch
6144    constant context.assembler
\ HOST-LAYOUT-END

\ Mutable names refer to this invocation's R13 context, never saved image data.
\ Native base address of the candidate image being compiled.
variable build.base

\ Image offset of the next free candidate dictionary record.
variable dictionary.here
\ Image offset of the newest candidate dictionary entry, or zero.
variable dictionary.root

\ Image offset of the entry being built, or zero when released.
variable entry.current

\ Source byte offset of the defining token that introduces an entry.
variable label.start

\ Native address of the source span being parsed.
variable parser.source
\ Length of the source span in bytes.
variable parser.length
\ Current byte offset within the source span.
variable parser.position

\ Native address of the current token in the source span.
variable token.address
\ Length of the current token in bytes.
variable token.length
\ Byte offset of the current token relative to parser.source.
variable token.start

\ Execution token of the current interpretation, compilation, or CODE reader.
variable compiler.action
\ Next free R13-relative byte offset for a candidate variable.
variable compiler.variables

\ Number of pending entries on the compiler control-flow stack.
variable control.depth

\ Unsigned magnitude accumulated while parsing a numeric token.
variable number.value
\ Radix used for the current numeric token: decimal or hexadecimal.
variable number.base
\ Multiplier applied to the parsed magnitude: one or minus one.
variable number.sign
\ Byte offset of the next character within the numeric token.
variable number.position

\ Native address of the name sought by dictionary.find.
variable find.address
\ Length in bytes of the name sought by dictionary.find.
variable find.length
\ Image offset of the entry currently visited during dictionary lookup.
variable find.entry
\ Native base address of the image whose dictionary is being searched.
variable find.base

\ Source byte offset of the first character in the string being compiled.
variable string.start

\ Native address of the next byte in the left comparison range.
variable compare.left
\ Native address of the next byte in the right comparison range.
variable compare.right
\ Number of bytes still to compare in bytes.equal?.
variable compare.length

\ Increment a cell by one.
: 1+ 1 + ;

\ Decrement a cell by one.
: 1- 1 - ;

\ Negate a cell using two's-complement arithmetic.
: negate 0 swap - ;

\ Return whether a cell is zero.
: 0= 0 = ;

\ Return whether a cell is nonzero.
: 0<> 0= 0= ;

\ Return whether two cells differ.
: <> = 0= ;

\ Return whether the first signed cell is greater than the second.
: > swap < ;

\ Return whether the first signed cell is less than or equal to the second.
: <= > 0= ;

\ Return whether the first signed cell is greater than or equal to the second.
: >= < 0= ;

\ Return whether the first unsigned cell is greater than the second.
: u> swap u< ;

\ Duplicate the top pair of data-stack cells.
: 2dup over over ;

\ Discard the top pair of data-stack cells.
: 2drop drop drop ;

\ Discard the second data-stack cell, retaining the top cell.
: nip swap drop ;

\ Copy the top cell beneath the second cell.
: tuck swap over ;

\ Rotate three cells so the third cell becomes the top cell.
: rot >r swap r> swap ;

\ Rotate three cells so the top cell becomes the third cell.
: -rot swap >r swap r> ;

\ Add a value to the cell at a native address.
: +! dup @ rot + swap ! ;

\ Test whether a cell lies in an unsigned half-open interval.
: within ( n low high -- flag ) over - >r - r> u< ;

\ Move a pair of cells to the Forth return stack in order.
: 2>r ( a b -- ) swap >r >r ;

\ Restore a pair of cells from the Forth return stack in order.
: 2r> ( -- a b ) r> r> swap ;

\ Convert a cell count to a byte count.
: cells 8 * ;

\ Advance an address by one native cell.
: cell+ 8 + ;

\ Divide unsigned cells and return the quotient.
: / u/mod nip ;

\ Divide unsigned cells and return the remainder.
: mod u/mod drop ;

\ Round a byte count upward to the next page boundary.
: page.align page.size 1- + page.size negate and ;

\ Return the absolute value of a signed cell.
: abs dup 0 < if negate then ;

\ Return the smaller of two signed cells.
: min 2dup > if swap then drop ;

\ Clear a native memory range to zero.
: erase 0 fill ;

\ Terminate the process with the supplied exit status.
: process.exit 0 0 0 0 0 60 syscall6 drop ;

\ Write a byte range to standard output and return the system-call result.
: stdout.write ( addr length -- result ) 1 -rot 0 0 0 1 syscall6 ;

\ Write a complete byte range to standard output, handling partial writes.
: type ( addr length -- )
  begin dup 0 > while
    2dup stdout.write dup 0 <= if 2 process.exit then
    >r swap r@ + swap r> -
  repeat 2drop ;

\ Write the low byte of a cell to standard output.
: emit context context.scratch + tuck c! 1 type ;

\ Write a newline to standard output.
: cr 10 emit ;

\ Write a space to standard output.
: space 32 emit ;

\ Print an unsigned cell in decimal without trailing whitespace.
: u. ( unsigned -- )
  10 u/mod dup if u. else drop then 48 + emit ;

\ Print a signed cell in decimal followed by a space.
: . dup 0 < if 45 emit negate then u. space ;

\ Report the current source token and terminate with a compiler failure.
: fail ( -- ) s" source compiler failure near: " type
  token.address @ token.length @ type cr 2 process.exit ;

\ Terminate with a compiler failure when the supplied flag is false.
: require ( flag -- ) 0= if fail then ;

\ Compare two native byte ranges for exact equality.
: bytes.equal? ( left right length -- flag )
  compare.length ! compare.right ! compare.left !
  begin compare.length @ while
    compare.left @ c@ compare.right @ c@ <> if 0 ; then
    1 compare.left +! 1 compare.right +! -1 compare.length +!
  repeat -1 ;

\ Resolve an image-relative offset against the candidate image's native base.
\ The assembler writes into the candidate, using its virtual image offsets.
: target.address ( offset -- address ) build.base @ + ;

\ Return the invocation-private context record used for image assembly.
: assembler.output ( -- context-address ) context context.assembler + ;
unit.end

\ HOST-ASSEMBLER-BEGIN
\ One selected output vector per invocation; instruction words take operands only.
\ SwiftForth evaluates this same source when constructing the seed image.
2 constant cc.below
4 constant cc.equal
9 constant cc.not.sign
12 constant cc.less
0 constant rax 1 constant rcx 2 constant rdx 3 constant rbx
4 constant rsp 5 constant rbp 6 constant rsi 7 constant rdi
8 constant r8 9 constant r9 10 constant r10 11 constant r11
12 constant r12 13 constant r13 14 constant r14 15 constant r15
\ Native address of the selected assembler base/capacity/cursor record.
variable asm.ctx
\ Native address of scratch storage used by assembler encoding checks.
variable assembler.test.buffer

\ Select an output context once when changing the assembler destination.
\ The variable belongs to the invocation's R13 context in the native system.
: >asm ( context-address -- ) asm.ctx ! ;

\ Return the selected output buffer's native base address.
: out.base ( -- address ) asm.ctx @ @ ;

\ Return the selected output buffer's capacity in bytes.
: out.capacity ( -- bytes ) asm.ctx @ cell+ @ ;

\ Return the selected output cursor's cell address.
: code.here ( -- address ) asm.ctx @ 2 cells + ;

\ Return the selected output cursor's byte offset.
: out.size ( -- offset ) code.here @ ;

\ Reset the selected output cursor without changing its buffer binding.
: out.reset ( -- ) 0 code.here ! ;

\ Bind a buffer and capacity to the selected context and reset its cursor.
\ Context records contain three cells: buffer base, capacity, and cursor.
: out.init ( base capacity -- ) asm.ctx @ cell+ ! asm.ctx @ ! out.reset ;

\ Append a byte through the current output vector and check its capacity.
: byte, ( byte -- )
  out.size out.capacity < require
  out.base out.size + c! 1 code.here +! ;

\ Append a little-endian 16-bit operand.
: le16, ( value -- ) dup byte, 8 rshift byte, ;

\ Append a little-endian 32-bit operand.
: le32, ( value -- ) dup le16, 16 rshift le16, ;

\ Append a little-endian 64-bit operand.
: le64, ( value -- ) dup le32, 32 rshift le32, ;

\ Fill forward to an output offset, rejecting a backward seek.
: out.pad ( offset -- )
  dup out.size >= require begin dup out.size > while 0 byte, repeat drop ;

\ Append a byte range to the selected output buffer.
: bytes, ( address length -- )
  begin dup while over c@ byte, swap 1+ swap 1- repeat 2drop ;

\ Require an x86_64 general-purpose register number.
: reg? ( reg -- ) 0 16 within require ;

\ Require a signed 32-bit displacement.
: s32? ( value -- ) -2147483648 2147483648 within require ;

\ Validate two registers and combine their REX extension bits.
: rex.bits ( reg rm -- bits )
  2dup reg? reg?
  8 and 3 rshift swap 8 and 1 rshift or ;

\ Emit a 64-bit REX prefix for register and r/m operands.
: rex, ( reg rm -- ) rex.bits $48 or byte, ;

\ Emit a 32-bit REX prefix for register and r/m operands.
: rex32, ( reg rm -- ) rex.bits $40 or byte, ;

\ Emit the addressing mode and register bits in a ModR/M byte.
: modrm, ( mode reg rm -- )
  7 and >r 7 and 3 lshift or r> or byte, ;

\ Emit a two-register ALU operation with the supplied opcode.
: alu.rr, ( dst src opcode -- )
  >r swap 2dup rex, r> byte, $c0 -rot modrm, ;

\ Emit MOV between registers in destination, source order.
: mov.rr, ( dst src -- ) $89 alu.rr, ;

\ Emit MOV of a 64-bit immediate into a register.
: mov64, ( reg bits -- )
  >r dup 0 swap rex, 7 and $b8 + byte, r> le64, ;

\ Encode a base-plus-displacement operand with SIB and displacement sizing.
: mem, ( reg base displacement -- )
  >r r@ s32?
  r@ 0= over 7 and 5 <> and if 0 else
    r@ -128 128 within if $40 else $80 then
  then -rot dup >r modrm,
  r> dup 7 and 4 = if $24 byte, then
  7 and 5 <> r@ 0= and 0= if
    r@ -128 128 within if r@ byte, else r@ le32, then
  then r> drop ;

\ Emit a one-byte opcode with a 64-bit memory operand.
: memory.op, ( reg base displacement opcode -- )
  >r >r 2dup rex, r> r> byte, mem, ;

\ Emit MOV from a 64-bit memory operand into a register.
: load, ( dst base displacement -- ) $8b memory.op, ;

\ Emit MOV from a register into a 64-bit memory operand.
: store, ( src base displacement -- ) $89 memory.op, ;

\ Emit LEA with a signed 32-bit base displacement.
: lea, ( dst base displacement -- )
  >r r@ s32? 2dup rex, $8d byte,
  dup >r $80 -rot modrm,
  r> 7 and 4 = if $24 byte, then r> le32, ;

\ Emit RIP-relative LEA using an image-relative target offset.
: rip.lea, ( dst target -- )
  >r dup 0 rex, $8d byte, 0 swap 5 modrm,
  r> out.size 4 + - dup s32? le32, ;

\ Emit an opcode followed by a checked relative displacement.
: relative, ( target opcode -- ) byte, out.size 4 + - dup s32? le32, ;

\ Emit a relative CALL.
: call, ( target -- ) $e8 relative, ;

\ Emit a relative JMP.
: jump, ( target -- ) $e9 relative, ;

\ Emit a near conditional jump to an image-relative target.
: jcc, ( target condition -- )
  dup 0 16 within require $0f byte, $80 + byte,
  out.size 4 + - dup s32? le32, ;

\ Emit SYSCALL.
: syscall, ( -- ) $0f byte, $05 byte, ;

\ Emit RET without closing a source or execution region.
: ret, ( -- ) $c3 byte, ;

\ Emit PUSH of a register onto the hardware stack.
: push, ( reg -- )
  dup reg? dup 8 and if $41 byte, then 7 and $50 + byte, ;

\ Emit POP of a register from the hardware stack.
: pop, ( reg -- )
  dup reg? dup 8 and if $41 byte, then 7 and $58 + byte, ;

\ Emit an opcode group whose ModR/M extension selects the operation.
: group, ( reg extension opcode -- )
  >r swap dup 0 swap rex, r> byte, $c0 -rot modrm, ;

\ Emit an indirect register transfer selected by its opcode extension.
: indirect, ( reg extension -- ) $ff group, ;

\ Emit CALL through a register.
: execute, ( reg -- ) 2 indirect, ;

\ Emit JMP through a register.
: jump.reg, ( reg -- ) 4 indirect, ;

\ Emit a register ALU operation with a sign-extended 32-bit immediate.
: imm32.op, ( reg value extension -- )
  swap >r r@ s32? $81 group, r> le32, ;

\ Emit ADD of an immediate to a register.
: add#, ( reg value -- ) 0 imm32.op, ;

\ Emit SUB of an immediate from a register.
: sub#, ( reg value -- ) 5 imm32.op, ;

\ Emit CMP of a register against an immediate.
: cmp#, ( reg value -- ) 7 imm32.op, ;

\ Emit CMP of two registers.
: cmp.rr, ( lhs rhs -- ) $39 alu.rr, ;

\ Emit ADD of two registers.
: add.rr, ( dst src -- ) $01 alu.rr, ;

\ Emit SUB of two registers.
: sub.rr, ( dst src -- ) $29 alu.rr, ;

\ Emit XOR of two registers.
: xor.rr, ( dst src -- ) $31 alu.rr, ;

\ Emit MOVZX from a memory byte into a 64-bit register.
: load8, ( dst base displacement -- )
  >r 2dup rex, $0f byte, $b6 byte, r> mem, ;

\ Emit MOV from a register's low byte into memory.
: store8, ( src base displacement -- ) $88 memory.op, ;

\ Emit a register operation selected by an F7 opcode extension.
: unary, ( reg extension -- ) $f7 group, ;

\ Emit NEG of a register.
: negate, ( reg -- ) 3 unary, ;

\ Emit unsigned DIV using RDX:RAX as the dividend.
: divide, ( reg -- ) 6 unary, ;

\ Emit unsigned MUL using RAX and a register.
: multiply, ( reg -- ) 4 unary, ;

\ Save the selected output cursor in an explicit label table.
: label! ( id table -- ) swap cells + out.size swap ! ;

\ Read a target offset from an explicit label table.
: label@ ( id table -- target ) swap cells + @ ;

\ Emit JMP to a saved label.
: goto, ( id table -- ) label@ jump, ;

\ Emit a conditional jump to a saved label.
: branch, ( id table condition -- ) >r label@ r> jcc, ;

\ Emit CALL to a saved label.
: invoke, ( id table -- ) label@ call, ;

\ Emit MOVSXD from a signed memory doubleword.
: load.s32, ( dst base displacement -- ) $63 memory.op, ;

\ Emit MOV from a register's low doubleword into memory.
: store32, ( src base displacement -- )
  >r 2dup rex32, $89 byte, r> mem, ;

\ Emit two-operand IMUL, storing the low product in the destination.
: imul.rr, ( dst src -- )
  2dup rex, $0f byte, $af byte, $c0 -rot modrm, ;

\ Emit AND of a register with an immediate.
: and#, ( reg value -- ) 4 imm32.op, ;

\ Emit SHR by a validated immediate bit count.
: shift.right#, ( reg count -- )
  dup 0 64 within require >r 5 $c1 group, r> byte, ;

\ Patch a four-byte little-endian operand at a native address.
: u32! ( value address -- )
  >r dup r@ c! 8 rshift dup r@ 1+ c! 8 rshift
  dup r@ 2 + c! 8 rshift r> 3 + c! ;

\ Emit AND of two registers.
: and.rr, ( dst src -- ) $21 alu.rr, ;

\ Emit OR of two registers.
: or.rr, ( dst src -- ) $09 alu.rr, ;

\ Emit a register shift whose count is in CL.
: shift.cl, ( reg extension -- ) $d3 group, ;

\ Emit logical left shift by CL.
: shl.cl, ( reg -- ) 4 shift.cl, ;

\ Emit logical right shift by CL.
: shr.cl, ( reg -- ) 5 shift.cl, ;

\ Set a register's low byte from an x86 condition.
: setcc, ( reg condition -- )
  dup 0 16 within require >r dup 0 swap rex,
  $0f byte, r> $90 + byte, $c0 0 rot modrm, ;

\ Emit CLD to select forward string operations.
: cld, ( -- ) $fc byte, ;

\ Emit REP MOVSB.
: movsb, ( -- ) $f3 byte, $a4 byte, ;

\ Emit REP STOSB.
: stosb, ( -- ) $f3 byte, $aa byte, ;

\ Reserve a conditional branch and return its displacement offset.
: jcc.hole, ( condition -- hole ) 0 swap jcc, out.size 4 - ;

\ Reserve an unconditional branch and return its displacement offset.
: jump.hole, ( -- hole ) 0 jump, out.size 4 - ;

\ Resolve a forward branch using the selected output context.
: resolve, ( hole -- )
  out.size over 4 + - dup s32? swap out.base + u32! ;

\ Append a byte through the selected output vector.
: c, ( byte -- ) byte, ;

\ Append a little-endian 16-bit operand.
: u16, ( value -- ) le16, ;

\ Append a little-endian 32-bit operand.
: u32, ( value -- ) le32, ;

\ Append a little-endian 64-bit operand.
: u64, ( value -- ) le64, ;

\ Emit instructions that push RAX onto the target data stack.
: asm.push.rax
  rax rbp 0 store,
  rbp 8 add#, ;

\ Emit instructions that push a literal cell.
: asm.literal ( value -- ) rax swap mov64, asm.push.rax ;

\ Emit instructions that push an image-relative address.
: asm.address ( offset -- ) rax rbx rot lea, asm.push.rax ;

\ Emit instructions that push a mutable context-relative address.
: asm.variable ( offset -- ) rax r13 rot lea, asm.push.rax ;

\ Emit a relative native call through the shared assembler.
: asm.call ( xt -- ) call, ;

\ Emit a relative native jump through the shared assembler.
: asm.jump ( target -- ) jump, ;

\ Reserve a forward native jump through the shared assembler.
: asm.jump.hole ( -- hole ) jump.hole, ;

\ Resolve a forward native branch through the shared assembler.
: asm.patch ( hole -- ) resolve, ;

\ Emit a flag-consuming conditional branch with an unresolved destination.
: asm.if ( -- hole )
  rax rbp -8 load,
  rbp 8 sub#,
  rax 0 cmp#,
  4 jcc.hole, ;

\ Emit a conditional loop branch directly to an image-relative target.
: asm.until ( target -- )
  rax rbp -8 load,
  rbp 8 sub#,
  rax 0 cmp#,
  4 jcc, ;

\ Emit a native return while leaving the source region open.
: asm.ret ret, ;

\ Check known encodings using an independent output buffer and context.
\ The same checks run under SwiftForth and inside the native image.
: assembler.check ( buffer -- ) assembler.test.buffer !
  assembler.test.buffer @ 64 out.init
  rax r12 -8 load,
  out.size 5 = require assembler.test.buffer @ @ $ffffffffff and $f824448b49 = require
  out.reset rax r13 0 load,
  out.size 4 = require assembler.test.buffer @ @ $ffffffff and $00458b49 = require
  out.reset rax rbp 128 load,
  out.size 7 = require assembler.test.buffer @ @ $ffffffffffffff and $80858b48 = require
  out.reset r15 $feedfacedeadbeef mov64,
  out.size 10 = require assembler.test.buffer @ @ $ffff and $bf49 = require
  assembler.test.buffer @ 2 + @ $feedfacedeadbeef = require
  out.reset 0 call,
  out.size 5 = require assembler.test.buffer @ c@ $e8 = require
  assembler.test.buffer @ 1+ @ $ffffffff and $fffffffb = require
  out.reset 10 jump,
  out.size 5 = require assembler.test.buffer @ c@ $e9 = require
  assembler.test.buffer @ 1+ @ $ffffffff and 5 = require
  out.reset r15 0 rip.lea,
  out.size 7 = require assembler.test.buffer @ @ $ffffff and $3d8d4c = require
  assembler.test.buffer @ 3 + @ $ffffffff and $fffffff9 = require
  out.reset cc.equal jcc.hole,
  ret, resolve,
  out.size 7 = require assembler.test.buffer @ @ $ffff and $840f = require
  assembler.test.buffer @ 2 + @ $ffffffff and 1 = require
  out.reset r12 r9 imul.rr,
  out.size 4 = require assembler.test.buffer @ @ $ffffffff and $e1af0f4d = require
  out.reset r9 r12 0 store32,
  out.size 4 = require assembler.test.buffer @ @ $ffffffff and $240c8945 = require
  out.reset r12 cc.less setcc,
  out.size 4 = require assembler.test.buffer @ @ $ffffffff and $c49c0f49 = require
  0 begin dup 16 < while
    out.reset dup dup mov.rr,
    out.size 3 = require
    dup 8 and if $4d else $48 then assembler.test.buffer @ c@ = require
    assembler.test.buffer @ 1+ c@ $89 = require
    dup 7 and dup 3 lshift or $c0 or assembler.test.buffer @ 2 + c@ = require
    1+
  repeat drop
  \ Switch context records and verify their buffers and cursors remain separate.
  asm.ctx @ >r
  assembler.test.buffer @ 16 out.init $a5 c,
  out.size 1 = require assembler.test.buffer @ c@ $a5 = require
  assembler.test.buffer @ 32 + >asm
  assembler.test.buffer @ 16 + 16 out.init $5a c,
  out.size 1 = require
  assembler.test.buffer @ c@ $a5 = require
  assembler.test.buffer @ 16 + c@ $5a = require
  r> >asm
  out.size 1 = require out.capacity 16 = require
  out.base assembler.test.buffer @ = require
  $a6 c, out.size 2 = require
  assembler.test.buffer @ 1+ c@ $a6 = require ;

\ HOST-ASSEMBLER-END


\ Return whether the parser has reached the end of its source range.
\ The parser reads only the mapped source span supplied to image.build.
: source.end? parser.position @ parser.length @ >= ;

\ Fetch the byte at the current parser position.
: source.byte parser.source @ parser.position @ + c@ ;

\ Advance the parser by one source byte.
: source.next 1 parser.position +! ;

\ Advance past source bytes whose values are at most ASCII space.
: source.space.skip
  begin source.end? 0= while
    source.byte 32 > if ; then source.next
  repeat ;

\ Read the next whitespace-delimited token and record its source location.
: token.parse ( -- length )
  source.space.skip parser.position @ dup token.start !
  parser.source @ + token.address !
  begin source.end? 0= while
    source.byte 32 <= if
      parser.position @ token.start @ - dup token.length ! source.next ;
    then source.next
  repeat parser.position @ token.start @ - dup token.length ! ;

\ Consume source through the next newline or the end of the source.
: source.line.skip
  begin source.end? 0= while source.byte 10 = if source.next ; then source.next repeat ;

\ Consume a parenthesized comment, failing if no closing parenthesis exists.
: source.comment.skip
  begin source.end? 0= while source.byte 41 = if source.next ; then source.next repeat fail ;

\ Convert an ASCII decimal or hexadecimal digit to a value, or return minus one.
: digit ( char -- n )
  dup 48 >= over 57 <= and if 48 - ; then
  dup 65 >= over 70 <= and if 55 - ; then
  dup 97 >= over 102 <= and if 87 - ; then drop -1 ;

\ Parse the current token as a signed decimal or hexadecimal cell literal.
: number? ( -- n flag )
  0 number.value ! 10 number.base ! 1 number.sign ! 0 number.position !
  token.address @ c@ 45 = if -1 number.sign ! 1 number.position ! then
  token.address @ number.position @ + c@ 36 = if
    16 number.base ! 1 number.position +!
  then
  number.position @ token.length @ >= if 0 0 ; then
  begin number.position @ token.length @ < while
    token.address @ number.position @ + c@ digit
    dup 0 < over number.base @ >= or if drop 0 0 ; then
    number.value @ number.base @ * + number.value ! 1 number.position +!
  repeat number.value @ number.sign @ * -1 ;

\ Resolve a field offset within the current candidate dictionary entry.
\ Dictionary entry: /entry = 64 bytes; every field is an 8-byte cell.
\ Byte offset  Field                 Stored value
\ +---------+-----------------------+---------------------------------------+
\ |   0     | entry.previous        | Previous entry image offset; 0 ends  |
\ |   8     | entry.xt              | Code entry point image offset        |
\ |  16     | entry.name.length     | Name byte count, greater than zero   |
\ |  24     | entry.source.start    | Source label start image offset      |
\ |  32     | entry.kind            | 1 colon, 2 CODE, 3 constant, 4 var   |
\ |  40     | entry.value           | Constant value or R13 context offset |
\ |  48     | entry.name.offset     | Name start image offset in source    |
\ |  56     | entry.flags           | flag.immediate: execute when read    |
\ +---------+-----------------------+---------------------------------------+
\ Auxiliary is zero for colon and CODE entries. Names refer to source bytes.
\ Entries record starts, NEVER execution or definition ends. Multiple labels
\ can enter shared code, and multiple ; returns can leave it (IF ; THEN).
\ SEE/LOCATE/WHERE must display source windows, not assume bounded bodies.
\ A following label can bound a display window; it is no execution boundary.
\
\ build.base @              native base of the image being compiled
\   + entry.current @  entry offset within that image
\   + field-offset          byte offset within the entry
\   = entry.field result   native address of the field, NOT its contents
\
\ Example: entry.xt entry.field @ fetches an image-relative XT.
\          entry.xt entry.field @ target.address gives its native address.
\ target.address adds build.base @, never the executing image's ORG.
\ Source and name fields also use image offsets: subtract source.start for a
\ file offset, or use target.address for the corresponding mapped source byte.
: entry.field ( field-offset -- native-address ) entry.current @ + target.address ;

\ Clear the current dictionary-entry cursor without defining a code boundary.
: entry.release 0 entry.current ! ;

\ Parse a name and create a candidate entry at the current code position.
: entry.open ( kind -- )
  entry.release token.start @ label.start !
  token.parse 0 > require
  dictionary.here @ /entry + source.start <= require
  dictionary.here @ entry.current !
  dictionary.root @ entry.previous entry.field !
  code.here @ entry.xt entry.field !
  token.length @ entry.name.length entry.field !
  label.start @ source.start + entry.source.start entry.field !
  entry.kind entry.field !
  token.start @ source.start + entry.name.offset entry.field !
  entry.current @ dictionary.root ! /entry dictionary.here +! ;

\ Search an image's linked dictionary for a name and return its native record address.
\ Search either immutable compiler dictionary or candidate dictionary.
\ The result is a native record address; each stored reference stays an offset.
: dictionary.find ( addr len image-base root-offset -- record-address|0 )
  find.entry ! find.base ! find.length ! find.address !
  begin find.entry @ while
    find.entry @ find.base @ + dup entry.name.length + @ find.length @ = if
      dup entry.name.offset + @ find.base @ +
      find.address @ find.length @ bytes.equal? if ; then
    then entry.previous + @ find.entry !
  repeat 0 ;

\ Search the candidate dictionary and return an entry offset or zero.
: target.find ( addr len -- header-offset|0 )
  build.base @ dictionary.root @ dictionary.find dup if build.base @ - then ;

\ Search the candidate dictionary for the current source token.
: token.find token.address @ token.length @ target.find ;

\ Find a candidate word's image-relative XT, failing if the name is absent.
: target.xt ( addr len -- xt ) target.find dup 0<> require target.address entry.xt + @ ;

\ Search a supplied image using the dictionary root in its header.
: image.find ( image addr len -- record-address|0 ) rot dup header.dictionary.root + @ dictionary.find ;

\ Search the sealed executing image's dictionary for a name.
: compiler.find ( addr len -- record-address|0 ) org org header.dictionary.root + @ dictionary.find ;

\ Find an installed compiler word's image-relative XT or fail.
: compiler.xt ( addr len -- xt ) compiler.find dup 0<> require entry.xt + @ ;

\ Execute an image-relative XT in the current image.
: execute ( xt-offset -- ) org swap image.call ;

\ Push a code offset onto the bounded compiler control stack.
: control.push ( offset -- )
  control.depth @ 128 < require
  context context.control + control.depth @ cells + ! 1 control.depth +! ;

\ Pop a code offset from the compiler control stack or fail on underflow.
: control.pop ( -- offset )
  control.depth @ 0 > require -1 control.depth +!
  context context.control + control.depth @ cells + @ ;

\ Emit a conditional branch and save its unresolved destination.
: compiler.if asm.if control.push ;

\ Resolve the most recent conditional branch to the current code cursor.
: compiler.then control.pop asm.patch ;

\ Emit a branch around the alternative and resolve the preceding false branch.
: compiler.else
  control.pop asm.jump.hole control.push asm.patch ;

\ Save the current code position as a loop entry.
: compiler.begin code.here @ control.push ;

\ Emit an unconditional branch to the saved loop entry.
: compiler.again control.pop asm.jump ;

\ Emit a backward branch that repeats while the consumed flag is false.
: compiler.until control.pop asm.until ;

\ Emit and save a conditional loop-exit branch.
: compiler.while compiler.if ;

\ Branch back to the loop entry and resolve its saved exit branch.
: compiler.repeat control.pop control.pop asm.jump asm.patch ;

\ Parse a quoted string and emit its mapped source address and length.
: string.compile
  parser.position @ string.start !
  begin source.end? 0= while
    source.byte 34 = if
      string.start @ source.start + asm.address
      parser.position @ string.start @ - asm.literal source.next ;
    then source.next
  repeat fail ;

\ Require resolved control flow and release the current entry cursor.
: entry.finish
  control.depth @ 0= require entry.release ;

\ Immediately emit a native return while leaving the source region open.
\ Compile-time behavior belongs to words, not to the token reader.
\ These words execute in the sealed compiler image and emit into build.base.
\ The seed shim supplies host counterparts only for this bootstrap vocabulary.
: ; asm.ret ; immediate

\ Immediately compile a conditional branch on a consumed flag.
: if compiler.if ; immediate

\ Immediately compile the alternative path of a conditional.
: else compiler.else ; immediate

\ Immediately resolve the preceding conditional's forward branch.
: then compiler.then ; immediate

\ Immediately mark the beginning of a loop.
: begin compiler.begin ; immediate

\ Immediately compile an unconditional return to the loop beginning.
: again compiler.again ; immediate

\ Immediately compile a loop branch that repeats on a false flag.
: until compiler.until ; immediate

\ Immediately compile a conditional exit from a loop.
: while compiler.while ; immediate

\ Immediately compile a loop back-edge and resolve its conditional exit.
: repeat compiler.repeat ; immediate

\ Immediately compile a quoted string as a mapped source address and length.
: s" string.compile ; immediate

\ Immediately skip the rest of the source line.
: \ source.line.skip ; immediate

\ Immediately skip source through the closing comment parenthesis.
: ( source.comment.skip ; immediate

\ Immediately name a code entry point and select the compiling reader.
: : 1 entry.open s" word.compile" compiler.xt compiler.action ! ; immediate

\ Immediately name a code entry point and select the assembly reader.
: code 2 entry.open s" word.assemble" compiler.xt compiler.action ! ; immediate

\ Immediately finish CODE input and restore the interpreting reader.
: code.end entry.finish s" word.interpret" compiler.xt compiler.action ! ; immediate

\ Immediately check pending control flow and finish the source unit.
: unit.end entry.finish s" word.interpret" compiler.xt compiler.action ! ; immediate

\ Immediately define a word that pushes the supplied constant value.
: constant ( value -- )
  3 entry.open dup entry.value entry.field ! asm.literal asm.ret entry.finish ; immediate

\ Immediately define a word that pushes a newly allocated context-cell address.
: variable
  4 entry.open compiler.variables @ dup entry.value entry.field ! asm.variable asm.ret
  8 compiler.variables +! compiler.variables @ context.control <= require entry.finish ; immediate

\ Mark the newest candidate dictionary entry for compile-time execution.
: immediate
  dictionary.root @ target.address entry.flags + dup @ flag.immediate or swap ! ; immediate

\ Compile an ordinary candidate word call or a numeric literal.
\ Non-immediate tokens go to the current reader action. There is no STATE or
\ numbered mode: : installs the compiler; CODE installs the assembler reader;
\ code.end and unit.end restore the interpreter. ; only emits a native RET.
: word.compile
  token.find dup if
    target.address dup entry.flags + @ flag.immediate and 0= require
    entry.xt + @ asm.call ;
  then drop
  number? require asm.literal ;

\ Execute an installed word or leave a parsed number on the data stack.
: word.interpret
  token.address @ token.length @ compiler.find dup if entry.xt + @ execute ; then drop
  number? require ;

\ Read a CODE token by executing an installed word or accepting a number.
: word.assemble word.interpret ;

\ Execute a dictionary immediate or pass the token to the selected reader.
: token.compile
  token.address @ token.length @ compiler.find dup if
    dup entry.flags + @ flag.immediate and if entry.xt + @ execute ; then
  then drop compiler.action @ execute ;

\ Process all source tokens and reject unfinished assembly or control flow.
: source.compile
  begin token.parse while token.compile repeat
  control.depth @ 0= require entry.release
  compiler.action @ s" word.assemble" compiler.xt <> require ;

\ Store a value in a named field of the candidate image header.
: header! ( value offset -- ) build.base @ + ! ;

\ Write the candidate's format, extents, roots, and entry-point offsets.
: image.finish
  image.magic header.magic header! image.version header.version header!
  parser.length @ source.start + page.align header.image.size header!
  code.here @ header.code.limit header! dictionary.here @ header.dictionary.limit header!
  dictionary.root @ header.dictionary.root header! source.start header.source.offset header!
  parser.length @ header.source.length header! s" main" target.xt header.main.xt header!
  compiler.variables @ header.context.limit header! s" kernel.start" target.xt header.start.xt header!
  s" rebuild" target.xt header.rebuild.xt header! ;

\ Compile an exact source range into a fresh writable candidate image.
: image.build ( source length destination -- )
  build.base ! parser.length ! parser.source !
  parser.length @ 0 > require parser.length @ image.capacity source.start - <= require
  parser.source @ build.base @ image.capacity + u<
  parser.source @ parser.length @ + build.base @ u> and 0= require
  build.base @ image.capacity erase
  parser.source @ source.start target.address parser.length @ move
  0 parser.position ! s" word.interpret" compiler.xt compiler.action !
  0 entry.current ! 0 dictionary.root ! 0 control.depth !
  assembler.output >asm build.base @ dictionary.start out.init
  code.start code.here ! dictionary.start dictionary.here !
  context.variables compiler.variables ! source.compile image.finish ;

\ Allocate writable memory for a candidate image.
: image.new ( -- address )
  0 image.capacity protection.read.write 34 -1 0 9 syscall6 dup 0 > require ;

\ Unmap an image's reserved memory range.
: image.free ( address -- ) image.capacity 0 0 0 0 11 syscall6 0= require ;

\ Apply native memory protection to an address range.
: image.protect ( address length protection -- )
  0 0 0 10 syscall6 0= require ;

\ Make image metadata read-only and compiled code readable and executable.
: image.seal ( image -- )
  dup code.start protection.read image.protect
  dup code.start + dictionary.start code.start - protection.read.execute image.protect
  dup dictionary.start + swap header.image.size + @ dictionary.start - protection.read image.protect ;

\ Compare two complete canonical images byte for byte.
: image.equal? ( left right -- flag )
  2dup header.image.size + @ swap header.image.size + @ <> if 2drop 0 ; then
  dup header.image.size + @ dup source.start >= swap image.capacity <= and 0= if 2drop 0 ; then
  dup header.image.size + @ bytes.equal? ;

\ Compile the executing image's mapped source into a new image.
: rebuild ( -- candidate-image )
  image.new >r org source.start + org header.source.length + @ r@ image.build r> ;

\ Rebuild, compare with the executing image, and release the candidate.
: verify ( -- flag ) rebuild dup >r org image.equal? r> image.free ;

\ Return the square of a cell.
: square dup * ;

\ Compute a factorial recursively, returning one for inputs at most one.
: factorial dup 1 > if dup 1- factorial * else drop 1 then ;

\ Immediately emit the replacement literal used by the native immediate test.
\ This arbitrary immediate has NO host binding or token-reader special case.
\ A native test substitutes its name for a literal before recompiling.
: litnow 414159 asm.literal ; immediate

\ Return the source literal that recompilation tests replace.
: test.literal 314159 ;

\ Exercise an early conditional return and a later return in shared code.
: test.return if 17 ; then 23 ;

\ Push three and fall through into the following named entry point.
: test.prefix 3

\ Push four and return from either this entry or the preceding fall-through.
: test.suffix 4 ;

\ Enter a conditional whose false branch crosses the next named entry point.
: test.shared.condition if 31 ;

\ Provide a direct return inside code shared with the preceding conditional.
: test.shared.entry 37 ; then 41 ;

\ Exercise a counted BEGIN/UNTIL loop and return five.
: test.until 0 begin 1+ dup 5 = until ;

\ Exercise a counted BEGIN/WHILE/REPEAT loop and return five.
: test.while 0 begin dup 5 < while 1+ repeat ;

\ Check arithmetic, recursion, immediate flags, shared entries, returns, and loops.
: test.native
  s" litnow" compiler.find dup 0<> require entry.flags + @ flag.immediate and require
  s" word.compile" compiler.find dup 0<> require entry.flags + @ flag.immediate and 0= require
  9 square 81 = require 6 factorial 720 = require
  0 test.return 23 = require 1 test.return 17 = require
  test.prefix 4 = require 3 = require test.suffix 4 = require
  0 test.shared.condition 41 = require 1 test.shared.condition 31 = require
  test.shared.entry 37 = require
  test.until 5 = require test.while 5 = require
  123 >r r@ 123 = require r> 123 = require
  23 7 u/mod 3 = require 2 = require ;

\ Toggle the low bit of the byte at a native address.
: byte.change dup c@ 1 xor swap c! ;

\ Check that a one-byte image change fails equality, then restore the byte.
: image.difference.reject ( candidate offset -- )
  over + dup >r byte.change dup org image.equal? 0= require
  r> byte.change dup org image.equal? require drop ;

\ Check that code, dictionary, source, and padding changes are detected.
: test.differences ( candidate -- )
  dup code.start image.difference.reject
  dup dictionary.start image.difference.reject
  dup source.start image.difference.reject
  dup page.size 1- image.difference.reject drop ;

\ Recompile a changed source literal and execute the changed candidate word.
: test.changed.source ( candidate -- )
  \ Change a source literal in B, compile it into D, and execute D's new word.
  \ Restoring the source byte leaves B identical to A again.
  dup s" test.literal" image.find dup 0<> require
  entry.source.start + @ over +
  begin dup c@ 51 <> while 1+ repeat
  dup >r 52 swap c!
  image.new >r
  source.start + org header.source.length + @ r@ image.build
  r@ org image.equal? 0= require r@ image.seal
  r@ s" test.literal" target.xt image.call 414159 = require
  r> image.free 51 r> c! ;

\ Recompile through an installed immediate that has no seed execution binding.
: test.immediate.source ( candidate -- )
  \ Compile using an installed immediate whose name the shim does not know.
  \ This exercises dictionary flags and native execution, not a built-in alias.
  dup s" test.literal" image.find dup 0<> require
  entry.source.start + @ over +
  begin dup c@ 51 <> while 1+ repeat
  dup >r s" litnow" drop swap 6 move
  image.new >r
  source.start + org header.source.length + @ r@ image.build
  r@ org image.equal? 0= require r@ image.seal
  r@ s" test.literal" target.xt image.call 414159 = require
  r> image.free s" 314159" drop r> 6 move ;

\ Return whether a byte offset is aligned to the configured page size.
: page.aligned? page.size 1- and 0= ;

\ Check image alignment and the named stack and compiler-context bounds.
: test.layout
  page.size 0 > require page.size page.size 1- and 0= require
  code.start page.aligned? require dictionary.start page.aligned? require
  source.start page.aligned? require image.capacity page.aligned? require
  code.start dictionary.start < require dictionary.start source.start < require
  context.mapping.size page.aligned? require
  context.guard.offset page.aligned? require data.guard.offset page.aligned? require
  return.guard.offset page.aligned? require
  context.guard.offset page.size + data.stack.offset = require
  data.stack.offset stack.size + data.guard.offset = require
  data.guard.offset page.size + return.stack.offset = require
  return.stack.offset stack.size + return.guard.offset = require
  return.guard.offset page.size + context.mapping.size <= require
  context.scratch page.size + context.guard.offset <= require
  context.assembler 6 cells + context.scratch <= require
  context.assembler 6 cells + context.guard.offset <= require ;

\ Protect the guard pages between the mutable context and language stacks.
: stacks.protect
  context context.guard.offset + page.size protection.none image.protect
  context data.guard.offset + page.size protection.none image.protect
  context return.guard.offset + page.size protection.none image.protect ;

\ Run native checks and verify complete-image self-compilation across three origins.
: main
  test.layout stacks.protect
  context context.assembler + 3 cells + >asm
  context context.scratch + assembler.check
  s" Native self-compiling Forth" type cr test.native
  s" Shared assembler encoding checks passed." type cr
  rebuild dup org <> require dup >r org over image.equal? require
  s" A == B: complete image" type cr
  dup test.differences dup test.changed.source dup test.immediate.source
  dup org image.equal? require
  s" Differences detected in code, dictionary, source and padding." type cr
  s" Changed source compiled and executed correctly." type cr
  s" Dictionary immediate executed; shared entry points and conditional returns passed." type cr
  dup image.seal
  dup header.rebuild.xt + @ image.call
  dup r@ <> require dup org <> require
  dup r@ image.equal? require dup org image.equal? require
  s" B == C: complete image, rebuilt by B at a different address" type cr
  image.free r> image.free
  s" Self-compilation verified." type cr ;
unit.end
