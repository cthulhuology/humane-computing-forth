SF ?= sf
SEED ?= selfhost/seed/forth
.PHONY: all verify test test-tty check-docs clean seed validate-sf
all: forth

forth: selfhost/build/forth
	@staged=$$(mktemp ./forth.XXXXXX); trap 'rm -f "$$staged"' EXIT; \
	cp -p $< "$$staged" && mv -f "$$staged" $@

# The retained native seed is an executable artifact; clean never removes it.
# Compile and validate in a fresh directory before publishing any build output.
selfhost/build/forth: forth.f $(SEED) | check-docs
	@set -e; stage=$$(mktemp -d selfhost/.build.XXXXXX); \
	trap 'rm -rf "$$stage"' EXIT; \
	"$(abspath $(SEED))" build.file forth.f "$$stage" </dev/null; \
	mkdir -p selfhost/build; \
	for artifact in image.bin code.bin dictionary.bin source.bin forth; do \
		mv -f "$$stage/$$artifact" "selfhost/build/$$artifact"; \
	done

$(SEED):
	@echo 'A native seed executable is required; supply SEED=/path/to/forth.' >&2
	@exit 1

# Promote the verified current runtime to the retained seed explicitly.
seed: forth
	./forth verify drop
	@mkdir -p "$$(dirname "$(SEED)")"; staged=$$(mktemp "$(SEED).XXXXXX"); \
	trap 'rm -f "$$staged"' EXIT; cp -p forth "$$staged" && mv -f "$$staged" "$(SEED)"

# SwiftForth is an independent comparison oracle, never the normal build path.
validate-sf: forth
	SF="$(SF)" sh selfhost/check-swiftforth.sh ./forth
	VALIDATE_SF=1 SF="$(SF)" sh selfhost/check-snapshot.sh ./forth
	VALIDATE_SF=1 SF="$(SF)" sh selfhost/check-source-load.sh ./forth

check-docs:
	awk -f selfhost/check-docs.awk forth.f shim.f selfhost/check.f

verify: forth
	./forth selftest

test: forth
	./forth selftest
	sh selfhost/check-native-build.sh ./forth
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
	sh selfhost/check-snapshot.sh ./forth
	sh selfhost/check-source-load.sh ./forth
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
	ruby selfhost/check-checkpoints-tty.rb ./forth

clean:
	rm -f forth selfhost/build/forth selfhost/build/image.bin selfhost/build/code.bin selfhost/build/dictionary.bin selfhost/build/source.bin
