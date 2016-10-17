cgvg
====
Grep that numbers its results.
`cg` command searches, `vg` goes-to.

  $ cg while
      1  cg.sh:23:  while read -r REPLY ; do
      2  vg.sh:21:while test ! -z "$n1" ; do
      3  vg.sh:29:  while read -r REPLY ; do
  $ vg 2
    # launches EDITOR vg.sh +21

Caveats
-------
Does not handle individual files, only directories.
Tries to search relevant code only, so `grep -r` might be needed
for rare-and-exotic filetypes, such as `m4`.

Requirements
------------
[ag](https://github.com/ggreer/the_silver_searcher.git)

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
