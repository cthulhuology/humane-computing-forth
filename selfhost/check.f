4096 constant page.size
$31464c4553465446 constant image.magic
2 constant image.version
0 constant header.magic
8 constant header.version
16 constant header.image.size
24 constant header.code.limit
32 constant header.dictionary.limit
40 constant header.dictionary.root
48 constant header.source.offset
56 constant header.source.length
64 constant header.main.xt
72 constant header.context.limit
80 constant header.start.xt
96 constant header.rebuild.xt
4096 constant code.start
131072 constant dictionary.start
262144 constant source.start
\ Dictionary field offsets are bytes, independent of host cell numbering.
0 constant entry.previous
8 constant entry.xt
16 constant entry.name.length
24 constant entry.source.start
32 constant entry.kind
40 constant entry.auxiliary
48 constant entry.name.offset
56 constant entry.flags
1 constant flag.immediate
\ Development-only file contract tests, also written in Forth.
\ Runtime self-compilation and A/B/C comparisons are implemented in forth.f.
variable image.file
variable image.length
variable source.original
variable source.length
variable split.file
variable split.length
variable word.record
variable code.next.start

\ Read a complete binary file into newly allocated host memory.
: file.read ( name length -- address length )
  r/o bin open-file throw >r r@ file-size throw
  0<> abort" oversized test file"
  dup allocate throw swap 2dup r@ read-file throw
  over <> abort" short test read" r> close-file throw ;

\ Fetch a cell at a canonical image offset in the loaded test image.
: image@ image.file @ + @ ;

\ Abort the file-contract checks when a condition is false.
: assert 0= abort" self-hosting image contract failed" ;

\ Compare a saved split artifact against the corresponding canonical image range.
: image.part.compare ( name length offset length -- )
  >r >r file.read split.length ! split.file !
  r> image.file @ + r> split.file @ split.length @ compare 0= assert
  split.file @ free throw ;

\ Verify mapped source, split artifacts, entry points, source references, and flags.
: check
  s" forth.f" file.read source.length ! source.original !
  s" selfhost/build/image.bin" file.read image.length ! image.file !
  header.magic image@ image.magic = assert
  header.version image@ image.version = assert header.image.size image@ image.length @ = assert
  header.source.offset image@ source.start = assert header.source.length image@ source.length @ = assert
  image.file @ source.start + source.length @ source.original @ source.length @ compare 0= assert
  s" selfhost/build/code.bin" 0 dictionary.start image.part.compare
  s" selfhost/build/dictionary.bin" dictionary.start source.start dictionary.start - image.part.compare
  s" selfhost/build/source.bin" source.start source.length @ image.part.compare
  \ Labels give starts, not exclusive ends of execution or source bodies.
  header.dictionary.root image@ word.record ! header.code.limit image@ code.next.start !
  begin word.record @ while
    word.record @ entry.xt + image@ dup code.start >= assert
    dup code.next.start @ <= assert code.next.start !
    word.record @ entry.source.start + image@ source.start >= assert
    word.record @ entry.source.start + image@ source.start source.length @ + < assert
    word.record @ entry.name.length + image@ 0 > assert
    word.record @ entry.name.offset + image@ dup source.start >= assert
    word.record @ entry.name.length + image@ + source.start source.length @ + <= assert
    word.record @ entry.flags + image@ flag.immediate invert and 0= assert
    word.record @ entry.previous + image@ word.record !
  repeat code.next.start @ code.start = assert
  source.original @ free throw image.file @ free throw
  ." Exact mapped source, split-image files, code entry points and source references passed." cr ;
check
bye
