cgvg
====
Grep that numbers its results.
`cg` command searches, `vg` goes-to.

Caveats
-------
Does not handle individual files, only directories.
Tries to search relevant code only, so `grep -r` might be needed
for rare-and-exotic filetypes, such as `m4`.

Requirements
------------
ag[https://github.com/ggreer/the\_silver\_searcher.git]

Installation
------------
- System-wide:
  * `make install`
- Per-user:
  * Add `~/bin` to PATH (in `~/.bashrc`-like file)
  * `make user-install` (or manually symlink `cg.sh`/`vg.sh` to `~/bin/cg`/`vg`)

License
-------
MIT license.
