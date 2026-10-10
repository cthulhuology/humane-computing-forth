humane computing forth
----------------------

humane computing forth is a proof of concept forth implementation whose goals
are aligned with the https://humanecomputing.org manifesto.

* pausable
* binary mapped one-to-one with source
* causal end to end
* bounded for one mind
* explicit state
* replayable and resumable
* alive

h.c.forth is written from scratch in forth and initially bootstrapped from
SwiftForth using a small cross compiling shim.f which generated the initial
binary.  Unlike most programming environment, h.c.forth embeds it's full 
source in the executable itself, and by verifies it can reproduce it's own
build from it's own source.  You can check for yourself by running:

    ./forth verify

The above command tells h.c.forth to run the word verify.  You can see the
implementation of this word using:

    ./forth see verify 

This will generate the following text:

![
    verify  image 0x0000563A06D99000  code +0x7D55  source +0x12ADF
    Code window +0x7D55 .. +0x7DD5 (display boundary)
    Memory:
    0000563A06DA0D55: E8 D7 FF FF FF E8 7A 93 FF FF 48 8B 45 F8 48 81 |......z...H.E.H.|
    0000563A06DA0D65: ED 08 00 00 00 48 81 F8 00 00 00 00 0F 84 2C 00 |.....H........,.|
    0000563A06DA0D75: 00 00 48 8D 83 08 2B 07 00 48 89 45 00 48 81 C5 |..H...+..H.E.H..|
    0000563A06DA0D85: 08 00 00 00 48 B8 30 00 00 00 00 00 00 00 48 89 |....H.0.......H.|
    0000563A06DA0D95: 45 00 48 81 C5 08 00 00 00 E9 27 00 00 00 48 8D |E.H.......'...H.|
    0000563A06DA0DA5: 83 46 2B 07 00 48 89 45 00 48 81 C5 08 00 00 00 |.F+..H.E.H......|
    0000563A06DA0DB5: 48 B8 2B 00 00 00 00 00 00 00 48 89 45 00 48 81 |H.+.......H.E.H.|
    0000563A06DA0DC5: C5 08 00 00 00 E8 0C B4 FF FF E8 68 B5 FF FF C3 |...........h....|
    Disassembly (Intel):
    +0x7D55: E8 D7 FF FF FF                               call 0x7D31 <verify?>
    +0x7D5A: E8 7A 93 FF FF                               call 0x10D9 <dup>
    +0x7D5F: 48 8B 45 F8                                  mov rax, qword ptr [rbp - 0x8]
    +0x7D63: 48 81 ED 08 00 00 00                         sub rbp, 0x8
    +0x7D6A: 48 81 F8 00 00 00 00                         cmp rax, 0x0
    +0x7D71: 0F 84 2C 00 00 00                            je 0x7DA3 <verify+0x4E>
    +0x7D77: 48 8D 83 08 2B 07 00                         lea rax, [rbx + 0x72B08]
    +0x7D7E: 48 89 45 00                                  mov qword ptr [rbp], rax
    +0x7D82: 48 81 C5 08 00 00 00                         add rbp, 0x8
    +0x7D89: 48 B8 30 00 00 00 00 00 00 00                mov rax, 0x30
    +0x7D93: 48 89 45 00                                  mov qword ptr [rbp], rax
    +0x7D97: 48 81 C5 08 00 00 00                         add rbp, 0x8
    +0x7D9E: E9 27 00 00 00                               jmp 0x7DCA <verify+0x75>
    +0x7DA3: 48 8D 83 46 2B 07 00                         lea rax, [rbx + 0x72B46]
    +0x7DAA: 48 89 45 00                                  mov qword ptr [rbp], rax
    +0x7DAE: 48 81 C5 08 00 00 00                         add rbp, 0x8
    +0x7DB5: 48 B8 2B 00 00 00 00 00 00 00                mov rax, 0x2B
    +0x7DBF: 48 89 45 00                                  mov qword ptr [rbp], rax
    +0x7DC3: 48 81 C5 08 00 00 00                         add rbp, 0x8
    +0x7DCA: E8 0C B4 FF FF                               call 0x31DB <type>
    +0x7DCF: E8 68 B5 FF FF                               call 0x333C <cr>
    +0x7DD4: C3                                           ret
    Source:
    +0x12A8E | \ Report whether native self-compilation reproduces the executing image exactly.
    +0x12ADF | : verify ( -- flag )
    +0x12AF4 |   verify? dup if s" Verification passed: rebuilt image is identical." else
    +0x12B3F |     s" Verification FAILED: rebuilt image differs."
    +0x12B73 |   then type cr ;
](verify.png)

The word "see" dumps a full machine code & source trace displaying where the code is in memory, 
dumps the content of memory for the machine code segment, disassembles the machine code to 
Intel assembler dereferencing for words, and displaying the source code that generated that code. 

You can find the source code to a word incontext using "locate" for example "locate verify?" will
display:

![
verify?  image 0x0000556C19F94000  code +0x7D31  source +0x12A47
Source context:
+0x12941 | \ Compile the executing image's mapped source into a new image.
+0x12981 | : rebuild ( -- candidate-image )
+0x129A2 |   image.new >r org source.start + org header.source.length + @ r@ image.build r> ;

+0x129F6 | \ Silently rebuild, compare with the executing image, and release the candidate.
+0x12A47 | : verify? ( -- flag ) rebuild dup >r org image.equal? r> image.free ;

+0x12A8E | \ Report whether native self-compilation reproduces the executing image exactly.
+0x12ADF | : verify ( -- flag )
+0x12AF4 |   verify? dup if s" Verification passed: rebuilt image is identical." else
+0x12B3F |     s" Verification FAILED: rebuilt image differs."
+0x12B73 |   then type cr ;
](locate.png)

To find all the locations a word is refrenced in the system you can use the command "where" to
find them.  For example "where verify?" will display the following interface:

![
verify?+0x2  source +0x12A49 | : verify? ( -- flag ) rebuild dup >r org image.equal? r> image.free ;
verify+0x17  source +0x12AF6 |   verify? dup if s" Verification passed: rebuilt image is identical." else
snapshot.check+0x2C  source +0x3847F |   s" verify? 0= 2 and process.exit" c.string snapshot.command !
](where.png)

To see all the words in the system you can use the "words" browser to navigate.  It also supports search!

![

Dictionary:
main selftest test.float.recovery test.float.fault 
test.debug.foreign test.debug.clean test.debug.fault command.run 
quit.loop input.run input.cycle prune 
prune.record prune.eligible? prune.window? prune.code? 
prune.runtime? prune.pointer? prune.offset? prune.append 
prune.count prune.cursor prune.high prune.low 
prune.entry prune.length prune.source prune.references 
entry.hide checkpoints source.load source.read 
source.load.release source.load.depth source.load.length source.load.buffer 
$ mkdir chdir system 
checkpoint.path undo restore build.file 
build.source build.finish build.artifacts build.executable 
build.run build.candidate build.source.buffer snapshots 
snapshots.navigate snapshots.render snapshots.row snapshots.select 
snapshots.text snapshots.comment snapshots.scan snapshots.insert 
snapshots.name? snapshots.complete? snapshots.release snapshot.restore 
snapshot.exec snapshot.enter snapshot.verify snapshot.boot 
source.save source.write path.parse checkpoint 
snapshot snapshot.comment.parse snapshot.comment.release snapshot.publish 
snapshot.persist snapshot.check snapshot.executable snapshot.memory.exec 
snapshot.elf elf.build elf.startup elf.link 
elf.tag elf.import elf.string elf.segment 
elf32! elf! elf.assembler.cursor elf.assembler.capacity 
elf.assembler elf.libdl.name elf.libc.name elf.dynamic.cursor 
elf.symbol.index elf.string.length elf.header elf.header.size 
elf.record.size elf.program.size elf.main elf.import.count 
elf.hash elf.relocations elf.strings elf.symbols 
elf.interpreter elf.program.count elf.dynamic.count elf.dynamic 
elf.imports elf.code elf.image elf.pages 
snapshot.encode snapshot.span.write snapshot.different? snapshot.reserve 
snapshot.load snapshot.reconstruct snapshot.apply snapshot.image.check 
snapshot.patch.read snapshot.identify snapshot.node snapshot.project 
snapshot.collection! snapshot.absolute snapshot.field! snapshot.field 
snapshot.allocate snapshot.release snapshot.need snapshot.saved 
snapshot.target snapshot.collection snapshot.number snapshot.read 
snapshot.sync.directory snapshot.finish snapshot.write snapshot.create 
snapshot.mkdir snapshot.filename snapshot.path! snapshot.ok 
snapshot.fail snapshot.close snapshot.init snapshot.wrapper 
snapshot.file snapshot.work snapshot.current snapshots.index 
snapshots.id snapshots.record.size snapshots.bytes snapshots.cursor 
snapshots.rows snapshots.first snapshots.selected snapshots.count 
snapshots.fd snapshots.entries snapshots.list snapshot.comment.length 
snapshot.comment.address snapshot.memfd snapshot.changed.end snapshot.records 
snapshot.end snapshot.span.length snapshot.offset snapshot.pending 
snapshot.target.id snapshot.id snapshot.chain.count snapshot.chain 
snapshot.result.length snapshot.result snapshot.cursor snapshot.patch.length 
snapshot.patch snapshot.parent.image snapshot.parent.id snapshot.collection.length 
snapshot.command snapshot.read.length snapshot.status snapshot.serial 
snapshot.io.length snapshot.io.address snapshot.fd snapshot.image 
snapshot.work.length snapshot.length snapshot.buffers snapshot.directory.flags 
snapshot.create.flags directory.snapshot.minimum directory.name.offset directory.length.offset 
syscall.getdents execveat.empty.path memfd.cloexec syscall.execveat 
syscall.memfd syscall.getcwd patch.capacity patch.span 
patch.header patch.count patch.after patch.before 
patch.parent patch.magic snapshot.magic snapshot.wrapper.size 
fconstant fvariable f. FUNCTION: 
LIBRARY function: library ffi.invoke 
ffi.return.struct ffi.assign ffi.register ffi.stack 
ffi.eightbyte.size ffi.resolve ffi.library ffi.parse 
ffi.token? ffi.parse.type ffi.aggregate ffi.decimal 
ffi.field ffi.classify ffi.merge ffi.fp? 
ffi.class ffi.type! ffi.type@ ffi.types 
ffi.align.up ffi.descriptor.hole ffi.need.sse ffi.need.integer 
ffi.eightbyte ffi.value ffi.index ffi.destination 
ffi.data.index ffi.floats ffi.float.count ffi.data.count 
ffi.arguments ffi.signature ffi.stack.bytes ffi.sses 
ffi.integers ffi.end ffi.text ffi.field.class 
ffi.field.size ffi.align ffi.size ffi.type 
ffi.variadic ffi.count ffi.symbol.length ffi.symbol.offset 
ffi.library.xt fliteral fnegate sf! 
sf@ f! f@ fover 
fswap fdup fdrop fdepth 
words words.navigate words.inspect words.render 
words.search.edit words.search.prompt words.search words.matches 
words.search.first words.search.start words.search.index words.search.link 
words.missing words.query.length words.select words.index 
words.cursor words.record words.rows words.count 
words.first words.selected see pager.browse 
pager.view pager.navigate pager.escape pager.forward 
pager.render pager.clamp pager.capture pager.next.line 
pager.column pager.measure pager.editor pager.done 
pager.width pager.remaining pager.cursor pager.rows 
pager.lines pager.first pager.record see.render 
dis.print dis.operands dis.symbol dis.operand 
dis.number dis.hex dis.register dis.trim 
dis.decode dis.prefixes dis.primary dis.binary 
dis.register.group dis.immediate.group dis.extended dis.scalar 
dis.alu dis.modrm dis.sib dis.s32 
dis.signed dis.unsigned dis.byte dis.name! 
dis.print.cursor dis.address.only dis.opcode dis.shift 
dis.value dis.immediate dis.displacement dis.rip 
dis.scale dis.index dis.rm dis.group 
dis.mode dis.rm.width dis.reg.width dis.reg 
dis.condition dis.form dis.name.length dis.name 
dis.rep dis.rex dis.bad dis.start 
dis.limit dis.cursor dis.image dump 
dump.rows dump.byte where where.navigate 
where.arrow where.back where.follow where.history.push 
where.render where.context where.select where.scan 
where.match where.remaining where.cursor where.offset 
where.context.rows where.rows where.first where.selected 
where.rendering where.interactive inspect.occurrence inspect.containing 
inspect.following.start inspect.following inspect.owner.start inspect.owner 
inspect.hit locate inspect.source inspect.token.end 
inspect.line.next inspect.line.print inspect.reference inspect.reset 
inspect.advance inspect.matches inspect.token inspect.length 
inspect.name inspect.line.start inspect.line inspect.cursor 
inspect.next inspect.selected inspect.location words.list 
inspect.named bye debug.off debug.on 
dump.index dump.width dump.remaining dump.address 
inspect.column inspect.limit inspect.entry ' 
input.read input.edit input.escape history.next 
history.previous history.recall input.redraw input.replace 
history.draft.save history.draft.free history.append history.open 
history.home history.grow history.sync history.write 
history.fail input.terminal history.draft.capacity history.draft.length 
history.draft history.environment history.cursor history.capacity 
history.length history.address history.ready history.fd 
input.read.stream input.grow input.eof input.status 
input.execute token.execute editor.compile editor.publish 
editor.begin editor.source editor.return editor.name 
editor.fail editor.cancel editor.bind editor.find 
editor.current input.resume editor.record editor.source.start 
editor.ready editor.source.length editor.bias editor.stage 
input.error arguments.copy arguments.next arguments.reset 
string.length arguments.remaining arguments.cursor input.position 
input.capacity input.length input.address debug.dump 
debug.navigate debug.arrow debug.select debug.key 
debug.terminal.close debug.terminal.open debug.render debug.table.row 
debug.register.row debug.where debug.ip debug.source 
source.window source.window.comments source.line.comment? source.line.blank? 
source.line.trim source.line.end source.line.begin source.image.end 
source.window.cursor source.window.definition source.window.end source.window.start 
debug.word debug.lookup debug.nearest debug.image? 
debug.spaces debug.hex.offset debug.hex debug.hex.digits 
debug.interactive debug.hex.count debug.hex.value debug.row 
debug.first debug.selected debug.frames debug.frame.count 
debug.data.count debug.limit debug.owner debug.offset 
debug.best.xt debug.best debug.entry debug.dispatch 
debug.run debug.call tui.off tui.on 
tui.reset where.history.free where.history tui.panel.end 
tui.panel tui.frame tui.frame.begin tui.frame.end 
tui.write tui.printable tui.row.end tui.row.begin 
tui.top tui.title.text tui.bottom tui.rule 
tui.horizontal tui.glyph tui.measure tui.repeat 
tui.selected tui.title tui.accent clear 
tui.normal tui.ansi tui.byte tui.raw 
pager.append pager.grow pager.release pager.length 
pager.capacity pager.address tui.remaining tui.text 
tui.character tui.size tui.row.active tui.clipped 
tui.clip tui.column tui.width tui.active 
tui.terminal tui.disabled debug.enter debug.install 
fault.address fault.ip fault.image fault.number 
fault.register fault.context quit stacks.reset 
rdepth depth debug.remaining debug.cursor 
debug.status debug.context debug.image DEBUG 
stacks.protect test.layout page.aligned? test.image.reserve 
test.recovery test.signal.fatal test.execute.protected test.read.protected 
test.write.protected test.signal test.signal.foreign test.signal.stack 
test.fault.rollback test.fault.foreign test.fault.interrupt test.bus.release 
test.bus.prepare test.fault.bus test.fault.divide test.fault.execute 
test.fault.read test.fault.write test.fault.return test.fault.data 
test.fault.native test.fault.illegal test.fault.image test.bus.mapping 
test.bus.fd test.fault.address test.immediate.source test.changed.source 
test.differences image.difference.reject byte.change test.native 
test.while test.until test.shared.entry test.shared.condition 
test.suffix test.prefix test.return test.literal 
litnow factorial square fault. 
signals.install signal.install recovery.run recovery.restore 
recovery.save signal.org signal.rip signal.address 
signal.code signal.number trap recovery.enter 
recovery.resume signal.handle signal.restore verify 
verify? rebuild image.equal? image.seal 
image.protect image.free image.new image.build 
image.finish header! source.compile token.compile 
word.assemble word.interpret word.compile immediate 
variable constant unit.end code.end 
code : ( \ 
." s" repeat while 
until again begin then 
else if ; entry.finish 
string.compile compiler.repeat compiler.while compiler.until 
compiler.again compiler.begin compiler.else compiler.then 
compiler.if control.pop control.push execute 
compiler.xt compiler.find image.find target.xt 
token.find target.find dictionary.find entry.open 
entry.release entry.field number? digit 
source.comment.skip source.line.skip token.parse source.space.skip 
source.next source.byte source.end? assembler.check 
asm.ret asm.until asm.if asm.patch 
asm.jump.hole asm.jump asm.call asm.variable 
asm.address asm.literal asm.push.rax float.compare, 
float.binary, cvttsd2si.load, cvtsi2sd.load, cvtsd2ss.load, 
u64, u32, u16, c, 
resolve, jump.hole, jcc.hole, stosb, 
movsb, cld, setcc, shr.cl, 
shl.cl, shift.cl, or.rr, and.rr, 
u32! shift.right#, shift.left#, and#, 
imul.rr, store32, load.s32, invoke, 
branch, goto, label@ label! 
multiply, divide, negate, unary, 
store8, load8, xor.rr, sub.rr, 
add.rr, cmp.rr, cmp#, sub#, 
add#, imm32.op, jump.reg, execute, 
indirect, group, pop, push, 
ret, int3, ud2, syscall, 
jcc, jump, call, relative, 
rip.lea, lea, cvtss2sd.load, movsd.store, 
movsd.load, sse.memory, store, load, 
memory.op, mem, mov64, mov.rr, 
alu.rr, modrm, rex32, rex, 
rex.bits s32? reg? bytes, 
out.pad le64, le32, le16, 
byte, out.init out.reset out.size 
code.here out.capacity out.base >asm 
assembler.test.buffer asm.ctx r15 r14 
r13 r12 r11 r10 
r9 r8 rdi rsi 
rbp rsp rbx rdx 
rcx rax cc.less.equal cc.less 
cc.not.sign cc.equal cc.below assembler.output 
target.address bytes.equal? >float ffi.service 
ffi.frame dlerror dlclose dlsym 
dlopen c.string.length c.string.free c.string 
require fail . u. 
space cr emit type 
output.image output.vector stdout.write output.capture.image 
output.capture process.exit c.int loader.function 
c.call5 c.call4 c.call3 c.call2 
c.call1 c.call0 erase min 
abs page.align mod / 
cell+ cells 2r> 2>r 
within +! -rot rot 
tuck nip 2drop 2dup 
u> >= <= > 
<> 0<> 0= negate 
1- 1+ compare.length compare.right 
compare.left string.start find.base find.entry 
find.length find.address number.position number.sign 
number.base number.value control.depth compiler.variables 
compiler.action token.start token.length token.address 
parser.position parser.length parser.source label.start 
entry.current dictionary.root dictionary.here compiler.name 
compiler.failure compiler.return editor.image build.base 
where.saved.image where.saved.first where.saved.selected where.saved.length 
where.saved.name where.saved.previous instruction.bytes.max operand.rm.cl 
operand.byte operand.reg operand.target operand.reg.immediate 
operand.rm operand.rm.immediate operand.reg.rm operand.rm.reg 
operand.none syscall.interrupted history.permissions history.open.flags 
syscall.fsync syscall.open syscall.sigaltstack syscall.sigreturn 
syscall.sigaction syscall.memfd syscall.kill syscall.wait 
syscall.fork syscall.getpid process.signal.exit flags.recovery.mask 
signal.flag.onstack signal.flag.restorer signal.flag.info signal.reason.kernel 
signal.reason.access signal.memory signal.arithmetic signal.bus 
signal.trap signal.illegal signal.interrupt ucontext.flags 
ucontext.rip ucontext.rsp ucontext.rbx ucontext.rbp 
ucontext.r13 ucontext.r12 siginfo.address siginfo.code 
signal.mask.size alt.size alt.flags alt.base 
action.mask action.restorer action.flags action.handler 
registers.rip registers.r12 registers.rbp registers.rsp 
registers.flags registers.rcx registers.rax registers.rdx 
registers.rbx registers.rsi registers.rdi registers.r15 
registers.r14 registers.r13 registers.r11 registers.r10 
registers.r9 registers.r8 terminal.echo.newline terminal.echo 
terminal.canonical syscall.ioctl terminal.window terminal.set 
terminal.get terminal.time terminal.minimum terminal.flags 
/terminal debug.terminal.active debug.terminal.work debug.terminal.saved 
rtld.default rtld.global rtld.local rtld.lazy 
rtld.now loader.exit loader.dlerror loader.dlclose 
loader.dlsym loader.dlopen loader.start loader.table.field 
ffi.kind.signed ffi.kind.promoted ffi.kind.struct ffi.kind.double 
ffi.kind.float ffi.kind.integer ffi.kind.void ffi.class.memory 
ffi.class.sse ffi.class.integer ffi.class.none ffi.frame.result.sse 
ffi.frame.result.integer ffi.frame.stack.bytes ffi.frame.sse.count ffi.frame.sse 
ffi.frame.integer ffi.frame.function ffi.type.class1 ffi.type.class0 
ffi.type.kind ffi.type.bytes ffi.type.size ffi.arguments.max 
ffi.frame.size ffi.stack.capacity ffi.stack.offset ffi.types.offset 
ffi.frame.offset input.error.field ucontext.registers fault.registers.size 
fault.registers.offset quit.request.field debug.xt.field debug.image.field 
debug.entry.field debug.caller.rsp.field debug.parent.field arguments.vector.field 
arguments.count.field signal.alt.offset signal.action.offset recovery.target.field 
signal.stack.field signal.org.field signal.rip.field signal.address.field 
signal.code.field signal.number.field recovery.continuation.field recovery.org.field 
recovery.r12.field recovery.rbp.field recovery.rsp.field recovery.active.field 
fault.float.sp.field recovery.float.field float.sp.field fault.float.offset 
float.snapshot.offset float.guard.offset float.stack.offset float.guard.low 
context.used.limit fault.native.offset fault.return.offset fault.data.offset 
recovery.snapshot.offset signal.guard.offset signal.stack.offset native.guard.offset 
native.stack.top native.stack.offset context.assembler words.query.capacity 
context.words.query context.scratch context.control context.variables 
flag.immediate entry.flags entry.name.offset entry.value 
entry.kind entry.source.start entry.name.length entry.xt 
entry.previous /entry source.start dictionary.start 
code.start image.capacity image.version image.magic 
header.magic protection.read.execute protection.read.write protection.read 
protection.none stack.size return.guard.offset return.stack.offset 
data.guard.offset data.stack.offset context.guard.offset context.mapping.size 
header.rebuild.xt header.start.xt header.context.limit header.main.xt 
header.source.length header.source.offset header.dictionary.root header.dictionary.limit 
header.code.limit header.image.size header.version page.size 
image.call ffi.demote f< f= 
f/ f* f- f+ 
f>s s>f f>bits bits>f 
ffi.promote ffi.native c.call6 syscall6 
context org fill move 
r@ r> >r c! 
c@ ! @ u/mod 
rshift lshift u< < 
= xor or and 
* - + over 
swap drop dup kernel.start 
](words.png)

