PREFIX = /usr

DEST_BIN = $(DESTDIR)/$(PREFIX)/bin
DEST_MAN = $(DESTDIR)/$(PREFIX)/share/man

.PHONY: install
install:
	install -v -d "$(DEST_BIN)"
	install -T cg.sh "$(DEST_BIN)/cg"
	install -T vg.sh "$(DEST_BIN)/vg"
	#
	install -v -d "$(DEST_MAN)/man1"
	install -T cgvg.1 "$(DEST_MAN)/man1/cgvg.1"
	ln -s cgvg.1 "$(DEST_MAN)/man1/cg.1"
	ln -s cgvg.1 "$(DEST_MAN)/man1/vg.1"

.PHONY: uninstall
uninstall:
	rm "$(DEST_BIN)/cg"
	rm "$(DEST_BIN)/vg"
	rm "$(DEST_MAN)/man1/cgvg.1"
	rm "$(DEST_MAN)/man1/cg.1"
	rm "$(DEST_MAN)/man1/vg.1"

.PHONY: user-install
user-install: PREFIX = $$HOME
user-install:
	ln -v -f -s "$$(pwd)/cg.sh" "$(DEST_BIN)/cg"
	ln -v -f -s "$$(pwd)/vg.sh" "$(DEST_BIN)/vg"

.PHONY: user-uninstall
user-uninstall: PREFIX = $$HOME
user-uninstall:
	$(MAKE) uninstall
