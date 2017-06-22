cgvg
====

A [sack](https://github.com/sampson-chen/sack).
`cg ...` searches, `vg N` goes to occurence.

Default grep tool name is read from `~/.config/cgvg/grepper`.
It could be temporarily overridden with `CG` environment variable.
Then, `rg`, `ag`, and `grep` would be tried.

Arguments could be stored in `~/.config/cgvg/{rg,ag,grep}/{Profile_name}`,
one per line (no quoting), and recalled as `cg -p{Profile_name}`,
or printed with `cg -pp`.

For example, to make rg ignore changelogs, put the following into `~/.config/cgvg/rg/NoLogs`:
```
-g
!*ChangeLog*
```
and run as `cg -pNoLogs`

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
