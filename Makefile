PREFIX = /usr

DEST_BIN = $(DESTDIR)/$(PREFIX)/bin
DEST_SHARE = $(DESTDIR)/$(PREFIX)/share
DEST_MAN = $(DEST_SHARE)/man

DEFAULT_CONFIG = $(DEST_SHARE)/cgvg/default_config

.PHONY: install
install:
	install -v -d "$(DEST_BIN)"
	install -T cg.sh "$(DEST_BIN)/cg"
	install -T vg.sh "$(DEST_BIN)/vg"
	install -v -d "$(DEST_SHARE)/cgvg"
	install -T default_config "$(DEFAULT_CONFIG)"
	sed -i -e 's|"$$__default_config__"|"$(DEFAULT_CONFIG)"|' "$(DEST_BIN)/cg"
	#
	install -v -d "$(DEST_MAN)/man1"
	install -T cgvg.1 "$(DEST_MAN)/man1/cgvg.1"
	ln -s cgvg.1 "$(DEST_MAN)/man1/cg.1"
	ln -s cgvg.1 "$(DEST_MAN)/man1/vg.1"

.PHONY: uninstall
uninstall:
	rm "$(DEST_BIN)/cg"
	rm "$(DEST_BIN)/vg"
	rm "$(DEFAULT_CONFIG)"
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
