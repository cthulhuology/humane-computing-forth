\ Linux page size in bytes used to align mappings and protection boundaries.
4096 constant page.size

\ Signature identifying the canonical native Forth image format.
$31464c4553465446 constant image.magic

\ Version of the canonical image and dictionary layout.
3 constant image.version

\ Header byte offset storing the image signature.
0 constant header.magic

\ Header byte offset storing the image-format version.
8 constant header.version

\ Header byte offset storing the page-rounded used image size.
16 constant header.image.size

\ Header byte offset storing the exclusive occupied-code boundary.
24 constant header.code.limit

\ Header byte offset storing the exclusive used dictionary boundary.
32 constant header.dictionary.limit

\ Header byte offset storing the newest dictionary entry offset.
40 constant header.dictionary.root

\ Header byte offset storing the mapped source start offset.
48 constant header.source.offset

\ Header byte offset storing the exact retained source byte count.
56 constant header.source.length

\ Header byte offset storing the image-relative main entry point.
64 constant header.main.xt

\ Header byte offset storing the exclusive private-variable allocation boundary.
72 constant header.context.limit

\ Header byte offset storing the image-relative process startup entry point.
80 constant header.start.xt

\ Header byte offset storing the image-relative native recompiler entry point.
96 constant header.rebuild.xt

\ Image-relative offset of the first executable code byte.
4096 constant code.start

\ Image-relative offset of the first dictionary record.
262144 constant dictionary.start

\ Image-relative offset of the retained source text.
393216 constant source.start

\ Dictionary field offsets are bytes, independent of host cell numbering.

\ Dictionary field byte offset storing the preceding dictionary record offset.
0 constant entry.previous

\ Dictionary field byte offset storing the image-relative executable entry point.
8 constant entry.xt

\ Dictionary field byte offset storing the source-backed name length.
16 constant entry.name.length

\ Dictionary field byte offset storing the defining source token offset.
24 constant entry.source.start

\ Dictionary field byte offset storing the definition kind.
32 constant entry.kind

\ Dictionary field byte offset storing the constant value or variable context offset.
40 constant entry.value

\ Dictionary field byte offset storing the image-relative name text offset.
48 constant entry.name.offset

\ Dictionary field byte offset storing the immediate/compiler flags.
56 constant entry.flags

\ Dictionary flag selecting execution during source compilation.
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
