SF ?= sf
.PHONY: all verify test check-docs clean
all: selfhost/build/forth

# forth.f is canonical hand-maintained Forth source, never a generated file.
selfhost/build/forth: forth.f shim.f | check-docs
	mkdir -p selfhost/build
	$(SF) shim.f
	chmod +x $@

check-docs:
	awk -f selfhost/check-docs.awk forth.f shim.f selfhost/check.f

verify: selfhost/build/forth
	./selfhost/build/forth

test: selfhost/build/forth
	./selfhost/build/forth
	$(SF) selfhost/check.f
	@work=$$(mktemp -d); trap 'rm -rf "$$work"' EXIT; \
	cp selfhost/build/forth "$$work/forth"; \
	cd "$$work"; env -i PATH=/nonexistent ./forth

clean:
	rm -f selfhost/build/forth selfhost/build/image.bin selfhost/build/code.bin selfhost/build/dictionary.bin selfhost/build/source.bin
