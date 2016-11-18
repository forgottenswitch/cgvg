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
- Install [ripgrep](https://github.com/BurntSushi/ripgrep):
  * Install [Rust](https://rust-lang.org)
  * Install [cargo](https://crates.io)
  * `cargo install --git https://github.com/BurntSushi/ripgrep.git`
- Add `~/.cargo/bin` and `~/bin` to $PATH in `.bashrc`
```
PATH="$PATH":"$HOME"/bin
PATH="$PATH":"$HOME"/.cargo/bin
```
- Symlink `cg.sh` and `vg.sh` into `~/bin`:
  * Install `make`
  * `make user-install`
- Adjust PAGER and EDITOR in `.bashrc`:
```
PAGER=less
EDITOR=vim
```
