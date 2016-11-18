PREFIX = /usr

DEST_BIN = $(DESTDIR)/$(PREFIX)/bin
DEST_SHARE = $(DESTDIR)/$(PREFIX)/share
DEST_MAN = $(DEST_SHARE)/man

.PHONY: install
install:
	install -v -d "$(DEST_BIN)"
	install -T cg.sh "$(DEST_BIN)/cg"
	install -T vg.sh "$(DEST_BIN)/vg"

.PHONY: uninstall
uninstall:
	rm "$(DEST_BIN)/cg" 2>/dev/null || true
	rm "$(DEST_BIN)/vg" 2>/dev/null || true

.PHONY: user-install
user-install:
	Uname=$$(uname) ;\
	if test "$${Uname#MINGW}" != "$$Uname" -o "$${Uname#MSYS}" != "$$Uname" ; then \
		sed -i -e '/^\(unalias cg vg\|alias cg=\|alias vg=\)/ D' "$$HOME"/.bashrc ;\
		echo "unalias cg vg 2>/dev/null" >> "$$HOME"/.bashrc ;\
		echo "alias cg=\"sh '$$(pwd)/cg.sh'\"" >> "$$HOME"/.bashrc ;\
		echo "alias vg=\"sh '$$(pwd)/vg.sh'\"" >> "$$HOME"/.bashrc ;\
		echo ;\
		echo "Installed as aliases into ~/.bashrc" ;\
		echo "Run 'exec bash' or open a new terminal" ;\
	else \
		mkdir -p ~/bin ;\
		ln -v -f -s "$$(pwd)/cg.sh" ~/bin/cg" ;\
		ln -v -f -s "$$(pwd)/vg.sh" ~/bin/vg" ;\
		echo ;\
		echo "Installed as symlinks into ~/bin" ;\
	fi

.PHONY: user-uninstall
user-uninstall:
	Uname=$$(uname) ;\
	if test "$${Uname#MINGW}" != "$$Uname" -o "$${Uname#MSYS}" != "$$Uname" ; then \
		sed -i -e '/^\(unalias cg vg\|alias cg=\|alias vg=\)/ D' "$$HOME"/.bashrc ;\
	fi
	rm "$(HOME)"/bin/cg 2>/dev/null || true
	rm "$(HOME)"/bin/vg 2>/dev/null || true
