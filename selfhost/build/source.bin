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
  r15 r13 loader.table.field store,
  rax rsp 0 load,
  rax r13 arguments.count.field store,
  rax rsp 16 lea,
  rax r13 arguments.vector.field store,
  rbp r13 data.stack.offset lea,
  r12 r13 return.stack.offset lea,
  rax r13 float.stack.offset lea,
  rax r13 float.sp.field store,
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

\ Call a System V C function with six integer/pointer arguments and one cell result.
\ C preserves RBX/RBP/R12/R13; R15 saves the native stack across alignment.
\ AL is zero for calls without vector arguments, including integer-only varargs.
code c.call6
  r11 rbp -8 load,
  r9 rbp -16 load,
  r8 rbp -24 load,
  rcx rbp -32 load,
  rdx rbp -40 load,
  rsi rbp -48 load,
  rdi rbp -56 load,
  r15 push,
  r15 rsp mov.rr,
  rsp -16 and#,
  rax 0 mov64,
  cld,
  r11 execute,
  rsp r15 mov.rr,
  r15 pop,
  rax rbp -56 store,
  rbp 48 sub#,
  ret,
code.end

\ Invoke the staged SysV call, preserving the native Forth register convention.
\ This is the Linux backend of the SwiftForth bridge port; AL counts all SSE args.
code ffi.native
  r14 push,
  r15 push,
  r14 r13 ffi.frame.offset lea,
  r15 rsp mov.rr,
  rsp -16 and#,
  rax r14 ffi.frame.stack.bytes load,
  rsp rax sub.rr,
  rdi rsp mov.rr,
  rsi r13 ffi.stack.offset lea,
  rcx rax mov.rr,
  cld,
  movsb,
  0 r14 ffi.frame.sse movsd.load,
  1 r14 ffi.frame.sse 8 + movsd.load,
  2 r14 ffi.frame.sse 16 + movsd.load,
  3 r14 ffi.frame.sse 24 + movsd.load,
  4 r14 ffi.frame.sse 32 + movsd.load,
  5 r14 ffi.frame.sse 40 + movsd.load,
  6 r14 ffi.frame.sse 48 + movsd.load,
  7 r14 ffi.frame.sse 56 + movsd.load,
  rdi r14 ffi.frame.integer load,
  rsi r14 ffi.frame.integer 8 + load,
  rdx r14 ffi.frame.integer 16 + load,
  rcx r14 ffi.frame.integer 24 + load,
  r8 r14 ffi.frame.integer 32 + load,
  r9 r14 ffi.frame.integer 40 + load,
  rax r14 ffi.frame.sse.count load,
  r11 r14 ffi.frame.function load,
  r11 execute,
  rax r14 ffi.frame.result.integer store,
  rdx r14 ffi.frame.result.integer 8 + store,
  0 r14 ffi.frame.result.sse movsd.store,
  1 r14 ffi.frame.result.sse 8 + movsd.store,
  rsp r15 mov.rr,
  r15 pop,
  r14 pop,
  ret,
code.end

\ Promote a single-precision cell bit pattern to a double-precision bit pattern.
code ffi.promote
  0 rbp -8 cvtss2sd.load,
  0 rbp -8 movsd.store,
  ret,
code.end

\ Move an IEEE double bit pattern from the data stack onto the guarded FP stack.
code bits>f
  rax r13 float.sp.field load,
  rdx rbp -8 load,
  rdx rax 0 store,
  rax 8 add#,
  rax r13 float.sp.field store,
  rbp 8 sub#,
  ret,
code.end

\ Move the top FP value's IEEE double bits onto the data stack.
code f>bits
  rax r13 float.sp.field load,
  rdx rax -8 load,
  rdx rbp 0 store,
  rbp 8 add#,
  rax 8 sub#,
  rax r13 float.sp.field store,
  ret,
code.end

\ Convert a signed data-stack cell to double precision on the FP stack.
code s>f
  0 rbp -8 cvtsi2sd.load,
  rax r13 float.sp.field load,
  0 rax 0 movsd.store,
  rax 8 add#,
  rax r13 float.sp.field store,
  rbp 8 sub#,
  ret,
code.end

\ Convert the top FP value to a signed cell by truncating toward zero.
code f>s
  rdx r13 float.sp.field load,
  rax rdx -8 cvttsd2si.load,
  rax rbp 0 store,
  rbp 8 add#,
  rdx 8 sub#,
  rdx r13 float.sp.field store,
  ret,
code.end

\ Add two floating-point stack values.
code f+
  $58 float.binary,
code.end

\ Subtract the top floating-point value from the preceding value.
code f-
  $5c float.binary,
code.end

\ Multiply two floating-point stack values.
code f*
  $59 float.binary,
code.end

\ Divide the preceding floating-point value by the top value.
code f/
  $5e float.binary,
code.end

\ Compare two floating-point values for ordered equality; NaN is always false.
code f=
  cc.equal float.compare,
code.end

\ Compare two floating-point values for ordered less-than; NaN is always false.
code f<
  cc.below float.compare,
code.end

\ Round a double-precision bit pattern to a single-precision cell bit pattern.
code ffi.demote
  0 rbp -8 cvtsd2ss.load,
  0 rbp -8 movsd.store,
  rax rbp -8 load,
  rax 32 shift.left#,
  rax 32 shift.right#,
  rax rbp -8 store,
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

\ Linux page size in bytes used to align mappings and protection boundaries.
4096    constant page.size

\ Header byte offset storing the image-format version.
8       constant header.version

\ Header byte offset storing the page-rounded used image size.
16      constant header.image.size

\ Header byte offset storing the exclusive occupied-code boundary.
24      constant header.code.limit

\ Header byte offset storing the exclusive used dictionary boundary.
32      constant header.dictionary.limit

\ Header byte offset storing the newest dictionary entry offset.
40      constant header.dictionary.root

\ Header byte offset storing the mapped source start offset.
48      constant header.source.offset

\ Header byte offset storing the exact retained source byte count.
56      constant header.source.length

\ Header byte offset storing the image-relative main entry point.
64      constant header.main.xt

\ Header byte offset storing the exclusive private-variable allocation boundary.
72      constant header.context.limit

\ Header byte offset storing the image-relative process startup entry point.
80      constant header.start.xt

\ Header byte offset storing the image-relative native recompiler entry point.
96      constant header.rebuild.xt

\ Linux x86-64 mapping and private R13-relative stack layout (all byte counts).
\ [context][guard][data stack][guard][return stack][guard][native stack]
\ [guard][signal stack][guard][recovery snapshot][fault stacks][guard][FP stack]
\ [guard][FP checkpoint][fault FP stack][inaccessible reserve]

\ Total byte size of the private context and guarded stack mapping.
1048576 constant context.mapping.size

\ R13-relative offset of the guard after private context storage.
65536   constant context.guard.offset

\ data stack allocation and depth check

\ R13-relative base of the upward-growing data stack.
69632   constant data.stack.offset

\ R13-relative offset of the guard after the data stack.
135168  constant data.guard.offset

\ return stack allocation, recursion depth echeck

\ R13-relative base of the upward-growing Forth return stack.
139264  constant return.stack.offset

\ R13-relative offset of the guard after the Forth return stack.
204800  constant return.guard.offset

\ default stack allocation 

\ Usable byte capacity of each guarded stack.
65536   constant stack.size

\ memory protection flags

\ Linux memory protection bits granting no access.
0 constant protection.none

\ Linux memory protection bits granting read access.
1 constant protection.read

\ Linux memory protection bits granting read and write access.
3 constant protection.read.write

\ Linux memory protection bits granting read and execute access.
5 constant protection.read.execute

\ image memory format

\ Header byte offset storing the image signature.
0                 constant header.magic

\ Signature identifying the canonical native Forth image format.
$31464c4553465446 constant image.magic

\ Version of the canonical image and dictionary layout.
3                 constant image.version

\ Reserved byte capacity of each independently compiled image.
1048576           constant image.capacity

\ Image-relative offset of the first executable code byte.
4096              constant code.start

\ Image-relative offset of the first dictionary record.
262144            constant dictionary.start

\ Image-relative offset of the retained source text.
393216            constant source.start

\ dictionary entry size

\ Byte size of one source-backed dictionary entry.
64      constant /entry

\ Dictionary field offsets are bytes, independent of host cell numbering.

\ Dictionary field byte offset storing the preceding dictionary record offset.
0       constant entry.previous

\ Dictionary field byte offset storing the image-relative executable entry point.
8       constant entry.xt

\ Dictionary field byte offset storing the source-backed name length.
16      constant entry.name.length

\ Dictionary field byte offset storing the defining source token offset.
24      constant entry.source.start

\ Dictionary field byte offset storing the definition kind.
32      constant entry.kind

\ Dictionary field byte offset storing the constant value or variable context offset.
40      constant entry.value

\ Dictionary field byte offset storing the image-relative name text offset.
48      constant entry.name.offset

\ Dictionary field byte offset storing the immediate/compiler flags.
56      constant entry.flags

\ compiler word flag

\ Dictionary flag selecting execution during source compilation.
1       constant flag.immediate

\ editable regions

\ R13-relative start of invocation-private Forth variable cells.
1024    constant context.variables

\ R13-relative start of the compiler control-flow stack.
4096    constant context.control

\ R13-relative start of transient scratch storage.
8192    constant context.scratch

\ R13-relative buffer retaining the dictionary browser search query.
12544   constant context.words.query

\ Maximum bytes accepted by the dictionary browser search prompt.
256     constant words.query.capacity

\ R13-relative start of the assembler output context records.
6144    constant context.assembler

\ Native and alternate signal stacks have guards on both sides.

\ R13-relative low address of the native return-address stack.
208896  constant native.stack.offset

\ R13-relative initial RSP for the downward-growing native stack.
274432  constant native.stack.top

\ R13-relative offset of the guard above the native stack.
274432  constant native.guard.offset

\ R13-relative base of the alternate signal-handler stack.
278528  constant signal.stack.offset

\ R13-relative offset of the guard above the signal stack.
344064  constant signal.guard.offset

\ R13-relative start of the recovery checkpoint snapshot.
348160  constant recovery.snapshot.offset

\ R13-relative start of the captured fault-time data stack.
544768  constant fault.data.offset

\ R13-relative start of the captured fault-time Forth return stack.
610304  constant fault.return.offset

\ R13-relative start of the captured fault-time native stack.
675840  constant fault.native.offset

\ Exclusive R13-relative end of used context and snapshot storage.
946176  constant context.used.limit

\ Guard separating fault snapshots from the upward-growing FP stack.
741376  constant float.guard.low

\ Base of the guarded, double-precision floating-point stack.
745472  constant float.stack.offset

\ Guard above the floating-point stack.
811008  constant float.guard.offset

\ Storage for the complete FP stack at a recovery checkpoint.
815104  constant float.snapshot.offset

\ Storage for the complete fault-time FP stack captured by the signal handler.
880640  constant fault.float.offset

\ Context field containing the next available FP stack address.
464     constant float.sp.field

\ Saved FP pointer for the current recovery boundary.
472     constant recovery.float.field

\ Captured fault-time FP pointer for inspection by debugger hooks.
480     constant fault.float.sp.field

\ Reserved recovery fields below context.variables; all offsets are bytes.

\ R13-relative field storing whether a recovery boundary is armed.
0       constant recovery.active.field

\ R13-relative field storing the boundary native stack pointer.
8       constant recovery.rsp.field

\ R13-relative field storing the boundary data-stack pointer.
16      constant recovery.rbp.field

\ R13-relative field storing the boundary Forth return-stack pointer.
24      constant recovery.r12.field

\ R13-relative field storing the image origin to restore when recovering.
32      constant recovery.org.field

\ R13-relative field storing the native address to resume after recovery.
40      constant recovery.continuation.field

\ R13-relative field storing the captured signal number.
48      constant signal.number.field

\ R13-relative field storing the captured signal reason code.
56      constant signal.code.field

\ R13-relative field storing the captured fault address.
64      constant signal.address.field

\ R13-relative field storing the captured instruction pointer.
72      constant signal.rip.field

\ R13-relative field storing the faulting image origin.
80      constant signal.org.field

\ R13-relative field storing the signal handler entry stack pointer.
88      constant signal.stack.field

\ R13-relative field storing the protected action execution token.
96      constant recovery.target.field

\ R13-relative storage for the kernel sigaction record.
128     constant signal.action.offset

\ R13-relative storage for the alternate-stack descriptor.
160     constant signal.alt.offset

\ R13-relative field storing the original Linux argc value.
192     constant arguments.count.field

\ R13-relative field storing the original argv[1] pointer.
200     constant arguments.vector.field

\ R13-relative field storing the parent context address of an isolated debugger.
208     constant debug.parent.field

\ R13-relative field storing the parent native stack pointer during debug entry.
216     constant debug.caller.rsp.field

\ R13-relative field storing the native debugger runner address.
224     constant debug.entry.field

\ R13-relative field storing the selected debug hook image origin.
232     constant debug.image.field

\ R13-relative field storing the selected image-relative debug hook token.
240     constant debug.xt.field

\ R13-relative field storing whether QUIT requested a fresh input cycle.
248     constant quit.request.field

\ R13-relative start of the captured general-register block.
256     constant fault.registers.offset

\ Byte length of the captured Linux general-register block.
184     constant fault.registers.size

\ Byte offset of the general-register block within Linux ucontext.
40      constant ucontext.registers

\ R13-relative field storing the current command error status.
448     constant input.error.field

\ R13-relative call frame for the ported System V ABI bridge.
16384   constant ffi.frame.offset

\ R13-relative scratch descriptors used while parsing a FUNCTION: signature.
17408   constant ffi.types.offset

\ R13-relative staging area for outgoing C stack arguments.
32768   constant ffi.stack.offset

\ Maximum outgoing C stack argument bytes, bounded below the context guard.
16384   constant ffi.stack.capacity

\ Total bytes of the private C call register frame.
176     constant ffi.frame.size

\ Maximum number of explicit parameters in a foreign signature.
32      constant ffi.arguments.max

\ Size of an argument descriptor: size, kind, and two eightbyte classes.
32      constant ffi.type.size

\ Descriptor field containing the byte size of a value.
0       constant ffi.type.bytes

\ Descriptor field selecting scalar or aggregate handling.
8       constant ffi.type.kind

\ Descriptor field containing the first eightbyte class.
16      constant ffi.type.class0

\ Descriptor field containing the second eightbyte class.
24      constant ffi.type.class1

\ Call-frame field containing the resolved native function address.
0       constant ffi.frame.function

\ Call-frame array of six integer argument register values.
8       constant ffi.frame.integer

\ Call-frame array of eight SSE argument register bit patterns.
56      constant ffi.frame.sse

\ Call-frame field containing the number of SSE registers used, for AL.
120     constant ffi.frame.sse.count

\ Call-frame field containing the aligned outgoing C stack byte count.
128     constant ffi.frame.stack.bytes

\ Call-frame array receiving RAX and RDX return values.
136     constant ffi.frame.result.integer

\ Call-frame array receiving XMM0 and XMM1 return values.
152     constant ffi.frame.result.sse

\ Eightbyte class for unused or padding-only bytes.
0       constant ffi.class.none

\ Eightbyte class passed in integer registers.
1       constant ffi.class.integer

\ Eightbyte class passed in SSE registers.
2       constant ffi.class.sse

\ Aggregate class requiring memory passing.
3       constant ffi.class.memory

\ Signature kind for an absent return value.
0       constant ffi.kind.void

\ Signature kind for an integer or pointer cell.
1       constant ffi.kind.integer

\ Signature kind for a scalar FP argument narrowed to C single precision.
2       constant ffi.kind.float

\ Signature kind for a scalar FP argument passed as C double precision.
3       constant ffi.kind.double

\ Signature kind for an aggregate passed by address on the Forth stack.
4       constant ffi.kind.struct

\ Signature kind for a variadic float promoted to C double.
5       constant ffi.kind.promoted

\ Signature kind requesting sign extension of a C int return.
6       constant ffi.kind.signed

\ R13-relative pointer to the ELF wrapper's resolved, read-only import table.
456     constant loader.table.field

\ Loader table slot containing the C process initialization entry point.
0       constant loader.start

\ Loader table slot containing dlopen.
8       constant loader.dlopen

\ Loader table slot containing dlsym.
16      constant loader.dlsym

\ Loader table slot containing dlclose.
24      constant loader.dlclose

\ Loader table slot containing dlerror.
32      constant loader.dlerror

\ Loader table slot containing exit for C cleanup and destructor processing.
40      constant loader.exit

\ Request immediate resolution of a library's undefined function symbols.
2       constant rtld.now

\ Permit deferred function binding when opening a library.
1       constant rtld.lazy

\ Keep a loaded library's exports local to its dependency group.
0       constant rtld.local

\ Make a loaded library's exports available to subsequent global lookups.
256     constant rtld.global

\ Pseudo-handle searching the global symbol scope in DLSYM.
0       constant rtld.default

\ R13-relative storage for the original terminal settings.
12288   constant debug.terminal.saved

\ R13-relative storage for temporary terminal settings.
12352   constant debug.terminal.work

\ R13-relative flag recording whether terminal restoration is needed.
12416   constant debug.terminal.active

\ Byte size of the Linux kernel termios record.
36      constant /terminal

\ Byte offset of local terminal flags within termios.
12      constant terminal.flags

\ Byte offset of the VMIN control character in termios.
23      constant terminal.minimum

\ Byte offset of the VTIME timeout control character in termios.
22      constant terminal.time

\ Linux TCGETS request for reading terminal settings.
$5401   constant terminal.get

\ Linux TCSETS request for applying terminal settings.
$5402   constant terminal.set

\ Linux TIOCGWINSZ request for reading terminal rows and columns.
$5413   constant terminal.window

\ Linux x86-64 syscall number for ioctl.
16      constant syscall.ioctl

\ ICANON flag selecting canonical line input.
2       constant terminal.canonical

\ ECHO flag enabling terminal input echo.
8       constant terminal.echo

\ ECHONL flag enabling newline echo even when ECHO is disabled.
64      constant terminal.echo.newline

\ Byte offset of R8 in the captured general-register block.
0       constant registers.r8

\ Byte offset of R9 in the captured general-register block.
8       constant registers.r9

\ Byte offset of R10 in the captured general-register block.
16      constant registers.r10

\ Byte offset of R11 in the captured general-register block.
24      constant registers.r11

\ Byte offset of R13 in the captured general-register block.
40      constant registers.r13

\ Byte offset of R14 in the captured general-register block.
48      constant registers.r14

\ Byte offset of R15 in the captured general-register block.
56      constant registers.r15

\ Byte offset of RDI in the captured general-register block.
64      constant registers.rdi

\ Byte offset of RSI in the captured general-register block.
72      constant registers.rsi

\ Byte offset of RBX in the captured general-register block.
88      constant registers.rbx

\ Byte offset of RDX in the captured general-register block.
96      constant registers.rdx

\ Byte offset of RAX in the captured general-register block.
104     constant registers.rax

\ Byte offset of RCX in the captured general-register block.
112     constant registers.rcx

\ Byte offset of RFLAGS in the captured general-register block.
136     constant registers.flags

\ Byte offset of RSP in the captured general-register block.
120     constant registers.rsp

\ Byte offset of RBP in the captured general-register block.
80      constant registers.rbp

\ Byte offset of R12 in the captured general-register block.
32      constant registers.r12

\ Byte offset of RIP in the captured general-register block.
128     constant registers.rip

\ Linux x86-64 kernel signal ABI, not the libc sigaction layout.

\ Byte offset of the handler address in the kernel sigaction record.
0       constant action.handler

\ Byte offset of the action flags in the kernel sigaction record.
8       constant action.flags

\ Byte offset of the sigreturn restorer address in the kernel sigaction record.
16      constant action.restorer

\ Byte offset of the blocked signal mask in the kernel sigaction record.
24      constant action.mask

\ Byte offset of the native stack base in the alternate-stack descriptor.
0       constant alt.base

\ Byte offset of the stack flags in the alternate-stack descriptor.
8       constant alt.flags

\ Byte offset of the stack byte capacity in the alternate-stack descriptor.
16      constant alt.size

\ Byte size of the signal mask accepted by rt_sigaction.
8       constant signal.mask.size

\ Byte offset of the signal reason code within siginfo.
8       constant siginfo.code

\ Byte offset of the faulting memory address within siginfo.
16      constant siginfo.address

\ Byte offset of saved R12 within Linux ucontext.
72      constant ucontext.r12

\ Byte offset of saved R13 within Linux ucontext.
80      constant ucontext.r13

\ Byte offset of saved RBP within Linux ucontext.
120     constant ucontext.rbp

\ Byte offset of saved RBX within Linux ucontext.
128     constant ucontext.rbx

\ Byte offset of saved RSP within Linux ucontext.
160     constant ucontext.rsp

\ Byte offset of saved RIP within Linux ucontext.
168     constant ucontext.rip

\ Byte offset of saved RFLAGS within Linux ucontext.
176     constant ucontext.flags

\ Linux SIGINT number for an interrupt request.
2       constant signal.interrupt

\ Linux SIGILL number for an invalid instruction.
4       constant signal.illegal

\ Linux SIGTRAP number for an INT3 breakpoint.
5       constant signal.trap

\ Linux SIGBUS number for an invalid mapped backing-store access.
7       constant signal.bus

\ Linux SIGFPE number for an arithmetic exception.
8       constant signal.arithmetic

\ Linux SIGSEGV number for an invalid memory access.
11      constant signal.memory

\ SEGV_ACCERR reason for a page-protection violation.
2       constant signal.reason.access

\ SI_KERNEL reason used to recognize an INT3 trap.
128     constant signal.reason.kernel

\ SA_SIGINFO flag requesting siginfo and ucontext arguments.
4       constant signal.flag.info

\ SA_RESTORER flag selecting the native sigreturn trampoline.
$04000000 constant signal.flag.restorer

\ SA_ONSTACK flag selecting the guarded alternate signal stack.
$08000000 constant signal.flag.onstack

\ RFLAGS mask clearing the trap and direction flags during recovery.
-1281   constant flags.recovery.mask

\ Base exit status added to a signal number for fault termination.
128     constant process.signal.exit

\ Linux x86-64 syscall number for getpid.
39      constant syscall.getpid

\ Linux x86-64 syscall number for fork.
57      constant syscall.fork

\ Linux x86-64 syscall number for wait4.
61      constant syscall.wait

\ Linux x86-64 syscall number for kill.
62      constant syscall.kill

\ Linux x86-64 syscall number for memfd_create.
319     constant syscall.memfd

\ Linux x86-64 syscall number for rt_sigaction.
13      constant syscall.sigaction

\ Linux x86-64 syscall number for rt_sigreturn.
15      constant syscall.sigreturn

\ Linux x86-64 syscall number for sigaltstack.
131     constant syscall.sigaltstack

\ Linux file operations and flags used by the persistent input history.

\ Linux x86-64 syscall number for open.
2       constant syscall.open

\ Linux x86-64 syscall number for fsync.
74      constant syscall.fsync

\ History open flags: read/write, create if absent and append writes.
525378  constant history.open.flags     \ O_RDWR | O_CREAT | O_APPEND | O_CLOEXEC.

\ Creation mode 0600, granting the owner read and write access.
384     constant history.permissions    \ Mode 0600: owner read and write.

\ Negative EINTR result requiring an interrupted syscall retry.
-4      constant syscall.interrupted

\ Native disassembler operand forms and architectural instruction-size limit.

\ Native disassembler operand form with no operands.
0       constant operand.none

\ Native disassembler operand form with r/m destination and register source.
1       constant operand.rm.reg

\ Native disassembler operand form with register destination and r/m source.
2       constant operand.reg.rm

\ Native disassembler operand form with r/m destination and immediate source.
3       constant operand.rm.immediate

\ Native disassembler operand form with one register or memory operand.
4       constant operand.rm

\ Native disassembler operand form with register destination and immediate source.
5       constant operand.reg.immediate

\ Native disassembler operand form with one relative branch target.
6       constant operand.target

\ Native disassembler operand form with one explicit register operand.
7       constant operand.reg

\ Native disassembler operand form with an undecoded raw byte.
8       constant operand.byte

\ Native disassembler operand form with r/m destination and CL shift count.
9       constant operand.rm.cl

\ Architectural maximum encoded length of one x86 instruction.
15      constant instruction.bytes.max

\ Previous saved WHERE view in the navigation history chain, or zero.
0       constant where.saved.previous

\ Native query-text address retained by a saved WHERE view.
8       constant where.saved.name

\ Query byte length retained by a saved WHERE view.
16      constant where.saved.length

\ Selected occurrence index retained by a saved WHERE view.
24      constant where.saved.selected

\ First visible occurrence index retained by a saved WHERE view.
32      constant where.saved.first

\ Source image origin retained by a saved WHERE view.
40      constant where.saved.image

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

\ Call a C function with no integer or pointer arguments.
: c.call0 ( function -- result ) >r 0 0 0 0 0 0 r> c.call6 ;

\ Call a C function with one integer or pointer argument.
: c.call1 ( a1 function -- result ) >r 0 0 0 0 0 r> c.call6 ;

\ Call a C function with two integer or pointer arguments.
: c.call2 ( a1 a2 function -- result ) >r 0 0 0 0 r> c.call6 ;

\ Call a C function with three integer or pointer arguments.
: c.call3 ( a1 a2 a3 function -- result ) >r 0 0 0 r> c.call6 ;

\ Call a C function with four integer or pointer arguments.
: c.call4 ( a1 a2 a3 a4 function -- result ) >r 0 0 r> c.call6 ;

\ Call a C function with five integer or pointer arguments.
: c.call5 ( a1 a2 a3 a4 a5 function -- result ) >r 0 r> c.call6 ;

\ Resolve an OS-loader service from the invocation's external import table.
: loader.function ( offset -- function ) context loader.table.field + @ + @ ;

\ Extend a C signed int result to the native 64-bit cell size.
: c.int ( result -- signed ) $ffffffff and dup $80000000 and if $ffffffff00000000 or then ;

\ Terminate through libc so buffered output and library destructors are processed.
: process.exit loader.exit loader.function c.call1 drop ;

\ Optional image-relative stdout capture handler, returning the written byte count.
variable output.capture

\ Image owning the stdout capture handler while a pager is collecting output.
variable output.capture.image

\ Write a byte range to standard output and return the system-call result.
: stdout.write ( addr length -- result )
  output.capture @ dup if output.capture.image @ swap image.call ; then drop
  1 -rot 0 0 0 1 syscall6 ;

\ Optional image-relative text-output handler; zero selects ordinary stdout.
variable output.vector

\ Owning image of the text-output handler, or zero for the currently running image.
variable output.image

\ Write a complete byte range to standard output, handling partial writes.
: type ( addr length -- )
  output.vector @ dup if output.image @ dup 0= if drop org then swap image.call ; then drop
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

\ Copy a Forth string into an owned NUL-terminated mapping with a size header.
\ The caller releases it with C.STRING.FREE; no address enters the saved image.
: c.string ( address length -- zstring )
  dup 0 >= require dup image.capacity < require
  dup cell+ 1+ page.align >r
  0 r@ protection.read.write 34 -1 0 9 syscall6 dup 0 > require
  r> over ! cell+ >r
  r@ over + 0 swap c! r@ swap move r> ;

\ Release an owned C string using the allocation size immediately before it.
: c.string.free ( zstring -- )
  8 - dup @ 0 0 0 0 11 syscall6 0= require ;

\ Return the length of a borrowed NUL-terminated C string; NULL gives zero length.
: c.string.length ( zstring -- length )
  dup 0= if ; then dup begin dup c@ while 1+ repeat swap - ;

\ Open a shared library from a Forth string; zero address and length select self.
\ Return NULL on loader failure; DLERROR supplies the loader's diagnostic.
: dlopen ( address length flags -- handle )
  >r 2dup or 0= if 2drop 0 r> loader.dlopen loader.function c.call2 ; then
  c.string r> over >r loader.dlopen loader.function c.call2
  r> c.string.free ;

\ Resolve a library symbol from a Forth string, returning its native C address.
\ Clear and check DLERROR to distinguish a null-valued symbol from failure.
: dlsym ( handle address length -- function )
  c.string dup >r loader.dlsym loader.function c.call2 r> c.string.free ;

\ Release one loader reference; symbols must not be called after their final close.
: dlclose ( handle -- status ) loader.dlclose loader.function c.call1 c.int ;

\ Fetch and clear the last loader error as a borrowed Forth string, or 0 0.
\ The string remains valid only until the next loader operation on this thread.
: dlerror ( -- address length ) loader.dlerror loader.function c.call0 dup c.string.length ;

\ Return the context-private call frame.
: ffi.frame context ffi.frame.offset + ;

\ Resolve a C service in the process-wide library scope.
: ffi.service ( address length -- function ) dlerror 2drop rtld.default -rot dlsym dup 0<> require ;

\ Parse an entire counted string as a C-locale double and push it on success.
\ Failure leaves the FP stack untouched and returns false on the data stack.
: >float ( address length -- flag ) ( F: -- value )
  dup 0= if 2drop 0 ; then
  ffi.frame ffi.frame.size erase
  s" strtod" ffi.service ffi.frame ffi.frame.function + !
  dup >r c.string dup r> + >r dup >r
  ffi.frame ffi.frame.integer + !
  0 context context.scratch + !
  context context.scratch + ffi.frame ffi.frame.integer + 8 + !
  ffi.native r> c.string.free
  context context.scratch + @ r> = if
    ffi.frame ffi.frame.result.sse + @ bits>f -1 ;
  then 0 ;

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

\ x86 condition-code encoding for unsigned below (CF set).
2 constant cc.below

\ x86 condition-code encoding for equal (ZF set).
4 constant cc.equal

\ x86 condition-code encoding for nonnegative (SF clear).
9 constant cc.not.sign

\ x86 condition-code encoding for signed less than (SF differs from OF).
12 constant cc.less

\ x86 condition-code encoding for signed less than or equal (ZF set or SF differs from OF).
14 constant cc.less.equal

\ Assembler register encoding for RAX.
0 constant rax

\ Assembler register encoding for RCX.
1 constant rcx

\ Assembler register encoding for RDX.
2 constant rdx

\ Assembler register encoding for RBX.
3 constant rbx

\ Assembler register encoding for RSP.
4 constant rsp

\ Assembler register encoding for RBP.
5 constant rbp

\ Assembler register encoding for RSI.
6 constant rsi

\ Assembler register encoding for RDI.
7 constant rdi

\ Assembler register encoding for R8.
8 constant r8

\ Assembler register encoding for R9.
9 constant r9

\ Assembler register encoding for R10.
10 constant r10

\ Assembler register encoding for R11.
11 constant r11

\ Assembler register encoding for R12.
12 constant r12

\ Assembler register encoding for R13.
13 constant r13

\ Assembler register encoding for R14.
14 constant r14

\ Assembler register encoding for R15.
15 constant r15

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

\ Emit a scalar SSE memory operation with an explicit mandatory prefix.
: sse.memory, ( xmm base displacement opcode prefix -- )
  byte, >r >r 2dup rex32, $0f byte, r> r> byte, mem, ;

\ Emit MOVSD from memory into an XMM register.
: movsd.load, ( xmm base displacement -- ) $10 $f2 sse.memory, ;

\ Emit MOVSD from an XMM register into memory.
: movsd.store, ( xmm base displacement -- ) $11 $f2 sse.memory, ;

\ Emit CVTSS2SD from scalar single memory into an XMM register.
: cvtss2sd.load, ( xmm base displacement -- ) $5a $f3 sse.memory, ;

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

\ Emit SHL by a validated immediate bit count.
: shift.left#, ( reg count -- )
  dup 0 64 within require >r 4 $c1 group, r> byte, ;

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

\ Emit CVTSD2SS from scalar double memory into an XMM register.
: cvtsd2ss.load, ( xmm base displacement -- ) $5a $f2 sse.memory, ;

\ Emit CVTSI2SD from a signed 64-bit memory integer.
: cvtsi2sd.load, ( xmm base displacement -- )
  $f2 byte, >r 2dup rex, $0f byte, $2a byte, r> mem, ;

\ Emit CVTTSD2SI from scalar double memory into a signed 64-bit register.
: cvttsd2si.load, ( reg base displacement -- )
  $f2 byte, >r 2dup rex, $0f byte, $2c byte, r> mem, ;

\ Emit a complete guarded two-input FP primitive using the selected SSE opcode.
: float.binary, ( opcode -- )
  rax r13 float.sp.field load,
  0 rax -16 movsd.load,
  >r 0 rax -8 r> $f2 sse.memory,
  0 rax -16 movsd.store,
  rax 8 sub#,
  rax r13 float.sp.field store,
  ret, ;

\ Emit an ordered FP comparison, returning a Forth flag and consuming both values.
: float.compare, ( condition -- )
  >r r10 r13 float.sp.field load,
  0 r10 -16 movsd.load,
  0 r10 -8 $2e $66 sse.memory,
  rax 0 mov64, rdx 0 mov64,
  rax r> setcc, rdx 11 setcc,
  rax rdx and.rr, rax negate,
  r10 16 sub#, r10 r13 float.sp.field store,
  rax rbp 0 store, rbp 8 add#, ret, ;

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
  number? if asm.literal ; then drop
  token.address @ token.length @ >float require
  f>bits asm.literal s" bits>f" target.xt asm.call ;

\ Execute an installed word or leave a parsed number on the data stack.
: word.interpret
  token.address @ token.length @ compiler.find dup if entry.xt + @ execute ; then drop
  number? if ; then drop token.address @ token.length @ >float require ;

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

\ Silently rebuild, compare with the executing image, and release the candidate.
: verify? ( -- flag ) rebuild dup >r org image.equal? r> image.free ;

\ Report whether native self-compilation reproduces the executing image exactly.
: verify ( -- flag )
  verify? dup if s" Verification passed: rebuilt image is identical." else
    s" Verification FAILED: rebuilt image differs."
  then type cr ;

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
  rax r13 float.sp.field load,
  rax r13 fault.float.sp.field store,
  rsi r13 float.stack.offset lea,
  rdi r13 fault.float.offset lea,
  rcx stack.size mov64,
  movsb,
  rax r13 recovery.float.field load,
  rax r13 float.sp.field store,
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
  rcx r13 float.sp.field load,
  rcx r13 recovery.float.field store,
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
  context return.stack.offset + context recovery.snapshot.offset + context.guard.offset + stack.size + stack.size move
  context float.stack.offset + context float.snapshot.offset + stack.size move ;

\ Restore stack contents and compiler state after leaving the signal handler.
: recovery.restore
  context recovery.snapshot.offset + context context.variables +
  context.guard.offset context.variables - move
  context recovery.snapshot.offset + context.guard.offset + context data.stack.offset + stack.size move
  context recovery.snapshot.offset + context.guard.offset + stack.size + context return.stack.offset + stack.size move
  context float.snapshot.offset + context float.stack.offset + stack.size move ;

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
  context loader.table.field + @ test.write.protected
  context loader.table.field + @ test.execute.protected
  context test.execute.protected
  org org header.code.limit + @ page.align + test.execute.protected
  context context.guard.offset + test.read.protected
  context data.guard.offset + test.read.protected
  context return.guard.offset + test.read.protected
  context native.guard.offset + test.read.protected
  context signal.guard.offset + test.read.protected
  context float.guard.low + test.read.protected
  context float.guard.offset + test.read.protected
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
  fault.native.offset stack.size + float.guard.low = require
  float.guard.low page.size + float.stack.offset = require
  float.stack.offset stack.size + float.guard.offset = require
  float.guard.offset page.size + float.snapshot.offset = require
  float.snapshot.offset stack.size + fault.float.offset = require
  fault.float.offset stack.size + context.used.limit = require
  fault.registers.offset fault.registers.size + context.variables <= require
  context.used.limit context.mapping.size <= require
  native.stack.offset page.aligned? require signal.stack.offset page.aligned? require
  recovery.snapshot.offset page.aligned? require context.used.limit page.aligned? require
  signal.alt.offset alt.size + cell+ context.variables <= require
  context.scratch page.size + context.words.query <= require
  debug.terminal.active cell+ context.words.query <= require
  context.words.query words.query.capacity + ffi.frame.offset <= require
  ffi.frame.offset ffi.frame.size + ffi.types.offset <= require
  ffi.types.offset ffi.arguments.max 1+ ffi.type.size * + 8 + ffi.stack.offset <= require
  ffi.stack.offset ffi.stack.capacity + context.guard.offset <= require
  context.assembler 6 cells + context.scratch <= require
  context.assembler 6 cells + context.guard.offset <= require ;

\ Protect the guard pages between the mutable context and language stacks.
: stacks.protect
  context context.guard.offset + page.size protection.none image.protect
  context data.guard.offset + page.size protection.none image.protect
  context return.guard.offset + page.size protection.none image.protect
  context native.guard.offset + page.size protection.none image.protect
  context signal.guard.offset + page.size protection.none image.protect
  context float.guard.low + page.size protection.none image.protect
  context float.guard.offset + page.size protection.none image.protect
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
  rax r13 float.stack.offset lea,
  rax r13 float.sp.field store,
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
  rax r13 float.stack.offset lea,
  rax r13 float.sp.field store,
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
  rax r13 float.stack.offset lea,
  rax r13 float.sp.field store,
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

\ True when automatic terminal styling has been explicitly disabled.
variable tui.disabled

\ True when stdout is a terminal and ANSI styling is available.
variable tui.terminal

\ True while TYPE is routing text through the current frame.
variable tui.active

\ Interior text width of the current frame, excluding borders and margins.
variable tui.width

\ Number of text columns already written on the current framed row.
variable tui.column

\ True when long rows are clipped instead of wrapped, for fixed-height tables.
variable tui.clip

\ True after the current row has displayed its truncation marker.
variable tui.clipped

\ True after the current row's left border has been written.
variable tui.row.active

\ Packed Linux winsize record used to query the output terminal dimensions.
variable tui.size

\ One-byte staging cell used for raw terminal output, separate from EMIT's scratch.
variable tui.character

\ Native address of the next byte being routed into the current frame.
variable tui.text

\ Number of bytes still to route into the current frame.
variable tui.remaining

\ Native address of the pager's captured terminal output, or zero when idle.
variable pager.address

\ Allocated byte capacity of the pager output buffer.
variable pager.capacity

\ Number of captured terminal output bytes.
variable pager.length

\ Release captured output and restore direct stdout before recovery or normal exit.
: pager.release
  0 output.capture ! 0 output.capture.image !
  pager.address @ if
    pager.address @ pager.capacity @ 0 0 0 0 11 syscall6 drop
  then 0 pager.address ! 0 pager.capacity ! 0 pager.length ! ;

\ Grow the captured-output mapping without changing its existing bytes.
: pager.grow
  pager.capacity @ dup 0= if drop page.size else 2 * then >r
  0 r@ protection.read.write 34 -1 0 9 syscall6 dup 0 > require
  pager.address @ if
    dup >r pager.address @ r@ pager.length @ move
    pager.address @ pager.capacity @ 0 0 0 0 11 syscall6 drop r> drop
  then pager.address ! r> pager.capacity ! ;

\ Capture a complete stdout byte range and report it as successfully written.
: pager.append ( address length -- written )
  dup >r
  begin pager.length @ r@ + pager.capacity @ > while pager.grow repeat
  pager.address @ pager.length @ + swap move
  r@ pager.length +! r> ;

\ Write directly to stdout without re-entering the TYPE output vector.
: tui.raw ( address length -- )
  begin dup 0 > while
    2dup stdout.write dup syscall.interrupted = if drop else
      dup 0 <= if 2 process.exit then
      >r swap r@ + swap r> -
    then
  repeat 2drop ;

\ Write one raw byte without changing the current frame's text-column count.
: tui.byte ( byte -- ) tui.character ! tui.character 1 tui.raw ;

\ Emit an ANSI sequence only when output is a styled terminal.
: tui.ansi ( address length -- )
  tui.terminal @ tui.disabled @ 0= and if 27 tui.byte tui.raw else 2drop then ;

\ Restore the terminal's default foreground, background and emphasis.
: tui.normal s" (B" tui.ansi s" [0m" tui.ansi ;

\ Clear the terminal screen and place the cursor at the top-left corner.
: clear 27 tui.byte s" [2J" tui.raw 27 tui.byte s" [H" tui.raw ;

\ Select the frame-border accent color.
: tui.accent s" [36m" tui.ansi ;

\ Select a bold title style.
: tui.title s" [1;36m" tui.ansi ;

\ Highlight the currently selected debugger frame.
: tui.selected s" [7m" tui.ansi ;

\ Repeat one raw ASCII character a fixed number of times.
: tui.repeat ( byte count -- )
  begin dup 0 > while over tui.byte 1- repeat 2drop ;

\ Detect terminal output and derive a bounded frame width from its current size.
: tui.measure
  0 tui.size !
  1 terminal.window tui.size 0 0 0 syscall.ioctl syscall6 0= tui.terminal !
  tui.terminal @ if tui.size @ 16 rshift 65535 and else 80 then
  dup 8 < if drop 80 then 240 min 4 - tui.width ! ;

\ Render one DEC line-drawing character, with an ASCII fallback for redirected output.
: tui.glyph ( terminal-character ascii-character -- )
  tui.terminal @ tui.disabled @ 0= and if
    drop s" (0" tui.ansi tui.byte s" (B" tui.ansi
  else nip tui.byte then ;

\ Draw horizontal edges using DEC special graphics on a styled terminal.
: tui.horizontal ( count -- )
  tui.terminal @ tui.disabled @ 0= and if
    s" (0" tui.ansi 113 swap tui.repeat s" (B" tui.ansi
  else 45 swap tui.repeat then ;

\ Draw a separator joined to both vertical edges with left and right tees.
: tui.rule
  tui.accent 116 43 tui.glyph tui.width @ 2 + tui.horizontal
  117 43 tui.glyph tui.normal 10 tui.byte ;

\ Draw the lower-left and lower-right corners of a completed frame.
: tui.bottom
  tui.accent 109 43 tui.glyph tui.width @ 2 + tui.horizontal
  106 43 tui.glyph tui.normal 10 tui.byte ;

\ Write a bounded title as text, without allowing terminal control bytes.
: tui.title.text ( address length -- )
  begin dup while
    over c@ dup 32 127 within 0= if drop 63 then tui.byte
    swap 1+ swap 1-
  repeat 2drop ;

\ Embed a clipped title in the top edge between the proper upper corners.
: tui.top ( title-address title-length -- )
  tui.width @ 2 - min dup >r
  tui.accent 108 43 tui.glyph 1 tui.horizontal 32 tui.byte
  tui.title tui.title.text tui.normal tui.accent 32 tui.byte
  tui.width @ 1- r> - tui.horizontal 107 43 tui.glyph
  tui.normal 10 tui.byte ;

\ Start a framed text row, leaving its content area ready for ordinary TYPE.
: tui.row.begin
  tui.active @ tui.row.active @ 0= and if
    tui.accent 120 124 tui.glyph 32 tui.byte tui.normal
    0 tui.column ! 0 tui.clipped ! 1 tui.row.active !
  then ;

\ Close the current row, padding it to the right border.
: tui.row.end
  tui.row.begin tui.normal
  32 tui.width @ tui.column @ - tui.repeat
  tui.accent 32 tui.byte 120 124 tui.glyph tui.normal 10 tui.byte
  0 tui.row.active ! 0 tui.column ! ;

\ Write a printable byte, wrapping long rows within the frame borders.
: tui.printable ( byte -- )
  tui.row.begin
  tui.column @ tui.width @ >= if
    tui.clip @ if
      drop tui.clipped @ 0= if 8 tui.byte 62 tui.byte 1 tui.clipped ! then ;
    then tui.row.end tui.row.begin
  then
  tui.byte 1 tui.column +! ;

\ Route text through the frame, expanding tabs and rendering controls harmlessly.
\ Frame contents use byte columns; non-ASCII bytes are displayed as question marks.
: tui.write ( address length -- )
  tui.remaining ! tui.text !
  begin tui.remaining @ while
    tui.text @ c@
    dup 10 = if drop tui.row.end else
      dup 9 = if drop
        8 tui.column @ 8 mod - begin dup while 32 tui.printable 1- repeat drop
      else
        dup 32 127 within 0= if drop 63 then tui.printable
      then
    then
    1 tui.text +! -1 tui.remaining +!
  repeat ;

\ Close an open frame and restore ordinary TYPE output.
: tui.frame.end
  tui.active @ if
    tui.row.active @ if tui.row.end then tui.bottom
  then 0 output.vector ! 0 output.image ! 0 tui.active ! 0 tui.row.active ! tui.normal ;

\ Draw a titled frame and route subsequent TYPE/EMIT output into its rows.
\ Frames are sequential; opening another frame closes the preceding one.
: tui.frame.begin ( title-address title-length -- )
  tui.frame.end tui.measure tui.top 1 tui.active ! 0 tui.clip !
  org output.image ! s" tui.write" compiler.xt output.vector ! ;

\ Draw a complete framed text block without changing the terminal input mode.
: tui.frame ( text-address text-length title-address title-length -- )
  tui.frame.begin type tui.frame.end ;

\ Open a styled inspection panel on terminals, or print its plain heading to a pipe.
: tui.panel ( title-address title-length -- )
  tui.measure tui.terminal @ tui.disabled @ 0= and if tui.frame.begin else type cr then ;

\ Close a styled inspection panel; plain redirected output needs no footer.
: tui.panel.end tui.active @ if tui.frame.end then ;

\ Newest saved WHERE view, with each history record held in its own mapped page.
variable where.history

\ Release all navigation history after closing or interrupting a WHERE browser.
: where.history.free
  begin where.history @ dup while
    dup where.saved.previous + @ where.history !
    page.size 0 0 0 0 11 syscall6 drop
  repeat drop ;

\ Abandon interrupted frame output and restore terminal attributes after recovery.
: tui.reset
  pager.release where.history.free
  tui.row.active @ if tui.normal 10 tui.byte then
  0 output.vector ! 0 output.image ! 0 tui.active ! 0 tui.row.active ! tui.normal ;

\ Enable automatic terminal panels for inspection and debugging.
: tui.on 0 tui.disabled ! ;

\ Disable automatic styling, leaving inspection output as ordinary text.
: tui.off tui.frame.end 1 tui.disabled ! ;

\ Call the configured hook with no arguments on initially empty language stacks.
: debug.call
  context debug.image.field + @ context debug.xt.field + @ image.call ;

\ Initialize the debugger's guards and signal stack, then contain hook failures.
\ DEBUG remains zero in this fresh context, preventing recursive hook dispatch.
: debug.run
  stacks.protect signals.install
  s" recovery.resume" compiler.xt org + context recovery.continuation.field + !
  s" debug.call" compiler.xt recovery.enter tui.reset ;

\ Invoke the optional hook after sigreturn, preserving the original fault record.
: debug.dispatch
  DEBUG @ 0= if ; then
  0 context.mapping.size protection.read.write 34 -1 0 9 syscall6
  dup 0 > require debug.context !
  context debug.context @ debug.parent.field + !
  context loader.table.field + @ debug.context @ loader.table.field + !
  tui.disabled @ debug.context @ tui.disabled context - + !
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

\ First source offset in the documented definition currently being displayed.
variable source.window.start

\ Exclusive source offset at the trailing blank line or source-image end.
variable source.window.end

\ Source line containing the selected entry, before including its documentation.
variable source.window.definition

\ Offset used to scan successive source lines for the display boundary.
variable source.window.cursor

\ Return the exclusive end of the selected image's retained source.
: source.image.end source.start debug.owner @ header.source.length + @ + ;

\ Find the start of the source line containing an image-relative offset.
: source.line.begin ( offset -- start )
  begin dup source.start > while
    dup debug.owner @ + 1- c@ 10 = if ; then 1-
  repeat ;

\ Find the newline or source-image end following an image-relative offset.
: source.line.end ( offset -- end )
  begin dup source.image.end < while
    dup debug.owner @ + c@ 10 = if ; then 1+
  repeat ;

\ Skip horizontal whitespace within a bounded source line.
: source.line.trim ( start end -- first end )
  begin 2dup < while
    over debug.owner @ + c@ 32 > if ; then swap 1+ swap
  repeat ;

\ Test whether a source line contains only whitespace.
: source.line.blank? ( start end -- flag ) source.line.trim = ;

\ Test whether a bounded source line begins with a backslash comment.
: source.line.comment? ( start end -- flag )
  source.line.trim 2dup = if 2drop 0 ; then
  drop debug.owner @ + c@ 92 = ;

\ Include contiguous documentation comments immediately before the definition.
: source.window.comments
  begin source.window.start @ source.start > while
    source.window.start @ 1- source.line.begin dup
    source.window.start @ 1- source.line.comment? 0= if drop ; then
    source.window.start !
  repeat ;

\ Select leading documentation and source through the first trailing blank line.
\ This is a text display window; labels and returns do not imply definition ends.
: source.window ( record -- start end )
  entry.source.start + @ source.line.begin dup source.window.definition !
  source.window.start ! source.window.comments
  source.window.definition @ source.window.cursor !
  source.image.end source.window.end !
  begin source.window.cursor @ source.image.end < while
    source.window.cursor @ dup source.line.end
    2dup source.line.blank? if
      drop source.window.end ! source.window.start @ source.window.end @ ;
    then nip dup source.image.end < if 1+ then source.window.cursor !
  repeat source.window.start @ source.window.end @ ;

\ Display the nearest entry's documented source block, ending at a blank line.
: debug.source ( address -- )
  s" Source:" tui.panel
  dup s" Source: " type debug.word cr
  debug.lookup dup 0= if drop s" No source in the known images." type cr tui.panel.end ; then
  source.window over - swap debug.owner @ + swap type cr tui.panel.end ;

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
  tui.active @ if tui.row.begin
    debug.first @ debug.row @ + debug.selected @ =
    debug.selected @ 0 < debug.row @ 17 = and or if tui.selected then
  then
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
  s" Registers and stacks:" tui.panel 1 tui.clip !
  s" Register (hex)       | Data stack (top) | Return stack (RSP) | Word + offset" type cr
  0 debug.row !
  begin debug.row @ 18 < while debug.table.row 1 debug.row +! repeat tui.panel.end
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
  editor.stage @ image.seal
  editor.stage @ editor.image !
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
  then drop number? if ; then drop
  token.address @ token.length @ >float if ; then s" Unknown command word: " input.error ;

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
: bye tui.reset 0 process.exit ;

\ Parse the following name and find it in the active sealed dictionary.
: inspect.named ( "name" -- record )
  token.parse 0= if s" Missing word name: " input.error then
  parser.position @ input.position !
  token.address @ token.length @ editor.find dup 0= if
    drop s" Unknown command word: " input.error
  then editor.current debug.owner ! ;

\ List active dictionary names, including earlier entries retained by redefinition.
: words.list
  s" Dictionary:" tui.panel
  editor.current header.dictionary.root + @ inspect.entry ! 0 inspect.column !
  begin inspect.entry @ while
    editor.current inspect.entry @ + dup
    entry.name.offset + @ editor.current + over entry.name.length + @ type
    space 1 inspect.column +!
    inspect.column @ 4 = if cr 0 inspect.column ! then
    entry.previous + @ inspect.entry !
  repeat inspect.column @ if cr then tui.panel.end ;

\ Print the selected name, its owning image and its source/code offsets.
: inspect.location ( record -- )
  dup entry.name.offset + @ debug.owner @ + over entry.name.length + @ type
  s"   image 0x" type debug.owner @ debug.hex
  s"   code +0x" type dup entry.xt + @ debug.hex.offset
  s"   source +0x" type entry.source.start + @ source.start - debug.hex.offset cr ;

\ Source entry selected for LOCATE, independently of the displayed context window.
variable inspect.selected

\ Native dictionary record of the following definition displayed by LOCATE.
variable inspect.next

\ Offset of the source byte currently being scanned or displayed.
variable inspect.cursor

\ One-based line number associated with the current source cursor.
variable inspect.line

\ Source offset of the start of the current line.
variable inspect.line.start

\ Native address of the spelling being searched by WHERE.
variable inspect.name

\ Byte length of the spelling being searched by WHERE.
variable inspect.length

\ Source offset of the beginning of the current search token.
variable inspect.token

\ Number of source occurrences printed by WHERE.
variable inspect.matches

\ Advance a source cursor while retaining its line number and line start.
: inspect.advance
  debug.owner @ inspect.cursor @ + c@ 10 = if
    1 inspect.line +! inspect.cursor @ 1+ inspect.line.start !
  then 1 inspect.cursor +! ;

\ Initialize source traversal without disturbing the command reader's parser.
: inspect.reset
  source.start inspect.cursor ! source.start inspect.line.start ! 1 inspect.line ! ;

\ Print a source-section offset without assuming an external filename or line number.
: inspect.reference ( offset -- )
  s" +0x" type source.start - debug.hex.offset s"  | " type ;

\ Print the current source line without reading beyond the mapped source span.
: inspect.line.print
  inspect.line.start @ dup
  begin dup source.start debug.owner @ header.source.length + @ + < while
    dup debug.owner @ + c@ 10 = if
      over - swap debug.owner @ + swap type cr ;
    then 1+
  repeat over - swap debug.owner @ + swap type cr ;

\ Advance through one source line within the selected display window.
: inspect.line.next
  begin inspect.cursor @ inspect.limit @ < while
    debug.owner @ inspect.cursor @ + c@ 10 = if inspect.advance ; then
    inspect.advance
  repeat ;

\ Find the end of a search token without consuming its trailing whitespace.
: inspect.token.end
  begin inspect.cursor @ inspect.limit @ < while
    debug.owner @ inspect.cursor @ + c@ 32 <= if ; then
    1 inspect.cursor +!
  repeat ;

\ Display the entry's documentation and source, stopping at the trailing blank line.
: inspect.source ( record -- )
  source.window inspect.limit ! inspect.selected ! inspect.reset
  begin inspect.cursor @ inspect.selected @ < while inspect.advance repeat
  begin inspect.cursor @ inspect.limit @ < while
    inspect.cursor @ dup inspect.reference >r inspect.line.next
    debug.owner @ r@ + inspect.cursor @ r> - type
    debug.owner @ inspect.cursor @ + 1- c@ 10 <> if cr then
  repeat ;

\ Locate a definition together with the immediately preceding and following entries.
\ These source starts delimit a display window, never an executable body extent.
: locate ( "name" -- )
  inspect.named dup inspect.location >r s" Source context:" tui.panel
  r@ entry.previous + @ dup if debug.owner @ + inspect.source cr else drop then
  r@ inspect.source
  0 inspect.next ! debug.owner @ header.dictionary.root + @ inspect.entry !
  begin inspect.entry @ while
    debug.owner @ inspect.entry @ + dup entry.previous + @
    r@ debug.owner @ - = if inspect.next ! 0 inspect.entry ! else
      entry.previous + @ inspect.entry !
    then
  repeat r> drop
  inspect.next @ if cr inspect.next @ inspect.source then tui.panel.end ;

\ Source offset of the occurrence being attributed to a definition.
variable inspect.hit

\ Native record of the nearest preceding source entry, or zero in the preamble.
variable inspect.owner

\ Source start of the nearest preceding entry during occurrence attribution.
variable inspect.owner.start

\ Native record of the next source entry, whose documentation may contain the hit.
variable inspect.following

\ Source start of the next entry during occurrence attribution.
variable inspect.following.start

\ Find the definition containing a source occurrence, including its leading comments.
: inspect.containing ( source-offset -- record|0 )
  inspect.hit ! 0 inspect.owner ! 0 inspect.owner.start ! 0 inspect.following !
  source.image.end inspect.following.start !
  debug.owner @ header.dictionary.root + @ inspect.entry !
  begin inspect.entry @ while
    debug.owner @ inspect.entry @ + dup entry.source.start + @
    dup inspect.hit @ <= if
      dup inspect.owner.start @ > if
        inspect.owner.start ! dup inspect.owner !
      else drop then
    else
      dup inspect.following.start @ < if
        inspect.following.start ! dup inspect.following !
      else drop then
    then entry.previous + @ inspect.entry !
  repeat
  inspect.following @ if
    inspect.following @ source.window drop inspect.hit @ <= if inspect.following @ ; then
  then inspect.owner @ ;

\ Print a definition-relative occurrence reference without external file assumptions.
: inspect.occurrence ( source-offset -- )
  inspect.containing dup if
    dup entry.name.offset + @ debug.owner @ + over entry.name.length + @ type
    entry.source.start + @ inspect.hit @ swap -
    dup 0 < if negate s"  [documentation] -0x" else s" +0x" then type debug.hex.offset
  else drop s" image preamble" type then
  s"   source +0x" type inspect.hit @ source.start - debug.hex.offset s"  | " type ;

\ True while WHERE owns a terminal navigation session.
variable where.interactive

\ True while the occurrence scanner is drawing a visible page.
variable where.rendering

\ Zero-based occurrence selected by Up/Down navigation.
variable where.selected

\ Zero-based first occurrence visible in the current list viewport.
variable where.first

\ Number of occurrence rows available at the current terminal height.
variable where.rows

\ Maximum source-context lines shown below the occurrence list.
variable where.context.rows

\ Image-relative source offset of the selected occurrence.
variable where.offset

\ Source cursor used only to render the selected occurrence's context.
variable where.cursor

\ Number of context lines still available in the source panel.
variable where.remaining

\ Display a matching occurrence only when it belongs to the visible list page.
: where.match
  where.interactive @ if
    inspect.matches @ where.selected @ = if inspect.token @ where.offset ! then
    where.rendering @ 0= if ; then
    inspect.matches @ where.first @ where.first @ where.rows @ + within 0= if ; then
    tui.row.begin
    inspect.matches @ where.selected @ = if tui.selected s" > " else s"   " then type
  then
  inspect.token @ inspect.occurrence inspect.line.print ;

\ Scan source occurrences without changing the command parser or allocating a list.
: where.scan
  inspect.reset 0 inspect.matches ! source.image.end inspect.limit !
  begin inspect.cursor @ inspect.limit @ < while
    debug.owner @ inspect.cursor @ + c@ 32 <= if inspect.advance else
      inspect.cursor @ inspect.token ! inspect.token.end
      inspect.cursor @ inspect.token @ - inspect.length @ = if
        inspect.token @ debug.owner @ + inspect.name @ inspect.length @ bytes.equal? if
          where.match 1 inspect.matches +!
        then
      then
    then
  repeat ;

\ Keep selection and viewport within the current occurrence count.
: where.select ( index -- )
  dup 0 < if drop 0 then inspect.matches @ 1- min where.selected !
  where.selected @ where.first @ < if where.selected @ where.first ! then
  where.selected @ where.first @ where.rows @ + >= if
    where.selected @ where.rows @ - 1+ where.first !
  then ;

\ Display a bounded source excerpt with the selected occurrence's line highlighted.
: where.context
  where.context.rows @ 0= if ; then
  s" Selected source:" tui.panel 1 tui.clip !
  where.offset @ source.line.begin where.cursor !
  2 begin dup while
    where.cursor @ source.start > if where.cursor @ 1- source.line.begin where.cursor ! then
    1-
  repeat drop
  where.context.rows @ where.remaining !
  begin where.remaining @ where.cursor @ source.image.end < and while
    where.cursor @ source.line.end >r tui.row.begin
    where.offset @ where.cursor @ r@ within if tui.selected then
    s" +0x" type where.cursor @ source.start - debug.hex.offset s"  | " type
    debug.owner @ where.cursor @ + r@ where.cursor @ - type cr
    r> dup source.image.end < if 1+ then where.cursor ! -1 where.remaining +!
  repeat tui.panel.end ;

\ Render the occurrence viewport and source context at the current terminal size.
: where.render
  tui.measure tui.size @ 65535 and dup 0= if drop 24 then
  dup 16 >= if 6 else 0 then where.context.rows !
  where.context.rows @ - 8 - dup 1 < if drop 1 then 24 min where.rows !
  where.selected @ where.select
  27 emit s" [H" type 27 emit s" [2J" type
  s" Where: " type inspect.name @ inspect.length @ tui.width @ 32 - dup 0 < if drop 0 then min type
  s"   location " type where.selected @ 1+ u. 47 emit inspect.matches @ u. cr
  s" Source occurrences:" tui.panel 1 tui.clip !
  1 where.rendering ! where.scan 0 where.rendering ! tui.panel.end
  where.context
  s" Up/Down: locations   Enter/q: return" type cr
  s" Right: follow definition   Left: back" type cr ;

\ Save the current query and exact list position before following a definition.
: where.history.push
  0 page.size protection.read.write 34 -1 0 9 syscall6 dup 0 > require >r
  where.history @ r@ where.saved.previous + !
  inspect.name @ r@ where.saved.name + !
  inspect.length @ r@ where.saved.length + !
  where.selected @ r@ where.saved.selected + !
  where.first @ r@ where.saved.first + !
  debug.owner @ r@ where.saved.image + !
  r> where.history ! ;

\ Follow the selected occurrence's containing definition to its source uses.
: where.follow
  where.offset @ inspect.containing dup 0= if drop ; then
  dup entry.name.length + @ inspect.length @ = if
    dup entry.name.offset + @ debug.owner @ + inspect.name @ inspect.length @ bytes.equal? if drop ; then
  then
  >r where.history.push r>
  dup entry.name.offset + @ debug.owner @ + inspect.name !
  entry.name.length + @ inspect.length !
  0 where.selected ! 0 where.first ! where.scan ;

\ Restore the previous query, selection and viewport, releasing its saved record.
: where.back
  where.history @ dup 0= if drop ; then >r
  r@ where.saved.name + @ inspect.name !
  r@ where.saved.length + @ inspect.length !
  r@ where.saved.selected + @ where.selected !
  r@ where.saved.first + @ where.first !
  r@ where.saved.image + @ debug.owner !
  r@ where.saved.previous + @ where.history !
  r> page.size 0 0 0 0 11 syscall6 drop where.scan ;

\ Apply an occurrence-navigation arrow, then redraw the bounded view.
: where.arrow ( key -- )
  dup 65 = if drop where.selected @ 1- where.select where.render ; then
  dup 66 = if drop where.selected @ 1+ where.select where.render ; then
  dup 67 = if drop where.follow where.render ; then
  68 = if where.back where.render then ;

\ Navigate occurrences until Enter, q, Ctrl-D or a lone Escape returns to input.
: where.navigate
  begin
    debug.key
    dup 113 = over 10 = or over 13 = or over 4 = or over -2 = or if drop ; then
    27 = if
      debug.key dup -1 = if drop ; then
      dup 91 = swap 79 = or if
        debug.key where.arrow
      then
    then
  again ;

\ Browse exact source occurrences on a styled terminal, or list them in plain output.
\ Definitions, comments and string text participate; partial-name matches do not.
: where ( "name" -- )
  token.parse 0= if s" Missing word name: " input.error then
  parser.position @ input.position !
  where.history.free token.address @ inspect.name ! token.length @ inspect.length !
  editor.current debug.owner ! 0 where.interactive ! 0 where.rendering !
  0 where.selected ! 0 where.first ! 1 where.rows !
  tui.measure tui.terminal @ tui.disabled @ 0= and
  context debug.terminal.active + @ 0= and if
    debug.terminal.open where.interactive !
  then
  where.scan
  inspect.matches @ 0= if s" No source occurrences." type cr else
    where.interactive @ if where.render where.navigate then
  then
  where.interactive @ if debug.terminal.close then
  0 where.interactive ! tui.panel.end where.history.free ;

\ Print one dump byte as two hexadecimal digits.
: dump.byte ( byte -- ) debug.hex.value ! 2 debug.hex.count ! debug.hex.digits ;

\ Display memory as sixteen-byte rows with hexadecimal addresses and ASCII.
\ Invalid memory is handled by the ordinary signal/debug/QUIT boundary.
: dump.rows ( address length -- )
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

\ Display a memory block in a terminal panel or plain redirected output.
: dump ( address length -- )
  s" Memory:" tui.panel dump.rows tui.panel.end ;

\ Image origin used for code-byte reads and symbolic relative targets.
variable dis.image

\ Image-relative cursor of the next instruction byte.
variable dis.cursor

\ Exclusive code display boundary, not an inferred function end.
variable dis.limit

\ Image-relative address of the current instruction's first byte.
variable dis.start

\ True after a truncated, unsupported or overlong instruction is encountered.
variable dis.bad

\ REX prefix byte, or zero when no REX prefix is present.
variable dis.rex

\ REP prefix byte, or zero when no REP prefix is present.
variable dis.rep

\ Native address of the decoded mnemonic in mapped Forth source.
variable dis.name

\ Length of the decoded mnemonic text.
variable dis.name.length

\ Operand layout selected from the named operand.* constants.
variable dis.form

\ Decoded condition-code suffix, or minus one for an unconditional operation.
variable dis.condition

\ Register operand selected by the ModR/M reg field or opcode low bits.
variable dis.reg

\ Bit width of the explicit register operand.
variable dis.reg.width

\ Register or memory operand width in bits.
variable dis.rm.width

\ ModR/M mode: three means a register operand, otherwise memory addressing.
variable dis.mode

\ ModR/M extension before applying the REX register extension.
variable dis.group

\ Register operand or memory base register; minus one means no base.
variable dis.rm

\ Memory index register, or minus one when absent.
variable dis.index

\ Index scale multiplier decoded from the SIB byte.
variable dis.scale

\ True for an instruction-pointer-relative memory operand.
variable dis.rip

\ Signed memory displacement.
variable dis.displacement

\ Immediate operand or image-relative branch target.
variable dis.immediate

\ Accumulator used for bounded little-endian operand reads.
variable dis.value

\ Current bit shift while reading a little-endian operand.
variable dis.shift

\ Opcode byte retained while selecting its mnemonic and operand form.
variable dis.opcode

\ True for LEA, whose memory operand has no dereference-size qualifier.
variable dis.address.only

\ Cursor used to print the instruction's encoded bytes.
variable dis.print.cursor

\ Set the mnemonic to a string retained in the source image.
: dis.name! ( address length -- ) dis.name.length ! dis.name ! ;

\ Read an instruction byte within both the code window and x86's 15-byte limit.
: dis.byte ( -- byte )
  dis.cursor @ dis.limit @ >= dis.cursor @ dis.start @ - instruction.bytes.max >= or if
    1 dis.bad ! 0 ;
  then dis.image @ dis.cursor @ + c@ 1 dis.cursor +! ;

\ Read an unsigned little-endian operand without reading beyond the code window.
: dis.unsigned ( bytes -- value )
  0 dis.value ! 0 dis.shift !
  begin dup while
    dis.byte dis.shift @ lshift dis.value @ or dis.value !
    8 dis.shift +! 1-
  repeat drop dis.value @ ;

\ Sign-extend a value containing the supplied number of bits.
: dis.signed ( value bits -- signed ) 1 swap 1- lshift tuck xor swap - ;

\ Read a signed four-byte immediate or displacement.
: dis.s32 ( -- value ) 4 dis.unsigned 32 dis.signed ;

\ Decode a SIB byte, retaining its base, optional index and scale.
: dis.sib
  dis.byte dup 6 rshift 1 swap lshift dis.scale !
  dup 3 rshift 7 and dis.rex @ 2 and 2 lshift +
  dup 4 = if drop -1 then dis.index !
  7 and dis.rex @ 1 and 3 lshift + dis.rm !
  dis.mode @ 0= dis.rm @ 7 and 5 = and if -1 dis.rm ! then ;

\ Decode ModR/M and any SIB/displacement emitted by the shared assembler.
: dis.modrm
  dis.byte dup 6 rshift dis.mode !
  dup 3 rshift 7 and dup dis.group ! dis.rex @ 4 and 1 lshift + dis.reg !
  7 and dis.rex @ 1 and 3 lshift + dis.rm !
  dis.mode @ 3 = if ; then
  dis.rm @ 7 and 4 = if dis.sib else
    dis.mode @ 0= dis.rm @ 7 and 5 = and if 1 dis.rip ! -1 dis.rm ! then
  then
  dis.mode @ 1 = if dis.byte 8 dis.signed dis.displacement ! ; then
  dis.mode @ 2 = dis.rm @ -1 = or if dis.s32 dis.displacement ! then ;

\ Select the mnemonic for an ALU opcode group extension.
: dis.alu
  dis.group @ dup 0 = if drop s" add" dis.name! ; then
  dup 1 = if drop s" or" dis.name! ; then
  dup 4 = if drop s" and" dis.name! ; then
  dup 5 = if drop s" sub" dis.name! ; then
  dup 6 = if drop s" xor" dis.name! ; then
  7 = if s" cmp" dis.name! else 1 dis.bad ! then ;

\ Decode scalar SSE loads, arithmetic, comparisons and integer/float conversions.
: dis.scalar ( -- handled )
  dis.rep @ 0= if 0 ; then
  dis.opcode @ dup $10 = over $11 = or over $58 = or over $59 = or
  over $5c = or over $5e = or over $2a = or over $2c = or if
    dis.rep @ $f2 <> if drop 0 ; then
  else
    dup $5a = if dis.rep @ $f2 <> dis.rep @ $f3 <> and if drop 0 ; then else
      dup $2e <> dis.rep @ $66 <> or if drop 0 ; then
    then
  then
  drop dis.modrm 128 dis.reg.width ! 64 dis.rm.width ! operand.reg.rm dis.form !
  dis.opcode @ dup $10 = over $11 = or if
    s" movsd" dis.name! $11 = if operand.rm.reg dis.form ! then
  else
    dup $58 = if drop s" addsd" dis.name! else
    dup $59 = if drop s" mulsd" dis.name! else
    dup $5c = if drop s" subsd" dis.name! else
    dup $5e = if drop s" divsd" dis.name! else
    dup $2a = if drop s" cvtsi2sd" dis.name! else
    dup $2c = if drop s" cvttsd2si" dis.name! 64 dis.reg.width ! else
    $2e = if s" ucomisd" dis.name! else
      dis.rep @ $f3 = if s" cvtss2sd" 32 dis.rm.width ! else s" cvtsd2ss" then dis.name!
    then then then then then then then
  then
  dis.mode @ 3 = if dis.opcode @ $2a <> if 128 dis.rm.width ! then then
  0 dis.rep ! -1 ;

\ Decode the shared assembler's two-byte opcode families.
: dis.extended
  dis.byte dis.opcode ! dis.scalar if ; then
  dis.opcode @ $80 $90 within if
    s" j" dis.name! dis.opcode @ 15 and dis.condition !
    operand.target dis.form ! dis.s32 dis.cursor @ + dis.immediate ! ;
  then
  dis.opcode @ $90 $a0 within if
    s" set" dis.name! dis.opcode @ 15 and dis.condition !
    dis.modrm 8 dis.rm.width ! operand.rm dis.form ! ;
  then
  dis.opcode @ $05 = if s" syscall" dis.name! ; then
  dis.opcode @ $0b = if s" ud2" dis.name! ; then
  dis.opcode @ $af = if s" imul" dis.name! dis.modrm operand.reg.rm dis.form ! ; then
  dis.opcode @ $b6 = if s" movzx" dis.name! dis.modrm 8 dis.rm.width ! operand.reg.rm dis.form ! ; then
  1 dis.bad ! ;

\ Decode immediate ALU operations and register shift groups.
: dis.immediate.group
  dis.modrm operand.rm.immediate dis.form !
  dis.opcode @ $81 = if dis.alu dis.s32 dis.immediate ! ; then
  dis.opcode @ $83 = if dis.alu dis.byte 8 dis.signed dis.immediate ! ; then
  dis.group @ dup 4 = if drop s" shl" dis.name! else
    5 = if s" shr" dis.name! else 1 dis.bad ! then
  then
  dis.opcode @ $c1 = if dis.byte dis.immediate ! else operand.rm.cl dis.form ! then ;

\ Decode F7 arithmetic and FF indirect control-transfer groups.
: dis.register.group
  dis.modrm operand.rm dis.form !
  dis.opcode @ $ff = if
    64 dis.rm.width !
    dis.group @ dup 2 = if drop s" call" dis.name! ; then
    4 = if s" jmp" dis.name! else 1 dis.bad ! then ;
  then
  dis.group @ dup 3 = if drop s" neg" dis.name! ; then
  dup 4 = if drop s" mul" dis.name! ; then
  6 = if s" div" dis.name! else 1 dis.bad ! then ;

\ Decode register/memory moves, address formation and binary ALU operations.
: dis.binary
  dis.modrm operand.rm.reg dis.form !
  dis.opcode @ $89 = if s" mov" dis.name! ; then
  dis.opcode @ $88 = if s" mov" dis.name! 8 dis.reg.width ! 8 dis.rm.width ! ; then
  dis.opcode @ $8b = if s" mov" dis.name! operand.reg.rm dis.form ! ; then
  dis.opcode @ $8d = if s" lea" dis.name! operand.reg.rm dis.form ! 1 dis.address.only ! ; then
  dis.opcode @ $63 = if s" movsxd" dis.name! 32 dis.rm.width ! operand.reg.rm dis.form ! ; then
  dis.opcode @ $01 = if s" add" dis.name! ; then
  dis.opcode @ $09 = if s" or" dis.name! ; then
  dis.opcode @ $21 = if s" and" dis.name! ; then
  dis.opcode @ $29 = if s" sub" dis.name! ; then
  dis.opcode @ $31 = if s" xor" dis.name! ; then
  dis.opcode @ $39 = if s" cmp" dis.name! ; then
  1 dis.bad ! ;

\ Decode a primary opcode, with operands in Intel destination/source order.
: dis.primary
  dis.opcode @ $0f = if dis.extended ; then
  dis.opcode @ $c3 = if s" ret" dis.name! ; then
  dis.opcode @ $cc = if s" int3" dis.name! ; then
  dis.opcode @ $fc = if s" cld" dis.name! ; then
  dis.opcode @ $90 = if s" nop" dis.name! ; then
  dis.opcode @ $a4 = if
    dis.rep @ if s" rep movsb" else s" movsb" then dis.name! ;
  then
  dis.opcode @ $aa = if
    dis.rep @ if s" rep stosb" else s" stosb" then dis.name! ;
  then
  dis.opcode @ $50 $60 within if
    dis.opcode @ $58 < if s" push" else s" pop" then dis.name!
    dis.opcode @ 7 and dis.rex @ 1 and 3 lshift + dis.reg !
    64 dis.reg.width ! operand.reg dis.form ! ;
  then
  dis.opcode @ $b8 $c0 within if
    s" mov" dis.name! dis.opcode @ 7 and dis.rex @ 1 and 3 lshift + dis.reg !
    dis.reg.width @ 8 / dis.unsigned dis.immediate ! operand.reg.immediate dis.form ! ;
  then
  dis.opcode @ $e8 = dis.opcode @ $e9 = or if
    dis.opcode @ $e8 = if s" call" else s" jmp" then dis.name!
    dis.s32 dis.cursor @ + dis.immediate ! operand.target dis.form ! ;
  then
  dis.opcode @ $eb = dis.opcode @ $70 $80 within or if
    dis.opcode @ $eb = if s" jmp" else
      dis.opcode @ 15 and dis.condition ! s" j"
    then dis.name!
    dis.byte 8 dis.signed dis.cursor @ + dis.immediate ! operand.target dis.form ! ;
  then
  dis.opcode @ $81 = dis.opcode @ $83 = or
  dis.opcode @ $c1 = or dis.opcode @ $d3 = or if dis.immediate.group ; then
  dis.opcode @ $f7 = dis.opcode @ $ff = or if dis.register.group ; then
  dis.binary ;

\ Consume optional REX/REP prefixes, bounded by the maximum instruction length.
: dis.prefixes
  begin
    dis.byte dup $40 $50 within if dis.rex ! else
      dup $f3 = over $f2 = or over $66 = or if dis.rep ! else dis.opcode ! ; then
    then
    dis.bad @ if ; then
  again ;

\ Decode one instruction, falling back to one explicit DB byte on invalid input.
: dis.decode
  dis.cursor @ dis.start ! 0 dis.bad ! 0 dis.rex ! 0 dis.rep !
  0 dis.name.length ! operand.none dis.form ! -1 dis.condition !
  -1 dis.index ! 0 dis.rip ! 0 dis.displacement ! 0 dis.address.only !
  dis.prefixes dis.rex @ 8 and if 64 else 32 then
  dup dis.reg.width ! dis.rm.width !
  dis.bad @ 0= if dis.primary then
  dis.rep @ if dis.opcode @ $a4 <> dis.opcode @ $aa <> and if 1 dis.bad ! then then
  dis.bad @ dis.name.length @ 0= or if
    dis.start @ 1+ dis.cursor ! s" db" dis.name! operand.byte dis.form !
    dis.image @ dis.start @ + c@ dis.immediate !
  then ;

\ Trim padding from a fixed-width source-backed name table entry.
: dis.trim ( address length -- address length )
  begin dup while 2dup + 1- c@ 32 <> if ; then 1- repeat ;

\ Render a register at its operand width, including REX low-byte register names.
: dis.register ( number width -- )
  dup 128 = if drop s" xmm" type dup 10 >= if 49 emit 10 - then 48 + emit ; then
  dup 64 = if drop
    s" rax rcx rdx rbx rsp rbp rsi rdi r8  r9  r10 r11 r12 r13 r14 r15 "
  else 32 = if
    s" eax ecx edx ebx esp ebp esi edi r8d r9d r10dr11dr12dr13dr14dr15d"
  else dis.rex @ if
    s" al  cl  dl  bl  spl bpl sil dil r8b r9b r10br11br12br13br14br15b"
  else
    s" al  cl  dl  bl  ah  ch  dh  bh  r8b r9b r10br11br12br13br14br15b"
  then then then
  drop swap 4 * + 4 dis.trim type ;

\ Render an unsigned hexadecimal operand with an explicit radix marker.
: dis.hex ( value -- ) s" 0x" type debug.hex.offset ;

\ Render a signed immediate without obscuring its displacement sign.
: dis.number ( value -- ) dup 0 < if 45 emit negate then dis.hex ;

\ Print a memory operand or register, respecting operand size and SIB addressing.
: dis.operand
  dis.mode @ 3 = if dis.rm @ dis.rm.width @ dis.register ; then
  dis.address.only @ 0= if
    dis.rm.width @ dup 64 = if drop s" qword ptr " else
      32 = if s" dword ptr " else s" byte ptr " then
    then type
  then
  91 emit
  dis.rip @ if s" rip" type else
    dis.rm @ -1 <> if dis.rm @ 64 dis.register then
  then
  dis.index @ -1 <> if
    dis.rm @ -1 <> dis.rip @ or if s"  + " type then
    dis.index @ 64 dis.register
    dis.scale @ 1 <> if 42 emit dis.scale @ u. then
  then
  dis.displacement @ if
    dis.displacement @ 0 < if s"  - " type else
      dis.rm @ -1 <> dis.index @ -1 <> or dis.rip @ or if s"  + " type then
    then dis.displacement @ abs dis.hex
  else dis.rm @ -1 = dis.index @ -1 = and dis.rip @ 0= and if 0 dis.hex then then
  93 emit ;

\ Annotate an image-relative target with the nearest known entry and offset.
: dis.symbol ( offset -- )
  dup dis.image @ + dis.image @ debug.nearest dup if
    s"  <" type dup entry.name.offset + @ dis.image @ + over entry.name.length + @ type
    entry.xt + @ - dup if s" +0x" type debug.hex.offset else drop then 62 emit
  else 2drop then ;

\ Render decoded operands in Intel order without changing the instruction cursor.
: dis.operands
  dis.form @ operand.none = if ; then space
  dis.form @ dup operand.rm.reg = if drop dis.operand s" , " type dis.reg @ dis.reg.width @ dis.register ; then
  dup operand.reg.rm = if drop dis.reg @ dis.reg.width @ dis.register s" , " type dis.operand ; then
  dup operand.rm.immediate = if drop dis.operand s" , " type dis.immediate @ dis.number ; then
  dup operand.rm = if drop dis.operand ; then
  dup operand.reg.immediate = if drop dis.reg @ dis.reg.width @ dis.register s" , " type dis.immediate @ dis.hex ; then
  dup operand.target = if drop dis.immediate @ dup dis.hex dis.symbol ; then
  dup operand.reg = if drop dis.reg @ dis.reg.width @ dis.register ; then
  operand.byte = if dis.immediate @ dis.hex else dis.operand s" , cl" type then ;

\ Display one decoded instruction with image offset, actual bytes and mnemonic.
: dis.print
  s" +0x" type dis.start @ debug.hex.offset s" : " type
  dis.start @ dis.print.cursor !
  begin dis.print.cursor @ dis.cursor @ < while
    dis.image @ dis.print.cursor @ + c@ dump.byte space 1 dis.print.cursor +!
  repeat
  instruction.bytes.max dis.cursor @ dis.start @ - - 3 * debug.spaces
  dis.name @ dis.name.length @ type
  dis.condition @ -1 <> if
    s" o   no  b   ae  e   ne  be  a   s   ns  p   np  l   ge  le  g   " drop
    dis.condition @ 4 * + 4 dis.trim type
  then dis.operands cr ;

\ Dump memory, disassemble code and then display the documented source block.
\ The next greater entry XT is only a display boundary; RET does not stop decoding.
: see.render ( record -- )
  tui.measure tui.terminal @ tui.disabled @ 0= and if
    dup entry.name.offset + @ debug.owner @ + over entry.name.length + @ tui.frame.begin
  then dup inspect.location
  dup entry.xt + @ dis.cursor ! >r
  editor.current dis.image ! dis.image @ header.code.limit + @ dis.limit !
  dis.image @ header.dictionary.root + @ inspect.entry !
  begin inspect.entry @ while
    dis.image @ inspect.entry @ + dup entry.xt + @
    dup dis.cursor @ > over dis.limit @ < and if dis.limit ! else drop then
    entry.previous + @ inspect.entry !
  repeat
  s" Code window +0x" type dis.cursor @ debug.hex.offset
  s"  .. +0x" type dis.limit @ debug.hex.offset s"  (display boundary)" type cr tui.panel.end
  dis.image @ dis.cursor @ + dis.limit @ dis.cursor @ - dump
  s" Disassembly (Intel):" tui.panel
  begin dis.cursor @ dis.limit @ < while dis.decode dis.print repeat
  tui.panel.end dis.image @ debug.owner ! s" Source:" tui.panel r> inspect.source tui.panel.end ;

\ Dictionary record whose inspection output is being paged.
variable pager.record

\ First visible captured line, counted from zero.
variable pager.first

\ Number of newline-terminated rows in the captured output.
variable pager.lines

\ Number of content rows available above pager controls.
variable pager.rows

\ Byte offset used to locate and render the visible captured lines.
variable pager.cursor

\ Remaining lines to skip or display while rendering a page.
variable pager.remaining

\ Terminal column count used when capturing the current layout.
variable pager.width

\ True after the user requests return from the inspection pager.
variable pager.done

\ True when Enter requests leaving nested inspection for the command editor.
variable pager.editor

\ Measure the viewport while reserving terminal rows for controls and the cursor.
: pager.measure
  tui.measure tui.size @ 65535 and dup 0= if drop 24 then
  3 - dup 1 < if drop 1 then pager.rows ! ;

\ Visual column count while locating a wrapped plain-text pager row.
variable pager.column

\ Advance one visible row, including terminal wrapping when styling is disabled.
: pager.next.line
  0 pager.column !
  begin pager.cursor @ pager.length @ < while
    pager.address @ pager.cursor @ + c@ dup 10 = if drop 1 pager.cursor +! ; then
    tui.disabled @ pager.column @ pager.width @ 4 + >= and if drop ; then
    9 = if 8 pager.column @ 8 mod - else 1 then pager.column +!
    1 pager.cursor +!
  repeat ;

\ Capture the selected definition's formatted output and count its display rows.
: pager.capture
  0 pager.length ! 0 pager.lines !
  org output.capture.image ! s" pager.append" compiler.xt output.capture !
  pager.record @ see.render
  0 output.capture ! 0 output.capture.image !
  tui.width @ pager.width ! 0 pager.cursor !
  begin pager.cursor @ pager.length @ < while
    pager.next.line 1 pager.lines +!
  repeat ;

\ Clamp the top row so the final page fills the available content area.
: pager.clamp
  pager.lines @ pager.rows @ - dup 0 < if drop 0 then
  pager.first @ min dup 0 < if drop 0 then pager.first ! ;

\ Render a bounded screenful, preserving terminal borders and title styling.
: pager.render
  pager.measure tui.width @ pager.width @ <> if pager.capture then pager.clamp
  tui.normal 27 tui.byte s" [H" tui.raw 27 tui.byte s" [2J" tui.raw
  0 pager.cursor ! pager.first @ pager.remaining !
  begin pager.remaining @ while pager.next.line -1 pager.remaining +! repeat
  pager.cursor @ >r pager.rows @ pager.remaining !
  begin pager.remaining @ pager.cursor @ pager.length @ < and while
    pager.next.line -1 pager.remaining +!
  repeat
  pager.address @ r@ + pager.cursor @ r> - tui.raw tui.normal
  pager.cursor @ if pager.address @ pager.cursor @ + 1- c@ 10 <> if 13 tui.byte 10 tui.byte then then
  s" Up/Down: line  Left: back  q: quit  Enter: editor" tui.raw
  pager.first @ pager.rows @ + pager.lines @ >= if s"  [end]" tui.raw then ;

\ Move one page forward, returning from the pager when already at its end.
: pager.forward
  pager.first @ pager.rows @ + pager.lines @ >= if 1 pager.done ! ; then
  pager.rows @ pager.first +! ;

\ Handle arrow and Page Up/Down escape sequences without executing input as Forth.
: pager.escape
  debug.key dup -1 = if drop 1 pager.done ! ; then
  dup 91 = swap 79 = or if
    debug.key dup 65 = if drop -1 pager.first +! ; then
    dup 66 = if drop 1 pager.first +! ; then
    dup 68 = if drop 1 pager.done ! ; then
    dup 53 = if drop debug.key 126 = if pager.rows @ negate pager.first +! then ; then
    54 = if debug.key 126 = if pager.forward then then
  then ;

\ Browse captured inspection output until the user exits or advances past the end.
: pager.navigate
  0 pager.done ! pager.render
  begin pager.done @ 0= while
    debug.key dup -1 <> if
      dup 113 = over 4 = or over -2 = or if drop 1 pager.done ! else
        dup 32 = if drop pager.forward else
          dup 98 = if drop pager.rows @ negate pager.first +! else
            dup 10 = over 13 = or if drop 1 pager.editor ! 1 pager.done ! else
              27 = if pager.escape then
            then
          then
        then
      then
      pager.done @ 0= if pager.render then
    else drop then
  repeat
  tui.normal 13 tui.byte 27 tui.byte s" [2K" tui.raw ;

\ Capture and page one definition while the caller owns terminal input settings.
: pager.view
  0 pager.editor ! 0 pager.first ! pager.capture pager.measure
  pager.lines @ pager.rows @ > if pager.navigate else
    pager.address @ pager.length @ tui.raw
  then pager.release ;

\ Keep a browser-selected definition open even when its inspection fits one page.
: pager.browse
  0 pager.editor ! 0 pager.first ! pager.capture pager.navigate pager.release ;

\ Inspect a definition with height-aware paging, independently of TUI styling.
\ Reuse an existing terminal input mode without overwriting its saved settings.
: see ( "name" -- )
  inspect.named pager.record ! tui.measure
  tui.terminal @ if
    context debug.terminal.active + @ if pager.view ; then
    debug.terminal.open if pager.view debug.terminal.close ; then
  then pager.record @ see.render ;

\ Zero-based dictionary entry selected in the WORDS browser.
variable words.selected

\ First dictionary entry visible in the WORDS viewport.
variable words.first

\ Number of dictionary entries available to the browser.
variable words.count

\ Number of dictionary rows fitting the current terminal height.
variable words.rows

\ Native dictionary record selected for inspection.
variable words.record

\ Dictionary-relative link currently being rendered.
variable words.cursor

\ Zero-based index of the dictionary link currently being rendered.
variable words.index

\ Keep the selected dictionary entry inside the current viewport.
: words.select ( index -- )
  dup 0 < if drop 0 then words.count @ 1- min words.selected !
  words.selected @ words.first @ < if words.selected @ words.first ! then
  words.selected @ words.first @ words.rows @ + >= if
    words.selected @ words.rows @ - 1+ words.first !
  then ;

\ Number of bytes in the dictionary browser's substring query.
variable words.query.length

\ True when the last dictionary search found no matching name.
variable words.missing

\ Dictionary link used by the search independently of viewport rendering.
variable words.search.link

\ Dictionary index used while scanning for a matching name.
variable words.search.index

\ Lowest index eligible before wrapping a dictionary search.
variable words.search.start

\ First matching dictionary index, used when the search wraps.
variable words.search.first

\ Test whether a dictionary entry's name contains the current query.
: words.matches ( record -- flag )
  dup entry.name.offset + @ editor.current + swap entry.name.length + @
  words.query.length @ - 1+
  begin dup 0 > while
    over context context.words.query + words.query.length @ bytes.equal? if 2drop -1 ; then
    swap 1+ swap 1-
  repeat 2drop 0 ;

\ Select the next substring match at or after an index, wrapping at dictionary end.
: words.search ( start -- )
  words.search.start ! 0 words.missing !
  words.query.length @ 0= if ; then
  -1 words.search.first ! 0 words.search.index !
  editor.current header.dictionary.root + @ words.search.link !
  begin words.search.link @ while
    editor.current words.search.link @ + dup words.matches if
      words.search.first @ -1 = if words.search.index @ words.search.first ! then
      words.search.index @ words.search.start @ >= if
        drop words.search.index @ words.select ;
      then
    then entry.previous + @ words.search.link ! 1 words.search.index +!
  repeat
  words.search.first @ dup -1 = if drop 1 words.missing ! else words.select then ;

\ Show the editable search query on the browser's final control row.
: words.search.prompt
  13 emit 27 emit s" [2K" type s" / " type
  words.query.length @ tui.width @ 2 - min
  context context.words.query + words.query.length @ + over - swap type ;

\ Read a bounded query; Enter accepts it, Escape cancels, and Backspace edits.
: words.search.edit
  0 words.query.length ! words.search.prompt
  begin
    debug.key
    dup 10 = over 13 = or if drop words.selected @ words.search ; then
    dup 27 = over 4 = or over -2 = or if drop 0 words.query.length ! ; then
    dup 8 = over 127 = or if
      drop words.query.length @ if -1 words.query.length +! then
    else
      dup 32 127 within words.query.length @ words.query.capacity < and if
        context context.words.query + words.query.length @ + c! 1 words.query.length +!
      else drop then
    then words.search.prompt
  again ;

\ Draw a terminal-sized dictionary page and remember the selected record.
: words.render
  tui.measure tui.size @ 65535 and dup 0= if drop 24 then
  6 - dup 1 < if drop 1 then words.rows ! words.selected @ words.select
  tui.normal 27 emit s" [H" type 27 emit s" [2J" type
  s" Words: " type words.selected @ 1+ u. 47 emit words.count @ u. cr
  s" Dictionary:" tui.panel 1 tui.clip !
  editor.current header.dictionary.root + @ words.cursor ! 0 words.index !
  begin words.cursor @ words.index @ words.first @ words.rows @ + < and while
    editor.current words.cursor @ +
    words.index @ words.selected @ = if dup words.record ! then
    words.index @ words.first @ >= if
      tui.row.begin words.index @ words.selected @ = if tui.selected s" > " else s"   " then type
      dup entry.name.offset + @ editor.current + over entry.name.length + @
      tui.width @ 2 - min type cr
    then
    entry.previous + @ words.cursor ! 1 words.index +!
  repeat tui.panel.end
  s" Up/Down: select  Enter/Right: see  q: return" tui.width @ min type cr
  words.missing @ if s" No matching words.  /: search  n: next" else s" /: search  n: next match" then tui.width @ min type ;

\ Inspect the selected dictionary record while retaining the browser viewport.
: words.inspect
  editor.current debug.owner ! words.record @ pager.record ! pager.browse ;

\ Browse entries and inspect the selected record without consuming command input.
: words.navigate
  words.render
  begin
    debug.key dup 113 = over 4 = or over -2 = or if drop ; then
    dup 10 = over 13 = or if
      drop words.inspect pager.editor @ if ; then words.render
    else
    dup 47 = if drop words.search.edit words.render else
    dup 110 = if drop words.selected @ 1+ words.search words.render else
    27 = if
      debug.key dup -1 = if drop ; then
      dup 91 = swap 79 = or if
        debug.key dup 65 = if words.selected @ 1- words.select then
        dup 66 = if words.selected @ 1+ words.select then
        67 = if
          words.inspect
          pager.editor @ if ; then
        then words.render
      then
    then then then then
  again ;

\ List redirected dictionary output or browse a terminal with Enter or Right opening SEE.
\ Preserve terminal ownership and the dictionary viewport across nested inspection.
: words
  tui.measure tui.terminal @ 0= if words.list ; then
  context debug.terminal.active + @ 0= dup if
    debug.terminal.open 0= if drop words.list ; then
  then >r
  0 words.query.length ! 0 words.missing !
  0 words.count ! 0 words.selected ! 0 words.first !
  editor.current header.dictionary.root + @
  begin dup while editor.current + entry.previous + @ 1 words.count +! repeat drop
  words.count @ if words.navigate then
  tui.normal clear r> if debug.terminal.close then ;

\ Return the number of double-precision values on the independent FP stack.
: fdepth context float.sp.field + @ context float.stack.offset + - 8 / ;

\ Discard the top floating-point value, checking the lower guard through a read.
: fdrop f>bits drop ;

\ Duplicate the top floating-point value.
: fdup f>bits dup bits>f bits>f ;

\ Exchange the top two floating-point values.
: fswap f>bits f>bits swap bits>f bits>f ;

\ Copy the second floating-point value to the top.
: fover f>bits f>bits dup >r bits>f bits>f r> bits>f ;

\ Fetch a double-precision value from memory onto the FP stack.
: f@ @ bits>f ;

\ Store the top FP value as a double-precision value in memory.
: f! f>bits swap ! ;

\ Fetch a single-precision value and widen it onto the FP stack.
: sf@ dup c@ over 1+ c@ 8 lshift or over 2 + c@ 16 lshift or
  swap 3 + c@ 24 lshift or ffi.promote bits>f ;

\ Round and store the top FP value as a four-byte single-precision value.
: sf! f>bits ffi.demote swap u32! ;

\ Negate the top FP value, preserving IEEE signed-zero and NaN payload bits.
: fnegate f>bits $8000000000000000 xor bits>f ;

\ Compile an FP literal as immutable IEEE bits followed by a native FP push.
: fliteral f>bits asm.literal s" bits>f" target.xt asm.call ; immediate

\ MIT License
\
\ Copyright (c) 2026 Dave Goehrig
\
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\
\ The above copyright notice and this permission notice shall be included in all
\ copies or substantial portions of the Software.
\
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.

\ Linux ABI classification and placement ported from ~/forth/ffi.f/ffi.f.
\ Integer scalars and struct addresses use the data stack; scalar FP uses the FP stack.
\ Descriptors contain sizes/classes only, never process-specific function pointers.

\ Candidate XT of the library accessor used by subsequent FUNCTION: declarations.
variable ffi.library.xt

\ Source offset of the foreign symbol being declared.
variable ffi.symbol.offset

\ Byte length of the foreign symbol being declared.
variable ffi.symbol.length

\ Number of explicit arguments in the signature being parsed or invoked.
variable ffi.count

\ True after the variadic marker in the signature parser.
variable ffi.variadic

\ Address of the type descriptor currently being classified.
variable ffi.type

\ Current field offset while classifying an aggregate.
variable ffi.size

\ Maximum natural field alignment in the aggregate.
variable ffi.align

\ Size of the field currently being classified.
variable ffi.field.size

\ Eightbyte class of the field currently being classified.
variable ffi.field.class

\ Source cursor used to parse an aggregate specifier.
variable ffi.text

\ Exclusive end of the aggregate specifier being parsed.
variable ffi.end

\ Register counts used while assigning arguments or collecting aggregate returns.
variable ffi.integers

\ Number of SSE registers consumed by the current call or return.
variable ffi.sses

\ Number of outgoing stack argument bytes assigned so far.
variable ffi.stack.bytes

\ Native address of the immutable signature descriptor for this invocation.
variable ffi.signature

\ Native address of the first explicit Forth argument cell.
variable ffi.arguments

\ Number of explicit arguments taken from the data stack.
variable ffi.data.count

\ Number of scalar arguments taken from the floating-point stack.
variable ffi.float.count

\ Next scalar floating-point argument address during placement.
variable ffi.floats

\ Next explicit data-stack argument index during placement.
variable ffi.data.index

\ Native destination of a structure return, or zero for scalar returns.
variable ffi.destination

\ Explicit argument index currently being marshalled.
variable ffi.index

\ Native address of the argument bytes currently being marshalled.
variable ffi.value

\ Eightbyte index currently being classified or transferred.
variable ffi.eightbyte

\ Number of integer registers required for the current aggregate.
variable ffi.need.integer

\ Number of SSE registers required for the current aggregate.
variable ffi.need.sse

\ Offset of the RIP-relative descriptor reference waiting for a compiler fixup.
variable ffi.descriptor.hole

\ Round a nonnegative byte count up to a power-of-two alignment.
: ffi.align.up ( size alignment -- aligned ) 1- tuck + swap -1 xor and ;

\ Return the descriptor parsing buffer; argument count precedes return/argument types.
: ffi.types context ffi.types.offset + ;

\ Read a named field from the current type descriptor.
: ffi.type@ ( offset -- value ) ffi.type @ + @ ;

\ Write a named field in the current type descriptor.
: ffi.type! ( value offset -- ) ffi.type @ + ! ;

\ Read an eightbyte class from the current type descriptor.
: ffi.class ( index -- class ) cells ffi.type.class0 + ffi.type@ ;

\ Return whether the current type consumes one floating-point stack value.
: ffi.fp?
  ffi.type.kind ffi.type@ dup ffi.kind.float = over ffi.kind.double = or
  swap ffi.kind.promoted = or ;

\ Merge SysV eightbyte classes, giving INTEGER precedence over SSE.
: ffi.merge ( old new -- class )
  over 0= if nip ; then dup 0= if drop ; then
  over ffi.class.integer = over ffi.class.integer = or if 2drop ffi.class.integer ; then
  drop ;

\ Classify the eightbyte containing the current field.
: ffi.classify
  ffi.size @ 8 / dup 2 < if
    cells ffi.type @ + ffi.type.class0 + dup @ ffi.field.class @ ffi.merge swap !
  else drop then ;

\ Convert a struct field letter into its natural byte size and SysV class.
: ffi.field ( char -- )
  32 or
  dup 99 = over 98 = or if drop 1 ffi.field.size ! ffi.class.integer ffi.field.class ! ; then
  dup 104 = over 115 = or over 119 = or if drop 2 ffi.field.size ! ffi.class.integer ffi.field.class ! ; then
  dup 105 = if drop 4 ffi.field.size ! ffi.class.integer ffi.field.class ! ; then
  dup 102 = if drop 4 ffi.field.size ! ffi.class.sse ffi.field.class ! ; then
  dup 100 = if drop 8 ffi.field.size ! ffi.class.sse ffi.field.class ! ; then
  dup 108 = over 113 = or over 112 = or over 120 = or require
  drop 8 ffi.field.size ! ffi.class.integer ffi.field.class ! ;

\ Parse the remaining aggregate token as a positive decimal byte size.
: ffi.decimal
  0 ffi.size ! ffi.text @ ffi.end @ < require
  begin ffi.text @ ffi.end @ < while
    ffi.text @ c@ dup 48 58 within require 48 -
    ffi.size @ 10 * + dup ffi.stack.capacity <= require ffi.size !
    1 ffi.text +!
  repeat ffi.size @ 0 > require ;

\ Classify a brace aggregate with numeric, SSE-numeric, or natural field syntax.
: ffi.aggregate
  token.length @ 2 > require
  token.address @ token.length @ + 1- dup c@ 125 = require ffi.end !
  token.address @ 1+ ffi.text !
  ffi.kind.struct ffi.type.kind ffi.type!
  ffi.text @ c@ dup 37 = swap 48 58 within or if
    ffi.class.integer ffi.field.class !
    ffi.text @ c@ 37 = if
      ffi.class.sse ffi.field.class ! 1 ffi.text +!
      ffi.text @ c@ 37 = if 1 ffi.text +! then
    then
    ffi.decimal
    ffi.field.class @ ffi.type.class0 ffi.type!
    ffi.size @ 8 > if ffi.field.class @ ffi.type.class1 ffi.type! then
  else
    0 ffi.size ! 1 ffi.align !
    begin ffi.text @ ffi.end @ < while
      ffi.text @ c@ ffi.field
      ffi.size @ ffi.field.size @ ffi.align.up ffi.size ! ffi.classify
      ffi.field.size @ ffi.size +!
      ffi.field.size @ ffi.align @ > if ffi.field.size @ ffi.align ! then
      1 ffi.text +!
    repeat
    ffi.size @ ffi.align @ ffi.align.up ffi.size !
  then
  ffi.size @ dup 0 > over ffi.stack.capacity <= and require ffi.type.bytes ffi.type!
  ffi.size @ 16 > if ffi.class.memory ffi.type.class0 ffi.type! then ;

\ Classify a scalar or aggregate signature token into the current descriptor.
: ffi.parse.type
  ffi.type @ ffi.type.size erase
  token.address @ c@ 123 = if ffi.aggregate ; then
  8 ffi.type.bytes ffi.type! ffi.kind.integer ffi.type.kind ffi.type!
  ffi.class.integer ffi.type.class0 ffi.type!
  token.address @ c@ 37 = if
    ffi.class.sse ffi.type.class0 ffi.type!
    token.length @ 1 > if token.address @ 1+ c@ 37 = else 0 then if
      ffi.kind.double ffi.type.kind ffi.type!
    else
      ffi.variadic @ if ffi.kind.promoted else 4 ffi.type.bytes ffi.type! ffi.kind.float then
      ffi.type.kind ffi.type!
    then
  then ;

\ Compare the current source token with a literal string.
: ffi.token? ( address length -- flag )
  dup token.length @ <> if 2drop 0 ; then token.address @ swap bytes.equal? ;

\ Parse FUNCTION: stack syntax and retain deterministic type descriptors.
: ffi.parse
  ffi.types ffi.arguments.max 1+ ffi.type.size * 8 + erase
  0 ffi.count ! 0 ffi.variadic !
  token.parse 0 > require s" (" ffi.token? require
  begin
    token.parse 0 > require s" --" ffi.token? 0=
  while
    s" ..." ffi.token? if ffi.variadic @ 0= require 1 ffi.variadic ! else
      ffi.count @ ffi.arguments.max < require
      ffi.types cell+ ffi.count @ 1+ ffi.type.size * + ffi.type !
      ffi.parse.type 1 ffi.count +!
    then
  repeat
  ffi.count @ ffi.types !
  0 ffi.variadic ! ffi.types cell+ ffi.type !
  token.parse 0 > require s" )" ffi.token? if ; then
  ffi.parse.type
  s" int" ffi.token? if ffi.kind.signed ffi.type.kind ffi.type! then
  token.parse 0 > require s" )" ffi.token? require ;

\ Open a library once per invocation context; keep its handle outside image bytes.
: ffi.library ( address length slot -- handle )
  dup @ dup if >r drop 2drop r> ; then
  drop >r rtld.now dlopen dup 0<> require dup r> ! ;

\ Resolve a foreign symbol at call time without saving its address in the image.
: ffi.resolve ( handle address length -- function )
  dlerror 2drop dlsym dup 0<> require ;

\ Compute the current eightbyte's actual size without reading aggregate padding.
: ffi.eightbyte.size ffi.type.bytes ffi.type@ ffi.eightbyte @ 8 * - 8 min ;

\ Copy an argument that is passed wholly on the native C stack.
: ffi.stack
  ffi.type.bytes ffi.type@ 8 ffi.align.up
  dup ffi.stack.bytes @ + ffi.stack.capacity <= require >r
  ffi.value @ context ffi.stack.offset + ffi.stack.bytes @ + ffi.type.bytes ffi.type@ move
  r> ffi.stack.bytes +! ;

\ Copy the current eightbyte into its next INTEGER or SSE argument register slot.
: ffi.register
  ffi.eightbyte @ ffi.class dup ffi.class.none = if drop ; then
  ffi.class.integer = if
    ffi.frame ffi.frame.integer + ffi.integers @ cells + 1 ffi.integers +!
  else
    ffi.frame ffi.frame.sse + ffi.sses @ cells + 1 ffi.sses +!
  then
  ffi.value @ ffi.eightbyte @ 8 * + swap ffi.eightbyte.size move ;

\ Place one scalar or aggregate using the original bridge's all-or-stack rule.
: ffi.assign
  ffi.fp? if
    ffi.floats @ ffi.value ! 8 ffi.floats +!
  else
    ffi.arguments @ ffi.data.index @ cells + ffi.value ! 1 ffi.data.index +!
  then
  ffi.type.kind ffi.type@ ffi.kind.struct = if ffi.value @ @ ffi.value ! then
  ffi.type.kind ffi.type@ dup ffi.kind.float = swap ffi.kind.promoted = or if
    ffi.value @ @ ffi.demote
    ffi.type.kind ffi.type@ ffi.kind.promoted = if ffi.promote then
    ffi.frame ffi.frame.result.sse + !
    ffi.frame ffi.frame.result.sse + ffi.value !
  then
  ffi.type.class0 ffi.type@ ffi.class.memory = if ffi.stack ; then
  0 ffi.need.integer ! 0 ffi.need.sse ! 0 ffi.eightbyte !
  begin ffi.eightbyte @ 8 * ffi.type.bytes ffi.type@ < while
    ffi.eightbyte @ ffi.class dup ffi.class.integer = if 1 ffi.need.integer +! then
    ffi.class.sse = if 1 ffi.need.sse +! then 1 ffi.eightbyte +!
  repeat
  ffi.integers @ ffi.need.integer @ + 6 > ffi.sses @ ffi.need.sse @ + 8 > or if ffi.stack ; then
  0 ffi.eightbyte !
  begin ffi.eightbyte @ 8 * ffi.type.bytes ffi.type@ < while ffi.register 1 ffi.eightbyte +! repeat ;

\ Copy a register-returned aggregate into its supplied destination buffer.
: ffi.return.struct
  ffi.type.class0 ffi.type@ ffi.class.memory = if ; then
  0 ffi.integers ! 0 ffi.sses ! 0 ffi.eightbyte !
  begin ffi.eightbyte @ 8 * ffi.type.bytes ffi.type@ < while
    ffi.eightbyte @ ffi.class ffi.class.integer = if
      ffi.frame ffi.frame.result.integer + ffi.integers @ cells + 1 ffi.integers +!
    else
      ffi.frame ffi.frame.result.sse + ffi.sses @ cells + 1 ffi.sses +!
    then
    ffi.destination @ ffi.eightbyte @ 8 * + ffi.eightbyte.size move
    1 ffi.eightbyte +!
  repeat ;

\ Marshal a typed call using per-context state, then restore the Forth stack shape.
\ C callbacks into Forth are not supported by this non-reentrant invocation frame.
: ffi.invoke ( arguments function descriptor -- result )
  ffi.signature ! ffi.frame ffi.frame.size erase ffi.frame ffi.frame.function + !
  ffi.signature @ @ ffi.count ! 0 ffi.integers ! 0 ffi.sses ! 0 ffi.stack.bytes !
  0 ffi.data.count ! 0 ffi.float.count ! 0 ffi.index ! 0 ffi.data.index !
  begin ffi.index @ ffi.count @ < while
    ffi.signature @ cell+ ffi.index @ 1+ ffi.type.size * + ffi.type !
    ffi.fp? if 1 ffi.float.count +! else 1 ffi.data.count +! then
    1 ffi.index +!
  repeat
  depth ffi.data.count @ >= require fdepth ffi.float.count @ >= require
  context float.sp.field + @ ffi.float.count @ cells - ffi.floats !
  ffi.signature @ cell+ ffi.type ! 0 ffi.destination !
  depth ffi.data.count @ - cells context data.stack.offset + + ffi.arguments !
  ffi.type.kind ffi.type@ ffi.kind.struct = if
    depth ffi.data.count @ 1+ >= require ffi.arguments @ 8 - @ ffi.destination !
    ffi.type.class0 ffi.type@ ffi.class.memory = if
      ffi.destination @ ffi.frame ffi.frame.integer + ! 1 ffi.integers !
    then
  then
  0 ffi.index !
  begin ffi.index @ ffi.count @ < while
    ffi.signature @ cell+ ffi.index @ 1+ ffi.type.size * + ffi.type !
    ffi.assign 1 ffi.index +!
  repeat
  ffi.sses @ ffi.frame ffi.frame.sse.count + !
  ffi.stack.bytes @ 16 ffi.align.up ffi.frame ffi.frame.stack.bytes + !
  ffi.native
  ffi.data.count @ begin dup while >r drop r> 1- repeat drop
  ffi.float.count @ cells negate context float.sp.field + +!
  ffi.signature @ cell+ ffi.type !
  ffi.type.kind ffi.type@ dup ffi.kind.struct = if drop ffi.return.struct ; then
  dup ffi.kind.void = if drop ; then
  dup ffi.kind.float = over ffi.kind.double = or if
    ffi.frame ffi.frame.result.sse + @ swap ffi.kind.float = if ffi.promote then bits>f ;
  then
  ffi.frame ffi.frame.result.integer + @ swap ffi.kind.signed = if c.int then ;

\ Define a source-backed library accessor and select it for following FUNCTION: words.
\ Library handles are cached in context cells, so rebuilt images remain identical.
: library
  1 entry.open entry.xt entry.field @ ffi.library.xt !
  entry.name.offset entry.field @ asm.address entry.name.length entry.field @ asm.literal
  compiler.variables @ asm.variable 8 compiler.variables +!
  compiler.variables @ context.control <= require
  s" ffi.library" target.xt asm.call asm.ret entry.finish ; immediate

\ Define a typed foreign word using the Linux ABI port and source-backed symbol name.
\ Syntax follows SwiftForth: FUNCTION: name ( args -- result ); no trailing semicolon.
: function:
  ffi.library.xt @ 0<> require 1 entry.open
  entry.name.offset entry.field @ ffi.symbol.offset !
  entry.name.length entry.field @ ffi.symbol.length !
  ffi.parse
  ffi.library.xt @ asm.call ffi.symbol.offset @ asm.address ffi.symbol.length @ asm.literal
  s" ffi.resolve" target.xt asm.call
  rax 0 rip.lea, out.size 4 - ffi.descriptor.hole ! asm.push.rax
  s" ffi.invoke" target.xt asm.call asm.ret
  out.size ffi.descriptor.hole @ 4 + - ffi.descriptor.hole @ target.address u32!
  ffi.types ffi.count @ 1+ ffi.type.size * 8 + bytes,
  entry.finish ; immediate

\ Accept the original SwiftForth spelling for library declarations.
: LIBRARY s" library" compiler.xt execute ; immediate

\ Accept the original SwiftForth spelling for typed foreign declarations.
: FUNCTION: s" function:" compiler.xt execute ; immediate

\ Print and consume the top FP value with enough digits to round-trip a double.
: f. ( F: value -- )
  ffi.frame ffi.frame.size erase
  s" snprintf" ffi.service ffi.frame ffi.frame.function + !
  f>bits ffi.frame ffi.frame.sse + ! 1 ffi.frame ffi.frame.sse.count + !
  context context.scratch + ffi.frame ffi.frame.integer + !
  64 ffi.frame ffi.frame.integer + 8 + !
  s" %.17g " c.string dup >r ffi.frame ffi.frame.integer + 16 + !
  ffi.native r> c.string.free
  ffi.frame ffi.frame.result.integer + @ c.int dup 0 64 within require
  context context.scratch + swap type ;

\ Define a context-backed memory cell suitable for F@ and F!.
: fvariable
  4 entry.open compiler.variables @ dup entry.value entry.field ! asm.variable asm.ret
  8 compiler.variables +! compiler.variables @ context.control <= require entry.finish ; immediate

\ Define a word that pushes a source-compiled double on the FP stack.
: fconstant ( F: value -- )
  3 entry.open f>bits dup entry.value entry.field ! asm.literal
  s" bits>f" target.xt asm.call asm.ret entry.finish ; immediate

unit.end

\ Bytes of the ELF launch adapter preceding the canonical image.
12288   constant snapshot.wrapper.size

\ Magic identifying the parent-linked binary snapshot format.
$2050414e53485446 constant snapshot.magic

\ Patch header: magic | parent ID | parent bytes | image bytes | span count.
\ Each following span is: image offset | byte count | replacement bytes.
\ Cells are little-endian 64-bit values; replacement bytes have no padding.
\ Parent ID -1 denotes a root, whose patch contains the full canonical image.
0       constant patch.magic

\ Numeric revision of the parent in this project's snapshot collection.
8       constant patch.parent

\ Exact reconstructed parent extent, or zero for a root.
16      constant patch.before

\ Exact canonical image extent after applying the replacement spans.
24      constant patch.after

\ Number of ordered, nonoverlapping replacement spans.
32      constant patch.count

\ Bytes preceding the first replacement span.
40      constant patch.header

\ Bytes occupied by a span's offset and length cells.
16      constant patch.span

\ Maximum patch allocation: twice image.capacity, including span overhead.
2097152 constant patch.capacity

\ Linux syscall for obtaining the absolute working directory.
79      constant syscall.getcwd

\ Linux syscall for creating an anonymous executable file.
319     constant syscall.memfd

\ Linux syscall for executing an open file descriptor.
322     constant syscall.execveat

\ Close the anonymous executable descriptor after a successful exec.
1       constant memfd.cloexec

\ Resolve an empty exec pathname through the supplied descriptor.
4096    constant execveat.empty.path

\ Linux syscall for enumerating directory entries in their 64-bit layout.
217     constant syscall.getdents

\ Offset of the two-byte record length in a Linux dirent64.
16      constant directory.length.offset

\ Offset of the NUL-terminated filename in a Linux dirent64.
19      constant directory.name.offset

\ Minimum directory record size containing an eight-digit revision and NUL.
28      constant directory.snapshot.minimum

\ Open flags for exclusive, close-on-exec checkpoint files.
524481  constant snapshot.create.flags

\ Open flags for close-on-exec directory descriptors.
589824  constant snapshot.directory.flags

\ Persistent buffer holding current/work/file paths and the ELF adapter.
variable snapshot.buffers

\ Length of the selected checkpoint directory, or zero before the first checkpoint.
variable snapshot.length

\ Length of the candidate directory being written or restored.
variable snapshot.work.length

\ Image whose immutable bytes are currently being persisted.
variable snapshot.image

\ File descriptor currently used by checkpoint I/O, or minus one when closed.
variable snapshot.fd

\ Cursor into a byte range being written to a checkpoint.
variable snapshot.io.address

\ Bytes remaining in the current checkpoint write.
variable snapshot.io.length

\ Numeric child directory suffix currently being attempted.
variable snapshot.serial

\ Return status from the most recent filesystem operation.
variable snapshot.status

\ Bytes read while validating an exact file extent.
variable snapshot.read.length

\ Temporary zero-terminated exec argument naming the validator command.
variable snapshot.command

\ Collection directory for the operation in progress.
variable snapshot.collection.length

\ Parent revision for a save, or minus one for a new root.
variable snapshot.parent.id

\ Reconstructed parent image owned by a save transaction.
variable snapshot.parent.image

\ Reusable input and output patch allocation.
variable snapshot.patch

\ Number of valid bytes in the current patch buffer.
variable snapshot.patch.length

\ Cursor within the patch records being encoded or applied.
variable snapshot.cursor

\ Canonical image reconstructed by the current load operation.
variable snapshot.result

\ Bytes in the image produced by the preceding chain member.
variable snapshot.result.length

\ Reverse-ordered revision chain used during reconstruction.
variable snapshot.chain

\ Number of pending revisions in the reconstruction chain.
variable snapshot.chain.count

\ Revision currently being reconstructed or written.
variable snapshot.id

\ Revision requested by the caller of the loader.
variable snapshot.target.id

\ True only when loading the uncommitted revision being saved.
variable snapshot.pending

\ Offset of the next byte to compare or span to apply.
variable snapshot.offset

\ Length of a replacement span.
variable snapshot.span.length

\ Previous span's end, enforcing ordered nonoverlapping records.
variable snapshot.end

\ Number of replacement records still to apply.
variable snapshot.records

\ Last changed byte plus one when coalescing nearby changes.
variable snapshot.changed.end

\ Anonymous executable descriptor plus one; zero means none is owned.
variable snapshot.memfd


\ Owned description of an explicit snapshot, separate from its canonical image.
variable snapshot.comment.address

\ Bytes in the description captured from the rest of the input line.
variable snapshot.comment.length

\ Allocated array of committed revision IDs for the snapshot browser.
variable snapshots.list

\ Temporary directory-record buffer owned by the browser.
variable snapshots.entries

\ Directory descriptor plus one, or zero when closed.
variable snapshots.fd

\ Number of committed revisions in the browser.
variable snapshots.count

\ Zero-based selected revision in the sorted browser list.
variable snapshots.selected

\ First visible revision in the snapshot viewport.
variable snapshots.first

\ Maximum number of snapshot rows fitting the terminal.
variable snapshots.rows

\ Byte offset of the directory record being scanned.
variable snapshots.cursor

\ Number of valid directory bytes in the current batch.
variable snapshots.bytes

\ Length of the current Linux directory record.
variable snapshots.record.size

\ Revision ID decoded from the current directory name.
variable snapshots.id

\ Index used for sorting or rendering snapshot rows.
variable snapshots.index

\ Return the current checkpoint pathname buffer.
: snapshot.current snapshot.buffers @ ;

\ Return the candidate checkpoint pathname buffer.
: snapshot.work snapshot.buffers @ page.size + ;

\ Return the buffer used to construct a file pathname.
: snapshot.file snapshot.buffers @ page.size 2 * + ;

\ Return the buffer used to generate ELF metadata and native startup code.
: snapshot.wrapper snapshot.buffers @ page.size 3 * + ;

\ Allocate invocation-private path buffers and initialize descriptor state.
: snapshot.init
  snapshot.buffers @ if ; then
  0 page.size 9 * protection.read.write 34 -1 0 9 syscall6 dup 0 > require
  snapshot.buffers ! -1 snapshot.fd ! ;

\ Close the active checkpoint descriptor, including after a failed operation.
: snapshot.close
  snapshot.fd @ 0 >= if snapshot.fd @ 0 0 0 0 0 3 syscall6 drop -1 snapshot.fd ! then ;

\ Abort a filesystem transaction while keeping the previously published image.
: snapshot.fail
  snapshot.close s" Checkpoint I/O failed: " input.error ;

\ Require a successful nonnegative filesystem result and discard it.
: snapshot.ok ( result -- ) 0 < if snapshot.fail then ;

\ Copy a counted path to the candidate buffer and terminate it with NUL.
: snapshot.path! ( address length -- )
  dup 0 > over page.size 64 - < and require dup snapshot.work.length !
  snapshot.work swap move 0 snapshot.work snapshot.work.length @ + c! ;

\ Append a file suffix to the candidate directory in the file pathname buffer.
: snapshot.filename ( suffix length -- )
  snapshot.work snapshot.file snapshot.work.length @ move
  dup >r snapshot.file snapshot.work.length @ + swap move
  0 snapshot.file snapshot.work.length @ + r> + c! ;

\ Create a private directory or accept an already existing directory.
: snapshot.mkdir
  snapshot.work 448 0 0 0 0 83 syscall6 dup -17 = if drop ; then snapshot.ok ;

\ Open a new checkpoint file without overwriting any existing file.
: snapshot.create ( mode -- )
  snapshot.file snapshot.create.flags rot 0 0 0 syscall.open syscall6
  dup 0 < if snapshot.fail then snapshot.fd ! ;

\ Write every requested byte, retrying interrupted and partial writes.
: snapshot.write ( address length -- )
  snapshot.io.length ! snapshot.io.address !
  begin snapshot.io.length @ while
    snapshot.fd @ snapshot.io.address @ snapshot.io.length @ 0 0 0 1 syscall6
    dup syscall.interrupted = if drop else
      dup 0 <= if drop snapshot.fail then
      dup snapshot.io.address +! negate snapshot.io.length +!
    then
  repeat ;

\ Flush a complete file before closing it.
: snapshot.finish
  snapshot.fd @ 0 0 0 0 0 syscall.fsync syscall6 snapshot.ok snapshot.close ;

\ Flush the candidate directory so its file entries survive a crash.
: snapshot.sync.directory
  snapshot.work snapshot.directory.flags 0 0 0 0 syscall.open syscall6
  dup 0 < if snapshot.fail then snapshot.fd ! snapshot.finish ;

\ Read a file into the supplied buffer, rejecting oversized or short required data.
: snapshot.read ( address capacity -- bytes )
  snapshot.io.length ! snapshot.io.address ! 0 snapshot.read.length !
  snapshot.file 524288 0 0 0 0 syscall.open syscall6
  dup 0 < if snapshot.fail then snapshot.fd !
  begin snapshot.read.length @ snapshot.io.length @ < while
    snapshot.fd @ snapshot.io.address @ snapshot.read.length @ +
    snapshot.io.length @ snapshot.read.length @ - 0 0 0 0 syscall6
    dup syscall.interrupted = if drop else
      dup 0 < if snapshot.fail then
      dup 0= if drop snapshot.close snapshot.read.length @ ; then
      snapshot.read.length +!
    then
  repeat
  begin snapshot.fd @ context context.scratch + 128 + 1 0 0 0 0 syscall6
    dup syscall.interrupted <> until
  0= if snapshot.close snapshot.read.length @ ; then snapshot.fail ;

\ Format a fixed-width hexadecimal child number without using the output vector.
: snapshot.number ( number address -- )
  8 + 8 begin dup while
    >r 1- over 15 and dup 10 < if 48 else 87 then + over c!
    swap 4 rshift swap r> 1-
  repeat drop 2drop ;

\ Return the collection pathname retained while visiting its revisions.
: snapshot.collection snapshot.buffers @ page.size 6 * + ;

\ Return a scratch buffer for normalizing the requested pathname.
: snapshot.target snapshot.buffers @ page.size 7 * + ;

\ Return the reserved candidate directory, retained across parent loading.
: snapshot.saved snapshot.buffers @ page.size 8 * + ;

\ Reject malformed snapshots through the ordinary recoverable input boundary.
: snapshot.need ( flag -- )
  0= if s" Invalid snapshot: " input.error then ;

\ Release transaction allocations after success, a compiler error or a signal.
: snapshot.release
  snapshot.close
  snapshot.command @ if snapshot.command @ c.string.free 0 snapshot.command ! then
  snapshot.memfd @ if snapshot.memfd @ 1- 0 0 0 0 0 3 syscall6 drop 0 snapshot.memfd ! then
  snapshot.patch @ if snapshot.patch @ patch.capacity 0 0 0 0 11 syscall6 drop 0 snapshot.patch ! then
  snapshot.chain @ if snapshot.chain @ image.free 0 snapshot.chain ! then
  snapshot.result @ if snapshot.result @ image.free 0 snapshot.result ! then
  snapshot.parent.image @ if snapshot.parent.image @ image.free 0 snapshot.parent.image ! then ;

\ Allocate reusable patch and revision-chain storage for a transaction.
: snapshot.allocate
  snapshot.patch @ 0= if
    0 patch.capacity protection.read.write 34 -1 0 9 syscall6
    dup 0 > snapshot.need snapshot.patch !
  then
  snapshot.chain @ 0= if image.new snapshot.chain ! then ;

\ Read a patch header cell using its named field offset.
: snapshot.field ( field -- value ) snapshot.patch @ + @ ;

\ Store a patch header cell using its named field offset.
: snapshot.field! ( value field -- ) snapshot.patch @ + ! ;

\ Normalize a relative or absolute counted path into the work buffer.
: snapshot.absolute ( address length -- )
  dup 0 > over page.size 128 - < and snapshot.need
  dup >r snapshot.target swap move 0 snapshot.target r@ + c!
  snapshot.target c@ 47 = if snapshot.target r> snapshot.path! ; then
  snapshot.work page.size 128 - 0 0 0 0 syscall.getcwd syscall6 dup 0 > snapshot.need
  1- snapshot.work.length !
  snapshot.work.length @ r@ + 2 + page.size 64 - < snapshot.need
  47 snapshot.work snapshot.work.length @ + c! 1 snapshot.work.length +!
  snapshot.target snapshot.work snapshot.work.length @ + r@ move
  r> snapshot.work.length +! 0 snapshot.work snapshot.work.length @ + c! ;

\ Retain the work pathname as the active collection pathname.
: snapshot.collection!
  snapshot.work snapshot.collection snapshot.work.length @ 1+ move
  snapshot.work.length @ snapshot.collection.length ! ;

\ Select CWD/CWD-NAME.snapshots, creating the project collection when necessary.
: snapshot.project
  snapshot.work page.size 2 / 0 0 0 0 syscall.getcwd syscall6 dup 0 > snapshot.need
  1- snapshot.work.length ! snapshot.work.length @ >r
  snapshot.work.length @ dup 1 = if
    drop s" root" snapshot.target swap move 4
  else
    begin 1- dup snapshot.work + c@ 47 = until 1+
    dup >r snapshot.work + snapshot.target snapshot.work.length @ r> - dup >r move r>
  then
  >r
  snapshot.work.length @ 1 > if 47 snapshot.work snapshot.work.length @ + c! 1 snapshot.work.length +! then
  snapshot.target snapshot.work snapshot.work.length @ + r@ move r> snapshot.work.length +!
  s" .snapshots" snapshot.work snapshot.work.length @ + swap move
  10 snapshot.work.length +! 0 snapshot.work snapshot.work.length @ + c!
  snapshot.mkdir snapshot.collection!
  r> snapshot.work.length ! 0 snapshot.work snapshot.work.length @ + c! snapshot.sync.directory ;

\ Build the pathname of a numbered revision in the retained collection.
: snapshot.node ( revision -- )
  snapshot.collection snapshot.collection.length @ snapshot.path!
  47 snapshot.work snapshot.work.length @ + c!
  snapshot.work snapshot.work.length @ + 1+ snapshot.number
  9 snapshot.work.length +! 0 snapshot.work snapshot.work.length @ + c! ;

\ Parse the final eight hexadecimal pathname characters as a revision ID.
: snapshot.identify
  snapshot.work.length @ 9 > snapshot.need
  snapshot.work snapshot.work.length @ + 9 - c@ 47 = snapshot.need
  0 snapshot.id ! snapshot.work snapshot.work.length @ + 8 - 8
  begin dup while
    >r dup c@ dup 48 >= over 57 <= and if 48 - else
      dup 97 >= over 102 <= and snapshot.need 87 -
    then snapshot.id @ 4 lshift + snapshot.id ! 1+ r> 1-
  repeat 2drop
  -9 snapshot.work.length +! 0 snapshot.work snapshot.work.length @ + c!
  snapshot.collection! snapshot.id @ snapshot.target.id ! ;

\ Read and check one committed patch, permitting only the pending target to lack its marker.
: snapshot.patch.read
  snapshot.id @ snapshot.node
  snapshot.pending @ snapshot.id @ snapshot.target.id @ = and 0= if
    s" /complete" snapshot.filename snapshot.wrapper 8 snapshot.read 8 = snapshot.need
    snapshot.wrapper @ snapshot.magic = snapshot.need
  then
  s" /image.patch" snapshot.filename snapshot.patch @ patch.capacity snapshot.read snapshot.patch.length !
  snapshot.patch.length @ patch.header >= snapshot.need
  patch.magic snapshot.field snapshot.magic = snapshot.need
  patch.after snapshot.field dup source.start >= swap image.capacity <= and snapshot.need
  patch.before snapshot.field dup 0 >= swap image.capacity <= and snapshot.need
  patch.parent snapshot.field dup -1 = swap snapshot.id @ u< or snapshot.need ;

\ Validate canonical extents before any reconstructed image is made executable.
: snapshot.image.check
  snapshot.result @ header.magic + @ image.magic = snapshot.need
  snapshot.result @ header.version + @ image.version = snapshot.need
  snapshot.result @ header.image.size + @ snapshot.result.length @ = snapshot.need
  snapshot.result @ header.source.offset + @ source.start = snapshot.need
  snapshot.result @ header.source.length + @ dup 0 > swap image.capacity source.start - <= and snapshot.need
  snapshot.result @ header.source.length + @ source.start + page.align snapshot.result.length @ = snapshot.need
  snapshot.result @ header.code.limit + @ dup code.start >= swap dictionary.start <= and snapshot.need
  snapshot.result @ header.dictionary.limit + @ dup dictionary.start >= swap source.start <= and snapshot.need
  snapshot.result @ header.start.xt + @ dup code.start >=
  swap snapshot.result @ header.code.limit + @ < and snapshot.need
  snapshot.result @ header.context.limit + @ context.control <= snapshot.need ;

\ Apply checked replacement spans, rejecting overlaps, overflow and trailing bytes.
: snapshot.apply
  patch.before snapshot.field snapshot.result.length @ = snapshot.need
  patch.after snapshot.field snapshot.result.length !
  patch.count snapshot.field dup 0 >= swap snapshot.patch.length @ patch.span / <= and snapshot.need
  patch.count snapshot.field snapshot.records ! patch.header snapshot.cursor ! 0 snapshot.end !
  begin snapshot.records @ while
    snapshot.patch.length @ snapshot.cursor @ - patch.span >= snapshot.need
    snapshot.patch @ snapshot.cursor @ + dup @ snapshot.offset ! cell+ @ snapshot.span.length !
    patch.span snapshot.cursor +!
    snapshot.offset @ snapshot.end @ >= snapshot.need
    snapshot.offset @ snapshot.result.length @ <= snapshot.need
    snapshot.span.length @ 0 > snapshot.need
    snapshot.span.length @ snapshot.result.length @ snapshot.offset @ - <= snapshot.need
    snapshot.span.length @ snapshot.patch.length @ snapshot.cursor @ - <= snapshot.need
    snapshot.patch @ snapshot.cursor @ + snapshot.result @ snapshot.offset @ + snapshot.span.length @ move
    snapshot.span.length @ snapshot.cursor +!
    snapshot.offset @ snapshot.span.length @ + snapshot.end ! -1 snapshot.records +!
  repeat
  snapshot.cursor @ snapshot.patch.length @ = snapshot.need
  snapshot.result @ snapshot.result.length @ + image.capacity snapshot.result.length @ - erase
  snapshot.image.check ;

\ Reconstruct a revision by following parents backwards and applying them forwards.
\ SNAPSHOT.PENDING is private to the save transaction; public callers clear it.
: snapshot.reconstruct ( address length -- )
  snapshot.allocate snapshot.absolute snapshot.identify 0 snapshot.chain.count !
  begin
    snapshot.chain.count @ image.capacity 8 / < snapshot.need
    snapshot.id @ snapshot.chain @ snapshot.chain.count @ cells + ! 1 snapshot.chain.count +!
    snapshot.patch.read patch.parent snapshot.field dup -1 <>
  while snapshot.id ! repeat drop
  snapshot.result @ 0= snapshot.need image.new snapshot.result ! 0 snapshot.result.length !
  -1 snapshot.status !
  begin snapshot.chain.count @ while
    -1 snapshot.chain.count +!
    snapshot.chain @ snapshot.chain.count @ cells + @ snapshot.id ! snapshot.patch.read
    patch.parent snapshot.field snapshot.status @ = snapshot.need
    snapshot.apply snapshot.id @ snapshot.status !
  repeat ;

\ Reconstruct a committed canonical image; the caller owns the returned mapping.
: snapshot.load ( address length -- image )
  snapshot.init 0 snapshot.pending ! snapshot.reconstruct
  snapshot.result @ 0 snapshot.result ! snapshot.release ;

\ Reserve a flat revision directory with an ID greater than its parent.
: snapshot.reserve
  snapshot.parent.id @ 1+ snapshot.serial !
  begin
    snapshot.serial @ $ffffffff <= snapshot.need
    snapshot.serial @ snapshot.node
    snapshot.work 448 0 0 0 0 83 syscall6 dup -17 = if
      drop 1 snapshot.serial +!
    else snapshot.ok snapshot.work snapshot.saved snapshot.work.length @ 1+ move ; then
  again ;

\ Test whether a candidate byte differs from its zero-padded reconstructed parent.
: snapshot.different? ( offset -- flag )
  dup snapshot.image @ + c@ swap
  snapshot.parent.image @ if snapshot.parent.image @ + c@ else drop 0 then <> ;

\ Append one replacement record from the candidate image.
: snapshot.span.write ( offset length -- )
  snapshot.span.length ! snapshot.offset !
  snapshot.cursor @ patch.span + snapshot.span.length @ + patch.capacity <= snapshot.need
  snapshot.offset @ snapshot.patch @ snapshot.cursor @ + !
  snapshot.span.length @ snapshot.patch @ snapshot.cursor @ + cell+ !
  patch.span snapshot.cursor +!
  snapshot.image @ snapshot.offset @ + snapshot.patch @ snapshot.cursor @ + snapshot.span.length @ move
  snapshot.span.length @ snapshot.cursor +!
  1 snapshot.patch @ patch.count + +! ;

\ Encode replacements, coalescing gaps no larger than a record header.
: snapshot.encode
  snapshot.allocate snapshot.patch @ patch.header erase
  snapshot.magic patch.magic snapshot.field! snapshot.parent.id @ patch.parent snapshot.field!
  snapshot.parent.image @ dup if header.image.size + @ then patch.before snapshot.field!
  snapshot.image @ header.image.size + @ patch.after snapshot.field!
  patch.header snapshot.cursor !
  snapshot.parent.id @ -1 = if
    0 patch.after snapshot.field snapshot.span.write
  else
    0 snapshot.offset !
    begin snapshot.offset @ patch.after snapshot.field < while
      snapshot.offset @ snapshot.different? if
        snapshot.offset @ >r snapshot.offset @ 1+ snapshot.changed.end !
        begin
          1 snapshot.offset +!
          snapshot.offset @ patch.after snapshot.field <
          snapshot.offset @ snapshot.changed.end @ - patch.span <= and
        while
          snapshot.offset @ snapshot.different? if snapshot.offset @ 1+ snapshot.changed.end ! then
        repeat
        r> snapshot.offset @ >r
        snapshot.changed.end @ over - snapshot.span.write r> snapshot.offset !
      else 1 snapshot.offset +! then
    repeat
  then snapshot.cursor @ snapshot.patch.length ! ;

unit.end

\ Number of wrapper pages preceding the canonical image.
3       constant elf.pages

\ File and virtual offset of the canonical image.
12288   constant elf.image

\ Offset of the wrapper's executable startup page.
4096    constant elf.code

\ Offset of the writable-then-read-only service table page.
8192    constant elf.imports

\ Offset of the wrapper's dynamic-link records.
8320    constant elf.dynamic

\ Number of 16-byte dynamic-link records, including the terminating null record.
14      constant elf.dynamic.count

\ Number of ELF program-header records.
11      constant elf.program.count

\ Offset of the NUL-terminated Linux interpreter path.
1024    constant elf.interpreter

\ Offset of the imported symbol table, including its null entry.
1280    constant elf.symbols

\ Offset of the dynamic string table.
1536    constant elf.strings

\ Offset of the explicit-addend import relocation table.
1792    constant elf.relocations

\ Offset of the SysV symbol hash table.
2048    constant elf.hash

\ Number of imported functions in loader table order.
6       constant elf.import.count

\ Offset of the libc main trampoline within the ELF wrapper.
4352    constant elf.main

\ Size of one ELF64 program-header record.
56      constant elf.program.size

\ Size of one ELF64 symbol or explicit-addend relocation record.
24      constant elf.record.size

\ Size of the ELF64 file header preceding the program-header table.
64      constant elf.header.size

\ Return the native buffer for generated ELF headers, startup and import slots.
: elf.header snapshot.wrapper ;

\ Current byte length of the ELF dynamic string table.
variable elf.string.length

\ Next import symbol number, excluding the null symbol.
variable elf.symbol.index

\ Current byte offset in the ELF dynamic table.
variable elf.dynamic.cursor

\ Dynamic string-table offset of the libc dependency name.
variable elf.libc.name

\ Dynamic string-table offset of the libdl dependency name.
variable elf.libdl.name

\ Dedicated assembler vector for the OS startup adapter.
variable elf.assembler

\ Capacity cell of the dedicated three-cell assembler vector.
variable elf.assembler.capacity

\ Cursor cell of the dedicated three-cell assembler vector.
variable elf.assembler.cursor

\ Store a cell in the ELF wrapper header.
: elf! elf.header + ! ;

\ Store a four-byte little-endian field in the ELF wrapper header.
: elf32! elf.header + u32! ;

\ Describe a program segment with type, flags, offset, size and alignment.
: elf.segment ( type flags offset length alignment index -- )
  elf.program.size * elf.header.size + >r
  r@ 48 + elf!
  dup r@ 32 + elf! r@ 40 + elf!
  dup r@ 8 + elf! dup r@ 16 + elf! r@ 24 + elf!
  r@ 4 + elf32! r> elf32! ;

\ Append a NUL-terminated dynamic string and return its table-relative offset.
: elf.string ( address length -- offset )
  elf.string.length @ >r
  2dup elf.header elf.strings + r@ + swap move
  nip 1+ elf.string.length +!
  elf.strings elf.string.length @ + elf.relocations <= require r> ;

\ Append one undefined function symbol and its R_X86_64_GLOB_DAT relocation.
: elf.import ( address length -- )
  elf.string
  elf.symbol.index @ elf.record.size * elf.symbols + >r
  r@ elf32! $12 elf.header r> + 4 + c!
  elf.symbol.index @ 1- elf.record.size * elf.relocations + >r
  elf.imports elf.symbol.index @ 1- cells + r@ elf!
  elf.symbol.index @ 32 lshift 6 or r> 8 + elf!
  1 elf.symbol.index +! ;

\ Append one tag/value pair to the bounded ELF dynamic table.
: elf.tag ( tag value -- )
  elf.dynamic.cursor @ >r r@ 8 + elf! r> elf!
  16 elf.dynamic.cursor +! ;

\ Describe libc/libdl dependencies and eager external service relocations.
: elf.link
  1 elf.string.length ! 1 elf.symbol.index !
  s" libc.so.6" elf.string elf.libc.name !
  s" libdl.so.2" elf.string elf.libdl.name !
  s" __libc_start_main" elf.import
  s" dlopen" elf.import s" dlsym" elf.import s" dlclose" elf.import
  s" dlerror" elf.import s" exit" elf.import
  elf.symbol.index @ elf.import.count 1+ = require
  1 elf.hash elf32! elf.symbol.index @ elf.hash 4 + elf32!
  elf.dynamic elf.dynamic.cursor !
  1 elf.libc.name @ elf.tag 1 elf.libdl.name @ elf.tag
  4 elf.hash elf.tag 5 elf.strings elf.tag 6 elf.symbols elf.tag
  7 elf.relocations elf.tag 8 elf.import.count elf.record.size * elf.tag
  9 elf.record.size elf.tag 10 elf.string.length @ elf.tag
  11 elf.record.size elf.tag 21 0 elf.tag 30 8 elf.tag
  $6ffffffb $08000001 elf.tag 0 0 elf.tag
  elf.dynamic.cursor @ elf.dynamic - elf.dynamic.count 16 * = require ;

\ Emit ABI-correct libc initialization and a trampoline to the selected image.
\ The trampoline restores Linux argc/argv layout and passes imports in R15.
: elf.startup
  asm.ctx @ >r elf.assembler >asm
  elf.header elf.image out.init elf.code code.here !
  r9 rdx mov.rr,
  rsi rsp 0 load,
  rdx rsp 8 lea,
  rsp -16 and#,
  rax 0 mov64,
  rax push,
  rsp push,
  rcx 0 mov64,
  r8 0 mov64,
  rdi elf.main rip.lea,
  rax elf.imports loader.start + rip.lea,
  rax rax 0 load,
  rax execute,
  ud2,
  elf.main out.pad
  rsp rsi -8 lea,
  r15 elf.imports rip.lea,
  rax elf.image snapshot.image @ header.start.xt + @ + rip.lea,
  rax jump.reg,
  out.size elf.imports <= require
  r> >asm ;

\ Generate a PIE adapter with a system interpreter, RELRO imports and W^X segments.
: elf.build
  elf.header elf.image erase
  $00010102464c457f 0 elf!
  $00000001003e0003 16 elf!
  elf.code 24 elf! elf.header.size 32 elf!
  elf.program.count 32 lshift $00380040 or 52 elf!
  6 4 elf.header.size elf.program.count elf.program.size * 8 0 elf.segment
  3 4 elf.interpreter 28 1 1 elf.segment
  s" /lib64/ld-linux-x86-64.so.2" elf.header elf.interpreter + swap move
  1 4 0 page.size page.size 2 elf.segment
  1 5 elf.code page.size page.size 3 elf.segment
  1 6 elf.imports page.size page.size 4 elf.segment
  1 4 elf.image code.start page.size 5 elf.segment
  1 5 elf.image code.start + snapshot.image @ header.code.limit + @ page.align code.start - page.size 6 elf.segment
  1 4 snapshot.image @ header.code.limit + @ page.align elf.image +
  snapshot.image @ header.image.size + @ snapshot.image @ header.code.limit + @ page.align - page.size 7 elf.segment
  2 6 elf.dynamic elf.dynamic.count 16 * 8 8 elf.segment
  $6474e551 6 0 0 16 9 elf.segment
  $6474e552 4 elf.imports page.size 1 10 elf.segment
  elf.link elf.startup
  ;

\ Generate the entire ELF adapter from native source for the selected image.
: snapshot.elf elf.build ;

\ Execute the anonymous reconstructed image with the owned command as argv[1].
: snapshot.memory.exec ( -- error )
  snapshot.work context context.scratch + !
  snapshot.command @ context context.scratch + cell+ !
  0 context context.scratch + 16 + ! 0 context context.scratch + 32 + !
  snapshot.memfd @ 1- context context.scratch + 32 + context context.scratch +
  context arguments.vector.field + @ context arguments.count.field + @ cells +
  execveat.empty.path 0 syscall.execveat syscall6 ;

\ Generate an anonymous ELF executable from the reconstructed canonical image.
: snapshot.executable
  snapshot.image @ >r snapshot.result @ snapshot.image ! snapshot.elf
  0 context context.scratch + 32 + !
  context context.scratch + 32 + memfd.cloexec 0 0 0 0 syscall.memfd syscall6
  dup 0 >= snapshot.need dup 1+ snapshot.memfd ! snapshot.fd !
  snapshot.wrapper snapshot.wrapper.size snapshot.write
  snapshot.result @ snapshot.result.length @ snapshot.write
  -1 snapshot.fd ! r> snapshot.image ! ;

\ Require Binary A == Binary B using A's compiler in a fresh native process.
: snapshot.check
  snapshot.executable
  s" verify? 0= 2 and process.exit" c.string snapshot.command !
  0 0 0 0 0 0 57 syscall6 dup 0 < if snapshot.fail then
  dup 0= if
    drop 0 0 0 0 0 0 3 syscall6 drop
    snapshot.memory.exec drop 2 process.exit
  then
  >r begin r@ context context.scratch + 64 + 0 0 0 0 61 syscall6
    dup syscall.interrupted <> until
  r> = snapshot.need snapshot.command @ c.string.free 0 snapshot.command !
  context context.scratch + 64 + @ if s" Snapshot source verification failed: " input.error then ;

\ Write a patch, reconstruct it from disk, verify its compiler and commit last.
: snapshot.persist
  snapshot.reserve snapshot.encode
  s" /image.patch" snapshot.filename 384 snapshot.create
  snapshot.patch @ snapshot.patch.length @ snapshot.write snapshot.finish
  snapshot.parent.image @ if snapshot.parent.image @ image.free 0 snapshot.parent.image ! then
  -1 snapshot.pending ! snapshot.saved dup string.length snapshot.reconstruct
  snapshot.image @ snapshot.result @ image.equal? snapshot.need snapshot.check
  snapshot.comment.length @ if
    s" /comment" snapshot.filename 384 snapshot.create
    snapshot.comment.address @ snapshot.comment.length @ snapshot.write snapshot.finish
  then
  s" /complete" snapshot.filename 384 snapshot.create
  snapshot.magic snapshot.wrapper ! snapshot.wrapper 8 snapshot.write snapshot.finish
  snapshot.sync.directory
  snapshot.collection snapshot.collection.length @ snapshot.path! snapshot.sync.directory
  snapshot.saved dup string.length dup snapshot.length ! 1+ snapshot.current swap move
  snapshot.release ;

\ Save one candidate as a root or as a child of the selected project snapshot.
: snapshot.publish ( image -- )
  >r snapshot.init snapshot.project
  snapshot.length @ snapshot.collection.length @ 9 + = if
    snapshot.current snapshot.collection snapshot.collection.length @ bytes.equal? 0= if 0 snapshot.length ! then
  else 0 snapshot.length ! then
  snapshot.length @ 0= if
    -1 snapshot.parent.id ! r> snapshot.image ! snapshot.persist ;
  then
  0 snapshot.pending ! snapshot.current snapshot.length @ snapshot.reconstruct
  snapshot.result @ snapshot.parent.image ! 0 snapshot.result !
  snapshot.target.id @ snapshot.parent.id !
  r> snapshot.image ! snapshot.persist ;

\ Release an explicit snapshot's owned description after saving or recovery.
: snapshot.comment.release
  snapshot.comment.address @ if snapshot.comment.address @ c.string.free 0 snapshot.comment.address ! then
  0 snapshot.comment.length ! ;

\ Capture the rest of the input line as descriptive text without interpreting it.
: snapshot.comment.parse
  snapshot.comment.release source.space.skip
  parser.length @ parser.position @ - dup page.size 1- <= snapshot.need
  dup snapshot.comment.length ! parser.source @ parser.position @ + swap c.string snapshot.comment.address !
  parser.length @ dup parser.position ! input.position ! ;

\ Save a verified snapshot with the rest of this line as its optional description.
: snapshot
  editor.stage @ 0= require snapshot.comment.parse editor.current snapshot.publish
  snapshot.comment.release s" Snapshot: " type snapshot.current snapshot.length @ type cr ;

\ Save the current system using the original checkpoint command name.
: checkpoint snapshot ;

\ Return the rest of this input line as a pathname and consume it.
: snapshot.path.parse ( -- address length )
  source.space.skip parser.source @ parser.position @ +
  parser.length @ parser.position @ - dup 0 > require
  parser.length @ dup parser.position ! input.position ! ;

\ Write the complete retained source to a new file, without replacing existing files.
: source.write ( address length -- )
  snapshot.init dup page.size 1- < require
  dup >r snapshot.file swap move 0 snapshot.file r> + c!
  384 snapshot.create editor.current source.start +
  editor.current header.source.length + @ snapshot.write snapshot.finish ;

\ File out the source of the currently selected system to the following pathname.
: source.save snapshot.path.parse source.write ;

\ Initialize project snapshot services without retaining runtime state from disk.
: snapshot.boot snapshot.init ;

\ Verify a committed snapshot using its own compiler without adopting it.
: snapshot.verify
  snapshot.path.parse snapshot.init 0 snapshot.pending ! snapshot.reconstruct
  snapshot.check snapshot.release s" Snapshot verification passed." type cr ;

\ Bind a restored image to its disk revision and enter the ordinary editor.
: snapshot.enter
  snapshot.path.parse 0 snapshot.pending ! snapshot.reconstruct
  org snapshot.result @ image.equal? snapshot.need
  snapshot.work snapshot.current snapshot.work.length @ 1+ move
  snapshot.work.length @ snapshot.length ! snapshot.release quit ;

\ Replace this process with the candidate executable, optionally running validation.
\ Native file builds retain this pathname-based launcher independently of snapshots.
: snapshot.exec ( validate -- error )
  if snapshot.command @ else 0 then context context.scratch + cell+ !
  snapshot.file context context.scratch + ! 0 context context.scratch + 16 + !
  snapshot.file context context.scratch +
  context arguments.vector.field + @ context arguments.count.field + @ cells +
  0 0 0 59 syscall6 ;

\ Verify and restore a reconstructed image with fresh variables, stacks and C handles.
: snapshot.restore ( address length -- )
  snapshot.init 0 snapshot.pending ! snapshot.reconstruct snapshot.check
  s" snapshot.enter " snapshot.target swap move
  snapshot.work snapshot.target 15 + snapshot.work.length @ move
  snapshot.target snapshot.work.length @ 15 + c.string snapshot.command !
  snapshot.memory.exec snapshot.ok ;

\ Release directory and browser storage after normal exit or input recovery.
: snapshots.release
  snapshots.fd @ if snapshots.fd @ 1- 0 0 0 0 0 3 syscall6 drop 0 snapshots.fd ! then
  snapshots.entries @ if snapshots.entries @ image.free 0 snapshots.entries ! then
  snapshots.list @ if snapshots.list @ image.free 0 snapshots.list ! then ;

\ Read a revision's commit marker; incomplete or inaccessible revisions are omitted.
: snapshots.complete? ( -- flag )
  s" /complete" snapshot.filename
  snapshot.file 524288 0 0 0 0 syscall.open syscall6 dup 0 < if drop 0 ; then
  snapshot.fd ! snapshot.fd @ snapshot.wrapper 9 0 0 0 0 syscall6
  8 = snapshot.wrapper @ snapshot.magic = and snapshot.close ;

\ Decode exactly eight hexadecimal digits from a directory entry name.
: snapshots.name? ( address -- flag )
  dup 8 + c@ if drop 0 ; then 0 snapshots.id ! 8
  begin dup while
    >r dup c@ dup 48 >= over 57 <= and if 48 - else
      dup 97 >= over 102 <= and 0= if drop drop r> drop 0 ; then 87 -
    then snapshots.id @ 4 lshift + snapshots.id ! 1+ r> 1-
  repeat 2drop -1 ;

\ Insert a committed revision into descending numeric order, newest first.
: snapshots.insert
  snapshots.count @ image.capacity 8 / < snapshot.need
  snapshots.count @ snapshots.index !
  begin snapshots.index @ while
    snapshots.list @ snapshots.index @ 1- cells + @ snapshots.id @ >= if
      snapshots.id @ snapshots.list @ snapshots.index @ cells + ! 1 snapshots.count +! ;
    then
    snapshots.list @ snapshots.index @ 1- cells + @ snapshots.list @ snapshots.index @ cells + !
    -1 snapshots.index +!
  repeat snapshots.id @ snapshots.list @ ! 1 snapshots.count +! ;

\ Collect committed revisions using Linux directory records without a shell.
: snapshots.scan
  snapshot.init snapshot.project image.new snapshots.entries ! image.new snapshots.list !
  0 snapshots.count !
  snapshot.collection snapshot.directory.flags 0 0 0 0 syscall.open syscall6
  dup 0 >= snapshot.need 1+ snapshots.fd !
  begin
    snapshots.fd @ 1- snapshots.entries @ page.size 0 0 0 syscall.getdents syscall6
    dup syscall.interrupted = if drop else
      dup 0 >= snapshot.need dup 0= if drop
        snapshots.fd @ 1- 0 0 0 0 0 3 syscall6 drop 0 snapshots.fd ! ;
      then snapshots.bytes ! 0 snapshots.cursor !
      begin snapshots.cursor @ snapshots.bytes @ < while
        snapshots.bytes @ snapshots.cursor @ - directory.name.offset >= snapshot.need
        snapshots.entries @ snapshots.cursor @ + directory.length.offset +
        dup c@ swap 1+ c@ 8 lshift or snapshots.record.size !
        snapshots.record.size @ directory.name.offset > snapshot.need
        snapshots.record.size @ snapshots.bytes @ snapshots.cursor @ - <= snapshot.need
        snapshots.record.size @ directory.snapshot.minimum >= if
          snapshots.entries @ snapshots.cursor @ + directory.name.offset + snapshots.name? if
            snapshots.id @ snapshot.node snapshots.complete? if snapshots.insert then
          then
        then snapshots.record.size @ snapshots.cursor +!
      repeat
    then
  again ;

\ Read a saved description, returning an empty string when none was supplied.
: snapshots.comment ( -- address length )
  s" /comment" snapshot.filename
  snapshot.file 524288 0 0 0 0 syscall.open syscall6 dup 0 < if drop snapshot.wrapper 0 ; then
  snapshot.fd ! snapshot.fd @ snapshot.wrapper page.size 1- 0 0 0 0 syscall6
  dup 0 >= snapshot.need snapshot.close snapshot.wrapper swap ;

\ Print a single-line description with control characters rendered harmlessly.
: snapshots.text ( address length -- )
  begin dup while
    >r dup c@ dup 32 127 within 0= if drop 63 then emit 1+ r> 1-
  repeat 2drop ;

\ Select a row and keep it in the visible portion of the list.
: snapshots.select ( index -- )
  dup 0 < if drop 0 then snapshots.count @ 1- min snapshots.selected !
  snapshots.selected @ snapshots.first @ < if snapshots.selected @ snapshots.first ! then
  snapshots.selected @ snapshots.first @ snapshots.rows @ + >= if
    snapshots.selected @ snapshots.rows @ - 1+ snapshots.first !
  then ;

\ Display one revision ID and its saved description using the current output vector.
: snapshots.row ( index -- )
  cells snapshots.list @ + @ snapshot.node
  snapshot.work snapshot.work.length @ + 8 - 8 type s"   " type
  snapshots.comment dup if
    tui.active @ if tui.width @ 13 - dup 0 < if drop 0 then min then snapshots.text
  else 2drop s" (no comment)" type then cr ;

\ Draw a bounded snapshot viewport with the selected revision highlighted.
: snapshots.render
  tui.measure tui.size @ 65535 and dup 0= if drop 24 then
  6 - dup 1 < if drop 1 then snapshots.rows ! snapshots.selected @ snapshots.select
  tui.normal clear s" Snapshot " type snapshots.selected @ 1+ u. 47 emit snapshots.count @ u. cr
  s" Snapshots" tui.panel 1 tui.clip ! snapshots.first @ snapshots.index !
  begin snapshots.index @ snapshots.count @ < snapshots.index @ snapshots.first @ snapshots.rows @ + < and while
    tui.row.begin snapshots.index @ snapshots.selected @ = if tui.selected s" > " else s"   " then type
    snapshots.index @ snapshots.row 1 snapshots.index +!
  repeat tui.panel.end
  s" Up/Down: select  Enter: restore  Esc/q: return" tui.width @ min type ;

\ Navigate revisions, returning true only when Enter requests restoration.
: snapshots.navigate ( -- restore? )
  snapshots.render
  begin
    debug.key dup 10 = over 13 = or if drop -1 ; then
    dup 113 = over 4 = or over -2 = or if drop 0 ; then
    27 = if
      debug.key dup -1 = if drop 0 ; then
      dup 91 = swap 79 = or if
        debug.key dup 65 = if snapshots.selected @ 1- snapshots.select then
        66 = if snapshots.selected @ 1+ snapshots.select then snapshots.render
      then
    then
  again ;

\ Browse project snapshots; Enter verifies and restores the selected revision.
\ Redirected output lists all revisions without consuming command input.
: snapshots
  snapshots.scan
  snapshots.count @ 0= if snapshots.release s" No snapshots in this project." type cr ; then
  tui.measure tui.terminal @ if debug.terminal.open else 0 then if
    0 snapshots.selected ! 0 snapshots.first ! snapshots.navigate >r
    snapshots.selected @ cells snapshots.list @ + @ snapshot.node
    snapshot.work snapshot.saved snapshot.work.length @ 1+ move
    tui.normal clear debug.terminal.close snapshots.release
    r> if snapshot.saved dup string.length snapshot.restore then
  else
    0 snapshots.index ! begin snapshots.index @ snapshots.count @ < while
      snapshots.index @ snapshots.row 1 snapshots.index +!
    repeat snapshots.release
  then ;

\ Source file buffer owned by a native replacement build.
variable build.source.buffer

\ Candidate canonical image owned by a native replacement build.
variable build.candidate

\ Execute a build worker in a fresh process and require a successful exit.
\ The executable path is in snapshot.file; the counted text becomes argv[1].
: build.run ( address length -- )
  c.string snapshot.command !
  0 0 0 0 0 0 57 syscall6 dup 0 < if snapshot.fail then
  dup 0= if
    drop 0 0 0 0 0 0 3 syscall6 drop
    -1 snapshot.exec drop 2 0 0 0 0 0 60 syscall6 drop ;
  then
  >r begin r@ context context.scratch + 64 + 0 0 0 0 61 syscall6
    dup syscall.interrupted <> until
  r> = require snapshot.command @ c.string.free 0 snapshot.command !
  context context.scratch + 64 + @ if
    s" Native build worker failed; output was not published." type cr 2 process.exit
  then ;

\ Write the selected canonical image with a freshly generated ELF adapter.
\ The caller supplies a new pathname in snapshot.file; existing files are refused.
: build.executable
  snapshot.elf 448 snapshot.create
  snapshot.wrapper snapshot.wrapper.size snapshot.write
  snapshot.image @ dup header.image.size + @ snapshot.write snapshot.finish ;

\ Save all native build artifacts in the selected empty output directory.
: build.artifacts
  s" /image.bin" snapshot.filename 384 snapshot.create
  snapshot.image @ dup header.image.size + @ snapshot.write snapshot.finish
  s" /code.bin" snapshot.filename 384 snapshot.create
  snapshot.image @ dictionary.start snapshot.write snapshot.finish
  s" /dictionary.bin" snapshot.filename 384 snapshot.create
  snapshot.image @ dictionary.start + source.start dictionary.start - snapshot.write snapshot.finish
  s" /source.bin" snapshot.filename 384 snapshot.create
  snapshot.image @ source.start + snapshot.image @ header.source.length + @ snapshot.write snapshot.finish
  s" /forth" snapshot.filename build.executable snapshot.sync.directory ;

\ Rebuild with the candidate compiler, generate its ELF and validate the result.
\ Invoked in a fresh process so changed variable offsets never share the old context.
: build.finish
  snapshot.path.parse snapshot.path!
  rebuild dup build.candidate ! snapshot.image ! build.artifacts
  s" /forth" snapshot.filename s" selftest" build.run
  build.candidate @ image.free 0 process.exit ;

\ Compile a replacement source file into an empty output directory using native Forth.
\ The first candidate runs a fresh compiler generation before final self-verification.
: build.source ( source-address source-length directory-address directory-length -- )
  snapshot.init snapshot.path!
  dup 0 > over page.size 1- < and require
  dup >r snapshot.file swap move 0 snapshot.file r> + c!
  image.new build.source.buffer !
  build.source.buffer @ image.capacity source.start - snapshot.read
  build.source.buffer @ swap image.new dup build.candidate ! image.build
  build.candidate @ snapshot.image !
  s" /bootstrap" snapshot.filename build.executable
  s" build.finish " snapshot.wrapper swap move
  snapshot.work snapshot.wrapper 13 + snapshot.work.length @ move
  snapshot.wrapper snapshot.work.length @ 13 + build.run
  s" /bootstrap" snapshot.filename snapshot.file 0 0 0 0 0 87 syscall6 snapshot.ok
  snapshot.sync.directory
  build.candidate @ image.free build.source.buffer @ image.free
  s" Native file rebuild and executable verification passed." type cr ;

\ Rebuild the next source filename into the directory occupying the rest of the line.
\ For a source pathname containing spaces, call the counted BUILD.SOURCE interface.
: build.file
  editor.stage @ 0= require
  token.parse 0 > require token.address @ token.length @
  snapshot.path.parse input.position @ input.resume ! build.source ;

\ Restore the following checkpoint directory; the rest of the line is its path.
: restore snapshot.path.parse snapshot.restore ;

\ Restore the parent checkpoint, preserving the abandoned branch on disk.
: undo
  snapshot.length @ 0 > snapshot.need
  0 snapshot.pending ! snapshot.current snapshot.length @ snapshot.reconstruct
  patch.parent snapshot.field dup -1 = if drop snapshot.release s" No parent snapshot: " input.error then
  snapshot.node snapshot.work snapshot.saved snapshot.work.length @ 1+ move
  snapshot.release snapshot.saved dup string.length snapshot.restore ;

\ Display the selected checkpoint path for filesystem browsing or later restoration.
: checkpoint.path
  snapshot.length @ if snapshot.current snapshot.length @ type cr else
    s" No snapshot saved; use snapshot followed by a description." type cr
  then ;

\ Run a counted shell command through libc and return its encoded wait status.
: system ( address length -- status )
  c.string dup >r s" system" ffi.service c.call1 c.int r> c.string.free ;

\ Change the process working directory; return zero on success or minus one.
: chdir ( address length -- status )
  c.string dup >r s" chdir" ffi.service c.call1 c.int r> c.string.free ;

\ Create a directory with the supplied permission bits; return libc's status.
: mkdir ( address length mode -- status )
  >r c.string dup r> swap >r s" mkdir" ffi.service c.call2 c.int r> c.string.free ;

\ Execute the remainder of the input line in the shell, preserving Forth stack depth.
: $
  source.space.skip parser.source @ parser.position @ +
  parser.length @ parser.position @ -
  parser.length @ dup parser.position ! input.position ! system drop ;

\ Owned buffer for the combined source during a transactional file load.
variable source.load.buffer

\ Byte count of the existing source followed by the imported file.
variable source.load.length

\ Data-stack depth before compiling a source import; unbalanced input is rejected.
variable source.load.depth

\ Release an interrupted source import without changing the published dictionary.
: source.load.release
  source.load.buffer @ dup if image.free else drop then 0 source.load.buffer ! ;

\ Compile a file after the complete current source and checkpoint it atomically.
: source.read ( address length -- )
  editor.stage @ 0= require snapshot.init
  dup 0 > over page.size 1- < and require
  dup >r snapshot.file swap move 0 snapshot.file r> + c!
  source.load.release image.new source.load.buffer !
  editor.current header.source.length + @ source.load.length !
  editor.current source.start + source.load.buffer @ source.load.length @ move
  10 source.load.buffer @ source.load.length @ + c! 1 source.load.length +!
  source.load.buffer @ source.load.length @ +
  image.capacity source.start - source.load.length @ - 16 - snapshot.read
  source.load.length +!
  s"

unit.end
" source.load.buffer @ source.load.length @ + swap move
  10 source.load.length +!
  image.new editor.stage ! s" editor.fail" compiler.xt compiler.failure !
  depth source.load.depth !
  source.load.buffer @ source.load.length @ editor.stage @ image.build
  depth source.load.depth @ = require
  editor.stage @ image.seal
  editor.stage @ editor.image ! 0 editor.stage ! 0 compiler.failure ! source.load.release ;

\ Load and compile the following pathname, consuming the rest of the input line.
: source.load
  snapshot.path.parse input.position @ input.resume ! source.read ;
unit.end

\ Display the current checkpoint path without entering an interactive browser.
: checkpoints checkpoint.path ;

\ Unlink a superseded record by offset, leaving code and allocation frontiers intact.
\ Persisted offsets make pruning deterministic when the saved source is recompiled.
: entry.hide ( offset -- )
  dup dictionary.start >= over dictionary.here @ < and require
  dup dictionary.start - /entry mod 0= require
  dup target.address dup entry.name.offset + @ target.address
  swap entry.name.length + @ target.find over <> require
  >r dictionary.root
  begin dup @ while
    dup @ r@ = if r@ target.address entry.previous + @ swap ! r> drop ; then
    @ target.address entry.previous +
  repeat drop r> drop fail ; immediate

\ Immutable census of variable and stack cells captured before pruning analysis.
variable prune.references

\ Writable source buffer containing the old source followed by frozen removals.
variable prune.source

\ Used bytes in the pruning source buffer.
variable prune.length

\ Dictionary record offset currently considered for removal.
variable prune.entry

\ First code offset belonging to the candidate entry.
variable prune.low

\ Next distinct entry point, conservatively bounding candidate code addresses.
variable prune.high

\ Scan cursor shared by the conservative reference checks.
variable prune.cursor

\ Number of superseded records removed by this transaction.
variable prune.count

\ Copy input bytes to the bounded source buffer.
: prune.append ( address length -- )
  dup prune.length @ + image.capacity source.start - < require
  dup >r prune.source @ prune.length @ + swap move r> prune.length +! ;

\ Test an image-relative value against the candidate's conservative code window.
: prune.offset? ( value -- flag ) prune.low @ prune.high @ within ;

\ Recognize offset XTs and pointers into either the current or executing image.
: prune.pointer? ( value -- flag )
  dup prune.offset? if drop -1 ; then
  dup editor.current - prune.offset? swap org - prune.offset? or ;

\ Keep entries whose offsets or addresses remain in captured variables or stacks.
\ Inactive stack cells deliberately count too: uncertainty retains an entry.
: prune.runtime? ( -- flag )
  0 prune.cursor !
  begin prune.cursor @ stack.size 4 * < while
    prune.references @ prune.cursor @ + @ prune.pointer? if -1 ; then
    8 prune.cursor +!
  repeat 0 ;

\ Decode native references; unknown encodings conservatively retain every candidate.
\ Literal XTs, address displacements and branch targets all count as references.
: prune.code? ( -- flag )
  editor.current dis.image ! code.start dis.cursor !
  editor.current header.code.limit + @ dis.limit !
  begin dis.cursor @ dis.limit @ < while
    dis.decode
    dis.bad @ dis.form @ operand.byte = or if -1 ; then
    dis.displacement @ prune.offset? if -1 ; then
    dis.form @ dup operand.target = over operand.reg.immediate = or
    swap operand.rm.immediate = or if
      dis.immediate @ prune.pointer? if -1 ; then
    then
  repeat 0 ;

\ Find the next distinct entry point; shared entry points retain their records.
: prune.window? ( -- unique )
  editor.current header.code.limit + @ prune.high !
  dictionary.start prune.cursor !
  begin prune.cursor @ editor.current header.dictionary.limit + @ < while
    prune.cursor @ prune.entry @ <> if
      editor.current prune.cursor @ + entry.xt + @
      dup prune.low @ = if drop 0 ; then
      dup prune.low @ > if prune.high @ min prune.high ! else drop then
    then
    /entry prune.cursor +!
  repeat -1 ;

\ Retain installed kernel entries, immediates, visible words and referenced entries.
: prune.eligible? ( -- flag )
  prune.entry @ s" snapshot.boot" compiler.find org - <= if 0 ; then
  editor.current prune.entry @ +
  dup entry.flags + @ flag.immediate and if drop 0 ; then
  dup entry.name.offset + @ editor.current + over entry.name.length + @
  editor.current header.dictionary.root + @ editor.current swap dictionary.find
  over = if drop 0 ; then
  entry.xt + @ prune.low !
  prune.window? 0= if 0 ; then
  prune.runtime? if 0 ; then prune.code? 0= ;

\ Append one documented, fixed-offset removal to the replayable source.
: prune.record
  s"

\ Remove an unreferenced superseded dictionary record; retain its code and source.
$" prune.append
  prune.entry @ prune.source @ prune.length @ + snapshot.number
  8 prune.length +! s"  entry.hide
unit.end
" prune.append 1 prune.count +! ;

\ Prune superseded unreferenced editor entries in the running dictionary.
\ This removes lookup records, not executable bytes, source history or old images.
: prune
  editor.stage @ 0= require
  image.new prune.references !
  context prune.references @ context.guard.offset move
  context data.stack.offset + prune.references @ stack.size + stack.size move
  context return.stack.offset + prune.references @ stack.size 2 * + stack.size move
  context native.stack.offset + prune.references @ stack.size 3 * + stack.size move
  image.new prune.source ! 0 prune.length ! 0 prune.count !
  editor.current source.start + editor.current header.source.length + @ prune.append
  editor.current header.dictionary.root + @ prune.entry !
  begin prune.entry @ while
    prune.eligible? if prune.record then
    editor.current prune.entry @ + entry.previous + @ prune.entry !
  repeat
  prune.references @ image.free 0 prune.references !
  prune.count @ if
    image.new editor.stage !
    prune.source @ prune.length @ editor.stage @ image.build
    editor.stage @ image.seal
    editor.stage @ editor.image ! 0 editor.stage !
  then
  prune.source @ image.free 0 prune.source !
  prune.count @ . s" superseded dictionary entries pruned." type cr ;

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
    stacks.reset tui.reset debug.terminal.close history.draft.free fault. debug.dispatch editor.cancel source.load.release snapshot.release snapshot.comment.release snapshots.release stacks.reset ;
  then drop
  context input.error.field + @ dup if input.status ! tui.reset debug.terminal.close editor.cancel source.load.release snapshot.release snapshot.comment.release snapshots.release ; then drop
  context quit.request.field + @ if tui.reset debug.terminal.close editor.cancel source.load.release snapshot.release snapshot.comment.release snapshots.release then
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

\ Change a checkpointed FP value before raising a deliberate debugger trap.
: test.float.fault 9 s>f f+ trap ;

\ Verify that a native recovery checkpoint restores FP contents and depth.
: test.float.recovery
  2 s>f s" test.float.fault" compiler.xt recovery.run signal.trap = require
  2 s>f f= require fdepth 0= require ;

\ Run the acceptance suite as a terminal action outside the command boundary.
: selftest
  0 context recovery.active.field + !
  test.float.recovery
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
  test.layout stacks.protect signals.install snapshot.boot
  command.run ;
unit.end
