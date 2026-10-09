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
  rax rsp 0 load,
  rax r13 arguments.count.field store,
  rax rsp 16 lea,
  rax r13 arguments.vector.field store,
  rbp r13 data.stack.offset lea,
  r12 r13 return.stack.offset lea,
  rsp r13 native.stack.top lea,
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
\ [context][guard][data stack][guard][return stack][guard][native stack]
\ [guard][signal stack][guard][recovery snapshot][fault stacks][inaccessible reserve]
786432  constant context.mapping.size
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

\ Native and alternate signal stacks have guards on both sides.
208896  constant native.stack.offset
274432  constant native.stack.top
274432  constant native.guard.offset
278528  constant signal.stack.offset
344064  constant signal.guard.offset
348160  constant recovery.snapshot.offset
544768  constant fault.data.offset
610304  constant fault.return.offset
675840  constant fault.native.offset
741376  constant context.used.limit

\ Reserved recovery fields below context.variables; all offsets are bytes.
0       constant recovery.active.field
8       constant recovery.rsp.field
16      constant recovery.rbp.field
24      constant recovery.r12.field
32      constant recovery.org.field
40      constant recovery.continuation.field
48      constant signal.number.field
56      constant signal.code.field
64      constant signal.address.field
72      constant signal.rip.field
80      constant signal.org.field
88      constant signal.stack.field
96      constant recovery.target.field
128     constant signal.action.offset
160     constant signal.alt.offset
192     constant arguments.count.field
200     constant arguments.vector.field
208     constant debug.parent.field
216     constant debug.caller.rsp.field
224     constant debug.entry.field
232     constant debug.image.field
240     constant debug.xt.field
248     constant quit.request.field
256     constant fault.registers.offset
184     constant fault.registers.size
40      constant ucontext.registers
448     constant input.error.field
12288   constant debug.terminal.saved
12352   constant debug.terminal.work
12416   constant debug.terminal.active
36      constant /terminal
12      constant terminal.flags
23      constant terminal.minimum
22      constant terminal.time
$5401   constant terminal.get
$5402   constant terminal.set
16      constant syscall.ioctl
2       constant terminal.canonical
8       constant terminal.echo
64      constant terminal.echo.newline
0       constant registers.r8
8       constant registers.r9
16      constant registers.r10
24      constant registers.r11
40      constant registers.r13
48      constant registers.r14
56      constant registers.r15
64      constant registers.rdi
72      constant registers.rsi
88      constant registers.rbx
96      constant registers.rdx
104     constant registers.rax
112     constant registers.rcx
136     constant registers.flags
120     constant registers.rsp
80      constant registers.rbp
32      constant registers.r12
128     constant registers.rip

\ Linux x86-64 kernel signal ABI, not the libc sigaction layout.
0       constant action.handler
8       constant action.flags
16      constant action.restorer
24      constant action.mask
0       constant alt.base
8       constant alt.flags
16      constant alt.size
8       constant signal.mask.size
8       constant siginfo.code
16      constant siginfo.address
72      constant ucontext.r12
80      constant ucontext.r13
120     constant ucontext.rbp
128     constant ucontext.rbx
160     constant ucontext.rsp
168     constant ucontext.rip
176     constant ucontext.flags
2       constant signal.interrupt
4       constant signal.illegal
5       constant signal.trap
7       constant signal.bus
8       constant signal.arithmetic
11      constant signal.memory
2       constant signal.reason.access
128     constant signal.reason.kernel
4       constant signal.flag.info
$04000000 constant signal.flag.restorer
$08000000 constant signal.flag.onstack
-1281   constant flags.recovery.mask
128     constant process.signal.exit
39      constant syscall.getpid
57      constant syscall.fork
61      constant syscall.wait
62      constant syscall.kill
319     constant syscall.memfd
13      constant syscall.sigaction
15      constant syscall.sigreturn
131     constant syscall.sigaltstack

\ Linux file operations and flags used by the persistent input history.
2       constant syscall.open
74      constant syscall.fsync
1090    constant history.open.flags     \ O_RDWR | O_CREAT | O_APPEND.
384     constant history.permissions    \ Mode 0600: owner read and write.
-4      constant syscall.interrupted

\ HOST-LAYOUT-END

\ Mutable names refer to this invocation's R13 context, never saved image data.
\ Native base address of the candidate image being compiled.
variable build.base

\ Sealed image currently selected by the editor, or zero for the startup image.
variable editor.image

\ Optional editor callback after emitting a return; zero during whole-image builds.
variable compiler.return

\ Optional recoverable compiler error callback; zero outside interactive compilation.
variable compiler.failure

\ Optional editor validation of a parsed definition name; zero for image rebuilding.
variable compiler.name

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
: fail ( -- )
  compiler.failure @ dup if org swap image.call ; then drop
  s" source compiler failure near: " type
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
14 constant cc.less.equal
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

\ Emit UD2 to raise an invalid-instruction fault.
: ud2, ( -- ) $0f byte, $0b byte, ;

\ Emit INT3 to enter the installed debug-trap handler.
: int3, ( -- ) $cc byte, ;

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
  ud2, int3,
  out.size 3 = require assembler.test.buffer @ @ $ffffff and $cc0b0f = require
  out.reset
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
\ The parser reads the bounded source span selected by the compiler or input reader.
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
  compiler.name @ dup if org swap image.call else drop then
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
: ; asm.ret compiler.return @ dup if execute else drop then ; immediate

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

\ Immediately compile a quoted string followed by a call to type.
: ." string.compile s" type" target.xt asm.call ; immediate

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
  compiler.return @ >r 0 compiler.return !
  compiler.name @ >r 0 compiler.name !
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
  context.variables compiler.variables ! source.compile image.finish
  r> compiler.name ! r> compiler.return ! ;

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
  dup header.code.limit + @ page.align >r
  dup header.image.size + @ >r
  dup image.capacity protection.none image.protect
  dup r> protection.read image.protect
  code.start + r> code.start -
  protection.read.execute image.protect ;

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


\ Return from a Linux signal frame, restoring the saved mask and alternate stack.
code signal.restore
  rax syscall.sigreturn mov64,
  syscall,
  ud2,
code.end

\ Record a fault and redirect sigreturn to the armed recovery continuation.
\ Linux supplies RDI=signal, RSI=siginfo, RDX=ucontext on the alternate stack.
\ This trusted boundary requires an intact R13; it calls no Forth or OS services
\ except immediate process termination when no recovery boundary is armed.
code signal.handle
  rax r13 recovery.active.field load,
  rax 0 cmp#,
  cc.equal jcc.hole,
  rdi r13 signal.number.field store,
  rax rsi siginfo.code load.s32,
  rax r13 signal.code.field store,
  rcx 0 mov64,
  rcx r13 signal.address.field store,
  rax 0 cmp#,
  cc.less.equal jcc.hole,
  rax rsi siginfo.address load,
  rax r13 signal.address.field store,
  resolve,
  rax rdx ucontext.rip load,
  rax r13 signal.rip.field store,
  rax rdx ucontext.rbx load,
  rax r13 signal.org.field store,
  rsp r13 signal.stack.field store,
  \ Preserve the fault-time register block and stacks before sigreturn changes them.
  rsi rdx ucontext.registers lea,
  rdi r13 fault.registers.offset lea,
  rcx fault.registers.size mov64,
  cld,
  movsb,
  rsi r13 data.stack.offset lea,
  rdi r13 fault.data.offset lea,
  rcx stack.size mov64,
  movsb,
  rsi r13 return.stack.offset lea,
  rdi r13 fault.return.offset lea,
  rcx stack.size mov64,
  movsb,
  rsi r13 native.stack.offset lea,
  rdi r13 fault.native.offset lea,
  rcx stack.size mov64,
  movsb,
  rax r13 recovery.continuation.field load,
  rax rdx ucontext.rip store,
  rax r13 recovery.rsp.field load,
  rax rdx ucontext.rsp store,
  rax r13 recovery.rbp.field load,
  rax rdx ucontext.rbp store,
  rax r13 recovery.r12.field load,
  rax rdx ucontext.r12 store,
  rax r13 recovery.org.field load,
  rax rdx ucontext.rbx store,
  r13 rdx ucontext.r13 store,
  rax rdx ucontext.flags load,
  rcx flags.recovery.mask mov64,
  rax rcx and.rr,
  rax rdx ucontext.flags store,
  rax 0 mov64,
  rax r13 recovery.active.field store,
  ret,
  resolve,
  rdi process.signal.exit add#,
  rax 60 mov64,
  syscall,
  ud2,
code.end

\ Return a recorded signal through the saved native caller after sigreturn.
\ Entry requires RSP, RBP, R12, RBX and R13 restored by signal.handle.
code recovery.resume
  rax r13 signal.number.field load,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Execute an image-relative XT with a native recovery boundary; return status.
\ This is the raw boundary; recovery.run also snapshots mutable language state.
code recovery.enter
  rax rbp -8 load,
  rbp 8 sub#,
  rsp r13 recovery.rsp.field store,
  rbp r13 recovery.rbp.field store,
  r12 r13 recovery.r12.field store,
  rbx r13 recovery.org.field store,
  rcx 1 mov64,
  rcx r13 recovery.active.field store,
  rax rbx add.rr,
  rax execute,
  rax 0 mov64,
  rax r13 recovery.active.field store,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Trigger a debugger trap; the recovery boundary aborts this invocation.
code trap
  int3,
  ret,
code.end

\ Return this context's most recently captured signal number.
: signal.number context signal.number.field + @ ;

\ Return the last captured signed Linux signal reason code.
: signal.code context signal.code.field + @ ;

\ Return the fault address when supplied by a synchronous signal.
: signal.address context signal.address.field + @ ;

\ Return the captured native instruction address (INT3 points past its opcode).
: signal.rip context signal.rip.field + @ ;

\ Return the image origin in effect at the fault, including calls into other images.
: signal.org context signal.org.field + @ ;

\ Copy mutable compiler state and both complete language stacks to the checkpoint.
\ Signal fields stay outside the snapshot so diagnostics survive rollback.
: recovery.save
  context context.variables + context recovery.snapshot.offset +
  context.guard.offset context.variables - move
  context data.stack.offset + context recovery.snapshot.offset + context.guard.offset + stack.size move
  context return.stack.offset + context recovery.snapshot.offset + context.guard.offset + stack.size + stack.size move ;

\ Restore stack contents and compiler state after leaving the signal handler.
: recovery.restore
  context recovery.snapshot.offset + context context.variables +
  context.guard.offset context.variables - move
  context recovery.snapshot.offset + context.guard.offset + context data.stack.offset + stack.size move
  context recovery.snapshot.offset + context.guard.offset + stack.size + context return.stack.offset + stack.size move ;

\ Execute one trusted top-level action, returning zero or a recovered signal number.
\ Boundaries do not nest. Failure restores full language stacks and compiler state;
\ external effects and writes outside the checkpoint are not transactional.
: recovery.run ( xt -- status )
  context recovery.active.field + @ 0= require
  context recovery.target.field + !
  0 context signal.number.field + !
  s" recovery.resume" compiler.xt org + context recovery.continuation.field + !
  recovery.save
  context recovery.target.field + @ recovery.enter
  if recovery.restore signal.number else 0 then ;

\ Register the prepared kernel sigaction for one signal.
: signal.install ( signal -- )
  context signal.action.offset + 0 signal.mask.size 0 0 syscall.sigaction syscall6 0= require ;

\ Install the alternate stack and minimal handlers for faults, traps and Ctrl-C.
\ The restorer and handler belong to the installed image, which must stay mapped.
: signals.install
  context signal.stack.offset + context signal.alt.offset + alt.base + !
  0 context signal.alt.offset + alt.flags + !
  stack.size context signal.alt.offset + alt.size + !
  context signal.alt.offset + 0 0 0 0 0 syscall.sigaltstack syscall6 0= require
  s" signal.handle" compiler.xt org + context signal.action.offset + action.handler + !
  signal.flag.info signal.flag.restorer or signal.flag.onstack or
  context signal.action.offset + action.flags + !
  s" signal.restore" compiler.xt org + context signal.action.offset + action.restorer + !
  -1 context signal.action.offset + action.mask + !
  signal.memory signal.install signal.bus signal.install
  signal.illegal signal.install signal.arithmetic signal.install
  signal.trap signal.install signal.interrupt signal.install ;

\ Report the captured fault outside the handler, ready for source inspection.
: fault. ( -- )
  signal.number 0= if s" No recorded fault." type cr ; then
  s" signal " type signal.number . s" code " type signal.code .
  s" image " type signal.org u. space s" offset " type signal.rip signal.org - u. space
  s" address " type signal.address u. cr ;

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


\ Address used by deliberate protection probes; restored with compiler state.
variable test.fault.address

\ Empty anonymous file used to provoke a real SIGBUS on a mapped page.
variable test.bus.fd

\ Native address of the empty file mapping used by the SIGBUS test.
variable test.bus.mapping

\ Sealed image called by the cross-image fault recovery test.
variable test.fault.image

\ Raise a hardware invalid-instruction fault.
code test.fault.illegal
  ud2,
  ret,
code.end

\ Exhaust the native stack at its lower guard with no usable fault-time RSP.
code test.fault.native
  rsp r13 native.stack.offset lea,
  rax push,
  ret,
code.end

\ Exhaust the data stack at its upper guard.
code test.fault.data
  rbp r13 data.guard.offset lea,
  rax rbp 0 store,
  ret,
code.end

\ Exhaust the language return stack at its upper guard.
code test.fault.return
  r12 r13 return.guard.offset lea,
  rax r12 0 store,
  ret,
code.end

\ Attempt a write to the selected protected address.
: test.fault.write 0 test.fault.address @ c! ;

\ Attempt a read from the selected inaccessible address.
: test.fault.read test.fault.address @ c@ drop ;

\ Attempt instruction execution in the selected non-executable region.
: test.fault.execute org test.fault.address @ org - image.call ;

\ Raise an integer divide-by-zero fault.
: test.fault.divide 1 0 u/mod 2drop ;

\ Read beyond the end of a mapped empty file to raise a hardware SIGBUS.
: test.fault.bus test.bus.mapping @ c@ drop ;

\ Build a temporary anonymous file mapping for the hardware SIGBUS test.
: test.bus.prepare
  context context.scratch + 32 erase
  s" forth-signal-test" context context.scratch + swap move
  context context.scratch + 0 0 0 0 0 syscall.memfd syscall6
  dup 0 >= require test.bus.fd !
  0 page.size protection.read 2 test.bus.fd @ 0 9 syscall6
  dup 0 > require test.bus.mapping ! ;

\ Release the SIGBUS fixture after returning through the recovery boundary.
: test.bus.release
  test.bus.mapping @ page.size 0 0 0 0 11 syscall6 0= require
  test.bus.fd @ 0 0 0 0 0 3 syscall6 0= require ;

\ Deliver SIGINT to this process to exercise the future REPL interrupt boundary.
: test.fault.interrupt
  0 0 0 0 0 0 syscall.getpid syscall6
  signal.interrupt 0 0 0 0 syscall.kill syscall6 drop ;

\ Enter another sealed image and fault before image.call can restore the origin.
: test.fault.foreign
  test.fault.image @ dup s" test.fault.illegal" image.find entry.xt + @ image.call ;


\ Overwrite live stack cells and compiler state before faulting.
: test.fault.rollback
  0 context data.stack.offset + !
  0 context return.stack.offset + !
  999 parser.position ! trap ;

\ Confirm execution reached the alternate stack and sigreturn restored its state.
: test.signal.stack
  context signal.stack.field + @
  context signal.stack.offset + context signal.guard.offset + within require
  0 context signal.alt.offset + 0 0 0 0 syscall.sigaltstack syscall6 0= require
  context signal.alt.offset + alt.flags + @ 0= require ;

\ Check that recovery restores the caller's origin and retains the faulting origin.
: test.signal.foreign ( image -- )
  test.fault.image !
  s" test.fault.foreign" compiler.xt recovery.run signal.illegal = require
  signal.org test.fault.image @ = require
  signal.rip signal.org - code.start signal.org header.code.limit + @ within require
  context recovery.org.field + @ org = require test.signal.stack ;

\ Recover a named deliberate fault and check its signal and captured image origin.
: test.signal ( name length signal -- )
  >r compiler.xt recovery.run r> = require
  signal.org org = require test.signal.stack ;

\ Verify a write fault reports the protected address exactly.
: test.write.protected ( address -- )
  test.fault.address !
  s" test.fault.write" signal.memory test.signal
  signal.address test.fault.address @ = require
  signal.code signal.reason.access = require ;

\ Verify a no-access region rejects reads and reports the attempted address.
: test.read.protected ( address -- )
  test.fault.address !
  s" test.fault.read" signal.memory test.signal
  signal.address test.fault.address @ = require ;

\ Verify a readable region rejects instruction execution.
: test.execute.protected ( address -- )
  test.fault.address !
  s" test.fault.execute" signal.memory test.signal
  signal.rip test.fault.address @ = require
  signal.code signal.reason.access = require ;

\ Confirm an unarmed fault terminates only a disposable child with 128+signal.
: test.signal.fatal
  0 0 0 0 0 0 syscall.fork syscall6 dup 0 >= require
  dup 0= if drop test.fault.illegal 1 process.exit then
  0 context context.scratch + !
  context context.scratch + 0 0 0 0 syscall.wait syscall6 0 > require
  context context.scratch + @ process.signal.exit signal.illegal + 8 lshift = require ;

\ Exercise real faults, repeated traps, complete rollback and all guarded stacks.
: test.recovery
  s" test.fault.illegal" signal.illegal test.signal
  s" test.fault.divide" signal.arithmetic test.signal
  test.bus.prepare s" test.fault.bus" signal.bus test.signal
  signal.address test.bus.mapping @ = require test.bus.release
  s" test.fault.interrupt" signal.interrupt test.signal
  s" trap" signal.trap test.signal s" trap" signal.trap test.signal
  s" test.fault.native" signal.memory test.signal
  s" test.fault.data" signal.memory test.signal
  s" test.fault.return" signal.memory test.signal
  12345 54321 >r parser.position @ >r
  s" test.fault.rollback" signal.trap test.signal
  parser.position @ r> = require r> 54321 = require 12345 = require
  9 s" square" compiler.xt recovery.run 0= require 81 = require
  signal.number 0= require
  org test.write.protected
  org code.start + test.write.protected
  org dictionary.start + test.write.protected
  org source.start + test.write.protected
  org test.execute.protected
  org dictionary.start + test.execute.protected
  org source.start + test.execute.protected
  context test.execute.protected
  org org header.code.limit + @ page.align + test.execute.protected
  context context.guard.offset + test.read.protected
  context data.guard.offset + test.read.protected
  context return.guard.offset + test.read.protected
  context native.guard.offset + test.read.protected
  context signal.guard.offset + test.read.protected
  context context.used.limit + test.read.protected
  test.signal.fatal ;

\ Verify a sealed candidate's unused reservation is inaccessible.
: test.image.reserve ( image -- )
  dup header.image.size + @ + test.read.protected ;

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
  return.guard.offset page.size + native.stack.offset = require
  native.stack.offset stack.size + native.stack.top = require
  native.stack.top native.guard.offset = require
  native.guard.offset page.size + signal.stack.offset = require
  signal.stack.offset stack.size + signal.guard.offset = require
  signal.guard.offset page.size + recovery.snapshot.offset = require
  recovery.snapshot.offset context.guard.offset + stack.size 2 * + fault.data.offset = require
  fault.data.offset stack.size + fault.return.offset = require
  fault.return.offset stack.size + fault.native.offset = require
  fault.native.offset stack.size + context.used.limit = require
  fault.registers.offset fault.registers.size + context.variables <= require
  context.used.limit context.mapping.size <= require
  native.stack.offset page.aligned? require signal.stack.offset page.aligned? require
  recovery.snapshot.offset page.aligned? require context.used.limit page.aligned? require
  signal.alt.offset alt.size + cell+ context.variables <= require
  context.scratch page.size + context.guard.offset <= require
  context.assembler 6 cells + context.scratch <= require
  context.assembler 6 cells + context.guard.offset <= require ;

\ Protect the guard pages between the mutable context and language stacks.
: stacks.protect
  context context.guard.offset + page.size protection.none image.protect
  context data.guard.offset + page.size protection.none image.protect
  context return.guard.offset + page.size protection.none image.protect
  context native.guard.offset + page.size protection.none image.protect
  context signal.guard.offset + page.size protection.none image.protect
  context context.used.limit + context.mapping.size context.used.limit - protection.none image.protect ;



\ Optional debugger XT in the current image; zero disables the hook.
variable DEBUG

\ Hook image origin; zero selects the image running the top-level boundary.
variable debug.image

\ Temporary debugger context allocation, owned by the calling runtime.
variable debug.context

\ Status returned by the isolated debug invocation.
variable debug.status

\ Cursor used by the default debugger to print captured registers or stack cells.
variable debug.cursor

\ Number of captured cells remaining in the bounded stack display.
variable debug.remaining

\ Return the data-stack depth without counting the result itself.
code depth
  rax rbp mov.rr,
  rax r13 sub.rr,
  rax data.stack.offset sub#,
  rax 3 shift.right#,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Return the language return-stack depth.
code rdepth
  rax r12 mov.rr,
  rax r13 sub.rr,
  rax return.stack.offset sub#,
  rax 3 shift.right#,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Reset both language stacks at a top-level boundary.
code stacks.reset
  rbp r13 data.stack.offset lea,
  r12 r13 return.stack.offset lea,
  ret,
code.end

\ Abandon the current protected input and return to its caller with empty stacks.
\ The outer input loop observes the request and reads a fresh line. A debugger
\ can also QUIT: its own boundary returns without unwinding the parent context.
code quit
  rax 1 mov64,
  rax r13 quit.request.field store,
  rax r13 recovery.active.field load,
  rax 0 cmp#,
  cc.equal jcc.hole,
  rsp r13 recovery.rsp.field load,
  rbx r13 recovery.org.field load,
  resolve,
  rbp r13 data.stack.offset lea,
  r12 r13 return.stack.offset lea,
  rax 0 mov64,
  rax r13 recovery.active.field store,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Return the fault owner's context, even while running in a fresh debugger context.
: fault.context
  context debug.parent.field + @ dup 0= if drop context then ;

\ Return a captured register by byte offset in the Linux general-register block.
: fault.register ( offset -- value )
  dup 0 >= over fault.registers.size 8 - <= and require
  dup 7 and 0= require
  fault.context fault.registers.offset + + @ ;

\ Return the original fault's signal number without consulting debugger-local state.
: fault.number fault.context signal.number.field + @ ;

\ Return the original faulting image's native base address.
: fault.image fault.context signal.org.field + @ ;

\ Return the original fault's native instruction address.
: fault.ip fault.context signal.rip.field + @ ;

\ Return the original fault's accessed memory address.
: fault.address fault.context signal.address.field + @ ;

\ Install an image-relative debugger XT, with an explicit owning image origin.
\ The caller must keep that sealed image mapped while the hook is installed.
: debug.install ( image xt -- )
  dup 0<> if
    dup code.start >= require 2dup swap header.code.limit + @ < require
  then DEBUG ! debug.image ! ;

\ Enter an isolated debugger context and return only its status to the caller.
\ All language/native stacks and R13 are replaced; RBX stays at the runner image.
code debug.enter
  rax rbp -8 load,
  rbp 8 sub#,
  rbx push,
  rbp push,
  r12 push,
  r13 push,
  r14 push,
  r15 push,
  rsp r13 debug.caller.rsp.field store,
  r13 rax mov.rr,
  rbp r13 data.stack.offset lea,
  r12 r13 return.stack.offset lea,
  rsp r13 native.stack.top lea,
  r14 0 mov64,
  r15 0 mov64,
  rax r13 debug.entry.field load,
  rax execute,
  rax rbp -8 load,
  rdx r13 debug.parent.field load,
  rsp rdx debug.caller.rsp.field load,
  r15 pop,
  r14 pop,
  r13 pop,
  r12 pop,
  rbp pop,
  rbx pop,
  rax rbp 0 store,
  rbp 8 add#,
  ret,
code.end

\ Call the configured hook with no arguments on initially empty language stacks.
: debug.call
  context debug.image.field + @ context debug.xt.field + @ image.call ;

\ Initialize the debugger's guards and signal stack, then contain hook failures.
\ DEBUG remains zero in this fresh context, preventing recursive hook dispatch.
: debug.run
  stacks.protect signals.install
  s" recovery.resume" compiler.xt org + context recovery.continuation.field + !
  s" debug.call" compiler.xt recovery.enter ;

\ Invoke the optional hook after sigreturn, preserving the original fault record.
: debug.dispatch
  DEBUG @ 0= if ; then
  0 context.mapping.size protection.read.write 34 -1 0 9 syscall6
  dup 0 > require debug.context !
  context debug.context @ debug.parent.field + !
  s" debug.run" compiler.xt org + debug.context @ debug.entry.field + !
  debug.image @ dup 0= if
    drop editor.image @ dup 0= if drop org then
  then debug.context @ debug.image.field + !
  DEBUG @ debug.context @ debug.xt.field + !
  debug.context @ debug.enter debug.status !
  debug.context @ debug.terminal.active + @ if
    0 terminal.set debug.context @ debug.terminal.saved + 0 0 0 syscall.ioctl syscall6 0= require
  then
  signals.install
  debug.context @ context.mapping.size 0 0 0 0 11 syscall6 0= require
  debug.status @ if
    s" Debug hook fault: signal " type debug.status @ . cr
  then ;


\ Current record while resolving a captured address against a known image.
variable debug.entry

\ Nearest preceding entry for source navigation, without inferring an end.
variable debug.best

\ Greatest entry XT at or below the address being resolved.
variable debug.best.xt

\ Image-relative address being resolved for display.
variable debug.offset

\ Known image selected for the current address translation.
variable debug.owner

\ End of the retained source span during bounded display.
variable debug.limit

\ Number of captured data-stack cells available to display.
variable debug.data.count

\ Number of captured native return-stack cells available to display.
variable debug.frame.count

\ Address of the first captured native return-stack cell at the fault-time RSP.
variable debug.frames

\ Selected native frame, or minus one for the faulting instruction.
variable debug.selected

\ First native return-stack row visible in the table.
variable debug.first

\ Current row being rendered in the register table.
variable debug.row

\ Current value during fixed-width hexadecimal conversion.
variable debug.hex.value

\ Remaining nibbles during fixed-width hexadecimal conversion.
variable debug.hex.count

\ Whether interactive terminal navigation was enabled for this dump.
variable debug.interactive

\ Render the configured number of hexadecimal nibbles from the saved value.
: debug.hex.digits
  begin debug.hex.count @ while
    -1 debug.hex.count +!
    debug.hex.value @ debug.hex.count @ 4 * rshift 15 and
    dup 10 < if 48 + else 55 + then emit
  repeat ;

\ Render one cell as sixteen hexadecimal digits, independent of numeric parsing.
: debug.hex ( value -- )
  debug.hex.value ! 16 debug.hex.count ! debug.hex.digits ;

\ Render a hexadecimal word offset without unnecessary leading zeroes.
: debug.hex.offset ( value -- )
  debug.hex.value ! 16 debug.hex.count !
  begin debug.hex.count @ 1 >
    debug.hex.value @ debug.hex.count @ 1- 4 * rshift 15 and 0= and
  while -1 debug.hex.count +! repeat debug.hex.digits ;

\ Print a fixed number of spaces.
: debug.spaces ( count -- ) begin dup while space 1- repeat drop ;

\ Resolve an address only in an explicitly known image's occupied code span.
: debug.image? ( address image -- flag )
  dup 0= if 2drop 0 ; then
  debug.owner ! debug.owner @ - debug.offset !
  debug.offset @ code.start debug.owner @ header.code.limit + @ within ;

\ Find the nearest entry for an address inside a supplied known image.
: debug.nearest ( address image -- record|0 )
  debug.image? 0= if 0 ; then
  0 debug.best ! 0 debug.best.xt !
  debug.owner @ header.dictionary.root + @ debug.entry !
  begin debug.entry @ while
    debug.owner @ debug.entry @ + entry.xt + @
    dup debug.offset @ <= over debug.best.xt @ >= and if
      debug.best.xt ! debug.entry @ debug.best !
    else drop then
    debug.owner @ debug.entry @ + entry.previous + @ debug.entry !
  repeat
  debug.best @ dup if debug.owner @ + then ;


\ Resolve a raw address in the faulting image or the boundary caller image.
: debug.lookup ( address -- record|0 )
  dup fault.image debug.nearest dup if nip ; then drop
  fault.context recovery.org.field + @ debug.nearest ;

\ Print a translated nearest word and hexadecimal offset, or an unknown marker.
: debug.word ( address -- )
  debug.lookup dup if
    dup entry.name.offset + @ debug.owner @ +
    over entry.name.length + @ type
    s" +0x" type entry.xt + @ debug.offset @ swap - debug.hex.offset
  else drop s" --" type then ;

\ Display four source lines beginning at the nearest entry for an address.
: debug.source ( address -- )
  dup s" Source: " type debug.word cr
  debug.lookup dup 0= if drop s" No source in the known images." type cr ; then
  entry.source.start + @ debug.owner @ + debug.cursor !
  debug.owner @ source.start + debug.owner @ header.source.length + @ + debug.limit !
  4 debug.remaining !
  begin debug.cursor @ debug.limit @ < debug.remaining @ 0 > and while
    debug.cursor @ c@ dup emit 10 = if -1 debug.remaining +! then
    1 debug.cursor +!
  repeat cr ;

\ Return the faulting instruction address, correcting INT3's post-instruction RIP.
: debug.ip
  fault.ip fault.number signal.trap =
  fault.context signal.code.field + @ signal.reason.kernel = and if 1- then ;

\ Display the source window for the faulting instruction.
: debug.where debug.ip debug.source ;

\ Select a register offset and a padded four-character label for a table row.
: debug.register.row ( row -- offset address length )
  dup 0 = if drop registers.rax s" RAX " ; then
  dup 1 = if drop registers.rbx s" RBX " ; then
  dup 2 = if drop registers.rcx s" RCX " ; then
  dup 3 = if drop registers.rdx s" RDX " ; then
  dup 4 = if drop registers.rsi s" RSI " ; then
  dup 5 = if drop registers.rdi s" RDI " ; then
  dup 6 = if drop registers.rbp s" RBP " ; then
  dup 7 = if drop registers.rsp s" RSP " ; then
  dup 8 = if drop registers.r8 s" R8  " ; then
  dup 9 = if drop registers.r9 s" R9  " ; then
  dup 10 = if drop registers.r10 s" R10 " ; then
  dup 11 = if drop registers.r11 s" R11 " ; then
  dup 12 = if drop registers.r12 s" R12 " ; then
  dup 13 = if drop registers.r13 s" R13 " ; then
  dup 14 = if drop registers.r14 s" R14 " ; then
  dup 15 = if drop registers.r15 s" R15 " ; then
  dup 16 = if drop registers.flags s" FL  " ; then
  dup 17 = if drop registers.rip s" RIP " ; then
  drop registers.rip s" RIP " ;

\ Render register, data-stack cell, raw native return address, and translated word.
: debug.table.row
  debug.row @ debug.register.row type fault.register debug.hex
  s"  | " type
  debug.row @ debug.data.count @ < if
    fault.context fault.data.offset + debug.data.count @ 1- debug.row @ - cells + @ debug.hex
  else 16 debug.spaces then
  s"  | " type
  debug.first @ debug.row @ + dup debug.frame.count @ < if
    dup debug.selected @ = if 62 else 32 then emit
    cells debug.frames @ + @ dup debug.hex s"  | " type
    \ Return PCs point after CALL; use the preceding byte for caller ownership.
    1- debug.word
  else drop 17 debug.spaces s"  | " type then cr ;

\ Print the table and source for the selected frame; all values are hexadecimal.
: debug.render
  debug.interactive @ if 27 emit s" [H" type 27 emit s" [2J" type then
  s" Signal " type fault.number . s"  Address 0x" type fault.address debug.hex cr
  s" Register (hex)       | Data stack (top) | Return stack (RSP) | Word + offset" type cr
  0 debug.row !
  begin debug.row @ 18 < while debug.table.row 1 debug.row +! repeat
  s" Forth return stack (R12, top first): " type
  registers.r12 fault.register fault.context return.stack.offset + -
  dup 0 < if drop 0 then stack.size min 8 / dup 8 min debug.remaining !
  cells fault.context fault.return.offset + + debug.cursor !
  begin debug.remaining @ while
    -8 debug.cursor +! debug.cursor @ @ debug.hex space -1 debug.remaining +!
  repeat cr
  debug.selected @ 0 < if debug.ip else
    debug.selected @ cells debug.frames @ + @ 1-
  then debug.source
  debug.interactive @ if
    s" Up/Down: frames   Left: fault   Right: caller   Enter/q: quit debugger" type cr
  then ;

\ Save terminal settings and enable timed single-character input only on a real TTY.
: debug.terminal.open ( -- flag )
  0 terminal.get context debug.terminal.saved + 0 0 0 syscall.ioctl syscall6 if 0 ; then
  1 terminal.get context debug.terminal.work + 0 0 0 syscall.ioctl syscall6 if 0 ; then
  context debug.terminal.saved + context debug.terminal.work + /terminal move
  context debug.terminal.work + terminal.flags + dup c@
  terminal.canonical terminal.echo or terminal.echo.newline or -1 xor and swap c!
  0 context debug.terminal.work + terminal.minimum + c!
  1 context debug.terminal.work + terminal.time + c!
  1 context debug.terminal.active + !
  0 terminal.set context debug.terminal.work + 0 0 0 syscall.ioctl syscall6 if 0 ; then
  -1 ;

\ Restore terminal settings after ordinary navigation or a direct dump invocation.
: debug.terminal.close
  context debug.terminal.active + @ if
    0 terminal.set context debug.terminal.saved + 0 0 0 syscall.ioctl syscall6 0= require
    0 context debug.terminal.active + !
  then ;

\ Read a terminal byte, returning minus one on timeout or EOF.
: debug.key
  0 context context.scratch + 1 0 0 0 0 syscall6
  dup 0 < if drop -2 ; then
  1 = if
    context context.scratch + c@ ;
  then -1 ;

\ Move the selected native frame and keep it inside the visible table window.
: debug.select ( frame -- )
  dup -1 < if drop -1 then
  debug.frame.count @ 1- min debug.selected !
  debug.selected @ 0 < if 0 debug.first ! ; then
  debug.selected @ debug.first @ < if debug.selected @ debug.first ! then
  debug.selected @ debug.first @ 18 + >= if debug.selected @ 17 - debug.first ! then ;

\ Handle an arrow-key suffix without executing or changing the captured program.
: debug.arrow ( character -- )
  dup 65 = if drop debug.selected @ 1- debug.select ; then
  dup 66 = if drop debug.selected @ 1+ debug.select ; then
  dup 67 = if drop debug.selected @ 1+ debug.select ; then
  68 = if -1 debug.select then ;

\ Navigate source windows on a TTY; piped input remains untouched by the debugger.
: debug.navigate
  begin
    debug.key
    dup 113 = over 10 = or over 13 = or over 4 = or over -2 = or if drop ; then
    27 = if
      debug.key dup -1 = if drop ; then
      dup 91 = swap 79 = or if debug.key debug.arrow debug.render then
    then
  again ;

\ Render hexadecimal registers and stack frames, optionally browsing source by arrows.
: debug.dump
  registers.rbp fault.register fault.context data.stack.offset + -
  dup 0 < if drop 0 then stack.size min 8 / debug.data.count !
  registers.rsp fault.register fault.context native.stack.offset + -
  dup 0 < if drop 0 then stack.size min
  dup fault.context fault.native.offset + + debug.frames !
  stack.size swap - 8 / debug.frame.count !
  -1 debug.selected ! 0 debug.first !
  debug.terminal.open debug.interactive !
  debug.render debug.interactive @ if debug.navigate then debug.terminal.close ;

\ Native address of the joined command-line input buffer.
variable input.address

\ Number of source bytes in the joined input, excluding the trailing zero.
variable input.length

\ Allocated byte capacity of the page-rounded input buffer.
variable input.capacity

\ Byte offset of the next token in the command input, independent of compiler parsing.
variable input.position

\ Native address of the next argv pointer while measuring or copying arguments.
variable arguments.cursor

\ Number of argv entries still to measure or copy, excluding argv[0].
variable arguments.remaining

\ Return the byte length of a Linux zero-terminated argument string.
: string.length ( address -- length )
  dup begin dup c@ while 1+ repeat swap - ;

\ Restart traversal at argv[1], leaving the executable name out of the input.
: arguments.reset
  context arguments.vector.field + @ arguments.cursor !
  context arguments.count.field + @ 1- arguments.remaining ! ;

\ Advance to the next startup argument.
: arguments.next
  8 arguments.cursor +! -1 arguments.remaining +! ;

\ Measure and copy argv[1..argc) into one input buffer separated by single spaces.
\ Empty arguments still participate in separators; shell-provided bytes are retained.
: arguments.copy
  0 input.length ! arguments.reset
  begin arguments.remaining @ while
    arguments.cursor @ @ string.length input.length +!
    arguments.remaining @ 1 > if 1 input.length +! then
    arguments.next
  repeat
  input.length @ 1+ page.align dup input.capacity !
  0 swap protection.read.write 34 -1 0 9 syscall6 dup 0 > require input.address !
  0 input.position ! arguments.reset
  begin arguments.remaining @ while
    arguments.cursor @ @ dup string.length
    dup input.position @ + input.position !
    input.address @ input.position @ + over - swap move
    arguments.remaining @ 1 > if
      32 input.address @ input.position @ + c! 1 input.position +!
    then arguments.next
  repeat
  0 input.address @ input.length @ + c! 0 input.position ! ;

\ Report an unsupported command token and abandon its input through QUIT.
: input.error ( message length -- )
  type token.address @ token.length @ type cr
  2 context input.error.field + ! quit ;


\ Writable candidate for the current editor compilation unit, or zero when idle.
variable editor.stage

\ Source offset bias translating the current input buffer into retained image source.
variable editor.bias

\ Retained source length in the candidate, including incomplete input lines.
variable editor.source.length

\ True when an immediate has requested publication at a resolved return boundary.
variable editor.ready

\ Start of the current unpublished input slice, including interpreted operands.
variable editor.source.start

\ Native record found in the active dictionary during token dispatch.
variable editor.record

\ Outer command cursor saved while a runtime word temporarily uses the compiler parser.
variable input.resume

\ Return the selected sealed image, defaulting to the startup image.
: editor.current editor.image @ dup 0= if drop org then ;

\ Find a name in the selected sealed dictionary.
: editor.find ( address length -- record|0 ) editor.current -rot image.find ;

\ Convert the current input cursor into a position in the retained source span.
: editor.bind
  editor.stage @ source.start + parser.source !
  editor.source.length @ parser.length !
  input.position @ editor.bias @ + parser.position ! ;

\ Abandon an unpublished unit while preserving every previously adopted image.
: editor.cancel
  0 compiler.return ! 0 compiler.failure ! 0 compiler.name !
  editor.stage @ dup if image.free else drop then
  0 editor.stage ! 0 editor.ready ! 0 entry.current ! 0 control.depth ! ;

\ Return an interactive compiler error to QUIT rather than terminating the runtime.
: editor.fail s" Compilation error: " input.error ;

\ Preserve installed compiler syntax so the retained source remains bootstrappable.
: editor.name
  token.address @ token.length @ editor.find dup if
    entry.flags + @ flag.immediate and if
      s" Cannot redefine installed compiler syntax: " input.error
    then
  else drop then ;

\ Request publication after a top-level return, preserving conditional early returns.
: editor.return control.depth @ 0= if 1 editor.ready ! then ;

\ Append a source slice after a newline and bind the parser to its retained copy.
: editor.source ( input-offset -- )
  editor.source.length @ 1+ over - editor.bias !
  input.length @ over - editor.source.length @ + 1+ dup
  image.capacity source.start - 16 - < require
  10 editor.stage @ source.start + editor.source.length @ + c!
  editor.source.length !
  dup >r input.address @ +
  editor.stage @ source.start + editor.bias @ + r@ +
  input.length @ r> - move
  editor.bind ;

\ Start appending at the selected image's code/dictionary frontiers in a private copy.
: editor.begin
  image.new editor.stage !
  editor.current editor.stage @ editor.current header.image.size + @ move
  editor.stage @ build.base !
  editor.current header.source.length + @ editor.source.length !
  editor.current header.dictionary.limit + @ dictionary.here !
  editor.current header.dictionary.root + @ dictionary.root !
  editor.current header.context.limit + @ compiler.variables !
  assembler.output >asm editor.stage @ dictionary.start out.init
  editor.current header.code.limit + @ code.here !
  0 control.depth ! 0 entry.current ! 0 editor.ready !
  s" word.interpret" compiler.xt compiler.action !
  s" editor.return" compiler.xt compiler.return !
  s" editor.fail" compiler.xt compiler.failure !
  s" editor.name" compiler.xt compiler.name !
  editor.source.start @ editor.source
  input.position @ editor.bias @ + parser.position !
  token.start @ editor.bias @ + token.start ! ;

\ Seal and adopt an appended unit; older sealed images remain valid for existing users.
: editor.publish
  control.depth @ 0= require
  parser.position @ dup editor.source.length !
  editor.stage @ source.start + + dup 10 swap c! 1+
  s" unit.end" rot swap move
  editor.stage @ source.start + editor.source.length @ + 9 + 10 swap c!
  editor.source.length @ 10 + parser.length !
  editor.stage @ source.start + parser.length @ +
  parser.length @ page.align parser.length @ - erase
  image.finish
  editor.stage @ image.seal editor.stage @ editor.image !
  input.position @ editor.source.start !
  0 editor.stage ! 0 editor.ready !
  0 compiler.return ! 0 compiler.failure ! 0 compiler.name ! ;

\ Compile one editor token through dictionary immediacy and the selected reader action.
: editor.compile
  token.find dup if target.address then dup editor.record ! dup if
    dup entry.flags + @ flag.immediate and if
      drop token.address @ token.length @ editor.find dup 0<> require
      dup entry.xt + @ editor.record @ entry.xt + @ = require
      entry.xt + @ editor.current swap image.call
    else drop editor.current compiler.action @ image.call then
  else drop editor.current compiler.action @ image.call then
  parser.position @ editor.bias @ - input.position !
  editor.ready @ compiler.action @ s" word.interpret" compiler.xt =
  entry.current @ 0= and or if editor.publish then ;

\ Execute an installed word, start an immediate's compilation unit, or push a number.
: token.execute
  editor.stage @ if editor.compile ; then
  token.address @ token.length @ editor.find dup if
    dup entry.flags + @ flag.immediate and if
      drop editor.begin editor.compile ;
    then entry.xt + @ input.position @ input.resume !
    editor.current swap image.call
    parser.source @ input.address @ <> if input.resume @ input.position ! then ;
  then drop number? if ; then drop s" Unknown command word: " input.error ;

\ Execute input while retaining complete source for any open compilation unit.
: input.execute
  0 editor.source.start !
  editor.stage @ if 0 editor.source then
  begin
    editor.stage @ if editor.bind else
      input.address @ parser.source ! input.length @ parser.length !
      input.position @ parser.position !
    then token.parse
  while
    parser.position @ editor.stage @ if editor.bias @ - then input.position !
    token.execute
  repeat ;

\ Most recent command status; retained across EOF after a fault.
variable input.status

\ True after standard input reaches EOF.
variable input.eof

\ Grow the transient input buffer while preserving accumulated bytes.
: input.grow
  0 input.capacity @ 2 * protection.read.write 34 -1 0 9 syscall6
  dup 0 > require >r
  input.address @ r@ input.length @ move
  input.address @ input.capacity @ 0 0 0 0 11 syscall6 0= require
  r> input.address ! input.capacity @ 2 * input.capacity ! ;

\ Read one line from stdin; EOF still permits execution of a final partial line.
: input.read.stream
  0 input.length ! 0 input.position !
  begin
    input.length @ 1+ input.capacity @ >= if input.grow then
    0 input.address @ input.length @ + 1 0 0 0 0 syscall6
    dup 0 < if drop s" Input read failed." type cr 2 process.exit then
    0= if 1 input.eof ! ; then
    input.address @ input.length @ + c@ 10 = if ; then
    1 input.length +!
  again ;

\ Append-mode history descriptor, initialized lazily for standard input.
variable history.fd

\ True once the history file and recall buffer have been initialized.
variable history.ready

\ Native address of the newline-separated history buffer.
variable history.address

\ Number of retained history bytes, including line terminators.
variable history.length

\ Allocated byte capacity of the history buffer.
variable history.capacity

\ Start of the recalled line, or history.length for the unfinished draft.
variable history.cursor

\ Temporary native pointer while searching the startup environment for HOME.
variable history.environment

\ Saved unfinished input while navigating older history entries.
variable history.draft

\ Byte length of the unfinished input saved before the first Up key.
variable history.draft.length

\ Allocation size of the saved draft, for releasing it after input completes.
variable history.draft.capacity

\ True when this input line is being edited on a terminal.
variable input.terminal

\ Report a history failure without executing an unrecorded command.
: history.fail
  debug.terminal.close s" Cannot save command history in ~/.forth." type cr
  2 process.exit ;

\ Append a complete byte range, retrying interrupted and short writes.
: history.write ( address length -- )
  begin dup while
    2dup history.fd @ -rot 0 0 0 1 syscall6
    dup syscall.interrupted = if drop else
      dup 0 <= if history.fail then
      >r swap r@ + swap r> -
    then
  repeat 2drop ;

\ Flush recorded commands before permitting their execution.
: history.sync
  begin history.fd @ 0 0 0 0 0 syscall.fsync syscall6
    dup syscall.interrupted <> if 0<> if history.fail then ; then drop
  again ;

\ Double the recall buffer while preserving all retained source lines.
: history.grow
  0 history.capacity @ 2 * protection.read.write 34 -1 0 9 syscall6
  dup 0 <= if history.fail then >r
  history.address @ r@ history.length @ move
  history.address @ history.capacity @ 0 0 0 0 11 syscall6 drop
  r> history.address ! history.capacity @ 2 * history.capacity ! ;

\ Find HOME in the original Linux environment without consulting another image.
: history.home ( -- address length )
  context arguments.vector.field + @
  context arguments.count.field + @ cells + history.environment !
  begin history.environment @ @ dup while
    dup string.length 5 >= if
      dup s" HOME=" drop 5 bytes.equal? if
        5 + dup string.length dup 0= if history.fail then ;
      then
    then drop 8 history.environment +!
  repeat drop history.fail ;

\ Open ~/.forth and load previous lines before accepting standard input.
: history.open
  history.ready @ if ; then
  history.home dup 9 + page.align >r
  0 r@ protection.read.write 34 -1 0 9 syscall6
  dup 0 <= if history.fail then
  >r 2dup r@ swap move nip
  r@ + s" /.forth" rot swap move
  \ Anonymous mappings supply the trailing zero after the pathname.
  r@ history.open.flags history.permissions 0 0 0 syscall.open syscall6
  dup 0 < if history.fail then history.fd !
  r> r> 0 0 0 0 11 syscall6 drop
  page.size history.capacity !
  0 page.size protection.read.write 34 -1 0 9 syscall6
  dup 0 <= if history.fail then history.address !
  begin
    history.length @ history.capacity @ = if history.grow then
    history.fd @ history.address @ history.length @ +
    history.capacity @ history.length @ - 0 0 0 0 syscall6
    dup syscall.interrupted = if drop else
      dup 0 < if history.fail then
      dup 0= if drop
        history.length @ if
          history.address @ history.length @ + 1- c@ 10 <> if
            history.length @ history.capacity @ = if history.grow then
            10 history.address @ history.length @ + c!
            history.address @ history.length @ + 1 history.write
            1 history.length +! history.sync
          then
        then
        1 history.ready ! ;
      then history.length +!
    then
  again ;

\ Persist one submitted line before the interpreter can execute any of its words.
: history.append
  begin history.length @ input.length @ + 1+ history.capacity @ > while history.grow repeat
  input.address @ history.address @ history.length @ + input.length @ move
  10 history.address @ history.length @ + input.length @ + c!
  history.address @ history.length @ + input.length @ 1+ history.write
  history.sync input.length @ 1+ history.length +! ;

\ Release the saved draft after accepting or abandoning terminal input.
: history.draft.free
  history.draft @ if
    history.draft @ history.draft.capacity @ 0 0 0 0 11 syscall6 drop
    0 history.draft !
  then ;

\ Save the current line before moving away from the newest history position.
: history.draft.save
  history.draft.free input.length @ history.draft.length !
  input.length @ 1+ page.align dup history.draft.capacity !
  0 swap protection.read.write 34 -1 0 9 syscall6
  dup 0 <= if history.fail then history.draft !
  input.address @ history.draft @ input.length @ move ;

\ Replace the editable input with a recalled line or the saved draft.
: input.replace ( address length -- )
  dup >r begin r@ 1+ input.capacity @ >= while input.grow repeat
  drop input.address @ r@ move r> input.length ! ;

\ Redisplay the current editable line after history navigation or deletion.
: input.redraw
  13 emit 27 emit s" [J" type input.address @ input.length @ type ;

\ Copy the selected newline-delimited history line into the input buffer.
: history.recall
  history.cursor @ history.address @ + dup
  begin dup c@ 10 <> while 1+ repeat over - input.replace input.redraw ;

\ Recall the preceding line, saving the unfinished draft on the first Up key.
: history.previous
  history.cursor @ 0= if ; then
  history.cursor @ history.length @ = if history.draft.save then
  -1 history.cursor +!
  begin history.cursor @ while
    history.address @ history.cursor @ + 1- c@ 10 = if history.recall ; then
    -1 history.cursor +!
  repeat history.recall ;

\ Recall the next line, restoring the draft after the newest stored line.
: history.next
  history.cursor @ history.length @ = if ; then
  begin history.address @ history.cursor @ + c@ 10 <> while 1 history.cursor +! repeat
  1 history.cursor +!
  history.cursor @ history.length @ = if
    history.draft @ history.draft.length @ input.replace input.redraw ;
  then history.recall ;

\ Consume an arrow escape sequence without inserting its bytes into source.
: input.escape
  debug.key dup 91 = swap 79 = or if
    debug.key dup 65 = if drop history.previous ; then
    66 = if history.next then
  then ;

\ Read terminal input with history recall, backspace, line erase and Ctrl-D.
: input.edit
  history.length @ history.cursor ! history.draft.free
  begin
    debug.key
    dup -2 = if drop debug.terminal.close
      s" Input read failed." type cr 2 process.exit then
    dup -1 = if drop else
      dup 10 = over 13 = or if drop cr ; then
      dup 4 = if drop input.length @ 0= if 1 input.eof ! ; then else
        dup 27 = if drop input.escape else
          dup 127 = over 8 = or if drop
            input.length @ if -1 input.length +! input.redraw then
          else dup 21 = if drop 0 input.length ! input.redraw else
            dup 32 >= over 9 = or if
              input.length @ 1+ input.capacity @ >= if input.grow then
              dup input.address @ input.length @ + c! 1 input.length +! emit
            else drop then
          then then
        then
      then
    then
  again ;

\ Read one line, using terminal editing only when both input and output are TTYs.
: input.read
  history.open 0 input.length ! 0 input.position !
  debug.terminal.open input.terminal !
  input.terminal @ if input.edit debug.terminal.close history.draft.free ; then
  input.read.stream ;

\ Parse a following word name and return its XT in the running image.
: ' ( "name" -- xt )
  token.parse 0= if s" Missing word name: " input.error then
  parser.position @ input.position !
  token.address @ token.length @ editor.find dup 0= if
    drop s" Unknown command word: " input.error
  then entry.xt + @ ;


\ Dictionary cursor used by WORDS and source-region lookup.
variable inspect.entry

\ First source byte of the selected display region, as an image offset.
variable inspect.start

\ Exclusive display boundary; this is not an executable definition extent.
variable inspect.limit

\ Number of names already printed on the current WORDS output line.
variable inspect.column

\ Native address of the next memory-dump row.
variable dump.address

\ Number of bytes left in the requested memory dump.
variable dump.remaining

\ Number of bytes in the current memory-dump row.
variable dump.width

\ Byte index within the current memory-dump row.
variable dump.index

\ Enable the standard debugger in the current active image.
: debug.on s" debug.dump" compiler.xt DEBUG ! 0 debug.image ! ;

\ Disable automatic debugger dispatch after faults.
: debug.off 0 DEBUG ! 0 debug.image ! ;

\ Leave the runtime with a successful process status.
: bye 0 process.exit ;

\ Parse the following name and find it in the active sealed dictionary.
: inspect.named ( "name" -- record )
  token.parse 0= if s" Missing word name: " input.error then
  parser.position @ input.position !
  token.address @ token.length @ editor.find dup 0= if
    drop s" Unknown command word: " input.error
  then editor.current debug.owner ! ;

\ List active dictionary names, including earlier entries retained by redefinition.
: words
  editor.current header.dictionary.root + @ inspect.entry ! 0 inspect.column !
  begin inspect.entry @ while
    editor.current inspect.entry @ + dup
    entry.name.offset + @ editor.current + over entry.name.length + @ type
    space 1 inspect.column +!
    inspect.column @ 4 = if cr 0 inspect.column ! then
    entry.previous + @ inspect.entry !
  repeat inspect.column @ if cr then ;

\ Print the selected name, its owning image and its source/code offsets.
: inspect.location ( record -- )
  dup entry.name.offset + @ debug.owner @ + over entry.name.length + @ type
  s"   image 0x" type debug.owner @ debug.hex
  s"   code +0x" type dup entry.xt + @ debug.hex.offset
  s"   source +0x" type entry.source.start + @ source.start - debug.hex.offset cr ;

\ Display retained source up to the next named source start or the source-span end.
\ This is a source navigation window; shared labels and early returns remain valid.
: inspect.source ( record -- )
  entry.source.start + @ inspect.start !
  source.start debug.owner @ header.source.length + @ + inspect.limit !
  debug.owner @ header.dictionary.root + @ inspect.entry !
  begin inspect.entry @ while
    debug.owner @ inspect.entry @ + dup entry.source.start + @
    dup inspect.start @ > over inspect.limit @ < and if inspect.limit ! else drop then
    entry.previous + @ inspect.entry !
  repeat
  debug.owner @ inspect.start @ + inspect.limit @ inspect.start @ - type cr ;

\ Show a named entry's location and retained source region.
: see ( "name" -- ) inspect.named dup inspect.location inspect.source ;

\ Locate a named definition in its image and display its source region.
: locate ( "name" -- ) see ;

\ Locate a native code address, or parse a name when the data stack is empty.
: where ( address -- | "name" -- )
  depth 0= if see ; then
  dup editor.current debug.nearest dup if nip else
    drop dup org debug.nearest dup if nip else
      drop fault.context recovery.org.field + @ debug.nearest
    then
  then dup if dup inspect.location inspect.source else
    drop s" No definition in the known images." type cr
  then ;

\ Print one dump byte as two hexadecimal digits.
: dump.byte ( byte -- ) debug.hex.value ! 2 debug.hex.count ! debug.hex.digits ;

\ Display memory as sixteen-byte rows with hexadecimal addresses and ASCII.
\ Invalid memory is handled by the ordinary signal/debug/QUIT boundary.
: dump ( address length -- )
  dup 0 >= require dump.remaining ! dump.address !
  begin dump.remaining @ while
    dump.remaining @ 16 min dump.width !
    dump.address @ debug.hex s" : " type 0 dump.index !
    begin dump.index @ 16 < while
      dump.index @ dump.width @ < if
        dump.address @ dump.index @ + c@ dump.byte space
      else 3 debug.spaces then 1 dump.index +!
    repeat s" |" type 0 dump.index !
    begin dump.index @ dump.width @ < while
      dump.address @ dump.index @ + c@ dup 32 127 within 0= if drop 46 then emit
      1 dump.index +!
    repeat s" |" type cr
    dump.width @ dump.address +! dump.width @ negate dump.remaining +!
  repeat ;

\ Read and execute one line using the ordinary runtime token reader.
: input.cycle
  input.read input.eof @ 0= input.length @ 0<> or if history.append then
  input.execute ;

\ Run input behind a raw signal boundary; faults enter DEBUG then reset the stacks.
\ Unlike recovery.run, top-level QUIT abandons the failed command's stack state.
: input.run ( xt -- )
  0 context quit.request.field + !
  0 context input.error.field + !
  s" recovery.resume" compiler.xt org + context recovery.continuation.field + !
  recovery.enter dup if
    process.signal.exit + input.status !
    stacks.reset debug.terminal.close history.draft.free fault. debug.dispatch editor.cancel stacks.reset ;
  then drop
  context input.error.field + @ dup if input.status ! editor.cancel ; then drop
  context quit.request.field + @ if editor.cancel then
  input.eof @ 0= input.length @ 0<> or if 0 input.status ! then ;

\ Read fresh commands until EOF, retaining normal stack state between lines.
: quit.loop
  begin input.eof @ 0= while s" input.cycle" compiler.xt input.run repeat ;

\ Execute argv input, entering the main loop after a fault or explicit QUIT.
: command.run
  arguments.copy
  context arguments.count.field + @ 1 > if
    s" input.execute" compiler.xt input.run
    input.status @ context quit.request.field + @ or editor.stage @ or if quit.loop then
  else quit.loop then
  editor.stage @ if
    s" Unfinished compilation at end of input." type cr
    editor.cancel 2 input.status !
  then
  input.address @ input.capacity @ 0 0 0 0 11 syscall6 0= require
  input.status @ process.exit ;


\ Set a recognizable fault-time register value before entering the debugger.
code test.debug.fault
  rax $12345678 mov64,
  int3,
  ret,
code.end

\ Check clean debugger stacks and preserved original registers and stack cells.
: test.debug.clean
  depth 0= require rdepth 0= require DEBUG @ 0= require
  fault.number signal.trap = require
  registers.rax fault.register $12345678 = require
  fault.context fault.data.offset + @ 10 = require
  fault.context fault.data.offset + cell+ @ 20 = require
  registers.rbp fault.register fault.context data.stack.offset + - 16 = require
  s" debug-clean" type cr
  99 >r 88 ;

\ Check that a hook in another sealed image retains the original fault owner.
: test.debug.foreign
  org fault.image <> require test.debug.clean ;

\ Run the acceptance suite as a terminal action outside the command boundary.
: selftest
  0 context recovery.active.field + !
  test.recovery
  s" Signals, recovery checkpoints and page protections passed." type cr
  context context.assembler + 3 cells + >asm
  context context.scratch + assembler.check
  s" Native self-compiling Forth" type cr test.native
  s" Shared assembler encoding checks passed." type cr
  rebuild dup org <> require dup >r org over image.equal? require
  dup code.start + test.execute.protected
  s" A == B: complete image" type cr
  dup test.differences dup test.changed.source dup test.immediate.source
  dup org image.equal? require
  s" Differences detected in code, dictionary, source and padding." type cr
  s" Changed source compiled and executed correctly." type cr
  s" Dictionary immediate executed; shared entry points and conditional returns passed." type cr
  dup image.seal dup test.image.reserve
  dup test.signal.foreign
  dup dup s" test.recovery" image.find entry.xt + @ image.call
  dup header.rebuild.xt + @ image.call
  dup r@ <> require dup org <> require
  dup r@ image.equal? require dup org image.equal? require
  s" B == C: complete image, rebuilt by B at a different address" type cr
  dup image.seal
  dup dup s" test.recovery" image.find entry.xt + @ image.call
  image.free r> image.free
  s" Self-compilation verified." type cr 0 process.exit ;

\ Initialize protected execution and process startup input or enter the main loop.
: main
  test.layout stacks.protect signals.install command.run ;
unit.end
