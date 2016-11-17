cgvg
====

A [Ripgrep](https://github.com/BurntSushi/ripgrep)-only [sack](https://github.com/sampson-chen/sack).

Usage
-----
`cg ...` searches.
Just `cg` prints the last search result.
`vg N` goes to N-th occurence.

Options could be put into a profile for later use as `cg -pPROF`.
`cg -p` lists profiles, `cg -pp` prints them.
`cg -p+` adds options to profile, `-p-` removes them.
`-p-rm` removes entire profile.

Installation
------------
- Install [ripgrep](https://github.com/BurntSushi/ripgrep):
  * Install [Rust](https://rust-lang.org)
  * Install [cargo](https://crates.io)
  * `cargo install --git https://BurntSushi/ripgrep.git`
- Add `~/.cargo/bin` and `~/bin` to $PATH in `.bashrc`
```
PATH="$PATH":"$HOME"/bin
PATH="$PATH":"$HOME"/.cargo/bin
```
- Symlink `cg.sh` and `vg.sh` into `~/bin`:
```
$ cd ~/bin
$ ln -s ~/path/to/cgvg/cg.sh cg
$ ln -s ~/path/to/cgvg/vg.sh cg
```
- Adjust PAGER and EDITOR in `.bashrc`:
```
PAGER=less
EDITOR=vim
```

License
-------
MIT license.
