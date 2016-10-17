PREFIX = /usr

DEST_BIN = $(DESTDIR)/$(PREFIX)/bin

.PHONY: install
install:
	install -v -d "$(DEST_BIN)"
	install -T cg.sh "$(DEST_BIN)/cg"
	install -T vg.sh "$(DEST_BIN)/vg"

.PHONY: uninstall
uninstall:
	rm "$(DEST_BIN)/cg"
	rm "$(DEST_BIN)/vg"

.PHONY: user-install
user-install: PREFIX = $$HOME
user-install:
	ln -v -f -s "$$(pwd)/cg.sh" "$(DEST_BIN)/cg"
	ln -v -f -s "$$(pwd)/vg.sh" "$(DEST_BIN)/vg"

.PHONY: user-uninstall
user-uninstall: PREFIX = $$HOME
user-uninstall:
	$(MAKE) uninstall
