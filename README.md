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


