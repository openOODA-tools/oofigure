# ==============================================================================
# oofigure: Sovereign Unicode Box Drawing, Tables, Callouts, and Code Panels
# Verification, Build, Test, and Packaging Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oofigure
SRC := $(shell find . -name "*.oo" -not -path "./dist/*")
VERSION ?= 0.2.0

OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oofigure-linux-x86_64
	@cd dist && sha256sum oofigure-linux-x86_64 > oofigure-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oofigure-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oofigure" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "oofigure" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "PASSED" && echo "PASS: internal anchors"
	@echo "=== testing default box rendering ==="
	@./$(BIN) "Hello openOODA" | grep -q "╭" && echo "PASS: default rounded box"
	@echo "=== testing double border style ==="
	@./$(BIN) -s double "Double Frame" | grep -q "╔" && echo "PASS: -s double"
	@echo "=== testing heavy border style ==="
	@./$(BIN) -s heavy "Heavy Frame" | grep -q "┏" && echo "PASS: -s heavy"
	@echo "=== testing ascii border style ==="
	@./$(BIN) -s ascii "ASCII Frame" | grep -q "+" && echo "PASS: -s ascii"
	@echo "=== testing title embedding ==="
	@./$(BIN) -t "Module A" "Content" | grep -q "Module A" && echo "PASS: -t title"
	@echo "=== testing GFM note callout ==="
	@./$(BIN) -c note "Information" | grep -q "NOTE" && echo "PASS: -c note"
	@echo "=== testing GFM warning callout ==="
	@./$(BIN) -c warning "Cautionary note" | grep -q "WARNING" && echo "PASS: -c warning"
	@echo "=== testing line numbers ==="
	@./$(BIN) --numbers "First line" | grep -q "1 │ First line" && echo "PASS: --numbers"
	@echo "=== testing JSON output -j ==="
	@./$(BIN) -j "Diagnostic content" | grep -q '"figure_type": "box"' && echo "PASS: JSON output"
	@echo "=== testing --demo -D ==="
	@./$(BIN) -D | grep -q "Showcase" && echo "PASS: --demo"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "figure_box" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call figure_box ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"figure_box","arguments":{"text":"Hello World","style":"rounded"}}}\n' | ./$(BIN) --mcp | grep -q "Hello World" && echo "PASS: MCP figure_box"
	@echo "=== testing MCP tools/call figure_callout ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"figure_callout","arguments":{"text":"Important alert","kind":"warning"}}}\n' | ./$(BIN) --mcp | grep -q "WARNING" && echo "PASS: MCP figure_callout"
	@echo "=== testing MCP tools/call figure_code ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"figure_code","arguments":{"code":"fn main() {}","title":"main.oo","language":"openOODA"}}}\n' | ./$(BIN) --mcp | grep -q "main.oo" && echo "PASS: MCP figure_code"
	@echo "=== testing MCP tools/call figure_table ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"figure_table","arguments":{"rows":"A,B\\\\n1,2"}}}\n' | ./$(BIN) --mcp | grep -q "┬" && echo "PASS: MCP figure_table"
	@echo "=== testing MCP tools/call figure_styles ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"figure_styles","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q "rounded" && echo "PASS: MCP figure_styles"
	@echo "=== testing MCP tools/call figure_demo ==="
	@printf '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"figure_demo","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q "Showcase" && echo "PASS: MCP figure_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oofigure
	@chmod 0755 dist/deb-root/usr/bin/oofigure
	@cp uninstall.sh dist/deb-root/usr/bin/oofigure-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oofigure-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oofigure_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oofigure_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oofigure-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oofigure.spec > ~/rpmbuild/SPECS/oofigure.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oofigure.spec
	@cp ~/rpmbuild/RPMS/x86_64/oofigure-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oofigure
	@chmod 0755 dist/arch-pkg/usr/bin/oofigure
	@cp uninstall.sh dist/arch-pkg/usr/bin/oofigure-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oofigure-uninstall
	@printf "pkgname = oofigure\npkgbase = oofigure\npkgver = $(VERSION)-1\npkgdesc = Sovereign Unicode box-drawing tables, callouts, and code borders in pure openOODA.\nurl = https://github.com/openOODA-tools/oofigure\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oofigure\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oofigure-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oofigure-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cd dist && sha256sum oofigure* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
