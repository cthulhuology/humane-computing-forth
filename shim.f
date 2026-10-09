\ SwiftForth seed cross-compiler. Target implementation lives in forth.f.
\ No host addresses, SwiftForth XTs, timestamps or host dictionary enter output.
\ This shim understands the small source grammar used to define its successor.
8 1 cells <> abort" this seed adapter requires 64-bit SwiftForth"
decimal
variable output
variable src
variable source.length
variable pos
variable tok
variable token.length
variable token.start
variable reader.action
variable dictionary.here
variable root
variable seed.current
variable label.start
variable variables.end
variable controls
create control.stack 1024 allot
variable num
variable radix
variable number.sign
variable digit.position
variable find.address
variable find.length
variable find.entry
variable string.start

\ Report the failing seed source token and throw a bootstrap error.
: bad cr ." shim: source error at byte " token.start @ .
  tok @ token.length @ type cr -1 throw ;

\ Throw a bootstrap error when the supplied condition is false.
: insist 0= if bad then ;

\ Read the canonical forth.f source into host memory.
: source.read
  s" forth.f" r/o bin open-file throw >r r@ file-size throw
  0<> abort" source too large" dup source.length ! allocate throw src !
  src @ source.length @ r@ read-file throw source.length @ <> abort" short source read"
  r> close-file throw ;

\ Select private host bindings while evaluating shared target source sections.

\ Private SwiftForth wordlist for the shared native assembler bindings.
wordlist constant assembler.words

get-order assembler.words swap 1+ set-order
assembler.words set-current

\ Add numeric displacements while evaluating native CODE operands.
: + + ;

\ Translate a shared assembler check failure into a host-catchable exception.
: require 0= if -4100 throw then ;

\ Select the seed's temporary assembler output context.
create assembler.output 3 cells allot

variable section.cursor
variable section.remaining
variable section.next
variable section.end.name
variable section.end.length

\ Evaluate lines without keeping reader state on the host compilation stack.
: lines.evaluate ( addr length -- )
  section.remaining ! section.cursor !
  begin section.remaining @ while
    section.cursor @ section.remaining @ 10 scan
    dup if 1- then section.next !
    section.cursor @ tuck - evaluate
    section.remaining @ section.next @ - section.cursor +!
    section.next @ section.remaining !
  repeat ;

\ Evaluate a marked section directly from the canonical mapped source text.
: section.evaluate ( begin-name begin-length end-name end-length -- )
  section.end.length ! section.end.name !
  dup >r src @ source.length @ 2swap search insist r> /string over >r
  section.end.name @ section.end.length @ search insist drop
  r> tuck - lines.evaluate ;

source.read
s" HOST-LAYOUT-BEGIN" s" HOST-LAYOUT-END" section.evaluate
s" HOST-ASSEMBLER-BEGIN" s" HOST-ASSEMBLER-END" section.evaluate

variable test.buffer
variable test.output

\ Reject an invalid register through the selected assembler context.
: test.invalid.register ( -- ) 16 0 mov.rr, ;

\ Reject a branch beyond the signed 32-bit displacement range.
: test.branch.overflow ( -- ) 2147483648 out.size 5 + + call, ;

\ Reject output beyond the selected buffer capacity.
: test.output.overflow ( -- ) out.capacity code.here ! 0 byte, ;

\ Run shared encoding checks and verify assembler errors preserve selection.
: test.assembler
  asm.ctx @ >r
  64 allocate throw test.buffer ! 3 cells allocate throw test.output !
  test.output @ >asm test.buffer @ assembler.check
  ['] test.invalid.register catch -4100 = insist
  out.reset ['] test.branch.overflow catch -4100 = insist
  out.reset ['] test.output.overflow catch -4100 = insist
  asm.ctx @ test.output @ = insist
  r> >asm
  test.output @ free throw test.buffer @ free throw ;

\ Resolve a target image offset against the seed output buffer.
: dst output @ + ;

\ Push a target code offset onto the bounded seed control stack.
: control+ controls @ 128 < insist controls @ cells control.stack + ! 1 controls +! ;

\ Pop a target code offset or reject control.stack underflow.
: control- controls @ 0 > insist -1 controls +! controls @ cells control.stack + @ ;

\ Return whether the seed parser has reached the source end.
: source.end? pos @ source.length @ >= ;

\ Fetch the byte at the seed parser's current source position.
: source.byte src @ pos @ + c@ ;

\ Advance the seed parser by one byte.
: source.next 1 pos +! ;

\ Skip source bytes whose values are at most ASCII space.
: source.space.skip begin source.end? 0= while source.byte 32 > if exit then source.next repeat ;

\ Read a whitespace-delimited token and record its source position.
: token.parse source.space.skip pos @ dup token.start ! src @ + tok !
  begin source.end? 0= while source.byte 32 <= if
    pos @ token.start @ - dup token.length ! source.next exit then source.next
  repeat pos @ token.start @ - dup token.length ! ;

\ Skip source through a newline or the source end.
: source.line.skip begin source.end? 0= while source.byte 10 = if source.next exit then source.next repeat ;

\ Skip source through a closing parenthesis or reject an unterminated comment.
: source.comment.skip begin source.end? 0= while source.byte 41 = if source.next exit then source.next repeat bad ;

\ Convert an ASCII decimal or hexadecimal digit, returning minus one on failure.
: source.digit dup 48 58 within if 48 - exit then
  dup 65 71 within if 55 - exit then dup 97 103 within if 87 - exit then drop -1 ;

\ Parse the current seed token as a signed decimal or hexadecimal literal.
: source.number? 0 num ! 10 radix ! 1 number.sign ! 0 digit.position !
  tok @ c@ 45 = if -1 number.sign ! 1 digit.position ! then
  tok @ digit.position @ + c@ 36 = if 16 radix ! 1 digit.position +! then
  digit.position @ token.length @ >= if 0 0 exit then
  begin digit.position @ token.length @ < while
    tok @ digit.position @ + c@ source.digit dup 0 < over radix @ >= or if drop 0 0 exit then
    num @ radix @ * + num ! 1 digit.position +!
  repeat num @ number.sign @ * -1 ;

\ Resolve a entry.field offset in the current seed dictionary entry.
\ Same entry layout as forth.f; output @ is the seed image native base.
: entry.field ( field-offset -- native-address ) seed.current @ + dst ;

\ Clear the seed entry cursor without inferring a definition end.
: entry.release 0 seed.current ! ;

\ Parse a source name and create a target entry at the current code position.
: entry.open entry.release token.start @ label.start ! token.parse 0 > insist
  dictionary.here @ /entry + source.start <= insist
  dictionary.here @ seed.current ! root @ entry.previous entry.field ! code.here @ entry.xt entry.field !
  token.length @ entry.name.length entry.field ! label.start @ source.start + entry.source.start entry.field ! entry.kind entry.field !
  token.start @ source.start + entry.name.offset entry.field ! seed.current @ root ! /entry dictionary.here +! ;

\ Require resolved control flow and release the seed entry cursor.
: entry.finish controls @ 0= insist entry.release ;

\ Search the seed image's source-backed dictionary for a target entry offset.
: target.find find.length ! find.address ! root @ find.entry !
  begin find.entry @ while
    find.entry @ dst dup entry.name.length + @ find.length @ = if
      dup entry.name.offset + @ dst find.length @ find.address @ find.length @ compare 0= if drop find.entry @ exit then
    then entry.previous + @ find.entry !
  repeat 0 ;

\ Find a target word's image-relative XT or reject an unknown name.
: target.xt target.find dup 0<> insist dst entry.xt + @ ;

\ Parse a quoted string and emit its target source address and length.
: source.string, pos @ string.start !
  begin source.end? 0= while source.byte 34 = if
    string.start @ source.start + asm.address
    pos @ string.start @ - asm.literal source.next exit
  then source.next repeat bad ;

\ Compile a quoted string followed by the target output operation.
: source.print, source.string, s" type" target.xt asm.call ;

\ Host execution bindings for the bootstrap vocabulary. These are SwiftForth
\ dictionary entries, not a string dispatch chain. No host XT enters the image.

\ Private SwiftForth wordlist for bootstrap compiler actions.
wordlist constant seed.words

\ Create a host dictionary binding for a bootstrap word's action and flags.
: seed: ( host-xt flags "name" -- )
  get-current >r seed.words set-current create swap , , r> set-current ;

\ Look up the current token in the host bootstrap vocabulary.
: seed.find ( -- binding|0 )
  tok @ token.length @ seed.words search-wordlist if execute else 0 then ;

\ Compile an ordinary target call or asm.literal rejecting unbound immediates.
: word,
  tok @ token.length @ target.find dup if
    dst dup entry.flags + @ flag.immediate and 0= insist
    entry.xt + @ asm.call exit
  then drop
  source.number? insist asm.literal ;

\ Execute a seed binding or leave a parsed literal on the host data stack.
: word.interpret
  seed.find dup if @ execute exit then drop source.number? insist ;

\ Read a CODE token using seed execution bindings and numeric literals.
: word.assemble
  tok @ token.length @ assembler.words search-wordlist if execute exit then
  source.number? insist ;

\ Create a target entry and select the compiling reader.
: action.colon 1 entry.open ['] word, reader.action ! ;

\ Create a target entry and select the assembly reader.
: action.code 2 entry.open ['] word.assemble reader.action ! ;

\ Check control flow, release the entry, and restore the interpreting reader.
: action.end entry.finish ['] word.interpret reader.action ! ;

\ Create a target word that pushes the supplied constant value.
: action.constant ( value -- )
  3 entry.open dup entry.value entry.field ! asm.literal asm.ret entry.finish ;

\ Create a target word that addresses a fresh mutable context cell.
: action.variable
  4 entry.open variables.end @ dup entry.value entry.field ! asm.variable asm.ret
  8 variables.end +! variables.end @ context.control <= insist entry.finish ;

\ Mark the newest target dictionary entry for compile-time execution.
: action.immediate root @ dst entry.flags + dup @ flag.immediate or swap ! ;

\ Replay a recorded dictionary unlink while preserving all code and source bytes.
: action.hide ( offset -- )
  dup dictionary.start >= over dictionary.here @ < and insist
  dup dictionary.start - /entry mod 0= insist
  dup dst dup entry.name.offset + @ dst swap entry.name.length + @
  target.find over <> insist
  >r root begin dup @ while
    dup @ r@ = if r@ dst entry.previous + @ swap ! r> drop exit then
    @ dst entry.previous +
  repeat drop r> drop bad ;

\ Emit a native return without ending the target source region.
: action.return asm.ret ;

\ Emit a conditional branch and save its destination hole.
: action.if asm.if control+ ;

\ Emit an alternative branch and resolve the preceding false path.
: action.else control- asm.jump.hole control+ asm.patch ;

\ Resolve the latest conditional branch to the current target position.
: action.then control- asm.patch ;

\ Save the current target code position as a loop entry.
: action.begin code.here @ control+ ;

\ Emit an unconditional branch to the saved loop entry.
: action.again control- asm.jump ;

\ Emit a backward loop branch on a false flag.
: action.until control- asm.until ;

\ Emit a loop back-edge and resolve the saved conditional exit.
: action.repeat control- control- asm.jump asm.patch ;
' action.colon flag.immediate seed: :
' action.code flag.immediate seed: code
' action.end flag.immediate seed: code.end
' action.end flag.immediate seed: unit.end
' action.constant flag.immediate seed: constant
' action.variable flag.immediate seed: variable
' action.immediate flag.immediate seed: immediate
' action.hide flag.immediate seed: entry.hide
' action.return flag.immediate seed: ;
' action.if flag.immediate seed: if
' action.else flag.immediate seed: else
' action.then flag.immediate seed: then
' action.begin flag.immediate seed: begin
' action.again flag.immediate seed: again
' action.until flag.immediate seed: until
' action.if flag.immediate seed: while
' action.repeat flag.immediate seed: repeat
' source.string, flag.immediate seed: s"
' source.print, flag.immediate seed: ."
' source.line.skip flag.immediate seed: \
' source.comment.skip flag.immediate seed: (
' c, 0 seed: c,

\ Execute a seed immediate or pass the token to the selected reader.
: token.process
  seed.find dup if
    dup cell+ @ flag.immediate and if @ execute exit then
  then drop reader.action @ execute ;

\ Store a value at a named target image-header offset.
: header! dst ! ;

\ Write canonical image metadata and target entry-point offsets.
: image.finish
  image.magic header.magic header! image.version header.version header!
  source.length @ source.start + page.size 1- + page.size negate and header.image.size header!
  code.here @ header.code.limit header! dictionary.here @ header.dictionary.limit header! root @ header.dictionary.root header!
  source.start header.source.offset header! source.length @ header.source.length header!
  s" main" target.xt header.main.xt header! variables.end @ header.context.limit header!
  s" kernel.start" target.xt header.start.xt header! s" rebuild" target.xt header.rebuild.xt header! ;

\ Allocate the seed image and compile the complete source into it.
: image.compile
  image.capacity allocate throw output ! output @ image.capacity erase
  src @ source.start dst source.length @ move
  assembler.output >asm output @ dictionary.start out.init
  code.start code.here ! dictionary.start dictionary.here ! context.variables variables.end !
  0 pos ! ['] word.interpret reader.action ! 0 root ! 0 seed.current ! 0 controls !
  begin token.parse while token.process repeat controls @ 0= insist entry.release
  reader.action @ ['] word.assemble <> insist image.finish ;

\ Write a byte range to a named binary file.
: save ( addr len name len -- ) w/o bin create-file throw >r
  r@ write-file throw r> close-file throw ;

\ ELF packaging is the host OS adapter; canonical image bytes are never relocated.
\ The system loader resolves services in a separate RELRO page before kernel entry.

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

\ Host buffer containing ELF headers, startup code and loader service slots.
create elf.header elf.pages page.size * allot

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
create elf.assembler 3 cells allot

\ Round an ELF segment boundary up to the image page size.
: page.align page.size 1- + page.size negate and ;

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
  elf.strings elf.string.length @ + elf.relocations <= insist r> ;

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
  elf.symbol.index @ elf.import.count 1+ = insist
  1 elf.hash elf32! elf.symbol.index @ elf.hash 4 + elf32!
  elf.dynamic elf.dynamic.cursor !
  1 elf.libc.name @ elf.tag 1 elf.libdl.name @ elf.tag
  4 elf.hash elf.tag 5 elf.strings elf.tag 6 elf.symbols elf.tag
  7 elf.relocations elf.tag 8 elf.import.count elf.record.size * elf.tag
  9 elf.record.size elf.tag 10 elf.string.length @ elf.tag
  11 elf.record.size elf.tag 21 0 elf.tag 30 8 elf.tag
  $6ffffffb $08000001 elf.tag 0 0 elf.tag
  elf.dynamic.cursor @ elf.dynamic - elf.dynamic.count 16 * = insist ;

\ Emit ABI-correct libc initialization and a trampoline to the unchanged image.
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
  rax elf.image header.start.xt dst @ + rip.lea,
  rax jump.reg,
  out.size elf.imports <= insist
  r> >asm ;

\ Write a PIE executable with a system interpreter, RELRO imports and W^X segments.
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
  1 5 elf.image code.start + header.code.limit dst @ page.align code.start - page.size 6 elf.segment
  1 4 header.code.limit dst @ page.align elf.image +
  header.image.size dst @ header.code.limit dst @ page.align - page.size 7 elf.segment
  2 6 elf.dynamic elf.dynamic.count 16 * 8 8 elf.segment
  $6474e551 6 0 0 16 9 elf.segment
  $6474e552 4 elf.imports page.size 1 10 elf.segment
  elf.link elf.startup
  s" selfhost/build/forth" w/o bin create-file throw >r
  elf.header elf.image r@ write-file throw
  output @ header.image.size dst @ r@ write-file throw r> close-file throw ;

\ Compile the initial image and save the executable and all split artifacts.
: bootstrap
  test.assembler image.compile
  output @ header.image.size dst @ s" selfhost/build/image.bin" save
  output @ dictionary.start s" selfhost/build/code.bin" save
  dictionary.start dst source.start dictionary.start - s" selfhost/build/dictionary.bin" save
  source.start dst source.length @ s" selfhost/build/source.bin" save
  elf.build
  ." SwiftForth seed: " code.here @ code.start - . ." code bytes; "
  dictionary.here @ dictionary.start - /entry / . ." words; " source.length @ . ." source bytes" cr ;
bootstrap
bye
