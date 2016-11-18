cgvg
====

A [sack](https://github.com/sampson-chen/sack). Tries rg, ag, and then grep.

`cg ...` searches.
Just `cg` prints the last search result.
`vg N` goes to N-th occurence.

Options could be put into a profile for later use as `cg -pPROF`.
`cg -h` lists options to edit profiles.

MIT license.

Installation
------------
- Symlink `cg.sh` and `vg.sh` into `~/bin`:
  * Install `make`
  * `make user-install`
- Adjust PATH, PAGER and EDITOR in `.bashrc`:
```
PATH="$PATH":"$HOME"/bin
PAGER=less
EDITOR=vim
```
