cgvg
====
Grep that numbers its results.
`cg` command searches, `vg` goes-to.

Caveats
-------
Does not handle individual files, only directories.

Requirements
------------
ag[https://github.com/ggreer/the\_silver\_searcher.git]

Installation
------------
- System-wide:
  * `make install`
- Per-user:
  * Add `~/bin` to PATH (in `~/.bashrc`-like file)
  * Do `make user-install`, or manually symlink `cg.sh`/`vg.sh` to `~/bin/cg`/`vg`

License
-------
MIT license.
