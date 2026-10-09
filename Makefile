SF ?= sf
.PHONY: all verify test test-tty check-docs clean
all: forth

forth: selfhost/build/forth
	@staged=$$(mktemp ./forth.XXXXXX); trap 'rm -f "$$staged"' EXIT; \
	cp -p $< "$$staged" && mv -f "$$staged" $@

# forth.f is canonical hand-maintained Forth source, never a generated file.
selfhost/build/forth: forth.f shim.f | check-docs
	mkdir -p selfhost/build
	$(SF) shim.f
	chmod +x $@

check-docs:
	awk -f selfhost/check-docs.awk forth.f shim.f selfhost/check.f

verify: forth
	./forth selftest

test: forth
	./forth selftest
	$(SF) selfhost/check.f
	@work=$$(mktemp -d); trap 'rm -rf "$$work"' EXIT; \
	export HOME="$$work"; \
	sh selfhost/check-cli.sh ./forth && \
	sh selfhost/check-debug.sh ./forth && \
	sh selfhost/check-editor.sh ./forth
	sh selfhost/check-history.sh ./forth
	sh selfhost/check-inspection.sh ./forth
	sh selfhost/check-tui.sh ./forth
	sh selfhost/check-ffi.sh ./forth
	sh selfhost/check-fp.sh ./forth
	SF="$(SF)" sh selfhost/check-snapshot.sh ./forth
	@work=$$(mktemp -d); trap 'rm -rf "$$work"' EXIT; \
	cp selfhost/build/forth "$$work/forth"; \
	cd "$$work"; env -i PATH=/nonexistent ./forth selftest && \
	[ "$$(env -i PATH=/nonexistent ./forth 6 7 '*' .)" = '42 ' ]

# Optional terminal interaction tests use Ruby standard-library PTY support.
test-tty: forth
	ruby selfhost/check-history-tty.rb ./forth
	ruby selfhost/check-tui-tty.rb ./forth
	ruby selfhost/check-where-tty.rb ./forth
	ruby selfhost/check-pager-tty.rb ./forth
	ruby selfhost/check-words-tty.rb ./forth

clean:
	rm -f forth selfhost/build/forth selfhost/build/image.bin selfhost/build/code.bin selfhost/build/dictionary.bin selfhost/build/source.bin
