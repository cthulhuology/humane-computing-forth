# Retained native compiler

`forth` is the executable seed used by the default Makefile. Keep it with the
source and other artifacts. `make clean` does not remove it.

This seed was produced by the preceding native runtime, then promoted from the
verified native file build. SwiftForth was used only for independent comparison.

Run `make seed` to replace it with the verified current executable. Use
`make SEED=/absolute/path/to/forth` to select another compatible native seed.
A missing seed is an error; the build never silently invokes SwiftForth.
