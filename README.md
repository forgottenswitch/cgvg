cgvg
====
Grep that numbers its results.
`cg` command searches, `vg` goes-to.

```
  $ cg while
      1  cg.sh:23:  while read -r REPLY ; do
      2  vg.sh:21:while test ! -z "$n1" ; do
      3  vg.sh:29:  while read -r REPLY ; do
  $ vg 2
    # launches EDITOR vg.sh +21
```

Allows for options to be grouped into "profiles",
which could be toggled at once (i.e. `cg - all` toggles `--hidden --all-text`).

Similar scripts:
[Original cgvg](http://uzix.org/cgvg.html)
[Sack](https://github.com/sampson-chen/sack)

Caveats
-------
Searches relevant code only; to search all files, try `cg - all`.
You may also find `cg --dry-run` output useful.

Requirements
------------
- awk
- [ag](https://github.com/ggreer/the_silver_searcher.git)

Installation
------------
- System-wide:
  * `make install`
  * Set up default EDITOR (in `/etc/profile`, etc.)
- Per-user:
  * Add `~/bin` to PATH (in `~/.bashrc`-like file)
  * Set up default EDITOR (the same file)
  * `make user-install` (or manually symlink `cg.sh`/`vg.sh` to `~/bin/cg`/`vg`)

License
-------
MIT license.
