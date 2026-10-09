# Architecture: Self-Compiling Native Forth

A self-hosting, self-compiling Forth for Linux x86-64 that generates complete ELF
executables without external tooling (no assembler, no linker, no libc at build time).

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Source Organization](#source-organization)
3. [Execution Model](#execution-model)
4. [Image File Format](#image-file-format)
5. [ELF Wrapper Format](#elf-wrapper-format)
6. [Dictionary Entry Format](#dictionary-entry-format)
7. [Context Layout](#context-layout)
8. [Snapshot Format](#snapshot-format)
9. [Build & Bootstrap Flow](#build--bootstrap-flow)
10. [Signal Handling & Recovery](#signal-handling--recovery)
11. [Foreign Function Interface](#foreign-function-interface)
12. [Self-Verification](#self-verification)

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        forth (ELF executable)                       │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  12 KB ELF wrapper  (pages 0-2)                              │   │
│  │  ┌─────────────┐  ┌────────────────┐  ┌──────────────────┐   │   │
│  │  │  ELF header │  │ startup        │  │ dynamic linker   │   │   │
│  │  │  + phdrs    │  │ trampoline     │  │ metadata         │   │   │
│  │  └─────────────┘  └────────────────┘  └──────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Canonical image  (page 3 onwards, ~640 KB)                  │   │
│  │  ┌──────────┐  ┌────────────┐  ┌────────────┐  ┌─────────┐   │   │
│  │  │  header  │  │    code    │  │ dictionary │  │ source  │   │   │
│  │  │  64 B    │  │  ~256 KB   │  │  ~128 KB   │  │ ~256 KB │   │   │
│  │  └──────────┘  └────────────┘  └────────────┘  └─────────┘   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

The canonical image is a **self-describing binary**: it contains its own header,
machine code, dictionary, and the verbatim source text used to compile it.
Running the image rebuilds an identical image from that embedded source,
verifying the compiler.

---

## Source Organization

```
forth/experiment/native/
├── forth.f                   canonical source (6867 lines)
├── forth                     final product ELF executable
├── Makefile                  build orchestration
├── FORTH-NATIVE.md           usage documentation
├── shim.f                    independent SwiftForth cross-validator
├── hello.f / test.f          examples and tests
│
├── selfhost/
│   ├── seed/forth            retained bootstrap seed binary
│   ├── build/                build artifacts (image.bin, forth, *.bin)
│   ├── check-native-build.sh triple self-compilation test
│   ├── check-snapshot.sh     snapshot save/restore test
│   ├── check-source-load.sh  file load and compile test
│   ├── check-swiftforth.sh   validate against SwiftForth shim
│   ├── fixture-ffi.c         FFI test shared library
│   └── reconstruct-snapshot.rb  independent snapshot oracle (Ruby)
│
└── native.snapshots/
    └── 00000000/
        ├── image.patch       snapshot binary (root, no parent)
        └── complete          presence marker
```

**forth.f** is divided into marked sections the compiler parses specially:

| Marker                                        | Lines | Purpose                                                  |
|-----------------------------------------------|-------|----------------------------------------------------------|
| `HOST-LAYOUT-BEGIN` … `HOST-LAYOUT-END`       | ~500  | Image header constants, context offsets, syscall numbers |
| `HOST-ASSEMBLER-BEGIN` … `HOST-ASSEMBLER-END` | ~90   | Register encodings, condition codes                      |
| Everything else                               | ~6200 | Runtime words, compiler, ELF generator, snapshot system  |

---

## Execution Model

### Register Allocation

Forth uses a **direct-threaded, register-cached** execution model. Five registers
are dedicated across all Forth word calls:

```
Register  Role
────────  ──────────────────────────────────────────────────────
RBX       Image origin — base address of the running image.
          All XTs and dictionary offsets are image-relative;
          absolute address = RBX + offset.

RBP       Data stack pointer (grows upward toward higher addresses).
          TOS is at [RBP], NOS at [RBP-8].

R12       Forth return stack pointer (grows upward).

R13       Context record pointer — base of the 1 MB private mapping
          that holds variables, stacks, guard pages, and checkpoints.

RSP       Native C stack (grows downward, follows System V ABI).
```

Volatile registers (RAX, RCX, RDX, RSI, RDI, R8–R11) are scratch.

### Call Convention

```
forth word call:
    CALL  [RBX + xt.offset]    ; push native return address onto RSP
    ; callee body executes
    RET                        ; pop native return address from RSP

data stack push:
    ADD  RBP, 8
    MOV  [RBP], value

data stack pop:
    MOV  value, [RBP]
    SUB  RBP, 8
```

---

## Image File Format

### image.bin — Full Canonical Image (~640 KB)

```
Byte offset   Size     Content
───────────   ──────   ──────────────────────────────────────────────
0             64 B     Image header (see below)
64            4032 B   Header padding (zeroed) → page boundary at 4096
4096          258048   Code section  (x86-64 machine code)
262144        131072   Dictionary section
393216        ~260000  Source section (verbatim forth.f text)
```

Page 0 (0–4095) holds the header; the code starts on page 1.

### Image Header (64 bytes, little-endian 64-bit cells)

```
Offset  Bytes  Field               Value / Meaning
──────  ─────  ──────────────────  ─────────────────────────────────────
0       8      magic               0x3146534c4655534  ("FTFSELF1" LE)
8       8      version             3
16      8      image.size          total image bytes, rounded to page
24      8      code.limit          exclusive end of code section
32      8      dictionary.limit    exclusive end of dictionary section
40      8      dictionary.root     offset of newest dictionary entry
48      8      source.offset       byte offset of source section (393216)
56      8      source.length       exact length of retained source
64      8      main.xt             image-relative entry point offset
72      8      context.limit       upper bound of mutable variable area
80      8      start.xt            startup entry point (called by ELF trampoline)
96      8      rebuild.xt          self-compilation entry point
```

```
  ┌────────────────────────────────────────────────────────────┐
  │ 0x3146534c4655534 │ version=3 │ image.size │ code.limit    │  0..31
  ├────────────────────────────────────────────────────────────┤
  │ dict.limit │ dict.root │ source.offset │ source.length     │  32..63
  └────────────────────────────────────────────────────────────┘
```

### code.bin / dictionary.bin / source.bin

These are direct byte-range extracts of image.bin for independent validation:

```
code.bin       = image.bin[4096 : 262144]
dictionary.bin = image.bin[262144 : 393216]
source.bin     = image.bin[393216 : 393216 + source.length]
```

---

## ELF Wrapper Format

The 12 KB ELF wrapper (3 pages) precedes the canonical image at file offset 0.
It is generated entirely in Forth — no external linker or assembler.

### Page Map

```
File offset   Page  Content
───────────   ────  ────────────────────────────────────────────────────
0             0     ELF header (64 B) + 11 program headers (616 B)
4096          1     Startup trampoline code + dynamic section
8192          2     Symbol table, string table, relocations, hash table
12288         3+    Canonical image (code + dictionary + source)
```

### ELF Header

Standard ELF64 header at offset 0:
- Class: ELF64, Data: LSB, OS/ABI: Linux
- Type: `ET_EXEC` (executable)
- Machine: `EM_X86_64`
- Entry: virtual address of startup trampoline
- `e_phoff` = 64, `e_phnum` = 11

### Program Headers (11 entries × 56 bytes = 616 bytes)

```
Index  Type            Flags  Description
─────  ──────────────  ─────  ─────────────────────────────────────────
0      PT_PHDR         R      Program header table itself
1      PT_INTERP       R      "/lib64/ld-linux-x86-64.so.2"
2      PT_LOAD         R+X    Page 0: trampoline code + dynamic metadata
3      PT_LOAD         R+W    Import table slots (RELRO after relocation)
4      PT_LOAD         R      Sym/string/reloc tables
5      PT_DYNAMIC      R+W    Dynamic linking records
6      PT_NOTE         R      ELF notes
7      PT_GNU_EH_FRAME R      Exception handling
8      PT_GNU_STACK    R+W    Stack attributes (no exec stack)
9      PT_GNU_RELRO    R      Read-only after relocation
10     PT_LOAD         R+X    Canonical image (code+dictionary+source)
```

### Dynamic Section (14 records × 16 bytes)

Located at file offset 8320. Each record is `(tag: u64, value: u64)`.

### Dynamic Imports (6 symbols resolved at load time)

```
Symbol              Purpose
──────────────────  ──────────────────────────────────────────────────
__libc_start_main   C startup hook (called by ELF trampoline)
dlopen              Load shared library (FFI)
dlsym               Resolve symbol (FFI)
dlclose             Unload library (FFI)
dlerror             Get error string (FFI)
exit                Process termination
```

### Startup Sequence

```
1. Linux dynamic linker maps ELF, resolves relocations
2. Entry point (_start) reached — trampoline in page 1
3. Trampoline calls __libc_start_main with forth_main
4. forth_main: mmap 1 MB private context region → R13
5. forth_main: locate canonical image (by file path or embedded)
6. forth_main: mmap canonical image read-only → RBX
7. Execute start.xt (image-relative) to enter Forth
```

---

## Dictionary Entry Format

Each entry is 64 bytes, stored in the dictionary section. The dictionary is a
**singly-linked list** from newest to oldest; the root pointer is in the header.

```
Offset  Bytes  Field          Meaning
──────  ─────  ─────────────  ──────────────────────────────────────────
0       8      previous       image-relative offset of preceding entry
                              (0xffffffffffffffff = end of list)
8       8      xt             image-relative code address
16      8      name.length    character count of the word name
24      8      source.start   byte offset into source section (defining token)
32      8      kind           entry type (1=code, 2=colon, 3=constant, …)
40      8      value          constant value or variable offset
48      8      name.offset    image-relative address of name text
56      8      flags          bit 0 = IMMEDIATE
```

### Dictionary Chain Traversal

```
header.dictionary.root
        │
        ▼
┌──────────────────┐      ┌──────────────────┐
│ entry N          │      │ entry N-1         │
│ previous ────────┼─────▶│ previous ─────────┼──▶ … ──▶ 0xffff…
│ xt               │      │ xt                │
│ name.length      │      │ name.length       │
│ source.start     │      │ source.start      │
│ kind             │      │ kind              │
│ value            │      │ value             │
│ name.offset      │      │ name.offset       │
│ flags            │      │ flags             │
└──────────────────┘      └──────────────────┘
```

Word name text is stored in the code section (not in the entry itself);
`name.offset` points there.

---

## Context Layout

Each Forth instance gets a **1 MB private anonymous mapping** (mmap, no file).
R13 holds the base. The layout has guard pages between every region.

```
R13 + offset    Size     Purpose
──────────────  ───────  ─────────────────────────────────────────────────
0               65536    Variables & compiler state (fields below)
65536           4096     GUARD PAGE (inaccessible)
69632           65536    Data stack (grows upward; RBP starts here)
135168          4096     GUARD PAGE
139264          65536    Forth return stack (grows upward; R12 starts here)
204800          4096     GUARD PAGE
208896          65536    Native return stack (grows downward; RSP region)
274432          4096     GUARD PAGE
278528          65536    Alternate signal stack (sigaltstack)
344064          4096     GUARD PAGE
348160          196608   Recovery checkpoint snapshot
544768          65536    Captured fault data stack
610304          65536    Captured fault return stack
675840          65536    Captured fault native stack
741376          4096     GUARD PAGE
745472          65536    Floating-point stack (grows upward)
811008          4096     GUARD PAGE
815104          65536    FP checkpoint snapshot
880640          65536    Captured fault FP stack
```

### Variable Region (R13+0, first 1024 bytes shown)

```
R13 + offset  Field                  Purpose
────────────  ─────────────────────  ──────────────────────────────────────
0             recovery.active        1 if recovery boundary is armed
8             recovery.rsp           saved native stack pointer
16            recovery.rbp           saved data stack pointer
24            recovery.r12           saved Forth return stack pointer
32            recovery.org           saved image origin (RBX)
40            recovery.continuation  resume address after signal
48            signal.number          fault signal number
56            signal.code            signal reason code
64            signal.address         faulting memory address
72            signal.rip             faulting instruction pointer
80            signal.org             image origin at fault time
88            signal.stack           handler's stack pointer
96            recovery.target        protected action XT
```

---

## Snapshot Format

Snapshots are **parent-linked incremental patches** against the canonical image.
Each snapshot stores only the changed byte spans; reconstruction walks the parent
chain to a root (which stores the full image), then applies deltas forward.

### Snapshot File (image.patch)

```
Byte offset  Size   Field          Value / Meaning
───────────  ─────  ─────────────  ────────────────────────────────────────
0            8      magic          0x2050414e53485446  ("TFSNAP P" LE)
8            8      parent.id      revision number of parent, or -1 (root)
16           8      parent.bytes   reconstructed extent of parent image (0 if root)
24           8      image.bytes    canonical image extent after applying spans
32           8      span.count     number of replacement spans that follow

40           [span.count × (16 + span.length)]  spans (see below)
```

### Replacement Span

```
Offset within span  Size  Field
──────────────────  ────  ─────────────────────────────────────────────
0                   8     image byte offset of this span (little-endian)
8                   8     length of replacement data (little-endian)
16                  N     replacement bytes (no padding or alignment)
```

Spans are non-overlapping and stored in ascending offset order.

### Storage on Disk

```
project/.snapshots/
├── 00000000/            revision 0 (root — stores full image)
│   ├── image.patch      spans cover entire image; parent.id = -1
│   └── complete         8-byte presence marker (magic)
├── 00000001/            revision 1 (delta from 00000000)
│   ├── image.patch      only changed spans since rev 0
│   ├── complete
│   └── comment          optional free-text description
└── 00000002/
    ├── image.patch      delta from 00000001
    └── complete
```

### Reconstruction Algorithm

```
1. Load target revision's header → get parent.id
2. Recursively load parent chain until root (parent.id == -1)
3. Reverse the chain (root → target)
4. Start with a zeroed buffer of root.image.bytes
5. For each revision from root to target:
   a. Apply each span: buffer[span.offset : span.offset+span.length] = span.data
   b. Zero-extend buffer if this revision's image.bytes > previous
6. Validate header magic, version, and entry-point sanity
```

---

## Build & Bootstrap Flow

### Triple Self-Compilation (normal `make forth`)

```
selfhost/seed/forth          (retained seed; may be old or different address)
         │
         │  reads forth.f from disk
         ▼
   Bootstrap B1  ──────────────────────────────────────────────────────┐
   (image at address A)                                                │
         │  embed source into image                                    │
         │  generates ELF wrapper                                      │
         ▼                                                             │
   Artifact set:                                                       │
     image.bin / forth / code.bin / dictionary.bin / source.bin        │
                                                                       │
         │  B1 forks, child runs itself                                │
         ▼                                                             │
   B1-child calls rebuild.xt                                           │
   (image mapped at new address B ≠ A → different context offsets)     │
         │                                                             │
         ▼                                                             │
   Candidate B2  (all addresses relative to B)                         │
                                                                       │
         │  B2 rebuilds itself                                         │
         ▼                                                             │
   Candidate B3  (at address C ≠ B)                                    │
                                                                       │
         │  image comparison:                                          │
         │    B2 == B3 ?  (byte-for-byte identical)   ──── YES ────────┘
         │                                                    promotes
         │                                              selfhost/build/forth
         │                                              as final product
         ▼ NO
         FAIL — compiler is not reproducible
```

The comparison is A-independent: B2 and B3 are both self-compiled at their own
addresses and must produce the same image bytes.

### File Build (`build.file forth.f /tmp/out`)

```
source file → parse → bootstrap binary → fork → rebuild → verify → artifacts
```

---

## Signal Handling & Recovery

Forth implements a **software recovery boundary** around any action that might fault.

```
recovery.enter   ( xt -- )
    saves: RSP, RBP, R12, RBX into R13 variable region
    arms:  recovery.active = 1
    calls: xt

  ┌─ if xt faults ──────────────────────────────────────────────────────┐
  │  signal handler fires on alt-stack (R13 + 278528)                  │
  │  records: signal.number, signal.code, signal.address, signal.rip   │
  │  snapshots data/return/native stacks into fault capture regions     │
  │  restores: RSP, RBP, R12, RBX from saved values                    │
  │  jumps to: recovery.continuation                                    │
  └─────────────────────────────────────────────────────────────────────┘
    recovery.continuation resumes after recovery.enter
    recovery.active = 0
    caller can inspect signal.* fields to report or handle the fault
```

Handled signals: SIGSEGV, SIGBUS, SIGILL, SIGFPE, SIGTRAP, SIGINT.

---

## Foreign Function Interface

Forth can call into shared libraries loaded via `dlopen`/`dlsym`.

```
ffi.native  ( sym-addr -- )      call C function by address (no type coercion)
ffi.promote ( n -- f )           integer → double (for passing to C)
ffi.demote  ( f -- n )           double → integer (for receiving from C)
```

Arguments are passed on the Forth data stack in System V x86-64 order
(integer args in RDI, RSI, RDX, RCX, R8, R9; floats in XMM0–XMM7).
The FFI type descriptor system (defined in HOST-LAYOUT) encodes argument
counts and types so the call stub can shuffle registers correctly.

---

## Self-Verification

Every image carries its own source. The `rebuild` word:

1. Reads `source.offset` and `source.length` from its own header
2. Compiles that source text in fresh memory
3. Calls `image.equal?` to compare the new image byte-for-byte with itself

A successful `verify` call (no output) proves the compiler is a fixed point:
it produces the exact binary that, when compiled again, reproduces itself.

`shim.f` provides an independent cross-check: it runs under SwiftForth and
generates the same binary from forth.f's marked sections, allowing validation
that the image layout is correct without running the native compiler.
